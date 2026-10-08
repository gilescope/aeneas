(** This files contains passes we apply on the AST *before* calling the
    (concrete/symbolic) interpreter on it *)

open Types
open TypesUtils
open Expressions
open ExpressionsUtils
open LlbcAst
open Utils
open LlbcAstUtils
open Errors

let log = Logging.pre_passes_log

let statement_to_string (crate : crate) =
  let fmt_env = Print.crate_to_fmt_env crate in
  Print.statement_to_string fmt_env "" "  "

let call_to_string (crate : crate) =
  let fmt_env = Print.crate_to_fmt_env crate in
  Print.call_to_string fmt_env "  "

let fun_decl_ref_to_string (crate : crate) =
  let fmt_env = Print.crate_to_fmt_env crate in
  Print.fun_decl_ref_to_string fmt_env

let generic_args_to_string (crate : crate) (generics : generic_args) =
  let fmt_env = Print.crate_to_fmt_env crate in
  let generics, traits = Print.generic_args_to_strings fmt_env generics in
  "<" ^ String.concat ", " (generics @ traits) ^ ">"

let generic_params_to_string (crate : crate) (generics : generic_params) =
  let fmt_env = Print.crate_to_fmt_env crate in
  let generics, traits = Print.generic_params_to_strings fmt_env generics in
  "<" ^ String.concat ", " (generics @ traits) ^ ">"

(** Erase the useless body regions.

    We erase the body regions which appear in:
    - locals
    - places

    We only keep those used in function calls. *)
let erase_body_regions (crate : crate) (f : fun_decl) : fun_decl =
  let f0 = f in

  let erase_visitor =
    object
      inherit [_] map_statement

      method! visit_fn_operand _ x =
        (* Do not erase the use of body regions inside function operands *)
        x

      method! visit_RBody _ _ = RErased
      method! visit_RVar _ _ = RErased
      method! visit_RStatic _ = RErased
    end
  in

  (* Map  *)
  let body =
    match f.body with
    | StructuredBody body ->
        let body =
          {
            body with
            locals =
              {
                body.locals with
                locals =
                  List.map Contexts.local_erase_regions body.locals.locals;
              };
          }
        in
        StructuredBody
          { body with body = erase_visitor#visit_block 0 body.body }
    | other -> other
  in

  let f : fun_decl = { f with body } in
  [%ldebug
    let env = Print.crate_to_fmt_env crate in
    "Before/after [erase_body_regions]:\n"
    ^ Print.fun_decl_to_string env "" "  " f0
    ^ "\n\n"
    ^ Print.fun_decl_to_string env "" "  " f];
  f

(** Replace the occurrences of [core::intrinsics::unreachable] with
    [UndefinedBehavior]. This helps with the analyzes and the symbolic
    evaluation (in particular, we stop the evaluation when encountering an
    [UndefinedBehavior] - this can help us avoid merging control-flow after a
    match for instance *)
let remove_unreachable (crate : crate) (f : fun_decl) : fun_decl =
  let impl_pat = NameMatcher.parse_pattern "core::intrinsics::unreachable" in
  let match_name = ExtractName.match_name crate in

  let is_unreachable (st : statement) : bool =
    match st.kind with
    | Call (call, _) -> (
        match call.func with
        | FnOpRegular { kind; _ } -> (
            match kind with
            | Fun fid ->
                let fun_decl =
                  [%silent_unwrap_opt_span] (Some st.span)
                    (FunDeclId.Map.find_opt fid crate.fun_decls)
                in
                match_name impl_pat fun_decl.item_meta.name
            | _ -> false)
        | FnOpDynamic _ -> false)
    | _ -> false
  in
  let rec update (stl : statement list) : statement list =
    match stl with
    | [] -> []
    | st :: stl ->
        if is_unreachable st then [ { st with kind = UndefinedBehavior } ]
        else st :: update stl
  in
  let visitor =
    object
      inherit [_] map_statement_base as super

      method! visit_block env b =
        let b = { b with statements = update b.statements } in
        super#visit_block env b
    end
  in
  match f.body with
  | StructuredBody body ->
      let body = { body with body = visitor#visit_block () body.body } in
      { f with body = StructuredBody body }
  | _ -> f

(** The Rust compiler generates a unique implementation of [Default] for arrays
    for every choice of length. For instance, if we write:
    {[
      let a: [u8; 32] = default ();
      let b: [u8; 64] = default ();
      ...
    ]}
    then rustc will introduce two different implementations of [Default]: an
    implementation for [u8; 32] and a different one for [u8; 64].

    For the purpose of the translation, we prefer using a single implementation
    which is generic in the length of the array. This pass thus replaces all the
    implementations of [Default<[T; N]>] with a single implementation.

    Concretely, we spot all the instances of [Default<[T; N]>] where [N] is a
    concrete array. We update the first such implementation so that it becomes
    generic in the length of the array, and replace all the other ones with this
    implementation. We also remove the useless implementations. *)
let update_array_default (crate : crate) : crate =
  let pctx = Print.crate_to_fmt_env crate in
  let impl_pat = NameMatcher.parse_pattern "core::default::Default" in
  let match_name = ExtractName.match_name crate in

  (* Helper: check whether a trait impl matches the [Default<[T; N]>] pattern,
     and if so return its array length [N]. We ignore the case where the length
     is equal to 0, because in this case rustc uses a different impl which
     doesn't require that the type of the elements also has a default
     implementation. *)
  let matches_default_array (impl : trait_impl) : constant_expr option =
    (* The trait may be missing, e.g. under [--monomorphize], where an impl can
       refer to a trait declaration Charon did not keep: such an impl is not ours. *)
    match TraitDeclId.Map.find_opt impl.impl_trait.id crate.trait_decls with
    | None -> None
    | Some trait_decl -> (
        if not (match_name impl_pat trait_decl.item_meta.name) then None
        else
          match impl.impl_trait.generics with
          | {
           regions = [];
           types =
             [
               TArray
                 ( TVar (Free _),
                   ({ kind = CInteger (UnsignedInteger (Usize, nv)); _ } as n),
                   _ );
             ];
           const_generics = [];
           trait_refs = _;
          }
            when Z.to_int nv != 0 -> Some n
          | _ -> None)
  in

  (* First pass: collect all the trait impls matching [Default<[T; N]>] and
     their default methods, together with the array length [N]. *)
  let impls = ref TraitImplId.Map.empty in
  let methods = ref FunDeclId.Map.empty in
  TraitImplId.Map.iter
    (fun _ (impl : trait_impl) ->
      match matches_default_array impl with
      | None -> ()
      | Some n ->
          [%ldebug
            "found a matching impl.\n - decl_generics: "
            ^ Print.generic_args_to_string pctx impl.impl_trait.generics];
          impls := TraitImplId.Map.add impl.def_id n !impls;
          [%sanity_check_opt_span] None
            (TraitMethodId.Map.cardinal impl.methods = 1);
          let meth = List.hd (TraitMethodId.Map.values impl.methods) in
          [%sanity_check_opt_span] None
            (meth.binder_params = empty_generic_params);
          let method_id = meth.binder_value.id in
          methods := FunDeclId.Map.add method_id n !methods)
    crate.trait_impls;
  let impls = !impls in
  let methods = !methods in

  (* If we didn't find any matching impl, there is nothing to do. *)
  if TraitImplId.Map.is_empty impls then crate
  else
    (* Pick the impl into which we will merge all the others.  Prefer the smallest id
       among the impls whose def_id appears in the declarations to extract, so that the
       merged impl is actually emitted. If none of the matching impls is in the
       declarations, fall back to the smallest id: the merging is still useful so that
       builtin name mappings (which match the generic pattern [@T; @N]) can resolve
       references at use sites. *)
    let decl_ids = ref TraitImplId.Set.empty in
    let collect_visitor =
      object
        inherit [_] iter_crate

        method! visit_trait_impl_id _ id =
          TraitImplId.Set.add_in_place id decl_ids
      end
    in
    List.iter
      (collect_visitor#visit_declaration_group ())
      (Option.get crate.declarations);
    let impls_in_decls =
      TraitImplId.Map.filter
        (fun id _ -> TraitImplId.Set.mem id !decl_ids)
        impls
    in
    let merged_impl_id, _ =
      if TraitImplId.Map.is_empty impls_in_decls then
        TraitImplId.Map.min_binding impls
      else TraitImplId.Map.min_binding impls_in_decls
    in
    let merged_impl =
      [%silent_unwrap_opt_span] None
        (TraitImplId.Map.find_opt merged_impl_id crate.trait_impls)
    in
    let merged_method =
      let meth = List.hd (TraitMethodId.Map.values merged_impl.methods) in
      meth.binder_value.id
    in

    (* Update the chosen merged_impl in place: make it generic in the
       array length. *)
    let merged_impl =
      let cg_id = ConstGenericVarId.zero in
      let cg : Types.constant_expr =
        { kind = CVar (Free cg_id); ty = TypesUtils.mk_usize_ty }
      in
      let elem_ty =
        match merged_impl.impl_trait.generics.types with
        | [ TArray ((TVar (Free _) as elem_ty), _, _) ] -> elem_ty
        | _ -> [%internal_error] merged_impl.item_meta.span
      in
      let generics =
        {
          merged_impl.impl_trait.generics with
          types = [ TArray (elem_ty, cg, None) ];
        }
      in
      let impl_trait = { merged_impl.impl_trait with generics } in
      let params =
        {
          merged_impl.generics with
          const_generics =
            [ { index = cg_id; name = "N"; ty = TypesUtils.mk_usize_ty } ];
        }
      in
      { merged_impl with impl_trait; generics = params }
    in

    (* Replace [merged_impl] in [crate.trait_impls] and filter out the
       other matching impls. *)
    let crate =
      {
        crate with
        trait_impls =
          TraitImplId.Map.filter_map
            (fun id impl ->
              if id = merged_impl.def_id then Some merged_impl
              else if TraitImplId.Map.mem id impls then None
              else Some impl)
            crate.trait_impls;
      }
    in

    (* Filter the functions *)
    let visit_fun id (fdecl : fun_decl) =
      match FunDeclId.Map.find_opt id methods with
      | None -> Some fdecl
      | Some _ ->
          if id = merged_method then (
            (* Update the method *)
            let cg_id = ConstGenericVarId.zero in
            let cg : Types.constant_expr =
              { kind = CVar (Free cg_id); ty = TypesUtils.mk_usize_ty }
            in
            let sg = fdecl.signature in
            [%sanity_check_opt_span] None (sg.inputs = []);
            match sg.output with
            | TArray ((TVar (Free _) as elem_ty), _, _) ->
                let generics =
                  {
                    fdecl.generics with
                    const_generics =
                      [
                        {
                          index = cg_id;
                          name = "N";
                          ty = TypesUtils.mk_usize_ty;
                        };
                      ];
                  }
                in
                let sg = { sg with output = TArray (elem_ty, cg, None) } in
                let fdecl = { fdecl with signature = sg; generics } in
                Some fdecl
            | _ -> [%internal_error] fdecl.item_meta.span)
          else (* Filter *)
            None
    in
    let filter_ids_visitor =
      object
        inherit [_] filter_decl_id

        method! visit_trait_impl_id _ id =
          match TraitImplId.Map.find_opt id impls with
          | None -> Some id
          | Some _ -> if id = merged_impl.def_id then Some id else None

        method! visit_fun_decl_id _ id =
          match FunDeclId.Map.find_opt id methods with
          | None -> Some id
          | Some _ -> if id = merged_method then Some id else None
      end
    in
    let crate =
      {
        crate with
        fun_decls = FunDeclId.Map.filter_map visit_fun crate.fun_decls;
        declarations =
          Some
            (filter_ids_visitor#visit_declaration_groups ()
               (Option.get crate.declarations));
      }
    in

    (* Update all the definitions in the crate *)
    let visitor =
      object
        inherit [_] map_crate_with_span as super

        method! visit_TraitImpl env impl_ref =
          match TraitImplId.Map.find_opt impl_ref.id impls with
          | None -> super#visit_TraitImpl env impl_ref
          | Some n ->
              super#visit_TraitImpl env
                {
                  id = merged_impl.def_id;
                  generics = { impl_ref.generics with const_generics = [ n ] };
                }

        method! visit_fn_ptr env fn_ptr =
          match fn_ptr.kind with
          | Fun fid -> begin
              match FunDeclId.Map.find_opt fid methods with
              | None -> super#visit_fn_ptr env fn_ptr
              | Some n ->
                  let fn_ptr =
                    {
                      kind = Fun merged_method;
                      generics = { fn_ptr.generics with const_generics = [ n ] };
                    }
                  in
                  super#visit_fn_ptr env fn_ptr
            end
          | _ -> super#visit_fn_ptr env fn_ptr
      end
    in
    visitor#visit_crate None crate

exception FoundStatement of statement

(** Check that loops:
    - do not contain early returns
    - do not continue/break to outer loops

    We also attempt to update the loops so that they have the proper shape (for
    instance, if a loop has returns but no breaks, we replace the returns with
    breaks, and move the returns after the loop).

    We do the following transformations:

    # Transformation 1:
    {[
      loop {
        if e {
          return;
        } else {
          continue;
        }
      }

        ~~>

      loop {
        if e {
          break;
        } else {
          continue;
        }
      };
      return;
    ]}

    # Transformation 2:
    {[
      loop {
        if e0 {
          st0;
          return;
        } else if e1 {
          st1;
          break;
        } else {
          continue;
        }
      }
      st2;
      return;

        ~~>

      loop {
        if e0 {
          st0;
          break;
        } else if e1 {
          st1;
          st2;
          break;
        } else {
          continue;
        }
      }
      return;
    ]}

    # Transformation 3:
    {[
      loop {
        if e0 {
          st0;
          return;
        } else if e1 {
          st1;
          break;
        } else {
          continue;
        }
      }
      st2;
      panic;

        ~~>

      loop {
        if e0 {
          st0;
          break;
        } else if e1 {
          st1;
          st2;
          panic;
        } else {
          continue;
        }
      }
      return;
    ]} *)
let update_loops (crate : crate) (f : fun_decl) : fun_decl =
  let f0 = f in
  let span = f.item_meta.span in

  let visitor =
    object (self)
      inherit [_] map_statement as super

      (* [after]: the list of statements coming *after* this one in this block.

         We return:
         - the list of statements resulting from updating the current statement
         - the list of statements to put after and that are yet to be updated
           (the reason is that we might have moved some of those statements
           inside the current statement).
      *)
      method update_statement (depth : int) (st : statement)
          (after : statement list) : statement list * statement list =
        match st.kind with
        | Loop loop -> (
            (* Recursively update the loop.

               Note that doing this will raise an exception if we find a loop with
               an early return. *)
            try ([ { st with kind = self#visit_Loop (depth + 1) loop } ], after)
            with FoundStatement return_st ->
              (* An exception was raised: it means we found a return in the loop: attempt
                 to replace it with a break.

                 There are 2 cases:
                 - either the loop does not contain any break, in which case we
                   can simply replace the return with a break, and move the return
                   after the loop (this is transformation 1 above)
                 - or there is already a break in the loop: we can apply transformation 2
                   (resp., 3) if the statements after the loop end with a return (resp., a panic)
              *)
              let block_has_no_breaks (b : block) : bool =
                let visitor =
                  object
                    inherit [_] iter_statement
                    method! visit_Break _ _ = raise Found
                  end
                in
                try
                  visitor#visit_block () b;
                  true
                with Found -> false
              in
              if block_has_no_breaks loop then (* Transformation 1 *)
                let block_replace (b : block) : block =
                  let visitor =
                    object
                      inherit [_] map_statement
                      method! visit_Loop i loop = super#visit_Loop (i + 1) loop

                      method! visit_Return i =
                        [%sanity_check] span (i = 0);
                        (* Replace the return with a break *)
                        Break i
                    end
                  in
                  visitor#visit_block 0 b
                in
                let loop = block_replace loop in
                let loop : statement = { st with kind = Loop loop } in
                let loop = super#visit_statement depth loop in
                let return : statement =
                  {
                    span = st.span;
                    statement_id =
                      StatementId.zero (* we'll refresh this later *);
                    kind = Return;
                    comments_before = [];
                  }
                in
                ([ loop; return ], after)
              else
                (* Transformations 2 and 3 *)
                (* Check if the statements after the loop end with a return or a panic.
                   We output the statements with which to replace breaks.
                *)
                let rec decompose_after (after : statement list) :
                    statement list =
                  match after with
                  | [] ->
                      [%craise] span
                        "Early returns inside of loops are not supported yet"
                  | st :: after -> (
                      match st.kind with
                      | Return -> [ { st with kind = Break 0 } ]
                      | Panic _ | UnwindTerminate | UndefinedBehavior -> [ st ]
                      | _ -> st :: decompose_after after)
                in
                let after = decompose_after after in
                let replace (st : statement) : statement list =
                  match st.kind with
                  | Return ->
                      (* Replace the return with a break *)
                      [ { st with kind = Break 0 } ]
                  | Break i ->
                      (* Move the statements [after] before the break *)
                      [%cassert] span (i = 0)
                        "Breaks to outer loops are not supported yet";
                      after
                  | _ -> [ st ]
                in

                let block_visitor =
                  object (self)
                    inherit [_] map_statement_base as super

                    method! visit_Loop depth loop =
                      super#visit_Loop (depth + 1) loop

                    method! visit_block depth b =
                      (* Only replace if the depth is 0 (it means we haven't dived
                         into an inner loop) *)
                      if depth = 0 then
                        let update st =
                          replace (self#visit_statement depth st)
                        in
                        {
                          b with
                          statements =
                            List.flatten (List.map update b.statements);
                        }
                      else b
                  end
                in

                let loop = block_visitor#visit_block 0 loop in
                let loop : statement = { st with kind = Loop loop } in
                let loop = super#visit_statement depth loop in
                ([ loop; return_st ], []))
        | _ -> ([ self#visit_statement depth st ], after)

      method! visit_block depth (block : block) : block =
        let rec update (stl : statement list) : statement list =
          match stl with
          | [] -> []
          | st :: stl ->
              let stl0, stl1 = self#update_statement depth st stl in
              stl0 @ update stl1
        in
        { block with statements = update block.statements }

      method! visit_Break depth i =
        [%cassert] span (i = 0) "Breaks to outer loops are not supported yet";
        super#visit_Break depth i

      method! visit_Continue depth i =
        [%cassert] span (i = 0) "Continue to outer loops are not supported yet";
        super#visit_Continue depth i

      method! visit_statement depth st =
        match st.kind with
        | Return ->
            [%cassert] span (depth <= 1)
              "Returns inside of nested loops are not supported yet";
            (* If we are inside a loop we need to get rid of the return.

               Note that raising an exception containing the full return
               statement allows us to use its span when moving it after the loop. *)
            if depth = 1 then raise (FoundStatement st) else st
        | _ -> super#visit_statement depth st

      method! visit_Return _ =
        (* The Return case should have been caught by the [visit_statement] method *)
        [%internal_error] span
    end
  in

  (* Map  *)
  let body =
    match f.body with
    | StructuredBody body ->
        StructuredBody { body with body = visitor#visit_block 0 body.body }
    | other -> other
  in

  let f : fun_decl = { f with body } in
  [%ldebug
    let env = Print.crate_to_fmt_env crate in
    "Before/after [update_loops]:\n"
    ^ Print.fun_decl_to_string env "" " " f0
    ^ "\n\n"
    ^ Print.fun_decl_to_string env "" " " f];
  f

(** Lift exits out of nested loops with flags.

    [update_loops] supports a [return] only in an outermost loop and [break]s
    and [continue]s only to the current loop. A [?] in an inner loop of an outer
    loop (e.g. [for i in xs { for v in i { t.common(v)?; } }]) is a return from
    two loops deep, which it rejects. We rewrite each such exit, innermost loops
    first:
    {[
      loop { .. loop { .. return; .. } .. }

        ~~>

      loop {
        ..
        flag := false;
        loop { .. flag := true; break; .. }
        if flag { return; }
        ..
      }
    ]}
    and likewise [break (i + 1)] / [continue (i + 1)] become a [break] out of
    the inner loop followed by [if flag { break i }] / [if flag { continue i }].
    A [return] carries its value out instead: the return local [_0] must not be
    live across the loop (it is unset on the loop's other exits, and the
    symbolic execution cannot join a set value with an unset one), so we move it
    into a fresh [ret : Option<T>]:
    {[
      ret := None; loop { .. ret := Some(move _0); break; .. }
      match ret { Some => { _0 := move (ret as Some).0; return; } _ => {} }
    ]}
    The flag is set only on the rewritten exit, which leaves the inner loop at
    once, so after the loop it is true exactly when that exit was taken, and the
    exit then continues one level up; repeating this at each level lifts it to
    where [update_loops] handles it. A [return] in an outermost loop is left to
    [update_loops]. *)
let lift_nested_loop_exits (crate : crate) (f : fun_decl) : fun_decl =
  match f.body with
  | StructuredBody body ->
      let bool_ty = TScalar TBool in
      let locals = ref body.locals.locals in
      let fresh_flag (span : span) : place =
        let index = LocalId.of_int (List.length !locals) in
        locals :=
          !locals
          @ [
              {
                index;
                name = Some "loop_exit";
                span;
                local_ty = bool_ty;
                drop_flag_for = None;
              };
            ];
        { kind = PlaceLocal index; ty = bool_ty }
      in
      let fresh_local (span : span) (name : string) (local_ty : ty) : place =
        let index = LocalId.of_int (List.length !locals) in
        locals :=
          !locals
          @ [
              { index; name = Some name; span; local_ty; drop_flag_for = None };
            ];
        { kind = PlaceLocal index; ty = local_ty }
      in
      (* [Option<T>] for the return value, with its [None] and [Some] variants *)
      let ret_option =
        let pat = NameMatcher.parse_pattern "core::option::Option" in
        let match_name = ExtractName.match_name crate in
        List.find_map
          (fun (d : type_decl) ->
            match d.kind with
            | Enum variants when match_name pat d.item_meta.name -> (
                let find n =
                  List.find_opt
                    (fun (v : variant) -> v.variant_name = n)
                    variants
                in
                match (find "None", find "Some") with
                | Some none, Some some -> Some (d.def_id, none.id, some.id)
                | _ -> None)
            | _ -> None)
          (TypeDeclId.Map.values crate.type_decls)
      in
      let ret_ty = (List.hd body.locals.locals).local_ty in
      let ret_place : place =
        { kind = PlaceLocal (LocalId.of_int 0); ty = ret_ty }
      in
      let mk (span : span) (kind : statement_kind) : statement =
        { span; statement_id = StatementId.zero; kind; comments_before = [] }
      in
      (* Marks the [return]s this pass moves up a level, so that the loop they
         now sit in ends its locals on every exit too (see [inner_locals]) *)
      let lifted_return = "aeneas: return lifted out of a nested loop" in
      let is_lifted_return (st : statement) =
        st.kind = Return && List.mem lifted_return st.comments_before
      in
      let local_of (p : place) : local_id =
        match p.kind with
        | PlaceLocal id -> id
        | _ -> [%internal_error] f.item_meta.span
      in
      let set (span : span) (flag : place) (b : bool) : statement =
        mk span
          (Assign
             (flag, Use (Constant { kind = CBool b; ty = bool_ty }, NoRetag)))
      in
      let if_flag (span : span) (b : block) (flag : place)
          (exit : statement_kind) : statement =
        let data : switch_data =
          {
            scrutinee = SwitchValue (Copy flag);
            branches =
              [ ({ kind = CBool true; ty = bool_ty }, BranchId.of_int 0) ];
            fallback = Some (BranchId.of_int 1);
          }
        in
        (* The flag dies on both branches, as a Rust local dies at the end of its
           scope: otherwise it is set on a loop's back-edge but not on entry. *)
        let dead = mk span (StorageDead (local_of flag)) in
        let block statements = { b with span; statements } in
        mk span
          (Switch (data, [ block [ dead; mk span exit ]; block [ dead ] ]))
      in
      (* [depth]: the number of loops around the block *)
      let rec update_block (depth : int) (b : block) : block =
        {
          b with
          statements = List.concat_map (update_statement depth b) b.statements;
        }
      and update_statement (depth : int) (_parent : block) (st : statement) :
          statement list =
        match st.kind with
        | Loop loop ->
            (* Inner loops first: their escaping exits now sit in this body *)
            let loop = update_block (depth + 1) loop in
            (* The exits of this loop's body (outside its inner loops) that go
               further than this loop *)
            (* Locals whose storage starts inside this loop: they are dead outside
               it, so we end them on every exit, the rewritten ones as well as the
               loop's own [break]s. Rust leaves some alive at a [break] (e.g. the
               [&mut iter] of a [for] loop's [next]) and kills all of them at a
               [return]: without this, the loop's exits would leave different
               borrows alive and could not be joined. *)
            let inner_locals =
              let acc = ref [] in
              (object
                 inherit [_] iter_statement

                 method! visit_StorageLive _ id =
                   if not (List.mem id !acc) then acc := id :: !acc
              end)
                #visit_block
                () loop;
              List.rev !acc
            in
            (* Whether this loop's body (outside its inner loops) returns from a
               nested position: only then do the exits need the locals' deaths
               aligned (a [break]/[continue] out of it kills what Rust's own
               [break] does) *)
            let has_escapes =
              let rec in_block (b : block) = List.exists in_st b.statements
              and in_st (st : statement) =
                match st.kind with
                | Return -> depth > 0 || is_lifted_return st
                | Loop _ -> false
                | Switch (_, branches) -> List.exists in_block branches
                | _ -> false
              in
              in_block loop
            in
            let end_inner (span : span) : statement list =
              List.map (fun id -> mk span (StorageDead id)) inner_locals
            in
            let lifted = ref [] in
            let escape (st : statement) (exit : statement_kind) : statement list
                =
              match exit with
              | Return -> (
                  match ret_option with
                  | None ->
                      [%craise] st.span
                        "Returns inside of nested loops need `Option` in the \
                         crate"
                  | Some (opt_id, none, some) ->
                      let tref : type_decl_ref =
                        {
                          id = opt_id;
                          generics =
                            {
                              regions = [];
                              types = [ ret_ty ];
                              const_generics = [];
                              trait_refs = [];
                            };
                          builtin = None;
                        }
                      in
                      let slot =
                        fresh_local st.span "loop_return" (TAdt tref)
                      in
                      let init =
                        [
                          mk st.span (StorageLive (local_of slot));
                          mk st.span
                            (Assign
                               ( slot,
                                 Aggregate
                                   (AggregatedAdt (tref, Some none, None), [])
                               ));
                        ]
                      in
                      let take =
                        let field : place =
                          {
                            kind =
                              PlaceProjection
                                (slot, Field (Some some, FieldId.of_int 0));
                            ty = ret_ty;
                          }
                        in
                        let data : switch_data =
                          {
                            scrutinee = SwitchDiscriminant slot;
                            branches =
                              [
                                ( {
                                    kind = CDiscriminant (tref, some);
                                    ty = TAdt tref;
                                  },
                                  BranchId.of_int 0 );
                              ];
                            fallback = Some (BranchId.of_int 1);
                          }
                        in
                        let block statements =
                          { loop with span = st.span; statements }
                        in
                        mk st.span
                          (Switch
                             ( data,
                               [
                                 block
                                   [
                                     mk st.span
                                       (Assign
                                          (ret_place, Use (Move field, NoRetag)));
                                     mk st.span (StorageDead (local_of slot));
                                     {
                                       (mk st.span Return) with
                                       comments_before = [ lifted_return ];
                                     };
                                   ];
                                 block
                                   [ mk st.span (StorageDead (local_of slot)) ];
                               ] ))
                      in
                      lifted := (init, take) :: !lifted;
                      [
                        mk st.span
                          (Assign
                             ( slot,
                               Aggregate
                                 ( AggregatedAdt (tref, Some some, None),
                                   [ Move ret_place ] ) ));
                      ]
                      @ end_inner st.span
                      @ [ mk st.span (Break 0) ])
              | _ ->
                  let flag = fresh_flag st.span in
                  lifted :=
                    ( [
                        mk st.span (StorageLive (local_of flag));
                        set st.span flag false;
                      ],
                      if_flag st.span loop flag exit )
                    :: !lifted;
                  [ set st.span flag true; mk st.span (Break 0) ]
            in
            let rec replace_block (b : block) : block =
              (* Rust kills every live local right before a [return]: a [return]
                 we turn into a [break] out of this loop must not kill the locals of
                 the enclosing scopes, which live on after it (the real return,
                 once lifted, ends them). *)
              let rec go (acc : statement list) (stl : statement list) =
                match stl with
                | [] -> List.rev acc
                | ({ kind = Return; _ } as st) :: stl when depth > 0 ->
                    let rec drop_outer_deaths acc =
                      match acc with
                      | ({ kind = StorageDead id; _ } : statement) :: acc'
                        when not (List.mem id inner_locals) ->
                          drop_outer_deaths acc'
                      | ({ kind = StorageDead _; _ } as d) :: acc' ->
                          d :: drop_outer_deaths acc'
                      | _ -> acc
                    in
                    go
                      (List.rev_append (replace st) (drop_outer_deaths acc))
                      stl
                | st :: stl -> go (List.rev_append (replace st) acc) stl
              in
              { b with statements = go [] b.statements }
            and replace (st : statement) : statement list =
              match st.kind with
              | Break 0 when has_escapes -> end_inner st.span @ [ st ]
              | Break i when i > 0 -> escape st (Break (i - 1))
              | Continue i when i > 0 -> escape st (Continue (i - 1))
              | Return when depth > 0 -> escape st Return
              | Return when is_lifted_return st -> end_inner st.span @ [ st ]
              | Loop _ -> [ st ]
              | Switch (data, branches) ->
                  [
                    {
                      st with
                      kind = Switch (data, List.map replace_block branches);
                    };
                  ]
              | _ -> [ st ]
            in
            let loop = replace_block loop in
            let lifted = List.rev !lifted in
            List.concat_map fst lifted
            @ [ { st with kind = Loop loop } ]
            @ List.map snd lifted
        | Switch (data, branches) ->
            [
              {
                st with
                kind = Switch (data, List.map (update_block depth) branches);
              };
            ]
        | _ -> [ st ]
      in
      let body_block = update_block 0 body.body in
      let locals = { body.locals with locals = !locals } in
      { f with body = StructuredBody { body with body = body_block; locals } }
  | _ -> f

(** Inline what comes after an [if then else], a [switch] or a [match], etc.
    under certain conditions, to prevent useless joins from being performed by
    the symbolic execution.

    The main goal of this pass is to improve the quality of the generated code.
*)
let remove_useless_joins (crate : crate) (f : fun_decl) : fun_decl =
  let f0 = f in

  let rec update_block (to_inline : statement list) (block : block) :
      bool * block =
    let can_inline, statements = update_statements to_inline block.statements in
    (can_inline, { block with statements })
  and update_statements (to_inline : statement list) (ls : statement list) :
      bool * statement list =
    match ls with
    | [] -> (true, to_inline)
    | st :: ls -> (
        [%ldebug
          "ls:\n"
          ^ Print.list_to_string ~sep:"\n" (statement_to_string crate) ls];
        let can_inline, ls = update_statements to_inline ls in
        match st.kind with
        | Nop | StorageLive _ | StorageDead _ | PlaceMention _ | Borrowck _
        | Drop (_, _, _, _) -> (can_inline, st :: ls)
        | Panic _
        | UnwindTerminate
        | UndefinedBehavior
        | Return
        | UnwindResume
        | Break _
        | Continue _ -> (true, [ st ])
        | Switch (data, branches) ->
            [%ldebug "Switch: can_inline: " ^ Print.bool_to_string can_inline];
            (* Attempt to inline inside the body *)
            let to_inline, ls = if can_inline then (ls, []) else ([], ls) in
            let update b = snd (update_block to_inline b) in
            let branches = List.map update branches in
            let ls = { st with kind = Switch (data, branches) } :: ls in
            [%ldebug
              "after updating the switch:\n"
              ^ Print.list_to_string ~sep:"\n" (statement_to_string crate) ls];
            (false, ls)
        | Loop loop ->
            (* Update the inside of the loop *)
            (false, { st with kind = Loop (snd (update_block [] loop)) } :: ls)
        | Assign (_, rv) -> (
            (* We allow inlining some assignments (otherwise the pass is too restrictive) *)
            match rv with
            | Use _ | RvRef _ | RawPtr _ | NullaryOp _ | Aggregate _ ->
                (can_inline, st :: ls)
            | BinaryOp _ | UnaryOp _ | Discriminant _ | Len _ | Repeat _ ->
                (false, st :: ls))
        | SetDiscriminant _ | Assert (_, _, _) | Call (_, _) -> (false, st :: ls)
        | _ ->
            [%craise] st.span
              ("unsupported statement: " ^ show_statement_kind st.kind))
  in

  let body =
    match f.body with
    | StructuredBody body ->
        StructuredBody { body with body = snd (update_block [] body.body) }
    | other -> other
  in

  let f : fun_decl = { f with body } in
  [%ldebug
    let env = Print.crate_to_fmt_env crate in
    "Before/after [remove_useless_joins]:\n"
    ^ Print.fun_decl_to_string env "" " " f0
    ^ "\n\n"
    ^ Print.fun_decl_to_string env "" " " f];
  f

(** Remove the use of shallow borrows and the storage live/dead instructions.

    Storage live/dead instructions are not used by the symbolic/concrete
    interpreter, so we can safely remove them.

    Shallow borrows are used in early versions of MIR for the sole use of the
    borrow checker (they have no runtime semantics). They are used to prevent
    match guards from changing a discriminant that is being matched on.

    For instance, let's consider the following Rust code:
    {[
      let mut x = (true, true);
      match x {
          (false, _) => 1,
          (true, _) if { x.0 = false; false } => 0,
          (_, true) => 2,
          (true, _) => 3,
      }
    ]}

    If this code was allowed, it would reach an `unreachable_unchecked` code
    path. Rust disallows this by adding a shallow borrow of each place whose
    discriminant is read, and a fake (removed before codegen) read of that
    borrow.

    We discard these in Aeneas. This does allow more code to pass the
    borrow-checker, but the UB is still correctly caught by the
    evaluator/translation hence the translation is still sound. *)
let remove_shallow_borrows_storage_live_dead (crate : crate) (f : fun_decl) :
    fun_decl =
  let f0 = f in
  let filter_in_body (argument_locals : LocalId.Set.t) (body : block) : block =
    let filtered = ref LocalId.Set.empty in

    let filter_shallow (st : statement) : statement list =
      match st.kind with
      | Assign (p, rv) -> (
          match (p.kind, rv) with
          | PlaceLocal var_id, RvRef (_, BShallow, _) ->
              (* Filter *)
              filtered := LocalId.Set.add var_id !filtered;
              []
          | _ -> [ st ])
      | _ -> [ st ]
    in

    let filter_storage (st : statement) : statement list =
      match st.kind with
      | StorageLive _ | Borrowck _ -> []
      | StorageDead loc
        when LocalId.Set.mem loc !filtered
             || LocalId.Set.mem loc argument_locals -> []
      | _ -> [ st ]
    in

    (* Filter the variables *)
    let body = map_statement filter_shallow body in
    let body = map_statement filter_storage body in

    (* Check that the filtered variables have completely disappeared from the body *)
    let check_visitor =
      object
        inherit [_] iter_statement as super

        (* Remember the span of the statement we enter *)
        method! visit_statement _ st = super#visit_statement st.span st

        method! visit_local_id span id =
          [%cassert] span
            (not (LocalId.Set.mem id !filtered))
            "Filtered variables should have completely disappeared from the \
             body"
      end
    in
    check_visitor#visit_block body.span body;

    (* Return the updated body *)
    body
  in

  let body =
    match f.body with
    | StructuredBody body ->
        let argument_locals =
          body.locals.locals |> List.tl
          |> Collections.List.prefix body.locals.arg_count
          |> List.map (fun (var : local) -> var.index)
          |> LocalId.Set.of_list
        in
        StructuredBody
          { body with body = filter_in_body argument_locals body.body }
    | other -> other
  in
  let f = { f with body } in
  [%ldebug
    let env = Print.crate_to_fmt_env crate in
    "Before/after [remove_shallow_borrows]:\n"
    ^ Print.fun_decl_to_string env "" " " f0
    ^ "\n\n"
    ^ Print.fun_decl_to_string env "" " " f];
  f

(** Strip unnecessary [PeTarget] suffixes from function and type names.

    Multi-target extraction appends [PeTarget] to per-target item names to
    disambiguate items that exist for multiple targets.

    For functions: if the function is not behind a target dispatch (its [src] is
    NOT [TargetDependentFun]), there is no ambiguity (the function is not used
    for several targets), so we remove the suffix.

    For types there is no notion of dispatch, meaning we can't use the item
    source. Instead, we compute a multi-set of base names (names without the
    [PeTarget] suffix) if a type has a suffix but its base name only appears
    once, it means there is no collision and the suffix is unnecessary. *)
let strip_unnecessary_target_suffixes (crate : crate) : crate =
  let module NameMap = Map.Make (struct
    type t = Types.name

    let compare = Types.compare_name
  end) in
  let add_name acc name =
    let base = strip_target_suffix name in
    let count =
      match NameMap.find_opt base acc with
      | Some n -> n
      | None -> 0
    in
    NameMap.add base (count + 1) acc
  in
  let get_name base_counts name =
    let base = strip_target_suffix name in
    if base = name then name
    else
      let count =
        match NameMap.find_opt base base_counts with
        | Some n -> n
        | None -> 0
      in
      if count <= 1 then base else name
  in
  (* --- Functions --- *)
  (* We also count how many non-dispatch functions share a base name.

     We shouldn't need to do this, but have to do it because of:
     https://github.com/AeneasVerif/charon/issues/1158

     Generally speaking it's a good way of being defensive against Charon's
     deduplication bugs.
  *)
  let fun_base_counts =
    FunDeclId.Map.fold
      (fun _ (f : fun_decl) acc ->
        match f.src with
        | TargetDependentFun _ -> acc
        | _ -> add_name acc f.item_meta.name)
      crate.fun_decls NameMap.empty
  in
  let fun_decls =
    FunDeclId.Map.map
      (fun (f : fun_decl) ->
        match f.src with
        | TargetDependentFun _ -> f
        | _ ->
            let name = get_name fun_base_counts f.item_meta.name in
            { f with item_meta = { f.item_meta with name } })
      crate.fun_decls
  in
  (* --- Types: strip PeTarget when the base name is unique --- *)
  let type_base_counts =
    TypeDeclId.Map.fold
      (fun _ (td : type_decl) acc -> add_name acc td.item_meta.name)
      crate.type_decls NameMap.empty
  in
  let type_decls =
    TypeDeclId.Map.map
      (fun (td : type_decl) ->
        let name = get_name type_base_counts td.item_meta.name in
        { td with item_meta = { td.item_meta with name } })
      crate.type_decls
  in
  { crate with fun_decls; type_decls }

(** Remove all occurrences of certain compiler-internal marker traits.

    These traits have no semantic content relevant to verification:
    - [Sized], [MetaSized], [PointeeSized]: type size plumbing
    - [Destruct]: carries drop information
    - [Pointee], [Thin]: pointer metadata plumbing
    - [Send], [Sync]: thread-safety markers
    - [Unpin]: pin-projection marker
    - [Tuple]: identifies tuples for use in the [Fn] family of traits
    - [TrivialClone]: internal marker trait used for some optimizations
    - [Allocator]: unstable API for custom allocators, present on Box/Vec/etc
      but not exposed to stable users

    When we will actually need to reason about these, we will capture their
    semantic content through separation logic predicates.

    We filter out the trait declarations, their impls, their associated items,
    and all references (trait refs, clauses, type constraints, parent clauses).
*)
let filter_marker_traits (crate : crate) : crate =
  let pats =
    List.map NameMatcher.parse_pattern
      [
        "core::marker::Sized";
        "core::marker::MetaSized";
        "core::marker::PointeeSized";
        "core::marker::Destruct";
        "core::ptr::metadata::Pointee";
        "core::ptr::metadata::Thin";
        "core::marker::Send";
        "core::marker::Sync";
        "core::marker::Unpin";
        "core::marker::Tuple";
        "core::clone::TrivialClone";
        "core::alloc::Allocator";
      ]
  in
  (* Collect the trait decl ids to filter *)
  let filtered_ids =
    TraitDeclId.Map.fold
      (fun id (decl : trait_decl) acc ->
        if
          List.exists
            (fun pat -> ExtractName.match_name crate pat decl.item_meta.name)
            pats
        then TraitDeclId.Set.add id acc
        else acc)
      crate.trait_decls TraitDeclId.Set.empty
  in
  if TraitDeclId.Set.is_empty filtered_ids then crate
  else
    let is_filtered_id id = TraitDeclId.Set.mem id filtered_ids in
    let is_filtered_ref (tr : trait_ref) : bool =
      is_filtered_id tr.trait_decl_ref.binder_value.id
    in
    let is_filtered_clause (clause : trait_param) : bool =
      is_filtered_id clause.trait.binder_value.id
    in
    let check_not_filtered_type_constraint
        (c : trait_type_constraint region_binder) : unit =
      if is_filtered_id c.binder_value.trait_ref.trait_decl_ref.binder_value.id
      then
        let span = c.binder_value.trait_ref.trait_decl_ref.binder_value in
        [%craise_opt_span] None
          ("Unexpected trait type constraint referencing a filtered marker \
            trait (id: "
          ^ TraitDeclId.to_string span.id
          ^ ")")
    in
    (* Remove the trait decls and their impls from declarations and maps *)
    let filtered_impl_ids =
      TraitImplId.Map.fold
        (fun id (impl : trait_impl) acc ->
          if is_filtered_id impl.impl_trait.id then TraitImplId.Set.add id acc
          else acc)
        crate.trait_impls TraitImplId.Set.empty
    in
    let fun_source_is_filtered (src : fun_source) : bool =
      match src with
      | TraitDefaultFun (trait_ref, _) -> is_filtered_id trait_ref.id
      | TraitImplFun (impl_ref, trait_ref, _, _) ->
          TraitImplId.Set.mem impl_ref.id filtered_impl_ids
          || is_filtered_id trait_ref.id
      | _ -> false
    in
    let global_source_is_filtered (src : global_source) : bool =
      match src with
      | TraitDefaultGlobal (trait_ref, _) -> is_filtered_id trait_ref.id
      | TraitImplGlobal (impl_ref, trait_ref, _, _) ->
          TraitImplId.Set.mem impl_ref.id filtered_impl_ids
          || is_filtered_id trait_ref.id
      | _ -> false
    in
    let filtered_global_ids =
      GlobalDeclId.Map.fold
        (fun id (decl : global_decl) acc ->
          if global_source_is_filtered decl.src then GlobalDeclId.Set.add id acc
          else acc)
        crate.global_decls GlobalDeclId.Set.empty
    in
    let filtered_fun_ids =
      FunDeclId.Map.fold
        (fun id (decl : fun_decl) acc ->
          let initializer_is_filtered =
            match fun_decl_global_initializer decl with
            | None -> false
            | Some global -> GlobalDeclId.Set.mem global.id filtered_global_ids
          in
          if fun_source_is_filtered decl.src || initializer_is_filtered then
            FunDeclId.Set.add id acc
          else acc)
        crate.fun_decls FunDeclId.Set.empty
    in
    let declarations =
      List.filter_map
        (fun (g : declaration_group) ->
          match g with
          | TraitDeclGroup (NonRecGroup id) ->
              if is_filtered_id id then None else Some g
          | TraitDeclGroup (RecGroup ids) ->
              let ids = List.filter (fun id -> not (is_filtered_id id)) ids in
              if ids <> [] then Some (TraitDeclGroup (RecGroup ids)) else None
          | TraitImplGroup (NonRecGroup id) ->
              if TraitImplId.Set.mem id filtered_impl_ids then None else Some g
          | TraitImplGroup (RecGroup ids) ->
              let ids =
                List.filter
                  (fun id -> not (TraitImplId.Set.mem id filtered_impl_ids))
                  ids
              in
              if ids <> [] then Some (TraitImplGroup (RecGroup ids)) else None
          | FunGroup (NonRecGroup id) ->
              if FunDeclId.Set.mem id filtered_fun_ids then None else Some g
          | FunGroup (RecGroup ids) ->
              let ids =
                List.filter
                  (fun id -> not (FunDeclId.Set.mem id filtered_fun_ids))
                  ids
              in
              if ids <> [] then Some (FunGroup (RecGroup ids)) else None
          | GlobalGroup (NonRecGroup id) ->
              if GlobalDeclId.Set.mem id filtered_global_ids then None
              else Some g
          | GlobalGroup (RecGroup ids) ->
              let ids =
                List.filter
                  (fun id -> not (GlobalDeclId.Set.mem id filtered_global_ids))
                  ids
              in
              if ids <> [] then Some (GlobalGroup (RecGroup ids)) else None
          | MixedGroup g -> (
              let is_filtered_item (id : item_id) =
                match id with
                | IdFun id -> FunDeclId.Set.mem id filtered_fun_ids
                | IdGlobal id -> GlobalDeclId.Set.mem id filtered_global_ids
                | IdTraitDecl id -> is_filtered_id id
                | IdTraitImpl id -> TraitImplId.Set.mem id filtered_impl_ids
                | _ -> false
              in
              match g with
              | NonRecGroup id ->
                  if is_filtered_item id then None else Some (MixedGroup g)
              | RecGroup ids ->
                  let ids =
                    List.filter (fun id -> not (is_filtered_item id)) ids
                  in
                  if ids <> [] then Some (MixedGroup (RecGroup ids)) else None)
          | _ -> Some g)
        (Option.get crate.declarations)
    in
    let trait_decls =
      TraitDeclId.Map.filter
        (fun id _ -> not (is_filtered_id id))
        crate.trait_decls
    in
    let trait_impls =
      TraitImplId.Map.filter
        (fun id _ -> not (TraitImplId.Set.mem id filtered_impl_ids))
        crate.trait_impls
    in
    let global_decls =
      GlobalDeclId.Map.filter
        (fun id _ -> not (GlobalDeclId.Set.mem id filtered_global_ids))
        crate.global_decls
    in
    let fun_decls =
      FunDeclId.Map.filter
        (fun id _ -> not (FunDeclId.Set.mem id filtered_fun_ids))
        crate.fun_decls
    in
    let crate =
      {
        crate with
        declarations = Some declarations;
        trait_decls;
        trait_impls;
        global_decls;
        fun_decls;
      }
    in
    let visitor =
      object (self)
        inherit [_] map_crate as super

        method! visit_generic_args env (args : generic_args) =
          let args = super#visit_generic_args env args in
          {
            args with
            trait_refs =
              List.filter (fun tr -> not (is_filtered_ref tr)) args.trait_refs;
          }

        method! visit_generic_params env (params : generic_params) =
          let params = super#visit_generic_params env params in
          List.iter check_not_filtered_type_constraint
            params.trait_type_constraints;
          {
            params with
            trait_clauses =
              List.filter
                (fun c -> not (is_filtered_clause c))
                params.trait_clauses;
          }

        method! visit_trait_ref_kind env (kind : trait_ref_kind) =
          match kind with
          | BuiltinOrAuto (data, parent_refs, types, vtable) ->
              let parent_refs =
                List.filter (fun tr -> not (is_filtered_ref tr)) parent_refs
              in
              let parent_refs =
                List.map (self#visit_trait_ref env) parent_refs
              in
              let types =
                AssocTypeId.Map.map
                  (fun t -> self#visit_trait_assoc_ty_impl env t)
                  types
              in
              let vtable = Option.map (self#visit_global_decl_ref env) vtable in
              BuiltinOrAuto (data, parent_refs, types, vtable)
          | _ -> super#visit_trait_ref_kind env kind

        method! visit_trait_decl env (decl : trait_decl) =
          let decl = super#visit_trait_decl env decl in
          {
            decl with
            implied_clauses =
              List.filter
                (fun c -> not (is_filtered_clause c))
                decl.implied_clauses;
          }

        method! visit_trait_impl env (impl_ : trait_impl) =
          let impl_ = super#visit_trait_impl env impl_ in
          {
            impl_ with
            implied_trait_refs =
              List.filter
                (fun tr -> not (is_filtered_ref tr))
                impl_.implied_trait_refs;
          }
      end
    in
    visitor#visit_crate () crate

(* Remove the type aliases from the type declarations and declaration groups *)
let filter_type_aliases (crate : crate) : crate =
  let type_decl_is_alias (ty : type_decl) =
    match ty.kind with
    | Alias _ -> true
    | _ -> false
  in
  (* Whether the declaration group has a single entry that is a type alias.
     Type aliases should not be in recursive groups so we also ensure this doesn't
     happen. *)
  let decl_group_is_single_alias = function
    | TypeGroup (NonRecGroup id) ->
        type_decl_is_alias (TypeDeclId.Map.find id crate.type_decls)
    | TypeGroup (RecGroup ids) ->
        List.iter
          (fun id ->
            let ty = TypeDeclId.Map.find id crate.type_decls in
            if type_decl_is_alias ty then
              [%craise] ty.item_meta.span
                "found a type alias within a recursive group; this is \
                 unexpected")
          ids;
        false
    | _ -> false
  in
  {
    crate with
    type_decls =
      TypeDeclId.Map.filter
        (fun _id ty -> not (type_decl_is_alias ty))
        crate.type_decls;
    declarations =
      Some
        (List.filter
           (fun decl -> not (decl_group_is_single_alias decl))
           (Option.get crate.declarations));
  }

(** Whenever we write a string literal in Rust, rustc actually introduces a
    constant of type [&str]. Generally speaking, because [str] is unsized, it
    doesn't make sense to manipulate values of type [str] directly. But in the
    context of Aeneas, it is reasonable to decompose those literals into: a
    string stored in a local variable, then a borrow of this variable.

    Remark: the new statements all have the id 0: this pass requires to refresh
    the ids later. *)
let decompose_str_borrows (_ : crate) (f : fun_decl) : fun_decl =
  (* Map  *)
  let body =
    match f.body with
    | StructuredBody body ->
        let new_locals = ref [] in
        let _, gen =
          LocalId.mk_stateful_generator_starting_at_id
            (LocalId.of_int (List.length body.locals.locals))
        in
        let fresh_local ty =
          let local =
            {
              index = gen ();
              local_ty = ty;
              name = None;
              span = f.item_meta.span;
              drop_flag_for = None;
            }
          in
          new_locals := local :: !new_locals;
          local.index
        in

        (* Function to decompose a constant literal *)
        let decompose_rvalue (span : Meta.span) (lv : place) (rv : rvalue) :
            statement list =
          let new_statements = ref [] in

          (* Visit the rvalue *)
          let visitor =
            object
              inherit [_] map_statement as super

              (* We have to visit all the constant operands.
                 As we might need to replace them with borrows, while borrows
                 are rvalues (i.e., not operands) we have to introduce two
                 intermediate statements: the string initialization, then
                 the borrow, that we can finally move.
              *)
              method! visit_Constant env (cv : constant_expr) =
                match (cv.kind, cv.ty) with
                | ( CStr str,
                    TRef
                      (_, (TAdt { builtin = Some TStr; _ } as str_ty), ref_kind)
                  ) ->
                    (* We need to introduce intermediate assignments *)
                    (* First the string initialization *)
                    let local_id =
                      let local_id = fresh_local str_ty in
                      let new_cv : constant_expr =
                        { kind = CStr str; ty = str_ty }
                      in
                      let st =
                        {
                          span;
                          statement_id = StatementId.zero;
                          kind =
                            Assign
                              ( { kind = PlaceLocal local_id; ty = str_ty },
                                Use (Constant new_cv, NoRetag) );
                          comments_before = [];
                        }
                      in
                      new_statements := st :: !new_statements;
                      local_id
                    in
                    let str_len =
                      Constant
                        {
                          kind =
                            CInteger
                              (UnsignedInteger
                                 (Usize, Z.of_int (String.length str)));
                          ty = TScalar (TInteger (Unsigned Usize));
                        }
                    in
                    (* Then the borrow *)
                    let local_id =
                      let nlocal_id = fresh_local cv.ty in
                      let bkind =
                        match ref_kind with
                        | RMut -> BMut
                        | RShared -> BShared
                      in
                      let rv =
                        RvRef
                          ( { kind = PlaceLocal local_id; ty = str_ty },
                            bkind,
                            str_len )
                      in
                      let lv = { kind = PlaceLocal nlocal_id; ty = cv.ty } in
                      let st =
                        {
                          span;
                          statement_id = StatementId.zero;
                          kind = Assign (lv, rv);
                          comments_before = [];
                        }
                      in
                      new_statements := st :: !new_statements;
                      nlocal_id
                    in
                    (* Finally we can move the value *)
                    Move { kind = PlaceLocal local_id; ty = cv.ty }
                | _ -> super#visit_Constant env cv
            end
          in

          let rv = visitor#visit_rvalue () rv in

          (* Construct the sequence *)
          let assign =
            {
              span;
              statement_id = StatementId.zero;
              kind = Assign (lv, rv);
              comments_before = [];
            }
          in
          (* Note that the new statements are in reverse order *)
          let statements = assign :: !new_statements in
          List.rev statements
        in

        (* Visit all the statements and decompose the literals *)
        let decompose_in_statement (st : statement) : statement list =
          match st.kind with
          | Assign (lv, rv) -> decompose_rvalue st.span lv rv
          | _ -> [ st ]
        in
        let body_body = map_statement decompose_in_statement body.body in
        StructuredBody
          {
            body with
            body = body_body;
            locals =
              {
                body.locals with
                locals = body.locals.locals @ List.rev !new_locals;
              };
          }
    | other -> other
  in
  { f with body }

(** Refresh the statement ids to make sure they are unique *)
let refresh_statement_ids (_ : crate) (f : fun_decl) : fun_decl =
  (* Map  *)
  let body =
    match f.body with
    | StructuredBody body ->
        let _, gen_id = StatementId.fresh_stateful_generator () in

        (* Visit the rvalue *)
        let visitor =
          object
            inherit [_] map_statement
            method! visit_statement_id _ _ = gen_id ()
          end
        in

        StructuredBody { body with body = visitor#visit_block () body.body }
    | other -> other
  in
  { f with body }

(** We simplify statements of the shape:
    {[
      x := from_str<'_>(const ("Error"));
      StorageDead ...;
      panic(core::panicking::panic_fmt)

        ~>

      panic(core::panicking::panic_fmt)
    ]}

    TODO: remove *)
let simplify_panics (crate : crate) (f : fun_decl) : fun_decl =
  let pats =
    [
      "core::fmt::{core::fmt::Arguments<'a>}::from_str";
      "core::fmt::{core::fmt::Arguments<'a>}::from_str_nonconst";
    ]
  in
  let pats = List.map (fun p -> (NameMatcher.parse_pattern p, ())) pats in
  (* TODO: we shouldn't need to use a names map *)
  let names_map = NameMatcher.NameMatcherMap.of_list pats in
  let match_ctx = Charon.NameMatcher.ctx_from_crate crate in
  let is_from_str (d : fun_decl) =
    let config = ExtractName.default_match_config in
    NameMatcher.NameMatcherMap.mem match_ctx config d.item_meta.name names_map
  in

  let visitor =
    object (self)
      inherit [_] map_statement

      method! visit_block env (block : block) =
        let is_from_str_call (st : statement) : bool =
          match st.kind with
          | Call ({ func = FnOpRegular { kind = Fun fid; _ }; _ }, _) -> (
              match FunDeclId.Map.find_opt fid crate.fun_decls with
              | Some decl -> is_from_str decl
              | None -> false)
          | _ -> false
        in

        let rec skip_storage_dead (stl : statement list) : statement list =
          match stl with
          | st :: stl -> (
              match st.kind with
              | StorageDead _ -> skip_storage_dead stl
              | _ -> st :: stl)
          | [] -> []
        in

        let rec update (stl : statement list) : statement list =
          match stl with
          | [] -> []
          | st0 :: stl when is_from_str_call st0 -> (
              match skip_storage_dead stl with
              | st1 :: stl1 -> (
                  match st1.kind with
                  | Panic _ -> self#visit_statement env st1 :: update stl1
                  | _ -> self#visit_statement env st0 :: update stl)
              | [] -> self#visit_statement env st0 :: update stl)
          | st0 :: stl -> self#visit_statement env st0 :: update stl
        in
        { block with statements = update block.statements }
    end
  in

  let body =
    match f.body with
    | StructuredBody body ->
        StructuredBody { body with body = visitor#visit_block () body.body }
    | other -> other
  in
  { f with body }

(** This micro-pass introduces intermediate assignments to access the global
    values in order to simplify the semantics.

    Whenever we access a constant, we introduce a shared borrow and a
    dereference. Ex.:

    {[
      let x = copy C;

        ~~>

      let tmp = &C;
      let x = copy *C;
    ]}

    Remark: we use the crate to lookup the type of the globals.

    TODO: generalize the evaluation of globals in the symbolic interpreter. *)
let decompose_global_accesses (crate : crate) (f : fun_decl) : fun_decl =
  (* Map  *)
  let body =
    match f.body with
    | StructuredBody body -> (
        let new_locals = ref [] in
        let _, gen =
          LocalId.mk_stateful_generator_starting_at_id
            (LocalId.of_int (List.length body.locals.locals))
        in
        let fresh_local ty =
          let local =
            {
              index = gen ();
              local_ty = ty;
              name = None;
              span = f.item_meta.span;
              drop_flag_for = None;
            }
          in
          new_locals := local :: !new_locals;
          local.index
        in

        (* Function to decompose the operands in a statement *)
        let decompose_in_statement (st : statement) : statement list =
          let span = st.span in
          let new_statements = ref [] in

          (* Visit the rvalue *)
          let visitor =
            object
              inherit [_] map_statement as super
              method! visit_place _ p = super#visit_place p.ty p

              method! visit_PlaceGlobal ty gref =
                (* Compute the type of the reference *)
                let ref_ty = TRef (RErased, ty, RShared) in

                (* Introduce the intermediate reference *)
                let local_id =
                  let local_id = fresh_local ref_ty in
                  let metadata = Constant mk_unit_const in
                  let st =
                    {
                      span;
                      statement_id = StatementId.zero;
                      kind =
                        Assign
                          ( { kind = PlaceLocal local_id; ty = ref_ty },
                            RvRef
                              ( { kind = PlaceGlobal gref; ty },
                                BShared,
                                metadata ) );
                      comments_before = [];
                    }
                  in
                  new_statements := st :: !new_statements;
                  local_id
                in

                (* Finally we can update the place *)
                PlaceProjection
                  ({ kind = PlaceLocal local_id; ty = ref_ty }, Deref)
            end
          in

          let kind =
            match st.kind with
            | Assign (lv, rv) -> Assign (lv, visitor#visit_rvalue mk_unit_ty rv)
            | Assert ({ cond; expected; check_kind }, on_failure, on_unwind) ->
                let cond = visitor#visit_operand mk_unit_ty cond in
                Assert ({ cond; expected; check_kind }, on_failure, on_unwind)
            | Call (({ func; args; _ } as call), on_unwind) ->
                let func = visitor#visit_fn_operand mk_unit_ty func in
                let args = List.map (visitor#visit_operand mk_unit_ty) args in
                Call ({ call with func; args }, on_unwind)
            | SetDiscriminant _ | StorageLive _ | StorageDead _ | PlaceMention _
            | Drop (_, _, _, _)
            | Panic _
            | UnwindTerminate
            | UndefinedBehavior
            | Return
            | UnwindResume
            | Break _
            | Continue _
            | Nop
            | Switch _
            | Loop _ -> st.kind
            | _ ->
                [%craise] st.span
                  ("unsupported statement: " ^ show_statement_kind st.kind)
          in
          let st = { st with kind } in

          List.rev (st :: !new_statements)
        in

        (* Visit all the statements and decompose the operands *)
        try
          let body_body = map_statement decompose_in_statement body.body in
          StructuredBody
            {
              body with
              body = body_body;
              locals =
                {
                  body.locals with
                  locals = body.locals.locals @ List.rev !new_locals;
                };
            }
        with CFailure error ->
          let mctx = Charon.NameMatcher.ctx_from_crate crate in
          let fmt_env = Print.crate_to_fmt_env crate in
          let name = Print.name_to_string fmt_env f.item_meta.name in
          let name_pattern =
            try
              let c : Charon.NameMatcher.to_pat_config =
                {
                  tgt = TkPattern;
                  use_trait_decl_refs = ExtractName.match_with_trait_decl_refs;
                }
              in
              let pat =
                LlbcAstUtils.name_to_pattern (Some f.item_meta.span) mctx c
                  f.item_meta.name
              in
              Charon.NameMatcher.pattern_to_string { tgt = TkPattern } pat
            with CFailure _ ->
              "(could not compute the name pattern due to a different error)"
          in
          [%save_error_opt_span] error.span
            ("Failure when pre- processing: " ^ name
           ^ "; ignoring its body.\nName pattern: '" ^ name_pattern ^ "'");
          OpaqueBody)
    | other -> other
  in
  { f with body }

(** We do not support static regions yet.

    In order to support some printing functions, for now we update their
    signature to replace ['static] with a region variable. This should be fine
    as a temporary measure as we can pretend these functions copy the input
    string they receive (the static references are references to strings).

    TODO: remove once https://github.com/AeneasVerif/aeneas/issues/727 is fixed
*)
let replace_static (crate : crate) : crate =
  (* We update the uses of: [core::fmt::{core::fmt::Arguments<'a>}::from_str] *)
  let pat =
    NameMatcher.parse_pattern "core::fmt::{core::fmt::Arguments<'a>}::from_str"
  in

  (* Find the function [core::fmt::{core::fmt::Arguments<'a>}::from_str]:
     - we want to update its signature to replace 'static with a lifetime variable
     - we want to update its uses
  *)
  let in_set (d : fun_decl) : bool =
    ExtractName.match_name crate pat d.item_meta.name
  in
  let decl_opt = ref None in
  let in_set (_ : FunDeclId.id) (d : fun_decl) =
    if in_set d then (
      decl_opt := Some d;
      true)
    else false
  in

  if not (FunDeclId.Map.exists in_set crate.fun_decls) then crate
  else (* The function [from_str] is used in the crate *)
    let d = Option.get !decl_opt in

    (* Update the signature *)
    let generics =
      {
        d.generics with
        regions =
          d.generics.regions
          @ [
              {
                index = RegionId.of_int 1;
                name = Some "'b";
                variance = VaUnknown;
                mutability = LtUnknown;
              };
            ];
      }
    in
    let signature =
      let visitor =
        object
          inherit [_] map_ty
          method! visit_RStatic _ = RVar (Free (RegionId.of_int 1))
        end
      in
      visitor#visit_fun_sig () d.signature
    in

    let d = { d with generics; signature } in
    [%ltrace
      let env = Print.crate_to_fmt_env crate in
      "Updated declaration:\n" ^ Print.fun_decl_to_string env "" " " d];
    let crate =
      { crate with fun_decls = FunDeclId.Map.add d.def_id d crate.fun_decls }
    in

    (* Update the uses of this definition *)
    let update (f : fun_decl) : fun_decl =
      match f.body with
      | StructuredBody body ->
          let visitor =
            object
              inherit [_] map_statement

              method! visit_Call _ call on_unwind =
                match call.func with
                | FnOpRegular { kind = Fun id as kind; generics }
                  when id = d.def_id ->
                    let func =
                      FnOpRegular
                        {
                          kind;
                          generics =
                            {
                              generics with
                              regions = generics.regions @ [ RErased ];
                            };
                        }
                    in
                    Call ({ call with func }, on_unwind)
                | _ -> Call (call, on_unwind)
            end
          in

          let body = { body with body = visitor#visit_block () body.body } in
          { f with body = StructuredBody body }
      | _ -> f
    in
    let fun_decls = FunDeclId.Map.map update crate.fun_decls in
    { crate with fun_decls }

(** Charon introduces vtables for the traits which support dyn. We do not want
    to translate the corresponding type and global declarations. Moreover, the
    presence of those declarations leads to mutually recursive groups of traits
    and types. This micro-pass filters these definitions. *)
let remove_vtables (crate : crate) : crate =
  let global_src_is_vtable (src : global_source) : bool =
    match src with
    | VTableInstanceGlobal _ -> true
    | _ -> false
  in
  let fun_src_is_vtable (src : fun_source) : bool =
    match src with
    | VTableShimFun -> true
    | GlobalInitializerFun global -> (
        match GlobalDeclId.Map.find_opt global.id crate.global_decls with
        | Some global -> global_src_is_vtable global.src
        | None -> false)
    | _ -> false
  in
  let type_src_is_vtable (src : type_source) : bool =
    match src with
    | VTableType _ -> true
    | _ -> false
  in

  (* Filter the groups.

     We detect mixed groups which combine trait declarations and their corresponding
     vtable types, and remove the vtable types (and convert the group to a homogeneous
     group if possible). We also filter the globals (and the functions corresponding
     to their implementation) introduced for the vtables.
  *)
  let declarations =
    List.filter_map
      (fun (g : declaration_group) ->
        match g with
        | GlobalGroup g -> (
            (* Filter the vtables *)
            let keep (id : global_decl_id) : bool =
              match GlobalDeclId.Map.find_opt id crate.global_decls with
              | None -> true
              | Some d -> not (global_src_is_vtable d.src)
            in
            match g with
            | RecGroup ids ->
                let ids = List.filter keep ids in
                if ids <> [] then Some (GlobalGroup (RecGroup ids)) else None
            | NonRecGroup id ->
                if keep id then Some (GlobalGroup (NonRecGroup id)) else None)
        | FunGroup g -> (
            (* Filter the vtables *)
            let keep (id : fun_decl_id) : bool =
              match FunDeclId.Map.find_opt id crate.fun_decls with
              | None -> true
              | Some d -> not (fun_src_is_vtable d.src)
            in
            match g with
            | RecGroup ids ->
                let ids = List.filter keep ids in
                if ids <> [] then Some (FunGroup (RecGroup ids)) else None
            | NonRecGroup id ->
                if keep id then Some (FunGroup (NonRecGroup id)) else None)
        | TypeGroup g -> (
            (* Filter the vtables *)
            let keep (id : type_decl_id) : bool =
              match TypeDeclId.Map.find_opt id crate.type_decls with
              | None -> true
              | Some d -> not (type_src_is_vtable d.src)
            in
            match g with
            | RecGroup ids ->
                let ids = List.filter keep ids in
                if ids <> [] then Some (TypeGroup (RecGroup ids)) else None
            | NonRecGroup id ->
                if keep id then Some (TypeGroup (NonRecGroup id)) else None)
        | MixedGroup g -> (
            (* If the group is a mutually recursive group, filter the vtable types
               and check if the resulting group is only made of trait declarations.

               TODO: we should check whether the resulting group is recursive or not.
            *)
            match g with
            | RecGroup ids ->
                let keep (id : type_decl_id) : bool =
                  match TypeDeclId.Map.find_opt id crate.type_decls with
                  | None -> true
                  | Some d -> not (type_src_is_vtable d.src)
                in
                let ids =
                  List.filter
                    (fun (id : item_id) ->
                      match id with
                      | IdType id -> keep id
                      | _ -> true)
                    ids
                in
                (* Note that the resulting group shouldn't be empty, but we can
                   still support this case *)
                if ids = [] then None
                else if
                  List.for_all
                    (fun (id : item_id) ->
                      match id with
                      | IdTraitDecl _ -> true
                      | _ -> false)
                    ids
                then
                  (* There only remains trait ids *)
                  let ids =
                    List.map
                      (fun (id : item_id) ->
                        match id with
                        | IdTraitDecl id -> id
                        | _ -> raise (Failure "Unreachable"))
                      ids
                  in
                  (* If the resulting group is a singleton, check whether
                     it is recursive *)
                  match ids with
                  | [ id ] ->
                      let is_rec =
                        match TraitDeclId.Map.find_opt id crate.trait_decls with
                        | None ->
                            (* don't know so by default we consider it to be recursive *)
                            true
                        | Some d ->
                            (* We count the number of occurrences of the id of the trait
                             decl itself - if it's > 1 then it means it is recursive
                             (there is one occurrence for the [def_id] field) *)
                            let found = ref 0 in
                            let visitor =
                              object (self)
                                inherit [_] iter_trait_decl

                                method! visit_trait_ref_contents _
                                    { kind; trait_decl_ref = _ } =
                                  (* We ignore the [trait_decl_ref] which refer
                                     to the trait declaration itself if this is
                                     an occurrence of [Self] *)
                                  self#visit_trait_ref_kind () kind

                                method! visit_trait_decl_id _ id' =
                                  if id' = id then found := !found + 1
                              end
                            in
                            visitor#visit_trait_decl () { d with vtable = None };
                            !found > 1
                      in
                      if is_rec then Some (TraitDeclGroup (RecGroup [ id ]))
                      else Some (TraitDeclGroup (NonRecGroup id))
                  | _ -> Some (TraitDeclGroup (RecGroup ids))
                else Some (MixedGroup (RecGroup ids))
            | _ -> Some (MixedGroup g))
        | _ -> Some g)
      (Option.get crate.declarations)
  in

  (* *)
  let type_decls =
    TypeDeclId.Map.filter
      (fun _ (d : type_decl) -> not (type_src_is_vtable d.src))
      crate.type_decls
  in

  let global_decls =
    GlobalDeclId.Map.filter
      (fun _ (d : global_decl) -> not (global_src_is_vtable d.src))
      crate.global_decls
  in

  let fun_decls =
    FunDeclId.Map.filter
      (fun _ (d : fun_decl) -> not (fun_src_is_vtable d.src))
      crate.fun_decls
  in

  let trait_decls =
    TraitDeclId.Map.map
      (fun (d : trait_decl) ->
        (* Remove the vtable *)
        { d with vtable = None })
      crate.trait_decls
  in

  {
    crate with
    declarations = Some declarations;
    type_decls;
    global_decls;
    fun_decls;
    trait_decls;
  }

let name_is_valid (n : string) : bool =
  let is_valid_char c =
    (c >= 'a' && c <= 'z')
    || (c >= 'A' && c <= 'Z')
    || (c >= '0' && c <= '9')
    || c = '_'
  in
  String.for_all is_valid_char n

(** The basename introduced by Charon for impl types (see
    https://github.com/AeneasVerif/charon/issues/1013) is an invalid name: we
    detect this case here and use a valid name instead. As it only happens for
    inputs of type `impl Trait` we use `Impl` as a basename. *)
let rename_type_vars (crate : crate) : crate =
  let visitor =
    object
      inherit [_] map_crate as super

      method! visit_generic_params env generics =
        (* Explore the types and rename them *)
        let num_renames =
          List.length
            (List.filter
               (fun (p : type_param) -> not (name_is_valid p.name))
               generics.types)
        in
        let rename =
          if num_renames > 1 then (
            let index = ref 0 in
            fun () ->
              let i = !index in
              index := !index + 1;
              "Impl" ^ string_of_int i)
          else fun () -> "Impl"
        in
        let types =
          List.map
            (fun (p : type_param) ->
              let name = if name_is_valid p.name then p.name else rename () in
              { p with name })
            generics.types
        in
        super#visit_generic_params env { generics with types }
    end
  in
  visitor#visit_crate () crate

(** Simplify calls to:
    - the blanket [IntoIterator::into_iter] implementation (we replace it with
      an assignment)
    - the blanket [TryInto::try_into] implementation (we replace it with a call
      to the [try_from] method of the required [TryFrom] clause)

    TODO: remove once we have partial monomorphization *)
let simplify_trait_calls (crate : crate) : crate =
  (* Create a map from pattern to method *)
  (* Blanket definition for [into_iter] *)
  let into_iter_pat =
    NameMatcher.parse_pattern
      "core::iter::traits::collect::{core::iter::traits::collect::IntoIterator<@I, \
       @Item, @I>}::into_iter"
  in
  (* Blanket definition for [try_into] *)
  let try_into_pat =
    NameMatcher.parse_pattern
      "core::convert::{core::convert::TryInto<@T, @U, @Error>}::try_into"
  in
  let match_pattern = ExtractName.match_name crate in
  let is_blanket_into_iter = match_pattern into_iter_pat in
  let is_blanket_try_into = match_pattern try_into_pat in

  let try_replace_call (super_visit : unit -> statement_kind) (span : Meta.span)
      (call : call) (on_unwind : block) : statement_kind =
    match call.func with
    | FnOpRegular { kind = Fun fid; generics } -> (
        match FunDeclId.Map.find_opt fid crate.fun_decls with
        | Some d
          when List.length generics.trait_refs > 0 && List.length call.args > 0
          ->
            if is_blanket_into_iter d.item_meta.name then (
              (* Replace the call by an assignment *)
              [%sanity_check] span (List.length call.args = 1);
              let arg = Use (List.hd call.args, NoRetag) in
              Assign (call.dest, arg))
            else if is_blanket_try_into d.item_meta.name then (
              [%ldebug
                "- call: " ^ call_to_string crate call ^ "\n- generics: "
                ^ generic_args_to_string crate generics];
              (* There should be a single trait ref implementing [TryFrom] *)
              match generics.trait_refs with
              | [ trait_ref ] -> (
                  (* There are two cases depending on whether this is an impl or not *)
                  match trait_ref.kind with
                  | TraitImpl { id = impl_id; generics = impl_generics } ->
                      (* Lookup the impl to retrieve the method id *)
                      let impl =
                        [%unwrap_with_span] span
                          (TraitImplId.Map.find_opt impl_id crate.trait_impls)
                          "Internal error"
                      in
                      (* The TryFrom trait has a single method (try_from) *)
                      let method_ref =
                        [%unwrap_with_span] span
                          (List.nth_opt
                             (TraitMethodId.Map.values impl.methods)
                             0)
                          "Internal error"
                      in

                      [%sanity_check] span
                        (method_ref.binder_params = empty_generic_params);

                      [%ldebug
                        "- call: " ^ call_to_string crate call
                        ^ "\n- generics: "
                        ^ generic_args_to_string crate generics
                        ^ "\n- impl.generic_params: "
                        ^ generic_params_to_string crate impl.generics
                        ^ "\n- impl_generics: "
                        ^ generic_args_to_string crate impl_generics
                        ^ "\n- method_ref.binder_params: "
                        ^ generic_params_to_string crate
                            method_ref.binder_params
                        ^ "\n- method_ref.binder_value: "
                        ^ fun_decl_ref_to_string crate method_ref.binder_value
                        ^ "\n "];

                      (* Instantiate *)
                      let subst =
                        [%add_loc] Substitute.make_subst_from_generics
                          (Some span) impl.generics impl_generics
                          (UnknownTrait "UNREACHABLE")
                      in
                      let generics =
                        Substitute.generic_args_substitute subst
                          method_ref.binder_value.generics
                      in

                      (* *)
                      let kind = Fun method_ref.binder_value.id in
                      let func = FnOpRegular { kind; generics } in
                      Call ({ call with func }, on_unwind)
                  | _ ->
                      (* TODO: *)
                      super_visit ())
              | _ -> [%internal_error] span)
            else super_visit ()
        | _ -> super_visit ())
    | _ -> super_visit ()
  in

  (* The map visitor to simplify the calls *)
  let visitor =
    object
      inherit [_] map_crate as super

      (* Keep track of the last span *)
      method! visit_statement _ st = super#visit_statement (Some st.span) st

      method! visit_Call span call on_unwind =
        try_replace_call
          (fun _ -> super#visit_Call span call on_unwind)
          (Option.get span) call on_unwind
    end
  in
  let crate = visitor#visit_crate None crate in

  (* Re-compute the set of used trait impls and fun declarations: by simplifying
     the calls we may have filtered some annoying ones

     Remark: the way we explore the crate is slightly approximative below.
     We should improve it.
  *)
  let used_impls = ref TraitImplId.Set.empty in
  let impls_to_explore = ref [] in
  let used_funs = ref FunDeclId.Set.empty in

  (* First explore the transparent functions *)
  let visitor =
    object
      inherit [_] iter_statement

      method! visit_trait_impl_id _ id =
        if not (TraitImplId.Set.mem id !used_impls) then (
          used_impls := TraitImplId.Set.add id !used_impls;
          impls_to_explore := id :: !impls_to_explore)

      method! visit_fun_decl_id _ id =
        used_funs := FunDeclId.Set.add id !used_funs
    end
  in
  FunDeclId.Map.iter
    (fun _ (f : fun_decl) ->
      if f.item_meta.is_local then visitor#visit_fun_decl_id () f.def_id;
      match f.body with
      | StructuredBody body -> visitor#visit_block () body.body
      | TargetDispatchBody targets ->
          List.iter
            (fun ((_ : string), (fdr : Types.fun_decl_ref)) ->
              visitor#visit_fun_decl_id () fdr.id)
            targets
      | _ -> ())
    crate.fun_decls;

  GlobalDeclId.Map.iter
    (fun _ (d : global_decl) -> visitor#visit_constant_expr () d.value)
    crate.global_decls;

  TraitDeclId.Map.iter
    (fun _ (d : trait_decl) ->
      TraitMethodId.Map.iter
        (fun _ (d : trait_method binder) ->
          Option.iter
            (fun (default : fun_decl_ref) ->
              visitor#visit_fun_decl_id () default.id)
            d.binder_value.default)
        d.methods)
    crate.trait_decls;

  (* Add the local trait impls *)
  TraitImplId.Map.iter
    (fun _ (d : trait_impl) ->
      if d.item_meta.is_local then visitor#visit_trait_impl_id () d.def_id)
    crate.trait_impls;

  (* Explore the impls *)
  while !impls_to_explore <> [] do
    let id = List.hd !impls_to_explore in
    impls_to_explore := List.tl !impls_to_explore;
    match TraitImplId.Map.find_opt id crate.trait_impls with
    | None -> ()
    | Some impl ->
        List.iter (visitor#visit_trait_ref ()) impl.implied_trait_refs;
        TraitMethodId.Map.iter
          (fun _ (x : fun_decl_ref binder) ->
            visitor#visit_fun_decl_id () x.binder_value.id)
          impl.methods
  done;

  (* Filter the declaration groups we want to extract *)
  let keep_group (gr : declaration_group) : bool =
    match gr with
    | TraitImplGroup (NonRecGroup id) ->
        if TraitImplId.Set.mem id !used_impls then true else false
    | TraitImplGroup (RecGroup ids) ->
        if List.exists (fun id -> TraitImplId.Set.mem id !used_impls) ids then
          true
        else false
    | FunGroup (NonRecGroup id) ->
        if FunDeclId.Set.mem id !used_funs then true else false
    | FunGroup (RecGroup ids) ->
        if List.exists (fun id -> FunDeclId.Set.mem id !used_funs) ids then true
        else false
    | _ -> true
  in
  let declarations =
    Some (List.filter keep_group (Option.get crate.declarations))
  in

  (* *)
  { crate with declarations }

(** Add missing outlives constraints for closure trait implementations.

    Charon sometimes fails to properly retrieves the lifetime constraints
    between the inputs and outputs of closures. This passes is a temporary
    (ad-hoc) fix for the following situation:
    {[
      call_mut<'a, 'b, 'c>(v@1 : &'c mut closure<'a>) -> &'b T
    ]}
    that we update to:
    {[
      call_mut<'b, 'c>(v@1 : &'c mut closure<'a>) -> &'a T
    ]}

    Similarly we do:
    {[
      call_once<'a, 'b>(v@1 : mut closure<'a>) -> &'b T
    ]}
    that we update to:
    {[
      call_once<'b, 'c>(v@1 : mut closure<'a>) -> &'a T
    ]}

    See https://github.com/AeneasVerif/aeneas/issues/804 and
    https://github.com/AeneasVerif/charon/issues/1040.

    TODO: remove once the Charon issue is fixed. *)
let fix_closure_lifetimes (crate : crate) (f : fun_decl) : fun_decl =
  (* Check that the function is a closure *)
  (* Decompose the type of the first argument (it should be the state).
     We do the update only if the state is inside a reference. *)
  let find_input_region (ty : ty) =
    match ty with
    | TAdt { id; generics = { regions = [ RVar rid ]; _ }; builtin = None }
    | TRef
        ( _,
          TAdt { id; generics = { regions = [ RVar rid ]; _ }; builtin = None },
          _ ) -> (
        match TypeDeclId.Map.find_opt id crate.type_decls with
        | Some decl -> (
            match decl.src with
            | ClosureType _ -> Some rid
            | _ -> None)
        | None -> None)
    | _ -> None
  in
  match f.signature.inputs with
  | [] -> f
  | first_input :: _ -> (
      match (find_input_region first_input, f.signature.output) with
      | Some input_rid, TRef (RVar _, ref_ty, kind) ->
          (* TODO: support more cases for the output? *)
          let output = TRef (RVar input_rid, ref_ty, kind) in
          (* Remark: we don't have to remove the region we substitute from the region
             parameters *)
          let signature = { f.signature with output } in
          let f = { f with signature } in
          [%ltrace
            let env = Print.crate_to_fmt_env crate in
            "Updated: " ^ Print.fun_decl_to_string env "" " " f];
          f
      | _, _ -> f)

(** Fill in erased lifetime arguments on closure types in function signatures.

    For example, the user may write:
    {[
      fn f<'a>(x: &'a u8) -> impl Fn() -> u8 + 'a {
        move || *x
      }
    ]}
    Charon resolves the opaque [impl Fn()] return type to the generated closure
    type, but leaves its lifetime argument erased:
    {[
      struct f::closure<'a> {
        _0 : &'a u8,
      }

      fn f<'a>(x : &'a u8) -> make::closure<'_>
    ]}
    The return type should instead be [f::closure<'a>].

    We can repair the signature when it binds exactly one region parameter: in
    that case every erased region argument of a closure type must refer to that
    region. With several region parameters, we cannot determine which lifetime
    the closure captured and leave the signature unchanged. Also note that the
    closure type may be nested inside another type, such as
    [Map<Range<i32>, f::closure<'_>>], so we have to be quite general.

    This complements [fix_closure_lifetimes], which repairs the generated
    closure methods rather than the function creating the closure.

    See https://github.com/AeneasVerif/charon/issues/1040 and
    https://github.com/AeneasVerif/aeneas/issues/1207.

    TODO: remove once the Charon issue is fixed. *)
let fix_closure_signature_regions (crate : crate) (f : fun_decl) : fun_decl =
  match f.generics.regions with
  | [ rp ] ->
      (* Only one region parameter: we can eventually fix *)
      let region = RVar (Free rp.index) in
      let updated = ref false in
      let is_closure_ty (id : TypeDeclId.id) : bool =
        match TypeDeclId.Map.find_opt id crate.type_decls with
        | Some { src = ClosureType _; _ } -> true
        | _ -> false
      in
      let visitor =
        object
          inherit [_] map_ty as super

          method! visit_TAdt env tref =
            let tref =
              if is_closure_ty tref.id then
                let regions =
                  List.map
                    (fun region0 ->
                      match region0 with
                      | RErased ->
                          updated := true;
                          region
                      | _ -> region0)
                    tref.generics.regions
                in
                { tref with generics = { tref.generics with regions } }
              else tref
            in
            super#visit_TAdt env tref
        end
      in
      let inputs = List.map (visitor#visit_ty ()) f.signature.inputs in
      let output = visitor#visit_ty () f.signature.output in
      (* A result that carries a closure is an [impl Trait] Charon resolved, and
         its other erased regions (e.g. [Iter<'_, T>] around the closure, or the
         [&'_ T] it yields) are elided lifetimes too: with a single lifetime
         parameter, they are that one. *)
      let output =
        if !updated then
          let visitor =
            object
              inherit [_] map_ty

              method! visit_region _ r =
                match r with
                | RErased -> region
                | _ -> r
            end
          in
          visitor#visit_ty () output
        else output
      in
      if !updated then begin
        let signature = { f.signature with inputs; output } in
        let f = { f with signature } in
        [%ltrace
          let env = Print.crate_to_fmt_env crate in
          "Updated: " ^ Print.fun_decl_to_string env "" " " f];
        f
      end
      else f
  | _ -> f

(** Let a closure's output borrow from anything the closure receives.

    Charon gives a closure method's output lifetimes as fresh parameters,
    unrelated to the inputs (https://github.com/AeneasVerif/charon/issues/1040):
    for [xs.iter().flat_map(|v| v.iter().map(f))] we get
    {[
      call_mut<'0, '1, '2>(state : &'2 mut closure, args : (&'0 Vec<u32>,))
        -> Map<Iter<'1, u32>, f>
    ]}
    although the result borrows from ['0]. Symbolic execution must then end ['0]
    before returning, which it cannot do with an input region.
    [fix_closure_lifetimes] repairs the case of a single captured region and a
    bare reference output; here, for every output region that no input mentions,
    we add the outlives bounds ['r : 'out] for every region ['r] the closure
    receives (captured in its state, or in its arguments). This is exactly what
    Rust allows: the result may borrow from any of them, for at most as long as
    each lives. The region of the [&mut] or [&] borrow of the state itself is
    excluded, as [Fn]/[FnMut] results cannot borrow from it.

    TODO: remove once the Charon issue is fixed. *)
let fix_closure_output_outlives (crate : crate) (f : fun_decl) : fun_decl =
  let is_closure (id : TypeDeclId.id) : bool =
    match TypeDeclId.Map.find_opt id crate.type_decls with
    | Some { src = ClosureType _; _ } -> true
    | _ -> false
  in
  let free_regions (tys : ty list) : RegionId.Set.t =
    let acc = ref RegionId.Set.empty in
    let visitor =
      object
        inherit [_] iter_ty

        method! visit_region _ r =
          match r with
          | RVar (Free rid) -> acc := RegionId.Set.add rid !acc
          | _ -> ()
      end
    in
    List.iter (visitor#visit_ty ()) tys;
    !acc
  in
  match f.signature.inputs with
  | state :: args -> (
      (* The state, possibly behind the [&]/[&mut] of [call]/[call_mut] *)
      let state_ty =
        match state with
        | TAdt { id; _ } when is_closure id -> Some state
        | TRef (_, (TAdt { id; _ } as ty), _) when is_closure id -> Some ty
        | _ -> None
      in
      match state_ty with
      | None -> f
      | Some state_ty ->
          let all_inputs = free_regions f.signature.inputs in
          (* Erased regions in the result (e.g. the lifetimes of an inner closure
             type, [Map<Iter<'1, T>, closure::closure<'_, '_>>]): give them a region
             parameter the inputs do not mention, preferably one the result already
             uses; Charon declares spare ones. *)
          let f =
            let spare =
              let in_output = free_regions [ f.signature.output ] in
              let candidates =
                List.filter
                  (fun (r : region_param) ->
                    not (RegionId.Set.mem r.index all_inputs))
                  f.generics.regions
              in
              match
                List.find_opt
                  (fun (r : region_param) -> RegionId.Set.mem r.index in_output)
                  candidates
              with
              | Some r -> Some r.index
              | None -> (
                  match candidates with
                  | r :: _ -> Some r.index
                  | [] -> None)
            in
            match spare with
            | None -> f
            | Some spare ->
                let visitor =
                  object
                    inherit [_] map_ty

                    method! visit_region _ r =
                      match r with
                      | RErased -> RVar (Free spare)
                      | _ -> r
                  end
                in
                let output = visitor#visit_ty () f.signature.output in
                { f with signature = { f.signature with output } }
          in
          let received = free_regions (state_ty :: args) in
          let outs =
            RegionId.Set.diff (free_regions [ f.signature.output ]) all_inputs
          in
          if RegionId.Set.is_empty outs || RegionId.Set.is_empty received then f
          else
            let preds =
              List.concat_map
                (fun out ->
                  List.map
                    (fun r ->
                      {
                        binder_regions = [];
                        binder_value = (RVar (Free r), RVar (Free out));
                      })
                    (RegionId.Set.elements received))
                (RegionId.Set.elements outs)
            in
            let generics =
              {
                f.generics with
                regions_outlive = f.generics.regions_outlive @ preds;
              }
            in
            let f = { f with generics } in
            [%ltrace
              let env = Print.crate_to_fmt_env crate in
              "Updated: " ^ Print.fun_decl_to_string env "" " " f];
            f)
  | [] -> f

(** Identify associated types reached through several bounds (a diamond).

    Charon's [--remove-associated-types] turns each associated type into a type
    parameter per path that reaches it, without noticing when two paths reach
    the same predicate (a documented limitation of its
    [expand_associated_types]): with
    [F: WithSmallOrderMulGroup<3> + FromUniformBytes<64>], both bounds imply
    [F: PrimeField], and [<F as PrimeField>::Repr] becomes two unrelated
    parameters [Clause2_Clause0_Repr] and [Clause5_Clause0_Repr]. Calls then
    fail to type-check ("The input arguments don't have the proper type").

    By coherence, two references to the same trait with the same arguments other
    than its associated types denote the same impl, so their associated types
    are equal. For every function, we gather the trait references its bounds
    imply (transitively through the traits' implied clauses), group them by
    trait and non-associated arguments, and identify the function's own type
    parameters that stand for the same associated type. Associated-type
    parameters of a trait are recognised by Charon's naming, [Self_<path>].

    TODO: remove once Charon identifies them. *)
let unify_diamond_assoc_types (crate : crate) (f : fun_decl) : fun_decl =
  (* Only the crate's own functions: a library function keeps the signature its
     Lean model was written for (e.g. [Iterator::rev]'s default, modelled with
     both [Item]s), or calls to it would pass the merged parameter explicitly. *)
  if not f.item_meta.is_local then f
  else
    let is_assoc (p : type_param) =
      String.length p.name > 5 && String.sub p.name 0 5 = "Self_"
    in
    (* The trait references implied by the bounds, with their declarations *)
    let refs = ref [] in
    let rec explore (depth : int) (tr : trait_decl_ref) =
      if depth <= 16 then
        match TraitDeclId.Map.find_opt tr.id crate.trait_decls with
        | None -> ()
        | Some d ->
            refs := (tr, d) :: !refs;
            let subst =
              [%add_loc] Substitute.make_subst_from_generics None d.generics
                tr.generics Self
            in
            List.iter
              (fun (c : trait_param) ->
                explore (depth + 1)
                  (Substitute.trait_decl_ref_substitute subst
                     c.trait.binder_value))
              d.implied_clauses
    in
    (try
       List.iter
         (fun (c : trait_param) -> explore 0 c.trait.binder_value)
         f.generics.trait_clauses
     with Invalid_argument _ -> refs := []);
    (* Union-find over the function's type variables *)
    let parent = Hashtbl.create 8 in
    let rec find id =
      match Hashtbl.find_opt parent id with
      | Some p when p <> id -> find p
      | _ -> id
    in
    let union a b =
      let a = find a and b = find b in
      if a <> b then
        if TypeVarId.compare_id a b < 0 then Hashtbl.replace parent b a
        else Hashtbl.replace parent a b
    in
    let split ((tr, d) : trait_decl_ref * trait_decl) =
      if List.length d.generics.types <> List.length tr.generics.types then None
      else
        let pairs = List.combine d.generics.types tr.generics.types in
        let key =
          ( tr.id,
            List.filter_map
              (fun (p, t) -> if is_assoc p then None else Some t)
              pairs,
            tr.generics.const_generics )
        in
        Some
          ( key,
            List.filter_map
              (fun (p, t) -> if is_assoc p then Some t else None)
              pairs )
    in
    let groups = Hashtbl.create 8 in
    List.iter
      (fun r ->
        match split r with
        | None -> ()
        | Some (key, assoc) -> (
            match Hashtbl.find_opt groups key with
            | None -> Hashtbl.add groups key assoc
            | Some assoc0 ->
                List.iter2
                  (fun t0 t ->
                    match (t0, t) with
                    | TVar (Free a), TVar (Free b) -> union a b
                    | _ -> ())
                  assoc0 assoc))
      !refs;
    if Hashtbl.length parent = 0 then f
    else
      let visitor =
        object
          inherit [_] map_crate as super

          method! visit_TVar env var =
            match var with
            | Free id -> TVar (Free (find id))
            | _ -> super#visit_TVar env var
        end
      in
      let f = visitor#visit_fun_decl () f in
      [%ltrace
        let env = Print.crate_to_fmt_env crate in
        "Updated: " ^ Print.fun_decl_to_string env "" " " f];
      f

(** Normalise function-item types: no binder, ['static] regions.

    A function item (e.g. [Ord::cmp] passed to [max_by]) holds no data, so the
    regions in its type - its signature's, including those it binds itself
    ([for<'a, 'b> Ord::cmp<'a, 'b>]) - constrain no borrow. Bodies give them
    erased, signatures bound or free, and the borrow machinery expects neither
    in a value's type; making them all ['static] lets every check see the same
    type. Function items are not otherwise compared by their regions. *)
let normalize_fn_def_types (crate : crate) : crate =
  let static_regions =
    object
      inherit [_] map_ty
      method! visit_region _ _ = RStatic
    end
  in
  let visitor =
    object
      inherit [_] map_crate as super

      method! visit_ty env ty =
        match ty with
        | TFnDef { binder_regions = _; binder_value } ->
            TFnDef
              {
                binder_regions = [];
                binder_value = static_regions#visit_fn_ptr () binder_value;
              }
        | _ -> super#visit_ty env ty
    end
  in
  visitor#visit_crate () crate

(** Make sure [Option] is in the declaration groups when it is in the crate.

    [lift_nested_loop_exits] carries the value of a [return] out of nested loops
    in an [Option], which the crate may not otherwise use; Charon then has its
    declaration but no group for it, and the type analysis (which goes over the
    groups) would not know it. *)
let declare_option (crate : crate) : crate =
  let pat = NameMatcher.parse_pattern "core::option::Option" in
  let match_name = ExtractName.match_name crate in
  match
    List.find_opt
      (fun (d : type_decl) -> match_name pat d.item_meta.name)
      (TypeDeclId.Map.values crate.type_decls)
  with
  | None -> crate
  | Some d ->
      let declarations = Option.value ~default:[] crate.declarations in
      let declared =
        List.exists
          (fun (g : declaration_group) ->
            match g with
            | TypeGroup (NonRecGroup id) -> id = d.def_id
            | TypeGroup (RecGroup ids) -> List.mem d.def_id ids
            | _ -> false)
          declarations
      in
      if declared then crate
      else
        {
          crate with
          declarations = Some (TypeGroup (NonRecGroup d.def_id) :: declarations);
        }

let apply_passes (crate : crate) : crate =
  (* Passes that apply to the whole crate *)
  let crate = update_array_default crate in
  let crate = normalize_fn_def_types crate in
  let crate = declare_option crate in
  (* Passes that apply to individual function bodies *)
  let function_passes =
    [
      ("fix_closure_lifetimes", fix_closure_lifetimes);
      ("fix_closure_signature_regions", fix_closure_signature_regions);
      ("fix_closure_output_outlives", fix_closure_output_outlives);
      ("unify_diamond_assoc_types", unify_diamond_assoc_types);
      ("erase_body_regions", erase_body_regions);
      ("remove_unreachable", remove_unreachable);
      ("lift_nested_loop_exits", lift_nested_loop_exits);
      ("update_loop", update_loops);
      ("remove_useless_joins", remove_useless_joins);
      ( "remove_shallow_borrows_storage_live_dead",
        remove_shallow_borrows_storage_live_dead );
      ("decompose_str_borrows", decompose_str_borrows);
      ("simplify_panics", simplify_panics);
      ("decompose_global_accesses", decompose_global_accesses);
      ("refresh_statement_ids", refresh_statement_ids);
    ]
  in
  (* Attempt to apply a pass: if it fails we replace the body by [None] *)
  let apply_function_pass (pass_name : string)
      (pass : crate -> fun_decl -> fun_decl) (f : fun_decl) =
    try
      let f = pass crate f in
      [%ltrace
        let env = Print.crate_to_fmt_env crate in
        "After applying [" ^ pass_name ^ "]:\n"
        ^ Print.fun_decl_to_string env "" " " f];
      f
    with CFailure e ->
      (* The error was already registered, we don't need to register it twice.
         However, we replace the body of the function, and save an error to
         report to the user the fact that we will ignore the function body *)
      let fmt = Print.crate_to_fmt_env crate in
      let name = Print.name_to_string fmt f.item_meta.name in
      [%save_error] f.item_meta.span
        ("Ignoring the body of '" ^ name ^ "' because of previous error");
      let msg =
        Errors.format_error_message_with_file_line e.file e.line e.span e.msg
      in
      { f with body = ErrorBody { span = f.item_meta.span; msg } }
  in
  let fun_decls : fun_decl FunDeclId.Map.t =
    let num_decls = FunDeclId.Map.cardinal crate.fun_decls in
    ProgressBar.with_reporter num_decls "Applied prepasses: " (fun report ->
        FunDeclId.Map.map
          (fun f ->
            [%ltrace
              let env = Print.crate_to_fmt_env crate in
              "Before applying the prepasses:\n"
              ^ Print.fun_decl_to_string env "" " " f];
            let f : fun_decl =
              List.fold_left
                (fun f (name, pass) -> apply_function_pass name pass f)
                f function_passes
            in
            report 1;
            f)
          crate.fun_decls)
  in
  let crate = { crate with fun_decls } in
  let crate = strip_unnecessary_target_suffixes crate in
  let crate = filter_marker_traits crate in
  let crate = filter_type_aliases crate in
  let crate = replace_static crate in
  let crate = remove_vtables crate in
  let crate = rename_type_vars crate in
  let crate = simplify_trait_calls crate in
  [%ltrace "After pre-passes:\n" ^ Print.crate_to_string crate ^ "\n"];
  crate
