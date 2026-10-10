(** THIS FILE WAS AUTOMATICALLY GENERATED FROM LEAN: DO NOT MODIFY DIRECTLY *)
open ExtractBuiltinCore

let lean_builtin_types =
  [
    (* file: "Aeneas/Std/Alloc.lean", line: 18 *)
    mk_type "alloc::alloc::Global" "Global" ~kind:(KEnum [ ("Mk", Some "mk") ]);
    (* file: "Aeneas/Std/BTree.lean", line: 37 *)
    mk_type "alloc::collections::btree::map::BTreeMap"
      "alloc.collections.btree.map.BTreeMap";
    (* file: "Aeneas/Std/BTree.lean", line: 208 *)
    mk_type "alloc::collections::btree::map::IntoIter"
      "alloc.collections.btree.map.IntoIter";
    (* file: "Aeneas/Std/BTree.lean", line: 163 *)
    mk_type "alloc::collections::btree::map::Iter"
      "alloc.collections.btree.map.Iter";
    (* file: "Aeneas/Std/BTree.lean", line: 101 *)
    mk_type "alloc::collections::btree::map::entry::Entry"
      "alloc.collections.btree.map.entry.Entry" ~mut_regions:[ 0 ];
    (* file: "Aeneas/Std/BTree.lean", line: 107 *)
    mk_type "alloc::collections::btree::map::entry::OccupiedEntry"
      "alloc.collections.btree.map.entry.OccupiedEntry" ~mut_regions:[ 0 ];
    (* file: "Aeneas/Std/BTree.lean", line: 111 *)
    mk_type "alloc::collections::btree::map::entry::VacantEntry"
      "alloc.collections.btree.map.entry.VacantEntry" ~mut_regions:[ 0 ];
    (* file: "Aeneas/Std/BTree.lean", line: 318 *)
    mk_type "alloc::collections::btree::set::BTreeSet"
      "alloc.collections.btree.set.BTreeSet";
    (* file: "Aeneas/Std/BTree.lean", line: 322 *)
    mk_type "alloc::collections::btree::set::IntoIter"
      "alloc.collections.btree.set.IntoIter";
    (* file: "Aeneas/Std/Alloc.lean", line: 13 *)
    mk_type "alloc::string::String" "String";
    (* file: "Aeneas/Std/Vec.lean", line: 30 *)
    mk_type "alloc::vec::Vec" "alloc.vec.Vec"
      ~kind:(KStruct [ ("slice", Some "slice") ]);
    (* file: "Aeneas/Std/VecIter.lean", line: 10 *)
    mk_type "alloc::vec::into_iter::IntoIter" "alloc.vec.into_iter.IntoIter"
      ~keep_params:(Some [ true; false ]);
    (* file: "Aeneas/Std/Core/Ptr.lean", line: 80 *)
    mk_type "core::alloc::layout::Layout" "core.alloc.layout.Layout"
      ~kind:(KStruct [ ("size", Some "size"); ("align", Some "align") ]);
    (* file: "Aeneas/Std/Array/ArraySlice.lean", line: 126 *)
    mk_type "core::array::TryFromSliceError" "core.array.TryFromSliceError";
    (* file: "Aeneas/Std/Core/IterOverrides.lean", line: 22 *)
    mk_type "core::array::iter::IntoIter" "core.array.iter.IntoIter";
    (* file: "Aeneas/Std/Core/Cmp.lean", line: 62 *)
    mk_type "core::cmp::Ordering" "Ordering"
      ~kind:
        (KEnum
           [ ("Less", Some "lt"); ("Equal", Some "eq"); ("Greater", Some "gt") ]);
    (* file: "Aeneas/Std/Core/Fmt.lean", line: 49 *)
    mk_type "core::fmt::Arguments" "core.fmt.Arguments";
    (* file: "Aeneas/Std/Core/Fmt.lean", line: 10 *)
    mk_type "core::fmt::Error" "core.fmt.Error";
    (* file: "Aeneas/Std/Core/Fmt.lean", line: 14 *)
    mk_type "core::fmt::Formatter" "core.fmt.Formatter";
    (* file: "Aeneas/Std/Core/Fmt.lean", line: 52 *)
    mk_type "core::fmt::rt::Argument" "core.fmt.rt.Argument";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 348 *)
    mk_type "core::iter::adapters::chain::Chain"
      "core.iter.adapters.chain.Chain"
      ~kind:(KStruct [ ("a", Some "a"); ("b", Some "b") ]);
    (* file: "Aeneas/Std/Core/Iter.lean", line: 41 *)
    mk_type "core::iter::adapters::enumerate::Enumerate"
      "core.iter.adapters.enumerate.Enumerate"
      ~kind:(KStruct [ ("iter", Some "iter"); ("count", Some "count") ]);
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 200 *)
    mk_type "core::iter::adapters::filter::Filter"
      "core.iter.adapters.filter.Filter"
      ~kind:(KStruct [ ("iter", Some "iter"); ("predicate", Some "predicate") ]);
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 278 *)
    mk_type "core::iter::adapters::filter_map::FilterMap"
      "core.iter.adapters.filter_map.FilterMap"
      ~kind:(KStruct [ ("iter", Some "iter"); ("f", Some "f") ]);
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 442 *)
    mk_type "core::iter::adapters::flatten::FlatMap"
      "core.iter.adapters.flatten.FlatMap";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 1077 *)
    mk_type "core::iter::adapters::map::Map" "core.iter.adapters.map.Map"
      ~kind:(KStruct [ ("iter", Some "iter"); ("f", Some "f") ]);
    (* file: "Aeneas/Std/Core/Iter.lean", line: 51 *)
    mk_type "core::iter::adapters::rev::Rev" "core.iter.adapters.rev.Rev"
      ~kind:(KStruct [ ("iter", Some "iter") ]);
    (* file: "Aeneas/Std/Core/Iter.lean", line: 35 *)
    mk_type "core::iter::adapters::step_by::StepBy"
      "core.iter.adapters.step_by.StepBy";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 46 *)
    mk_type "core::iter::adapters::take::Take" "core.iter.adapters.take.Take"
      ~kind:(KStruct [ ("iter", Some "iter"); ("n", Some "n") ]);
    (* file: "Aeneas/Std/Core/Iter.lean", line: 55 *)
    mk_type "core::iter::adapters::take_while::TakeWhile"
      "core.iter.adapters.take_while.TakeWhile"
      ~kind:
        (KStruct
           [
             ("iter", Some "iter");
             ("flag", Some "flag");
             ("predicate", Some "predicate");
           ]);
    (* file: "Aeneas/Std/Core/Iter.lean", line: 65 *)
    mk_type "core::iter::adapters::zip::Zip" "core.iter.adapters.zip.Zip"
      ~kind:(KStruct [ ("fst", Some "fst"); ("snd", Some "snd") ]);
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 582 *)
    mk_type "core::iter::sources::empty::Empty" "core.iter.sources.empty.Empty";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 554 *)
    mk_type "core::iter::sources::once::Once" "core.iter.sources.once.Once";
    (* file: "Aeneas/Std/CoreMisc.lean", line: 125 *)
    mk_type "core::marker::PhantomData" "core.marker.PhantomData";
    (* file: "Aeneas/Std/Scalar/CoreConvertNum.lean", line: 805 *)
    mk_type "core::num::error::TryFromIntError" "core.num.error.TryFromIntError";
    (* file: "Aeneas/Std/Core/Ops.lean", line: 92 *)
    mk_type "core::ops::control_flow::ControlFlow"
      "core.ops.control_flow.ControlFlow"
      ~kind:(KEnum [ ("Continue", Some "Continue"); ("Break", Some "Break") ]);
    (* file: "Aeneas/Std/Range.lean", line: 16 *)
    mk_type "core::ops::range::Range" "core.ops.range.Range"
      ~kind:(KStruct [ ("start", Some "start"); ("end", Some "end") ]);
    (* file: "Aeneas/Std/Core/Core.lean", line: 126 *)
    mk_type "core::ops::range::RangeFrom" "core.ops.range.RangeFrom"
      ~kind:(KStruct [ ("start", Some "start") ]);
    (* file: "Aeneas/Std/Range.lean", line: 31 *)
    mk_type "core::ops::range::RangeFull" "core.ops.range.RangeFull";
    (* file: "Aeneas/Std/Range.lean", line: 39 *)
    mk_type "core::ops::range::RangeInclusive" "core.ops.range.RangeInclusive"
      ~kind:
        (KStruct
           [
             ("start", Some "start");
             ("end", Some "end");
             ("exhausted", Some "exhausted");
           ]);
    (* file: "Aeneas/Std/Range.lean", line: 22 *)
    mk_type "core::ops::range::RangeTo" "core.ops.range.RangeTo"
      ~kind:(KStruct [ ("end", Some "end") ]);
    (* file: "Aeneas/Std/Core/Core.lean", line: 15 *)
    mk_type "core::option::Option" "Option" ~prefix_variant_names:false
      ~kind:(KEnum [ ("None", Some "none"); ("Some", Some "some") ]);
    (* file: "Aeneas/Std/Core/Panic.lean", line: 8 *)
    mk_type "core::panic::panic_info::PanicInfo"
      "core.panic.panic_info.PanicInfo";
    (* file: "Aeneas/Std/Core/Core.lean", line: 130 *)
    mk_type "core::panicking::AssertKind" "core.panicking.AssertKind"
      ~kind:
        (KEnum [ ("Eq", Some "Eq"); ("Ne", Some "Ne"); ("Match", Some "Match") ]);
    (* file: "Aeneas/Std/Core/Pin.lean", line: 8 *)
    mk_type "core::pin::Pin" "core.pin.Pin";
    (* file: "Aeneas/Std/Core/Pin.lean", line: 12 *)
    mk_type "core::pin::helper::PinHelper" "core.pin.helper.PinHelper";
    (* file: "Aeneas/Std/Core/Ptr.lean", line: 76 *)
    mk_type "core::ptr::alignment::Alignment" "core.ptr.alignment.Alignment";
    (* file: "Aeneas/Std/Core/Ptr.lean", line: 9 *)
    mk_type "core::ptr::alignment::AlignmentEnum"
      "core.ptr.alignment.AlignmentEnum"
      ~kind:
        (KEnum
           [
             ("_Align1Shl0", Some "_Align1Shl0");
             ("_Align1Shl1", Some "_Align1Shl1");
             ("_Align1Shl2", Some "_Align1Shl2");
             ("_Align1Shl3", Some "_Align1Shl3");
             ("_Align1Shl4", Some "_Align1Shl4");
             ("_Align1Shl5", Some "_Align1Shl5");
             ("_Align1Shl6", Some "_Align1Shl6");
             ("_Align1Shl7", Some "_Align1Shl7");
             ("_Align1Shl8", Some "_Align1Shl8");
             ("_Align1Shl9", Some "_Align1Shl9");
             ("_Align1Shl10", Some "_Align1Shl10");
             ("_Align1Shl11", Some "_Align1Shl11");
             ("_Align1Shl12", Some "_Align1Shl12");
             ("_Align1Shl13", Some "_Align1Shl13");
             ("_Align1Shl14", Some "_Align1Shl14");
             ("_Align1Shl15", Some "_Align1Shl15");
             ("_Align1Shl16", Some "_Align1Shl16");
             ("_Align1Shl17", Some "_Align1Shl17");
             ("_Align1Shl18", Some "_Align1Shl18");
             ("_Align1Shl19", Some "_Align1Shl19");
             ("_Align1Shl20", Some "_Align1Shl20");
             ("_Align1Shl21", Some "_Align1Shl21");
             ("_Align1Shl22", Some "_Align1Shl22");
             ("_Align1Shl23", Some "_Align1Shl23");
             ("_Align1Shl24", Some "_Align1Shl24");
             ("_Align1Shl25", Some "_Align1Shl25");
             ("_Align1Shl26", Some "_Align1Shl26");
             ("_Align1Shl27", Some "_Align1Shl27");
             ("_Align1Shl28", Some "_Align1Shl28");
             ("_Align1Shl29", Some "_Align1Shl29");
             ("_Align1Shl30", Some "_Align1Shl30");
             ("_Align1Shl31", Some "_Align1Shl31");
             ("_Align1Shl32", Some "_Align1Shl32");
             ("_Align1Shl33", Some "_Align1Shl33");
             ("_Align1Shl34", Some "_Align1Shl34");
             ("_Align1Shl35", Some "_Align1Shl35");
             ("_Align1Shl36", Some "_Align1Shl36");
             ("_Align1Shl37", Some "_Align1Shl37");
             ("_Align1Shl38", Some "_Align1Shl38");
             ("_Align1Shl39", Some "_Align1Shl39");
             ("_Align1Shl40", Some "_Align1Shl40");
             ("_Align1Shl41", Some "_Align1Shl41");
             ("_Align1Shl42", Some "_Align1Shl42");
             ("_Align1Shl43", Some "_Align1Shl43");
             ("_Align1Shl44", Some "_Align1Shl44");
             ("_Align1Shl45", Some "_Align1Shl45");
             ("_Align1Shl46", Some "_Align1Shl46");
             ("_Align1Shl47", Some "_Align1Shl47");
             ("_Align1Shl48", Some "_Align1Shl48");
             ("_Align1Shl49", Some "_Align1Shl49");
             ("_Align1Shl50", Some "_Align1Shl50");
             ("_Align1Shl51", Some "_Align1Shl51");
             ("_Align1Shl52", Some "_Align1Shl52");
             ("_Align1Shl53", Some "_Align1Shl53");
             ("_Align1Shl54", Some "_Align1Shl54");
             ("_Align1Shl55", Some "_Align1Shl55");
             ("_Align1Shl56", Some "_Align1Shl56");
             ("_Align1Shl57", Some "_Align1Shl57");
             ("_Align1Shl58", Some "_Align1Shl58");
             ("_Align1Shl59", Some "_Align1Shl59");
             ("_Align1Shl60", Some "_Align1Shl60");
             ("_Align1Shl61", Some "_Align1Shl61");
             ("_Align1Shl62", Some "_Align1Shl62");
             ("_Align1Shl63", Some "_Align1Shl63");
           ]);
    (* file: "Aeneas/Std/Core/Result.lean", line: 7 *)
    mk_type "core::result::Result" "core.result.Result"
      ~kind:(KEnum [ ("Ok", Some "Ok"); ("Err", Some "Err") ]);
    (* file: "Aeneas/Std/Core/IterOverrides.lean", line: 251 *)
    mk_type "core::slice::iter::Chunks" "core.slice.iter.Chunks"
      ~kind:(KStruct [ ("v", Some "v"); ("chunk_size", Some "chunk_size") ]);
    (* file: "Aeneas/Std/SliceIter.lean", line: 190 *)
    mk_type "core::slice::iter::ChunksExact" "core.slice.iter.ChunksExact";
    (* file: "Aeneas/Std/SliceIter.lean", line: 20 *)
    mk_type "core::slice::iter::Iter" "core.slice.iter.Iter"
      ~kind:(KStruct [ ("slice", Some "slice"); ("i", Some "i") ]);
    (* file: "Aeneas/Std/SliceIter.lean", line: 27 *)
    mk_type "core::slice::iter::IterMut" "core.slice.iter.IterMut"
      ~mut_regions:[ 0 ];
    (* file: "Aeneas/Std/StringIter.lean", line: 9 *)
    mk_type "core::str::iter::Chars" "core.str.iter.Chars";
    (* file: "Aeneas/Std/Core/Atomic.lean", line: 8 *)
    mk_type "core::sync::atomic::AtomicBool" "core.sync.atomic.AtomicBool";
    (* file: "Aeneas/Std/Core/Atomic.lean", line: 12 *)
    mk_type "core::sync::atomic::AtomicU32" "core.sync.atomic.AtomicU32";
  ]

let lean_builtin_consts = []

let lean_builtin_funs =
  [
    (* file: "Aeneas/Std/Alloc.lean", line: 27 *)
    mk_fun "alloc::alloc::{core::clone::Clone<alloc::alloc::Global>}::clone"
      "alloc.alloc.CloneGlobal.clone";
    (* file: "Aeneas/Std/Core/Core.lean", line: 52 *)
    mk_fun "alloc::boxed::{core::clone::Clone<Box<@T>>}::clone"
      "core.alloc.boxed.CloneBox.clone"
      ~keep_params:(Some [ true; false ])
      ~keep_trait_clauses:(Some [ true; false ]);
    (* file: "Aeneas/Std/Core/Cmp.lean", line: 297 *)
    mk_fun "alloc::boxed::{core::cmp::PartialEq<Box<@T>, Box<@T>>}::eq"
      "alloc.boxed.PartialEqBox.eq"
      ~keep_params:(Some [ true; false ]);
    (* file: "Aeneas/Std/Core/Core.lean", line: 17 *)
    mk_fun "alloc::boxed::{core::convert::AsMut<Box<@T>, @T>}::as_mut"
      "alloc.boxed.AsMutBox.as_mut"
      ~keep_params:(Some [ true; false ])
      ~can_fail:false;
    (* file: "Aeneas/Std/Alloc.lean", line: 21 *)
    mk_fun "alloc::boxed::{core::ops::deref::Deref<Box<@T>, @T>}::deref"
      "alloc.boxed.Box.deref"
      ~keep_params:(Some [ true; false ])
      ~can_fail:false;
    (* file: "Aeneas/Std/Alloc.lean", line: 24 *)
    mk_fun "alloc::boxed::{core::ops::deref::DerefMut<Box<@T>, @T>}::deref_mut"
      "alloc.boxed.Box.deref_mut"
      ~keep_params:(Some [ true; false ])
      ~can_fail:false;
    (* file: "Aeneas/Std/BTree.lean", line: 145 *)
    mk_fun
      "alloc::collections::btree::map::entry::{alloc::collections::btree::map::entry::Entry<'a, \
       @K, @V, @A>}::or_insert"
      "alloc.collections.btree.map.entry.Entry.or_insert";
    (* file: "Aeneas/Std/BTree.lean", line: 116 *)
    mk_fun
      "alloc::collections::btree::map::{alloc::collections::btree::map::BTreeMap<@K, \
       @V, @A>}::entry"
      "alloc.collections.btree.map.BTreeMap.entry";
    (* file: "Aeneas/Std/BTree.lean", line: 57 *)
    mk_fun
      "alloc::collections::btree::map::{alloc::collections::btree::map::BTreeMap<@K, \
       @V, @A>}::get"
      "alloc.collections.btree.map.BTreeMap.get";
    (* file: "Aeneas/Std/BTree.lean", line: 89 *)
    mk_fun
      "alloc::collections::btree::map::{alloc::collections::btree::map::BTreeMap<@K, \
       @V, @A>}::insert"
      "alloc.collections.btree.map.BTreeMap.insert";
    (* file: "Aeneas/Std/BTree.lean", line: 167 *)
    mk_fun
      "alloc::collections::btree::map::{alloc::collections::btree::map::BTreeMap<@K, \
       @V, @A>}::iter"
      "alloc.collections.btree.map.BTreeMap.iter";
    (* file: "Aeneas/Std/BTree.lean", line: 41 *)
    mk_fun
      "alloc::collections::btree::map::{alloc::collections::btree::map::BTreeMap<@K, \
       @V, alloc::alloc::Global>}::new"
      "alloc.collections.btree.map.BTreeMapKVGlobal.new";
    (* file: "Aeneas/Std/BTree.lean", line: 296 *)
    mk_fun
      "alloc::collections::btree::map::{core::iter::traits::collect::FromIterator<alloc::collections::btree::map::BTreeMap<@K, \
       @V, alloc::alloc::Global>, (@K, @V)>}::from_iter"
      "alloc.collections.btree.map.BTreeMapKVGlobal.Insts.CoreIterTraitsCollectFromIteratorPair.from_iter";
    (* file: "Aeneas/Std/BTree.lean", line: 212 *)
    mk_fun
      "alloc::collections::btree::map::{core::iter::traits::collect::IntoIterator<alloc::collections::btree::map::BTreeMap<@K, \
       @V, @A>, (@K, @V), alloc::collections::btree::map::IntoIter<@K, @V, \
       @A>>}::into_iter"
      "alloc.collections.btree.map.BTreeMap.Insts.CoreIterTraitsCollectIntoIteratorPairIntoIter.into_iter";
    (* file: "Aeneas/Std/BTree.lean", line: 219 *)
    mk_fun
      "alloc::collections::btree::map::{core::iter::traits::iterator::Iterator<alloc::collections::btree::map::IntoIter<@K, \
       @V, @A>, (@K, @V)>}::next"
      "alloc.collections.btree.map.IntoIter.Insts.CoreIterTraitsIteratorIteratorPair.next";
    (* file: "Aeneas/Std/BTree.lean", line: 230 *)
    mk_fun
      "alloc::collections::btree::map::{core::iter::traits::iterator::Iterator<alloc::collections::btree::map::IntoIter<@K, \
       @V, @A>, (@K, @V)>}::size_hint"
      "alloc.collections.btree.map.IntoIter.Insts.CoreIterTraitsIteratorIteratorPair.size_hint";
    (* file: "Aeneas/Std/BTree.lean", line: 192 *)
    mk_fun
      "alloc::collections::btree::map::{core::iter::traits::iterator::Iterator<alloc::collections::btree::map::Iter<'a, \
       @K, @V>, (&'a @K, &'a @V)>}::max"
      "alloc.collections.btree.map.Iter.Insts.CoreIterTraitsIteratorIteratorPairSharedAKSharedAV.max";
    (* file: "Aeneas/Std/BTree.lean", line: 174 *)
    mk_fun
      "alloc::collections::btree::map::{core::iter::traits::iterator::Iterator<alloc::collections::btree::map::Iter<'a, \
       @K, @V>, (&'a @K, &'a @V)>}::next"
      "alloc.collections.btree.map.Iter.Insts.CoreIterTraitsIteratorIteratorPairSharedAKSharedAV.next";
    (* file: "Aeneas/Std/BTree.lean", line: 184 *)
    mk_fun
      "alloc::collections::btree::map::{core::iter::traits::iterator::Iterator<alloc::collections::btree::map::Iter<'a, \
       @K, @V>, (&'a @K, &'a @V)>}::size_hint"
      "alloc.collections.btree.map.Iter.Insts.CoreIterTraitsIteratorIteratorPairSharedAKSharedAV.size_hint";
    (* file: "Aeneas/Std/BTree.lean", line: 66 *)
    mk_fun
      "alloc::collections::btree::map::{core::ops::index::Index<alloc::collections::btree::map::BTreeMap<@K, \
       @V, @A>, &'0 @Q, @V>}::index"
      "alloc.collections.btree.map.BTreeMap.Insts.CoreOpsIndexIndexShared0QV.index";
    (* file: "Aeneas/Std/BTree.lean", line: 327 *)
    mk_fun
      "alloc::collections::btree::set::{core::iter::traits::collect::FromIterator<alloc::collections::btree::set::BTreeSet<@T, \
       alloc::alloc::Global>, @T>}::from_iter"
      "alloc.collections.btree.set.BTreeSetTGlobal.Insts.CoreIterTraitsCollectFromIterator.from_iter";
    (* file: "Aeneas/Std/BTree.lean", line: 347 *)
    mk_fun
      "alloc::collections::btree::set::{core::iter::traits::collect::IntoIterator<alloc::collections::btree::set::BTreeSet<@T, \
       @A>, @T, alloc::collections::btree::set::IntoIter<@T, @A>>}::into_iter"
      "alloc.collections.btree.set.BTreeSet.Insts.CoreIterTraitsCollectIntoIteratorTIntoIter.into_iter";
    (* file: "Aeneas/Std/BTree.lean", line: 354 *)
    mk_fun
      "alloc::collections::btree::set::{core::iter::traits::iterator::Iterator<alloc::collections::btree::set::IntoIter<@T, \
       @A>, @T>}::next"
      "alloc.collections.btree.set.IntoIter.Insts.CoreIterTraitsIteratorIterator.next";
    (* file: "Aeneas/Std/BTree.lean", line: 364 *)
    mk_fun
      "alloc::collections::btree::set::{core::iter::traits::iterator::Iterator<alloc::collections::btree::set::IntoIter<@T, \
       @A>, @T>}::size_hint"
      "alloc.collections.btree.set.IntoIter.Insts.CoreIterTraitsIteratorIterator.size_hint";
    (* file: "Aeneas/Std/Vec.lean", line: 391 *)
    mk_fun "alloc::slice::{[@T]}::into_vec" "alloc.slice.Slice.into_vec"
      ~keep_params:(Some [ true; false ])
      ~can_fail:false ~lift:false;
    (* file: "Aeneas/Std/Vec.lean", line: 376 *)
    mk_fun "alloc::slice::{[@T]}::to_vec" "alloc.slice.Slice.to_vec";
    (* file: "Aeneas/Std/AllocString.lean", line: 16 *)
    mk_fun "alloc::string::{core::clone::Clone<alloc::string::String>}::clone"
      "alloc.string.String.Insts.CoreCloneClone.clone";
    (* file: "Aeneas/Std/AllocString.lean", line: 24 *)
    mk_fun "alloc::string::{core::cmp::Ord<alloc::string::String>}::cmp"
      "alloc.string.String.Insts.CoreCmpOrd.cmp";
    (* file: "Aeneas/Std/AllocString.lean", line: 19 *)
    mk_fun
      "alloc::string::{core::cmp::PartialEq<alloc::string::String, \
       alloc::string::String>}::eq"
      "alloc.string.String.Insts.CoreCmpPartialEqString.eq";
    (* file: "Aeneas/Std/AllocString.lean", line: 28 *)
    mk_fun
      "alloc::string::{core::cmp::PartialOrd<alloc::string::String, \
       alloc::string::String>}::partial_cmp"
      "alloc.string.String.Insts.CoreCmpPartialOrdString.partial_cmp";
    (* file: "Aeneas/Std/Vec.lean", line: 395 *)
    mk_fun "alloc::vec::from_elem" "alloc.vec.from_elem";
    (* file: "Aeneas/Std/Core/IterOverrides.lean", line: 79 *)
    mk_fun
      "alloc::vec::into_iter::{core::iter::traits::iterator::Iterator<alloc::vec::into_iter::IntoIter<@T, \
       @A>, @T>}::count"
      "alloc.vec.into_iter.IntoIter.Insts.CoreIterTraitsIteratorIterator.count"
      ~keep_params:(Some [ true; false ]);
    (* file: "Aeneas/Std/Core/IterOverrides.lean", line: 86 *)
    mk_fun
      "alloc::vec::into_iter::{core::iter::traits::iterator::Iterator<alloc::vec::into_iter::IntoIter<@T, \
       @A>, @T>}::fold"
      "alloc.vec.into_iter.IntoIter.Insts.CoreIterTraitsIteratorIterator.fold"
      ~keep_params:(Some [ true; false; true; true ]);
    (* file: "Aeneas/Std/VecIter.lean", line: 111 *)
    mk_fun
      "alloc::vec::into_iter::{core::iter::traits::iterator::Iterator<alloc::vec::into_iter::IntoIter<@T, \
       @A>, @T>}::map"
      "alloc.vec.into_iter.IntoIter.Insts.CoreIterTraitsIteratorIterator.map";
    (* file: "Aeneas/Std/VecIter.lean", line: 13 *)
    mk_fun
      "alloc::vec::into_iter::{core::iter::traits::iterator::Iterator<alloc::vec::into_iter::IntoIter<@T, \
       @A>, @T>}::next"
      "alloc.vec.into_iter.IteratorIntoIter.next"
      ~keep_params:(Some [ true; false ]);
    (* file: "Aeneas/Std/VecIter.lean", line: 23 *)
    mk_fun
      "alloc::vec::into_iter::{core::iter::traits::iterator::Iterator<alloc::vec::into_iter::IntoIter<@T, \
       @A>, @T>}::size_hint"
      "alloc.vec.into_iter.IteratorIntoIter.size_hint"
      ~keep_params:(Some [ true; false ]);
    (* file: "Aeneas/Std/Vec.lean", line: 621 *)
    mk_fun
      "alloc::vec::partial_eq::{core::cmp::PartialEq<alloc::vec::Vec<@T>, \
       alloc::vec::Vec<@U>>}::eq"
      "alloc.vec.partial_eq.PartialEqVec.eq"
      ~keep_params:(Some [ true; true; false; false ]);
    (* file: "Aeneas/Std/Vec.lean", line: 631 *)
    mk_fun
      "alloc::vec::partial_eq::{core::cmp::PartialEq<alloc::vec::Vec<@T>, \
       alloc::vec::Vec<@U>>}::ne"
      "alloc.vec.partial_eq.PartialEqVec.ne"
      ~keep_params:(Some [ true; true; false; false ]);
    (* file: "Aeneas/Std/Vec.lean", line: 416 *)
    mk_fun "alloc::vec::{alloc::vec::Vec<@T>}::extend_from_slice"
      "alloc.vec.Vec.extend_from_slice"
      ~keep_params:(Some [ true; false ]);
    (* file: "Aeneas/Std/Vec.lean", line: 170 *)
    mk_fun "alloc::vec::{alloc::vec::Vec<@T>}::insert" "alloc.vec.Vec.insert"
      ~keep_params:(Some [ true; false ]);
    (* file: "Aeneas/Std/Vec.lean", line: 88 *)
    mk_fun "alloc::vec::{alloc::vec::Vec<@T>}::len" "alloc.vec.Vec.len"
      ~keep_params:(Some [ true; false ])
      ~can_fail:false ~lift:false;
    (* file: "Aeneas/Std/Vec.lean", line: 81 *)
    mk_fun "alloc::vec::{alloc::vec::Vec<@T>}::new" "alloc.vec.Vec.new"
      ~can_fail:false ~lift:false;
    (* file: "Aeneas/Std/Vec.lean", line: 155 *)
    mk_fun "alloc::vec::{alloc::vec::Vec<@T>}::push" "alloc.vec.Vec.push"
      ~keep_params:(Some [ true; false ]);
    (* file: "Aeneas/Std/Vec.lean", line: 449 *)
    mk_fun "alloc::vec::{alloc::vec::Vec<@T>}::resize" "alloc.vec.Vec.resize"
      ~keep_params:(Some [ true; false ]);
    (* file: "Aeneas/Std/CoreMisc.lean", line: 113 *)
    mk_fun "alloc::vec::{alloc::vec::Vec<@T>}::swap_remove"
      "alloc.vec.Vec.swap_remove"
      ~keep_params:(Some [ true; false ]);
    (* file: "Aeneas/Std/Vec.lean", line: 413 *)
    mk_fun "alloc::vec::{alloc::vec::Vec<@T>}::with_capacity"
      "alloc.vec.Vec.with_capacity" ~can_fail:false ~lift:false;
    (* file: "Aeneas/Std/Vec.lean", line: 607 *)
    mk_fun "alloc::vec::{core::clone::Clone<alloc::vec::Vec<@T>>}::clone"
      "alloc.vec.CloneVec.clone"
      ~keep_params:(Some [ true; false ])
      ~keep_trait_clauses:(Some [ true; false ]);
    (* file: "Aeneas/Std/Vec.lean", line: 653 *)
    mk_fun "alloc::vec::{core::cmp::Ord<alloc::vec::Vec<@T>>}::cmp"
      "alloc.vec.OrdVec.cmp"
      ~keep_params:(Some [ true; false ]);
    (* file: "Aeneas/Std/Vec.lean", line: 522 *)
    mk_fun
      "alloc::vec::{core::convert::From<Box<[@T]>, alloc::vec::Vec<@T>>}::from"
      "alloc.vec.FromBoxSliceVec.from"
      ~keep_params:(Some [ true; false ]);
    (* file: "Aeneas/Std/Vec.lean", line: 508 *)
    mk_fun
      "alloc::vec::{core::convert::From<alloc::vec::Vec<@T>, [@T; @N]>}::from"
      "alloc.vec.FromVecArray.from";
    (* file: "Aeneas/Std/Vec.lean", line: 754 *)
    mk_fun "alloc::vec::{core::fmt::Debug<alloc::vec::Vec<@T>>}::fmt"
      "alloc.vec.DebugVec.fmt"
      ~keep_params:(Some [ true; false ]);
    (* file: "Aeneas/Std/VecIter.lean", line: 72 *)
    mk_fun
      "alloc::vec::{core::iter::traits::collect::FromIterator<alloc::vec::Vec<@T>, \
       @T>}::from_iter"
      "alloc.vec.FromIteratorVec.from_iter";
    (* file: "Aeneas/Std/Core/IterOverrides.lean", line: 96 *)
    mk_fun
      "alloc::vec::{core::iter::traits::collect::IntoIterator<&'a \
       alloc::vec::Vec<@T>, &'a @T, core::slice::iter::Iter<'a, \
       @T>>}::into_iter"
      "SharedAVec.Insts.CoreIterTraitsCollectIntoIteratorSharedATIter.into_iter"
      ~keep_params:(Some [ true; false ]);
    (* file: "Aeneas/Std/VecIter.lean", line: 46 *)
    mk_fun
      "alloc::vec::{core::iter::traits::collect::IntoIterator<alloc::vec::Vec<@T>, \
       @T, alloc::vec::into_iter::IntoIter<@T, @A>>}::into_iter"
      "alloc.vec.IntoIteratorVec.into_iter"
      ~keep_params:(Some [ true; false ]);
    (* file: "Aeneas/Std/Vec.lean", line: 426 *)
    mk_fun
      "alloc::vec::{core::ops::deref::Deref<alloc::vec::Vec<@T>, [@T]>}::deref"
      "alloc.vec.Vec.deref"
      ~keep_params:(Some [ true; false ])
      ~can_fail:false ~lift:false;
    (* file: "Aeneas/Std/Vec.lean", line: 436 *)
    mk_fun
      "alloc::vec::{core::ops::deref::DerefMut<alloc::vec::Vec<@T>, \
       [@T]>}::deref_mut"
      "alloc.vec.Vec.deref_mut"
      ~keep_params:(Some [ true; false ])
      ~can_fail:false;
    (* file: "Aeneas/Std/Vec.lean", line: 233 *)
    mk_fun
      "alloc::vec::{core::ops::index::Index<alloc::vec::Vec<@T>, @I, \
       @O>}::index"
      "alloc.vec.Vec.index"
      ~keep_params:(Some [ true; true; false; true ]);
    (* file: "Aeneas/Std/Vec.lean", line: 239 *)
    mk_fun
      "alloc::vec::{core::ops::index::IndexMut<alloc::vec::Vec<@T>, @I, \
       @O>}::index_mut"
      "alloc.vec.Vec.index_mut"
      ~keep_params:(Some [ true; true; false; true ]);
    (* file: "Aeneas/Std/Array/ArraySlice.lean", line: 138 *)
    mk_fun
      "core::array::equality::{core::cmp::PartialEq<[@T; @N], [@U; @N]>}::eq"
      "core.array.equality.PartialEqArray.eq";
    (* file: "Aeneas/Std/Array/ArraySlice.lean", line: 147 *)
    mk_fun
      "core::array::equality::{core::cmp::PartialEq<[@T; @N], [@U; @N]>}::ne"
      "core.array.equality.PartialEqArray.ne";
    (* file: "Aeneas/Std/Core/IterOverrides.lean", line: 26 *)
    mk_fun
      "core::array::iter::{core::iter::traits::collect::IntoIterator<[@T; @N], \
       @T, core::array::iter::IntoIter<@T, @N>>}::into_iter"
      "Array.Insts.CoreIterTraitsCollectIntoIteratorTIntoIter.into_iter";
    (* file: "Aeneas/Std/Core/IterOverrides.lean", line: 62 *)
    mk_fun
      "core::array::iter::{core::iter::traits::iterator::Iterator<core::array::iter::IntoIter<@T, \
       @N>, @T>}::count"
      "core.array.iter.IntoIter.Insts.CoreIterTraitsIteratorIterator.count";
    (* file: "Aeneas/Std/Core/IterOverrides.lean", line: 69 *)
    mk_fun
      "core::array::iter::{core::iter::traits::iterator::Iterator<core::array::iter::IntoIter<@T, \
       @N>, @T>}::fold"
      "core.array.iter.IntoIter.Insts.CoreIterTraitsIteratorIterator.fold";
    (* file: "Aeneas/Std/Core/IterOverrides.lean", line: 32 *)
    mk_fun
      "core::array::iter::{core::iter::traits::iterator::Iterator<core::array::iter::IntoIter<@T, \
       @N>, @T>}::next"
      "core.array.iter.IntoIter.Insts.CoreIterTraitsIteratorIterator.next";
    (* file: "Aeneas/Std/Core/IterOverrides.lean", line: 41 *)
    mk_fun
      "core::array::iter::{core::iter::traits::iterator::Iterator<core::array::iter::IntoIter<@T, \
       @N>, @T>}::size_hint"
      "core.array.iter.IntoIter.Insts.CoreIterTraitsIteratorIterator.size_hint";
    (* file: "Aeneas/Std/Array/Array.lean", line: 165 *)
    mk_fun "core::array::repeat" "Array.repeat"
      ~keep_trait_clauses:(Some [ false ]) ~can_fail:false ~lift:false;
    (* file: "Aeneas/Std/Array/ArraySlice.lean", line: 36 *)
    mk_fun "core::array::{[@T; @N]}::as_mut_slice" "Array.to_slice_mut"
      ~can_fail:false;
    (* file: "Aeneas/Std/Array/ArraySlice.lean", line: 22 *)
    mk_fun "core::array::{[@T; @N]}::as_slice" "Array.to_slice" ~can_fail:false;
    (* file: "Aeneas/Std/Array/Array.lean", line: 351 *)
    mk_fun "core::array::{core::clone::Clone<[@T; @N]>}::clone"
      "core.array.CloneArray.clone";
    (* file: "Aeneas/Std/Array/Array.lean", line: 365 *)
    mk_fun "core::array::{core::clone::Clone<[@T; @N]>}::clone_from"
      "core.array.CloneArray.clone_from";
    (* file: "Aeneas/Std/Array/ArraySlice.lean", line: 355 *)
    mk_fun "core::array::{core::convert::AsMut<[@T; @N], [@T]>}::as_mut"
      "Array.Insts.CoreConvertAsMutSlice.as_mut";
    (* file: "Aeneas/Std/Array/ArraySlice.lean", line: 348 *)
    mk_fun "core::array::{core::convert::AsRef<[@T; @N], [@T]>}::as_ref"
      "Array.Insts.CoreConvertAsRefSlice.as_ref";
    (* file: "Aeneas/Std/Array/ArraySlice.lean", line: 316 *)
    mk_fun
      "core::array::{core::convert::TryFrom<&'a [@T; @N], &'a [@T], \
       core::array::TryFromSliceError>}::try_from"
      "core.array.TryFromSharedArraySlice.try_from";
    (* file: "Aeneas/Std/Array/ArraySlice.lean", line: 331 *)
    mk_fun
      "core::array::{core::convert::TryFrom<&'a mut [@T; @N], &'a mut [@T], \
       core::array::TryFromSliceError>}::try_from"
      "core.array.TryFromMutArraySlice.try_from";
    (* file: "Aeneas/Std/Array/ArraySlice.lean", line: 296 *)
    mk_fun
      "core::array::{core::convert::TryFrom<[@T; @N], &'0 [@T], \
       core::array::TryFromSliceError>}::try_from"
      "core.array.TryFromArrayCopySlice.try_from";
    (* file: "Aeneas/Std/Array/Array.lean", line: 467 *)
    mk_fun "core::array::{core::default::Default<[@T; 0]>}::default"
      "core.default.DefaultArrayEmpty.default";
    (* file: "Aeneas/Std/Array/Array.lean", line: 451 *)
    mk_fun "core::array::{core::default::Default<[@T; @N]>}::default"
      "core.default.DefaultArray.default";
    (* file: "Aeneas/Std/Array/ArrayDebug.lean", line: 11 *)
    mk_fun "core::array::{core::fmt::Debug<[@T; @N]>}::fmt"
      "core.array.DebugArray.fmt";
    (* file: "Aeneas/Std/Array/ArraySlice.lean", line: 282 *)
    mk_fun
      "core::array::{core::fmt::Debug<core::array::TryFromSliceError>}::fmt"
      "core.array.DebugTryFromSliceError.fmt";
    (* file: "Aeneas/Std/SliceIter.lean", line: 154 *)
    mk_fun
      "core::array::{core::iter::traits::collect::IntoIterator<&'a [@T; @N], \
       &'a @T, core::slice::iter::Iter<'a, @T>>}::into_iter"
      "SharedArray.Insts.CoreIterTraitsCollectIntoIteratorSharedIter.into_iter";
    (* file: "Aeneas/Std/Array/ArraySlice.lean", line: 97 *)
    mk_fun "core::array::{core::ops::index::Index<[@T; @N], @I, @O>}::index"
      "core.array.Array.index";
    (* file: "Aeneas/Std/Array/ArraySlice.lean", line: 103 *)
    mk_fun
      "core::array::{core::ops::index::IndexMut<[@T; @N], @I, @O>}::index_mut"
      "core.array.Array.index_mut";
    (* file: "Aeneas/Std/Core/CoreOption.lean", line: 122 *)
    mk_fun "core::bool::{bool}::then" "core.bool.Bool.then";
    (* file: "Aeneas/Std/CoreMisc.lean", line: 15 *)
    mk_fun "core::borrow::{core::borrow::Borrow<@T, @T>}::borrow"
      "core.borrow.Borrow.Blanket.borrow";
    (* file: "Aeneas/Std/Core/Core.lean", line: 136 *)
    mk_fun "core::clone::impls::{core::clone::Clone<&'0 @T>}::clone"
      "core.clone.impls.CloneShared.clone";
    (* file: "Aeneas/Std/Core/Cmp.lean", line: 23 *)
    mk_fun "core::cmp::Eq::assert_fields_are_eq"
      "core.cmp.Eq.assert_fields_are_eq.default";
    (* file: "Aeneas/Std/Core/Cmp.lean", line: 200 *)
    mk_fun "core::cmp::Ord::clamp" "core.cmp.Ord.clamp.trait_default";
    (* file: "Aeneas/Std/Core/Cmp.lean", line: 181 *)
    mk_fun "core::cmp::Ord::max" "core.cmp.Ord.max.trait_default";
    (* file: "Aeneas/Std/Core/Cmp.lean", line: 190 *)
    mk_fun "core::cmp::Ord::min" "core.cmp.Ord.min.trait_default";
    (* file: "Aeneas/Std/Core/Cmp.lean", line: 33 *)
    mk_fun "core::cmp::PartialEq::ne" "core.cmp.PartialEq.ne.trait_default";
    (* file: "Aeneas/Std/Core/Cmp.lean", line: 142 *)
    mk_fun "core::cmp::PartialOrd::ge" "core.cmp.PartialOrd.ge.trait_default";
    (* file: "Aeneas/Std/Core/Cmp.lean", line: 130 *)
    mk_fun "core::cmp::PartialOrd::gt" "core.cmp.PartialOrd.gt.trait_default";
    (* file: "Aeneas/Std/Core/Cmp.lean", line: 118 *)
    mk_fun "core::cmp::PartialOrd::le" "core.cmp.PartialOrd.le.trait_default";
    (* file: "Aeneas/Std/Core/Cmp.lean", line: 106 *)
    mk_fun "core::cmp::PartialOrd::lt" "core.cmp.PartialOrd.lt.trait_default";
    (* file: "Aeneas/Std/CoreMisc.lean", line: 19 *)
    mk_fun "core::cmp::impls::{core::cmp::Ord<&'0 @A>}::cmp"
      "core.cmp.impls.OrdShared.cmp";
    (* file: "Aeneas/Std/Core/Cmp.lean", line: 232 *)
    mk_fun "core::cmp::impls::{core::cmp::Ord<()>}::cmp"
      "core.cmp.impls.OrdUnit.cmp";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 131 *)
    mk_fun
      "core::cmp::impls::{core::cmp::Ord<usize>}::{core::ops::function::FnMut<@,\
      \ (&'0 usize, &'1 usize), core::cmp::Ordering>}::call_mut"
      "core.cmp.impls.OrdUsize.cmp.Insts.CoreOpsFunctionFnMut.call_mut";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 125 *)
    mk_fun
      "core::cmp::impls::{core::cmp::Ord<usize>}::{core::ops::function::FnOnce<@,\
      \ (&'0 usize, &'1 usize), core::cmp::Ordering>}::call_once"
      "core.cmp.impls.OrdUsize.cmp.Insts.CoreOpsFunctionFnOnce.call_once";
    (* file: "Aeneas/Std/Core/Cmp.lean", line: 244 *)
    mk_fun "core::cmp::impls::{core::cmp::PartialEq<&'a @A, &'b @B>}::eq"
      "core.cmp.impls.PartialEqShared.eq";
    (* file: "Aeneas/Std/Core/Cmp.lean", line: 249 *)
    mk_fun "core::cmp::impls::{core::cmp::PartialEq<&'a @A, &'b @B>}::ne"
      "core.cmp.impls.PartialEqShared.ne";
    (* file: "Aeneas/Std/Core/Cmp.lean", line: 216 *)
    mk_fun "core::cmp::impls::{core::cmp::PartialEq<(), ()>}::eq"
      "core.cmp.impls.PartialEqUnit.eq";
    (* file: "Aeneas/Std/Core/Cmp.lean", line: 219 *)
    mk_fun "core::cmp::impls::{core::cmp::PartialEq<(), ()>}::ne"
      "core.cmp.impls.PartialEqUnit.ne";
    (* file: "Aeneas/Std/Core/Cmp.lean", line: 236 *)
    mk_fun "core::cmp::impls::{core::cmp::PartialEq<bool, bool>}::eq"
      "core.cmp.impls.PartialEqBool.eq";
    (* file: "Aeneas/Std/Core/Cmp.lean", line: 281 *)
    mk_fun "core::cmp::impls::{core::cmp::PartialOrd<&'a @A, &'b @B>}::ge"
      "core.cmp.impls.PartialOrdShared.ge";
    (* file: "Aeneas/Std/Core/Cmp.lean", line: 276 *)
    mk_fun "core::cmp::impls::{core::cmp::PartialOrd<&'a @A, &'b @B>}::gt"
      "core.cmp.impls.PartialOrdShared.gt";
    (* file: "Aeneas/Std/Core/Cmp.lean", line: 271 *)
    mk_fun "core::cmp::impls::{core::cmp::PartialOrd<&'a @A, &'b @B>}::le"
      "core.cmp.impls.PartialOrdShared.le";
    (* file: "Aeneas/Std/Core/Cmp.lean", line: 266 *)
    mk_fun "core::cmp::impls::{core::cmp::PartialOrd<&'a @A, &'b @B>}::lt"
      "core.cmp.impls.PartialOrdShared.lt";
    (* file: "Aeneas/Std/Core/Cmp.lean", line: 261 *)
    mk_fun
      "core::cmp::impls::{core::cmp::PartialOrd<&'a @A, &'b @B>}::partial_cmp"
      "core.cmp.impls.PartialOrdShared.partial_cmp";
    (* file: "Aeneas/Std/Core/Cmp.lean", line: 228 *)
    mk_fun "core::cmp::impls::{core::cmp::PartialOrd<(), ()>}::partial_cmp"
      "core.cmp.impls.PartialOrdUnit.partial_cmp";
    (* file: "Aeneas/Std/Core/Cmp.lean", line: 211 *)
    mk_fun "core::cmp::max" "core.cmp.max";
    (* file: "Aeneas/Std/Core/Cmp.lean", line: 206 *)
    mk_fun "core::cmp::min" "core.cmp.min";
    (* file: "Aeneas/Std/Scalar/CoreConvertNum.lean", line: 817 *)
    mk_fun
      "core::convert::num::ptr_try_from_impls::{core::convert::TryFrom<u32, \
       usize, core::num::error::TryFromIntError>}::try_from"
      "core.convert.num.ptr_try_from_impls.TryFromU32Usize.try_from";
    (* file: "Aeneas/Std/Core/Convert.lean", line: 31 *)
    mk_fun "core::convert::{core::convert::From<@T, @T>}::from"
      "core.convert.FromSame.from" ~can_fail:false;
    (* file: "Aeneas/Std/Core/Convert.lean", line: 16 *)
    mk_fun "core::convert::{core::convert::Into<@T, @U>}::into"
      "core.convert.IntoFrom.into";
    (* file: "Aeneas/Std/Core/Convert.lean", line: 43 *)
    mk_fun "core::convert::{core::convert::TryInto<@T, @U, @Error>}::try_into"
      "core.convert.TryInto.Blanket.try_into";
    (* file: "Aeneas/Std/Core/Default.lean", line: 12 *)
    mk_fun "core::default::{core::default::Default<bool>}::default"
      "core.default.DefaultBool.default";
    (* file: "Aeneas/Std/Scalar/Display.lean", line: 58 *)
    mk_fun "core::fmt::num::imp::{core::fmt::Display<i128>}::fmt"
      "core.fmt.num.imp.DisplayI128.fmt";
    (* file: "Aeneas/Std/Scalar/Display.lean", line: 43 *)
    mk_fun "core::fmt::num::imp::{core::fmt::Display<i16>}::fmt"
      "core.fmt.num.imp.DisplayI16.fmt";
    (* file: "Aeneas/Std/Scalar/Display.lean", line: 48 *)
    mk_fun "core::fmt::num::imp::{core::fmt::Display<i32>}::fmt"
      "core.fmt.num.imp.DisplayI32.fmt";
    (* file: "Aeneas/Std/Scalar/Display.lean", line: 53 *)
    mk_fun "core::fmt::num::imp::{core::fmt::Display<i64>}::fmt"
      "core.fmt.num.imp.DisplayI64.fmt";
    (* file: "Aeneas/Std/Scalar/Display.lean", line: 38 *)
    mk_fun "core::fmt::num::imp::{core::fmt::Display<i8>}::fmt"
      "core.fmt.num.imp.DisplayI8.fmt";
    (* file: "Aeneas/Std/Scalar/Display.lean", line: 63 *)
    mk_fun "core::fmt::num::imp::{core::fmt::Display<isize>}::fmt"
      "core.fmt.num.imp.DisplayIsize.fmt";
    (* file: "Aeneas/Std/Scalar/Display.lean", line: 28 *)
    mk_fun "core::fmt::num::imp::{core::fmt::Display<u128>}::fmt"
      "core.fmt.num.imp.DisplayU128.fmt";
    (* file: "Aeneas/Std/Scalar/Display.lean", line: 13 *)
    mk_fun "core::fmt::num::imp::{core::fmt::Display<u16>}::fmt"
      "core.fmt.num.imp.DisplayU16.fmt";
    (* file: "Aeneas/Std/Scalar/Display.lean", line: 18 *)
    mk_fun "core::fmt::num::imp::{core::fmt::Display<u32>}::fmt"
      "core.fmt.num.imp.DisplayU32.fmt";
    (* file: "Aeneas/Std/Scalar/Display.lean", line: 23 *)
    mk_fun "core::fmt::num::imp::{core::fmt::Display<u64>}::fmt"
      "core.fmt.num.imp.DisplayU64.fmt";
    (* file: "Aeneas/Std/Scalar/Display.lean", line: 8 *)
    mk_fun "core::fmt::num::imp::{core::fmt::Display<u8>}::fmt"
      "core.fmt.num.imp.DisplayU8.fmt";
    (* file: "Aeneas/Std/Scalar/Display.lean", line: 33 *)
    mk_fun "core::fmt::num::imp::{core::fmt::Display<usize>}::fmt"
      "core.fmt.num.imp.DisplayUsize.fmt";
    (* file: "Aeneas/Std/Scalar/Fmt.lean", line: 104 *)
    mk_fun "core::fmt::num::{core::fmt::Debug<i128>}::fmt"
      "core.fmt.num.DebugI128.fmt";
    (* file: "Aeneas/Std/Scalar/Fmt.lean", line: 86 *)
    mk_fun "core::fmt::num::{core::fmt::Debug<i16>}::fmt"
      "core.fmt.num.DebugI16.fmt";
    (* file: "Aeneas/Std/Scalar/Fmt.lean", line: 92 *)
    mk_fun "core::fmt::num::{core::fmt::Debug<i32>}::fmt"
      "core.fmt.num.DebugI32.fmt";
    (* file: "Aeneas/Std/Scalar/Fmt.lean", line: 98 *)
    mk_fun "core::fmt::num::{core::fmt::Debug<i64>}::fmt"
      "core.fmt.num.DebugI64.fmt";
    (* file: "Aeneas/Std/Scalar/Fmt.lean", line: 80 *)
    mk_fun "core::fmt::num::{core::fmt::Debug<i8>}::fmt"
      "core.fmt.num.DebugI8.fmt";
    (* file: "Aeneas/Std/Scalar/Fmt.lean", line: 110 *)
    mk_fun "core::fmt::num::{core::fmt::Debug<isize>}::fmt"
      "core.fmt.num.DebugIsize.fmt";
    (* file: "Aeneas/Std/Scalar/Fmt.lean", line: 38 *)
    mk_fun "core::fmt::num::{core::fmt::Debug<u128>}::fmt"
      "core.fmt.num.DebugU128.fmt";
    (* file: "Aeneas/Std/Scalar/Fmt.lean", line: 20 *)
    mk_fun "core::fmt::num::{core::fmt::Debug<u16>}::fmt"
      "core.fmt.num.DebugU16.fmt";
    (* file: "Aeneas/Std/Scalar/Fmt.lean", line: 26 *)
    mk_fun "core::fmt::num::{core::fmt::Debug<u32>}::fmt"
      "core.fmt.num.DebugU32.fmt";
    (* file: "Aeneas/Std/Scalar/Fmt.lean", line: 32 *)
    mk_fun "core::fmt::num::{core::fmt::Debug<u64>}::fmt"
      "core.fmt.num.DebugU64.fmt";
    (* file: "Aeneas/Std/Scalar/Fmt.lean", line: 14 *)
    mk_fun "core::fmt::num::{core::fmt::Debug<u8>}::fmt"
      "core.fmt.num.DebugU8.fmt";
    (* file: "Aeneas/Std/Scalar/Fmt.lean", line: 44 *)
    mk_fun "core::fmt::num::{core::fmt::Debug<usize>}::fmt"
      "core.fmt.num.DebugUsize.fmt";
    (* file: "Aeneas/Std/Scalar/Fmt.lean", line: 8 *)
    mk_fun "core::fmt::num::{core::fmt::LowerHex<u16>}::fmt"
      "core.fmt.num.LowerHexU16.fmt";
    (* file: "Aeneas/Std/Core/Fmt.lean", line: 64 *)
    mk_fun "core::fmt::rt::{core::fmt::rt::Argument<'0>}::new_debug"
      "core.fmt.rt.Argument.new_debug";
    (* file: "Aeneas/Std/Core/Fmt.lean", line: 195 *)
    mk_fun "core::fmt::rt::{core::fmt::rt::Argument<'0>}::new_display"
      "core.fmt.rt.Argument.new_display";
    (* file: "Aeneas/Std/Core/Fmt.lean", line: 78 *)
    mk_fun "core::fmt::rt::{core::fmt::rt::Argument<'0>}::new_lower_hex"
      "core.fmt.rt.Argument.new_lower_hex";
    (* file: "Aeneas/Std/Core/Fmt.lean", line: 55 *)
    mk_fun "core::fmt::{core::fmt::Arguments<'a>}::from_str"
      "core.fmt.Arguments.from_str";
    (* file: "Aeneas/Std/Core/Fmt.lean", line: 58 *)
    mk_fun "core::fmt::{core::fmt::Arguments<'a>}::new" "core.fmt.Arguments.new";
    (* file: "Aeneas/Std/Core/Fmt.lean", line: 98 *)
    mk_fun "core::fmt::{core::fmt::Debug<&'0 @T>}::fmt"
      "core.fmt.DebugShared.fmt";
    (* file: "Aeneas/Std/Core/Fmt.lean", line: 110 *)
    mk_fun "core::fmt::{core::fmt::Debug<()>}::fmt" "core.fmt.DebugUnit.fmt";
    (* file: "Aeneas/Std/Core/Fmt.lean", line: 104 *)
    mk_fun "core::fmt::{core::fmt::Debug<bool>}::fmt" "core.fmt.DebugBool.fmt";
    (* file: "Aeneas/Std/Core/Fmt.lean", line: 125 *)
    mk_fun "core::fmt::{core::fmt::Formatter<'a>}::debug_struct_field1_finish"
      "core.fmt.Formatter.debug_struct_field1_finish";
    (* file: "Aeneas/Std/Core/Fmt.lean", line: 132 *)
    mk_fun "core::fmt::{core::fmt::Formatter<'a>}::debug_struct_field2_finish"
      "core.fmt.Formatter.debug_struct_field2_finish";
    (* file: "Aeneas/Std/Core/Fmt.lean", line: 140 *)
    mk_fun "core::fmt::{core::fmt::Formatter<'a>}::debug_struct_field3_finish"
      "core.fmt.Formatter.debug_struct_field3_finish";
    (* file: "Aeneas/Std/Core/Fmt.lean", line: 150 *)
    mk_fun "core::fmt::{core::fmt::Formatter<'a>}::debug_struct_field4_finish"
      "core.fmt.Formatter.debug_struct_field4_finish";
    (* file: "Aeneas/Std/Core/Fmt.lean", line: 161 *)
    mk_fun "core::fmt::{core::fmt::Formatter<'a>}::debug_struct_field5_finish"
      "core.fmt.Formatter.debug_struct_field5_finish";
    (* file: "Aeneas/Std/Core/FmtWithSlice.lean", line: 9 *)
    mk_fun "core::fmt::{core::fmt::Formatter<'a>}::debug_struct_fields_finish"
      "core.fmt.Formatter.debug_struct_fields_finish";
    (* file: "Aeneas/Std/Core/Fmt.lean", line: 171 *)
    mk_fun "core::fmt::{core::fmt::Formatter<'a>}::debug_tuple_field1_finish"
      "core.fmt.Formatter.debug_tuple_field1_finish";
    (* file: "Aeneas/Std/Core/Fmt.lean", line: 91 *)
    mk_fun "core::fmt::{core::fmt::Formatter<'a>}::write_fmt"
      "core.fmt.Formatter.write_fmt";
    (* file: "Aeneas/Std/Core/Fmt.lean", line: 85 *)
    mk_fun "core::fmt::{core::fmt::Formatter<'a>}::write_str"
      "core.fmt.Formatter.write_str";
    (* file: "Aeneas/Std/Core/Discriminant.lean", line: 28 *)
    mk_fun "core::intrinsics::discriminant_value"
      "core.intrinsics.discriminant_value";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 408 *)
    mk_fun
      "core::iter::adapters::chain::{core::iter::traits::iterator::Iterator<core::iter::adapters::chain::Chain<@A, \
       @B>, @Clause0_Item>}::count"
      "core.iter.adapters.chain.Chain.Insts.CoreIterTraitsIteratorIterator.count";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 418 *)
    mk_fun
      "core::iter::adapters::chain::{core::iter::traits::iterator::Iterator<core::iter::adapters::chain::Chain<@A, \
       @B>, @Clause0_Item>}::fold"
      "core.iter.adapters.chain.Chain.Insts.CoreIterTraitsIteratorIterator.fold";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 354 *)
    mk_fun
      "core::iter::adapters::chain::{core::iter::traits::iterator::Iterator<core::iter::adapters::chain::Chain<@A, \
       @B>, @Clause0_Item>}::next"
      "core.iter.adapters.chain.Chain.Insts.CoreIterTraitsIteratorIterator.next";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 378 *)
    mk_fun
      "core::iter::adapters::chain::{core::iter::traits::iterator::Iterator<core::iter::adapters::chain::Chain<@A, \
       @B>, @Clause0_Item>}::size_hint"
      "core.iter.adapters.chain.Chain.Insts.CoreIterTraitsIteratorIterator.size_hint";
    (* file: "Aeneas/Std/Core/IterOverrides.lean", line: 113 *)
    mk_fun
      "core::iter::adapters::enumerate::{core::iter::traits::iterator::Iterator<core::iter::adapters::enumerate::Enumerate<@I>, \
       (usize, @Clause0_Item)>}::count"
      "core.iter.adapters.enumerate.Enumerate.Insts.CoreIterTraitsIteratorIteratorPairUsizeClause0_Item.count";
    (* file: "Aeneas/Std/Core/IterOverrides.lean", line: 121 *)
    mk_fun
      "core::iter::adapters::enumerate::{core::iter::traits::iterator::Iterator<core::iter::adapters::enumerate::Enumerate<@I>, \
       (usize, @Clause0_Item)>}::fold"
      "core.iter.adapters.enumerate.Enumerate.Insts.CoreIterTraitsIteratorIteratorPairUsizeClause0_Item.fold";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 595 *)
    mk_fun
      "core::iter::adapters::enumerate::{core::iter::traits::iterator::Iterator<core::iter::adapters::enumerate::Enumerate<@I>, \
       (usize, @Clause0_Item)>}::next"
      "core.iter.adapters.enumerate.IteratorEnumerate.next";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 610 *)
    mk_fun
      "core::iter::adapters::enumerate::{core::iter::traits::iterator::Iterator<core::iter::adapters::enumerate::Enumerate<@I>, \
       (usize, @Clause0_Item)>}::size_hint"
      "core.iter.adapters.enumerate.IteratorEnumerate.size_hint";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 245 *)
    mk_fun
      "core::iter::adapters::filter::{core::iter::traits::iterator::Iterator<core::iter::adapters::filter::Filter<@I, \
       @P>, @Clause0_Item>}::count"
      "core.iter.adapters.filter.Filter.Insts.CoreIterTraitsIteratorIterator.count";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 256 *)
    mk_fun
      "core::iter::adapters::filter::{core::iter::traits::iterator::Iterator<core::iter::adapters::filter::Filter<@I, \
       @P>, @Clause0_Item>}::fold"
      "core.iter.adapters.filter.Filter.Insts.CoreIterTraitsIteratorIterator.fold";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 206 *)
    mk_fun
      "core::iter::adapters::filter::{core::iter::traits::iterator::Iterator<core::iter::adapters::filter::Filter<@I, \
       @P>, @Clause0_Item>}::next"
      "core.iter.adapters.filter.Filter.Insts.CoreIterTraitsIteratorIterator.next";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 224 *)
    mk_fun
      "core::iter::adapters::filter::{core::iter::traits::iterator::Iterator<core::iter::adapters::filter::Filter<@I, \
       @P>, @Clause0_Item>}::size_hint"
      "core.iter.adapters.filter.Filter.Insts.CoreIterTraitsIteratorIterator.size_hint";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 325 *)
    mk_fun
      "core::iter::adapters::filter_map::{core::iter::traits::iterator::Iterator<core::iter::adapters::filter_map::FilterMap<@I, \
       @F>, @B>}::fold"
      "core.iter.adapters.filter_map.FilterMap.Insts.CoreIterTraitsIteratorIterator.fold";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 284 *)
    mk_fun
      "core::iter::adapters::filter_map::{core::iter::traits::iterator::Iterator<core::iter::adapters::filter_map::FilterMap<@I, \
       @F>, @B>}::next"
      "core.iter.adapters.filter_map.FilterMap.Insts.CoreIterTraitsIteratorIterator.next";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 303 *)
    mk_fun
      "core::iter::adapters::filter_map::{core::iter::traits::iterator::Iterator<core::iter::adapters::filter_map::FilterMap<@I, \
       @F>, @B>}::size_hint"
      "core.iter.adapters.filter_map.FilterMap.Insts.CoreIterTraitsIteratorIterator.size_hint";
    (* file: "Aeneas/Std/Core/IterOverrides.lean", line: 166 *)
    mk_fun
      "core::iter::adapters::flatten::{core::iter::traits::iterator::Iterator<core::iter::adapters::flatten::FlatMap<@I, \
       @U, @F, @Clause1_Item, @Clause1_IntoIter>, @Clause1_Item>}::count"
      "core.iter.adapters.flatten.FlatMap.Insts.CoreIterTraitsIteratorIterator.count";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 528 *)
    mk_fun
      "core::iter::adapters::flatten::{core::iter::traits::iterator::Iterator<core::iter::adapters::flatten::FlatMap<@I, \
       @U, @F, @Clause1_Item, @Clause1_IntoIter>, @Clause1_Item>}::fold"
      "core.iter.adapters.flatten.FlatMap.Insts.CoreIterTraitsIteratorIterator.fold";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 452 *)
    mk_fun
      "core::iter::adapters::flatten::{core::iter::traits::iterator::Iterator<core::iter::adapters::flatten::FlatMap<@I, \
       @U, @F, @Clause1_Item, @Clause1_IntoIter>, @Clause1_Item>}::next"
      "core.iter.adapters.flatten.FlatMap.Insts.CoreIterTraitsIteratorIterator.next";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 489 *)
    mk_fun
      "core::iter::adapters::flatten::{core::iter::traits::iterator::Iterator<core::iter::adapters::flatten::FlatMap<@I, \
       @U, @F, @Clause1_Item, @Clause1_IntoIter>, @Clause1_Item>}::size_hint"
      "core.iter.adapters.flatten.FlatMap.Insts.CoreIterTraitsIteratorIterator.size_hint";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 178 *)
    mk_fun
      "core::iter::adapters::map::{core::iter::traits::iterator::Iterator<core::iter::adapters::map::Map<@I, \
       @F>, @B>}::fold"
      "core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator.fold";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 141 *)
    mk_fun
      "core::iter::adapters::map::{core::iter::traits::iterator::Iterator<core::iter::adapters::map::Map<@I, \
       @F>, @B>}::next"
      "core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator.next";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 157 *)
    mk_fun
      "core::iter::adapters::map::{core::iter::traits::iterator::Iterator<core::iter::adapters::map::Map<@I, \
       @F>, @B>}::size_hint"
      "core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator.size_hint";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 1012 *)
    mk_fun
      "core::iter::adapters::rev::{core::iter::traits::iterator::Iterator<core::iter::adapters::rev::Rev<@I>, \
       @Clause0_Clause0_Item>}::next"
      "core.iter.adapters.rev.Rev.Insts.CoreIterTraitsIteratorIterator.next";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 149 *)
    mk_fun
      "core::iter::adapters::step_by::{core::iter::traits::iterator::Iterator<core::iter::adapters::step_by::StepBy<@I>, \
       @Clause0_Item>}::next"
      "core.iter.adapters.step_by.IteratorStepBy.next";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 172 *)
    mk_fun
      "core::iter::adapters::step_by::{core::iter::traits::iterator::Iterator<core::iter::adapters::step_by::StepBy<@I>, \
       @Clause0_Item>}::size_hint"
      "core.iter.adapters.step_by.IteratorStepBy.size_hint";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 638 *)
    mk_fun
      "core::iter::adapters::take::{core::iter::traits::iterator::Iterator<core::iter::adapters::take::Take<@I>, \
       @Clause0_Item>}::next"
      "core.iter.adapters.take.IteratorTake.next";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 653 *)
    mk_fun
      "core::iter::adapters::take::{core::iter::traits::iterator::Iterator<core::iter::adapters::take::Take<@I>, \
       @Clause0_Item>}::size_hint"
      "core.iter.adapters.take.IteratorTake.size_hint";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 992 *)
    mk_fun
      "core::iter::adapters::take_while::{core::iter::traits::iterator::Iterator<core::iter::adapters::take_while::TakeWhile<@I, \
       @P>, @Clause0_Item>}::next"
      "core.iter.adapters.take_while.TakeWhile.Insts.CoreIterTraitsIteratorIterator.next";
    (* file: "Aeneas/Std/Core/IterOverrides.lean", line: 156 *)
    mk_fun
      "core::iter::adapters::zip::{core::iter::traits::iterator::Iterator<core::iter::adapters::zip::Zip<@A, \
       @B>, (@Clause0_Item, @Clause1_Item)>}::fold"
      "core.iter.adapters.zip.Zip.Insts.CoreIterTraitsIteratorIteratorPair.fold";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 754 *)
    mk_fun
      "core::iter::adapters::zip::{core::iter::traits::iterator::Iterator<core::iter::adapters::zip::Zip<@A, \
       @B>, (@Clause0_Item, @Clause1_Item)>}::next"
      "core.iter.adapters.zip.Zip.Insts.CoreIterTraitsIteratorIteratorPair.next";
    (* file: "Aeneas/Std/Core/IterOverrides.lean", line: 131 *)
    mk_fun
      "core::iter::adapters::zip::{core::iter::traits::iterator::Iterator<core::iter::adapters::zip::Zip<@A, \
       @B>, (@Clause0_Item, @Clause1_Item)>}::size_hint"
      "core.iter.adapters.zip.Zip.Insts.CoreIterTraitsIteratorIteratorPair.size_hint";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 581 *)
    mk_fun
      "core::iter::range::{core::iter::range::Step<i128>}::backward_checked"
      "core.iter.range.StepI128.backward_checked";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 585 *)
    mk_fun
      "core::iter::range::{core::iter::range::Step<i128>}::backward_overflowing"
      "core.iter.range.StepI128.backward_overflowing";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 579 *)
    mk_fun "core::iter::range::{core::iter::range::Step<i128>}::forward_checked"
      "core.iter.range.StepI128.forward_checked";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 583 *)
    mk_fun
      "core::iter::range::{core::iter::range::Step<i128>}::forward_overflowing"
      "core.iter.range.StepI128.forward_overflowing";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 577 *)
    mk_fun "core::iter::range::{core::iter::range::Step<i128>}::steps_between"
      "core.iter.range.StepI128.steps_between";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 542 *)
    mk_fun "core::iter::range::{core::iter::range::Step<i16>}::backward_checked"
      "core.iter.range.StepI16.backward_checked";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 546 *)
    mk_fun
      "core::iter::range::{core::iter::range::Step<i16>}::backward_overflowing"
      "core.iter.range.StepI16.backward_overflowing";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 540 *)
    mk_fun "core::iter::range::{core::iter::range::Step<i16>}::forward_checked"
      "core.iter.range.StepI16.forward_checked";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 544 *)
    mk_fun
      "core::iter::range::{core::iter::range::Step<i16>}::forward_overflowing"
      "core.iter.range.StepI16.forward_overflowing";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 538 *)
    mk_fun "core::iter::range::{core::iter::range::Step<i16>}::steps_between"
      "core.iter.range.StepI16.steps_between";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 555 *)
    mk_fun "core::iter::range::{core::iter::range::Step<i32>}::backward_checked"
      "core.iter.range.StepI32.backward_checked";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 559 *)
    mk_fun
      "core::iter::range::{core::iter::range::Step<i32>}::backward_overflowing"
      "core.iter.range.StepI32.backward_overflowing";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 553 *)
    mk_fun "core::iter::range::{core::iter::range::Step<i32>}::forward_checked"
      "core.iter.range.StepI32.forward_checked";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 557 *)
    mk_fun
      "core::iter::range::{core::iter::range::Step<i32>}::forward_overflowing"
      "core.iter.range.StepI32.forward_overflowing";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 551 *)
    mk_fun "core::iter::range::{core::iter::range::Step<i32>}::steps_between"
      "core.iter.range.StepI32.steps_between";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 568 *)
    mk_fun "core::iter::range::{core::iter::range::Step<i64>}::backward_checked"
      "core.iter.range.StepI64.backward_checked";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 572 *)
    mk_fun
      "core::iter::range::{core::iter::range::Step<i64>}::backward_overflowing"
      "core.iter.range.StepI64.backward_overflowing";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 566 *)
    mk_fun "core::iter::range::{core::iter::range::Step<i64>}::forward_checked"
      "core.iter.range.StepI64.forward_checked";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 570 *)
    mk_fun
      "core::iter::range::{core::iter::range::Step<i64>}::forward_overflowing"
      "core.iter.range.StepI64.forward_overflowing";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 564 *)
    mk_fun "core::iter::range::{core::iter::range::Step<i64>}::steps_between"
      "core.iter.range.StepI64.steps_between";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 529 *)
    mk_fun "core::iter::range::{core::iter::range::Step<i8>}::backward_checked"
      "core.iter.range.StepI8.backward_checked";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 533 *)
    mk_fun
      "core::iter::range::{core::iter::range::Step<i8>}::backward_overflowing"
      "core.iter.range.StepI8.backward_overflowing";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 527 *)
    mk_fun "core::iter::range::{core::iter::range::Step<i8>}::forward_checked"
      "core.iter.range.StepI8.forward_checked";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 531 *)
    mk_fun
      "core::iter::range::{core::iter::range::Step<i8>}::forward_overflowing"
      "core.iter.range.StepI8.forward_overflowing";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 525 *)
    mk_fun "core::iter::range::{core::iter::range::Step<i8>}::steps_between"
      "core.iter.range.StepI8.steps_between";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 516 *)
    mk_fun
      "core::iter::range::{core::iter::range::Step<isize>}::backward_checked"
      "core.iter.range.StepIsize.backward_checked";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 520 *)
    mk_fun
      "core::iter::range::{core::iter::range::Step<isize>}::backward_overflowing"
      "core.iter.range.StepIsize.backward_overflowing";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 514 *)
    mk_fun
      "core::iter::range::{core::iter::range::Step<isize>}::forward_checked"
      "core.iter.range.StepIsize.forward_checked";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 518 *)
    mk_fun
      "core::iter::range::{core::iter::range::Step<isize>}::forward_overflowing"
      "core.iter.range.StepIsize.forward_overflowing";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 512 *)
    mk_fun "core::iter::range::{core::iter::range::Step<isize>}::steps_between"
      "core.iter.range.StepIsize.steps_between";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 503 *)
    mk_fun
      "core::iter::range::{core::iter::range::Step<u128>}::backward_checked"
      "core.iter.range.StepU128.backward_checked";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 507 *)
    mk_fun
      "core::iter::range::{core::iter::range::Step<u128>}::backward_overflowing"
      "core.iter.range.StepU128.backward_overflowing";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 501 *)
    mk_fun "core::iter::range::{core::iter::range::Step<u128>}::forward_checked"
      "core.iter.range.StepU128.forward_checked";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 505 *)
    mk_fun
      "core::iter::range::{core::iter::range::Step<u128>}::forward_overflowing"
      "core.iter.range.StepU128.forward_overflowing";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 499 *)
    mk_fun "core::iter::range::{core::iter::range::Step<u128>}::steps_between"
      "core.iter.range.StepU128.steps_between";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 464 *)
    mk_fun "core::iter::range::{core::iter::range::Step<u16>}::backward_checked"
      "core.iter.range.StepU16.backward_checked";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 468 *)
    mk_fun
      "core::iter::range::{core::iter::range::Step<u16>}::backward_overflowing"
      "core.iter.range.StepU16.backward_overflowing";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 462 *)
    mk_fun "core::iter::range::{core::iter::range::Step<u16>}::forward_checked"
      "core.iter.range.StepU16.forward_checked";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 466 *)
    mk_fun
      "core::iter::range::{core::iter::range::Step<u16>}::forward_overflowing"
      "core.iter.range.StepU16.forward_overflowing";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 460 *)
    mk_fun "core::iter::range::{core::iter::range::Step<u16>}::steps_between"
      "core.iter.range.StepU16.steps_between";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 477 *)
    mk_fun "core::iter::range::{core::iter::range::Step<u32>}::backward_checked"
      "core.iter.range.StepU32.backward_checked";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 481 *)
    mk_fun
      "core::iter::range::{core::iter::range::Step<u32>}::backward_overflowing"
      "core.iter.range.StepU32.backward_overflowing";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 475 *)
    mk_fun "core::iter::range::{core::iter::range::Step<u32>}::forward_checked"
      "core.iter.range.StepU32.forward_checked";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 479 *)
    mk_fun
      "core::iter::range::{core::iter::range::Step<u32>}::forward_overflowing"
      "core.iter.range.StepU32.forward_overflowing";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 473 *)
    mk_fun "core::iter::range::{core::iter::range::Step<u32>}::steps_between"
      "core.iter.range.StepU32.steps_between";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 490 *)
    mk_fun "core::iter::range::{core::iter::range::Step<u64>}::backward_checked"
      "core.iter.range.StepU64.backward_checked";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 494 *)
    mk_fun
      "core::iter::range::{core::iter::range::Step<u64>}::backward_overflowing"
      "core.iter.range.StepU64.backward_overflowing";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 488 *)
    mk_fun "core::iter::range::{core::iter::range::Step<u64>}::forward_checked"
      "core.iter.range.StepU64.forward_checked";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 492 *)
    mk_fun
      "core::iter::range::{core::iter::range::Step<u64>}::forward_overflowing"
      "core.iter.range.StepU64.forward_overflowing";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 486 *)
    mk_fun "core::iter::range::{core::iter::range::Step<u64>}::steps_between"
      "core.iter.range.StepU64.steps_between";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 451 *)
    mk_fun "core::iter::range::{core::iter::range::Step<u8>}::backward_checked"
      "core.iter.range.StepU8.backward_checked";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 455 *)
    mk_fun
      "core::iter::range::{core::iter::range::Step<u8>}::backward_overflowing"
      "core.iter.range.StepU8.backward_overflowing";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 449 *)
    mk_fun "core::iter::range::{core::iter::range::Step<u8>}::forward_checked"
      "core.iter.range.StepU8.forward_checked";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 453 *)
    mk_fun
      "core::iter::range::{core::iter::range::Step<u8>}::forward_overflowing"
      "core.iter.range.StepU8.forward_overflowing";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 447 *)
    mk_fun "core::iter::range::{core::iter::range::Step<u8>}::steps_between"
      "core.iter.range.StepU8.steps_between";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 438 *)
    mk_fun
      "core::iter::range::{core::iter::range::Step<usize>}::backward_checked"
      "core.iter.range.StepUsize.backward_checked";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 442 *)
    mk_fun
      "core::iter::range::{core::iter::range::Step<usize>}::backward_overflowing"
      "core.iter.range.StepUsize.backward_overflowing";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 436 *)
    mk_fun
      "core::iter::range::{core::iter::range::Step<usize>}::forward_checked"
      "core.iter.range.StepUsize.forward_checked";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 440 *)
    mk_fun
      "core::iter::range::{core::iter::range::Step<usize>}::forward_overflowing"
      "core.iter.range.StepUsize.forward_overflowing";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 434 *)
    mk_fun "core::iter::range::{core::iter::range::Step<usize>}::steps_between"
      "core.iter.range.StepUsize.steps_between";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 1025 *)
    mk_fun
      "core::iter::range::{core::iter::traits::double_ended::DoubleEndedIterator<core::ops::range::Range<@A>, \
       @A>}::next_back"
      "core.ops.range.Range.Insts.CoreIterTraitsDoubleEndedIterator.next_back";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 1059 *)
    mk_fun
      "core::iter::range::{core::iter::traits::double_ended::DoubleEndedIterator<core::ops::range::RangeInclusive<@A>, \
       @A>}::next_back"
      "core.ops.range.RangeInclusive.Insts.CoreIterTraitsDoubleEndedIterator.next_back";
    (* file: "Aeneas/Std/Core/IterOverrides.lean", line: 181 *)
    mk_fun
      "core::iter::range::{core::iter::traits::iterator::Iterator<core::ops::range::Range<@A>, \
       @A>}::count"
      "core.ops.range.Range.Insts.CoreIterTraitsIteratorIterator.count";
    (* file: "Aeneas/Std/Core/IterOverrides.lean", line: 193 *)
    mk_fun
      "core::iter::range::{core::iter::traits::iterator::Iterator<core::ops::range::Range<@A>, \
       @A>}::max"
      "core.ops.range.Range.Insts.CoreIterTraitsIteratorIterator.max";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 683 *)
    mk_fun
      "core::iter::range::{core::iter::traits::iterator::Iterator<core::ops::range::Range<@A>, \
       @A>}::next"
      "core.iter.range.IteratorRange.next";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 699 *)
    mk_fun
      "core::iter::range::{core::iter::traits::iterator::Iterator<core::ops::range::Range<@A>, \
       @A>}::size_hint"
      "core.iter.range.IteratorRange.size_hint";
    (* file: "Aeneas/Std/Core/IterOverrides.lean", line: 207 *)
    mk_fun
      "core::iter::range::{core::iter::traits::iterator::Iterator<core::ops::range::RangeInclusive<@A>, \
       @A>}::count"
      "core.ops.range.RangeInclusive.Insts.CoreIterTraitsIteratorIterator.count";
    (* file: "Aeneas/Std/Core/IterOverrides.lean", line: 227 *)
    mk_fun
      "core::iter::range::{core::iter::traits::iterator::Iterator<core::ops::range::RangeInclusive<@A>, \
       @A>}::fold"
      "core.ops.range.RangeInclusive.Insts.CoreIterTraitsIteratorIterator.fold";
    (* file: "Aeneas/Std/Core/IterOverrides.lean", line: 219 *)
    mk_fun
      "core::iter::range::{core::iter::traits::iterator::Iterator<core::ops::range::RangeInclusive<@A>, \
       @A>}::max"
      "core.ops.range.RangeInclusive.Insts.CoreIterTraitsIteratorIterator.max";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 793 *)
    mk_fun
      "core::iter::range::{core::iter::traits::iterator::Iterator<core::ops::range::RangeInclusive<@A>, \
       @A>}::next"
      "core.ops.range.RangeInclusive.Insts.CoreIterTraitsIteratorIterator.next";
    (* file: "Aeneas/Std/RangeIter.lean", line: 567 *)
    mk_fun
      "core::iter::range::{core::iter::traits::iterator::Iterator<core::ops::range::RangeInclusive<@A>, \
       @A>}::size_hint"
      "core.ops.range.RangeInclusive.Insts.CoreIterTraitsIteratorIterator.size_hint";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 585 *)
    mk_fun "core::iter::sources::empty::empty" "core.iter.sources.empty.empty";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 589 *)
    mk_fun
      "core::iter::sources::empty::{core::iter::traits::iterator::Iterator<core::iter::sources::empty::Empty<@T>, \
       @T>}::next"
      "core.iter.sources.empty.Empty.Insts.CoreIterTraitsIteratorIterator.next";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 595 *)
    mk_fun
      "core::iter::sources::empty::{core::iter::traits::iterator::Iterator<core::iter::sources::empty::Empty<@T>, \
       @T>}::size_hint"
      "core.iter.sources.empty.Empty.Insts.CoreIterTraitsIteratorIterator.size_hint";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 558 *)
    mk_fun "core::iter::sources::once::once" "core.iter.sources.once.once";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 562 *)
    mk_fun
      "core::iter::sources::once::{core::iter::traits::iterator::Iterator<core::iter::sources::once::Once<@T>, \
       @T>}::next"
      "core.iter.sources.once.Once.Insts.CoreIterTraitsIteratorIterator.next";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 568 *)
    mk_fun
      "core::iter::sources::once::{core::iter::traits::iterator::Iterator<core::iter::sources::once::Once<@T>, \
       @T>}::size_hint"
      "core.iter.sources.once.Once.Insts.CoreIterTraitsIteratorIterator.size_hint";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 110 *)
    mk_fun
      "core::iter::traits::accum::{core::iter::traits::accum::Sum<usize, \
       usize>}::sum"
      "Usize.Insts.CoreIterTraitsAccumSumUsize.sum";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 218 *)
    mk_fun
      "core::iter::traits::collect::{core::iter::traits::collect::IntoIterator<@I, \
       @Item, @I>}::into_iter"
      "core.iter.traits.collect.IntoIterator.Blanket.into_iter";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 52 *)
    mk_fun "core::iter::traits::iterator::Iterator::any"
      "core.iter.traits.iterator.Iterator.any.default";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 430 *)
    mk_fun "core::iter::traits::iterator::Iterator::chain"
      "core.iter.traits.iterator.Iterator.chain.default";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 265 *)
    mk_fun "core::iter::traits::iterator::Iterator::collect"
      "core.iter.traits.iterator.Iterator.collect.default";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 40 *)
    mk_fun "core::iter::traits::iterator::Iterator::count"
      "core.iter.traits.iterator.Iterator.count.default";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 121 *)
    mk_fun "core::iter::traits::iterator::Iterator::enumerate"
      "core.iter.traits.iterator.Iterator.enumerate.trait_default";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 268 *)
    mk_fun "core::iter::traits::iterator::Iterator::filter"
      "core.iter.traits.iterator.Iterator.filter.default";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 337 *)
    mk_fun "core::iter::traits::iterator::Iterator::filter_map"
      "core.iter.traits.iterator.Iterator.filter_map.default";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 543 *)
    mk_fun "core::iter::traits::iterator::Iterator::flat_map"
      "core.iter.traits.iterator.Iterator.flat_map.default";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 24 *)
    mk_fun "core::iter::traits::iterator::Iterator::fold"
      "core.iter.traits.iterator.Iterator.fold.default";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 190 *)
    mk_fun "core::iter::traits::iterator::Iterator::map"
      "core.iter.traits.iterator.Iterator.map.default";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 93 *)
    mk_fun "core::iter::traits::iterator::Iterator::max"
      "core.iter.traits.iterator.Iterator.max.default";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 68 *)
    mk_fun "core::iter::traits::iterator::Iterator::max_by"
      "core.iter.traits.iterator.Iterator.max_by.default";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 851 *)
    mk_fun "core::iter::traits::iterator::Iterator::rev"
      "core.iter.traits.iterator.Iterator.rev.trait_default";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 106 *)
    mk_fun "core::iter::traits::iterator::Iterator::size_hint"
      "core.iter.traits.iterator.Iterator.size_hint.trait_default";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 113 *)
    mk_fun "core::iter::traits::iterator::Iterator::step_by"
      "core.iter.traits.iterator.Iterator.step_by.trait_default";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 102 *)
    mk_fun "core::iter::traits::iterator::Iterator::sum"
      "core.iter.traits.iterator.Iterator.sum.default";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 129 *)
    mk_fun "core::iter::traits::iterator::Iterator::take"
      "core.iter.traits.iterator.Iterator.take.trait_default";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 865 *)
    mk_fun "core::iter::traits::iterator::Iterator::take_while"
      "core.iter.traits.iterator.Iterator.take_while.trait_default";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 836 *)
    mk_fun "core::iter::traits::iterator::Iterator::zip"
      "core.iter.traits.iterator.Iterator.zip.trait_default";
    (* file: "Aeneas/Std/CoreMisc.lean", line: 128 *)
    mk_fun
      "core::marker::{core::default::Default<core::marker::PhantomData<@T>>}::default"
      "core.marker.PhantomData.Insts.CoreDefaultDefault.default";
    (* file: "Aeneas/Std/Core/Core.lean", line: 77 *)
    mk_fun "core::mem::replace" "core.mem.replace" ~can_fail:false ~lift:false;
    (* file: "Aeneas/Std/Core/Core.lean", line: 81 *)
    mk_fun "core::mem::swap" "core.mem.swap" ~can_fail:false ~lift:false;
    (* file: "Aeneas/Std/Scalar/CoreConvertNum.lean", line: 696 *)
    mk_fun "core::num::{i128}::cast_unsigned" "core.num.I128.cast_unsigned";
    (* file: "Aeneas/Std/Scalar/WrappingOps/Shl.lean", line: 46 *)
    mk_fun "core::num::{i128}::wrapping_shl" "core.num.I128.wrapping_shl"
      ~can_fail:false;
    (* file: "Aeneas/Std/Scalar/WrappingOps/Shr.lean", line: 47 *)
    mk_fun "core::num::{i128}::wrapping_shr" "core.num.I128.wrapping_shr"
      ~can_fail:false;
    (* file: "Aeneas/Std/Scalar/CoreConvertNum.lean", line: 678 *)
    mk_fun "core::num::{i16}::cast_unsigned" "core.num.I16.cast_unsigned";
    (* file: "Aeneas/Std/Scalar/WrappingOps/Shl.lean", line: 43 *)
    mk_fun "core::num::{i16}::wrapping_shl" "core.num.I16.wrapping_shl"
      ~can_fail:false;
    (* file: "Aeneas/Std/Scalar/WrappingOps/Shr.lean", line: 44 *)
    mk_fun "core::num::{i16}::wrapping_shr" "core.num.I16.wrapping_shr"
      ~can_fail:false;
    (* file: "Aeneas/Std/CoreMisc.lean", line: 89 *)
    mk_fun "core::num::{i32}::abs" "core.num.I32.abs";
    (* file: "Aeneas/Std/Scalar/CoreConvertNum.lean", line: 684 *)
    mk_fun "core::num::{i32}::cast_unsigned" "core.num.I32.cast_unsigned";
    (* file: "Aeneas/Std/Scalar/WrappingOps/Shl.lean", line: 44 *)
    mk_fun "core::num::{i32}::wrapping_shl" "core.num.I32.wrapping_shl"
      ~can_fail:false;
    (* file: "Aeneas/Std/Scalar/WrappingOps/Shr.lean", line: 45 *)
    mk_fun "core::num::{i32}::wrapping_shr" "core.num.I32.wrapping_shr"
      ~can_fail:false;
    (* file: "Aeneas/Std/Scalar/CoreConvertNum.lean", line: 690 *)
    mk_fun "core::num::{i64}::cast_unsigned" "core.num.I64.cast_unsigned";
    (* file: "Aeneas/Std/CoreMisc.lean", line: 92 *)
    mk_fun "core::num::{i64}::unsigned_abs" "core.num.I64.unsigned_abs";
    (* file: "Aeneas/Std/Scalar/WrappingOps/Shl.lean", line: 45 *)
    mk_fun "core::num::{i64}::wrapping_shl" "core.num.I64.wrapping_shl"
      ~can_fail:false;
    (* file: "Aeneas/Std/Scalar/WrappingOps/Shr.lean", line: 46 *)
    mk_fun "core::num::{i64}::wrapping_shr" "core.num.I64.wrapping_shr"
      ~can_fail:false;
    (* file: "Aeneas/Std/Scalar/CoreConvertNum.lean", line: 672 *)
    mk_fun "core::num::{i8}::cast_unsigned" "core.num.I8.cast_unsigned";
    (* file: "Aeneas/Std/Scalar/WrappingOps/Shl.lean", line: 42 *)
    mk_fun "core::num::{i8}::wrapping_shl" "core.num.I8.wrapping_shl"
      ~can_fail:false;
    (* file: "Aeneas/Std/Scalar/WrappingOps/Shr.lean", line: 43 *)
    mk_fun "core::num::{i8}::wrapping_shr" "core.num.I8.wrapping_shr"
      ~can_fail:false;
    (* file: "Aeneas/Std/Scalar/CoreConvertNum.lean", line: 702 *)
    mk_fun "core::num::{isize}::cast_unsigned" "core.num.Isize.cast_unsigned";
    (* file: "Aeneas/Std/Scalar/WrappingOps/Shl.lean", line: 47 *)
    mk_fun "core::num::{isize}::wrapping_shl" "core.num.Isize.wrapping_shl"
      ~can_fail:false;
    (* file: "Aeneas/Std/Scalar/WrappingOps/Shr.lean", line: 48 *)
    mk_fun "core::num::{isize}::wrapping_shr" "core.num.Isize.wrapping_shr"
      ~can_fail:false;
    (* file: "Aeneas/Std/Scalar/CoreConvertNum.lean", line: 693 *)
    mk_fun "core::num::{u128}::cast_signed" "core.num.U128.cast_signed";
    (* file: "Aeneas/Std/Scalar/Ops/DivCeil.lean", line: 51 *)
    mk_fun "core::num::{u128}::div_ceil" "core.num.U128.div_ceil";
    (* file: "Aeneas/Std/Scalar/CoreConvertNum.lean", line: 786 *)
    mk_fun "core::num::{u128}::is_multiple_of" "core.num.U128.is_multiple_of";
    (* file: "Aeneas/Std/Scalar/Pow.lean", line: 29 *)
    mk_fun "core::num::{u128}::is_power_of_two" "core.num.U128.is_power_of_two";
    (* file: "Aeneas/Std/Scalar/WrappingOps/Shl.lean", line: 40 *)
    mk_fun "core::num::{u128}::wrapping_shl" "core.num.U128.wrapping_shl"
      ~can_fail:false;
    (* file: "Aeneas/Std/Scalar/WrappingOps/Shr.lean", line: 41 *)
    mk_fun "core::num::{u128}::wrapping_shr" "core.num.U128.wrapping_shr"
      ~can_fail:false;
    (* file: "Aeneas/Std/Scalar/CoreConvertNum.lean", line: 675 *)
    mk_fun "core::num::{u16}::cast_signed" "core.num.U16.cast_signed";
    (* file: "Aeneas/Std/Scalar/Ops/DivCeil.lean", line: 42 *)
    mk_fun "core::num::{u16}::div_ceil" "core.num.U16.div_ceil";
    (* file: "Aeneas/Std/Scalar/CoreConvertNum.lean", line: 777 *)
    mk_fun "core::num::{u16}::is_multiple_of" "core.num.U16.is_multiple_of";
    (* file: "Aeneas/Std/Scalar/Pow.lean", line: 20 *)
    mk_fun "core::num::{u16}::is_power_of_two" "core.num.U16.is_power_of_two";
    (* file: "Aeneas/Std/Scalar/WrappingOps/Shl.lean", line: 37 *)
    mk_fun "core::num::{u16}::wrapping_shl" "core.num.U16.wrapping_shl"
      ~can_fail:false;
    (* file: "Aeneas/Std/Scalar/WrappingOps/Shr.lean", line: 38 *)
    mk_fun "core::num::{u16}::wrapping_shr" "core.num.U16.wrapping_shr"
      ~can_fail:false;
    (* file: "Aeneas/Std/Scalar/CoreConvertNum.lean", line: 681 *)
    mk_fun "core::num::{u32}::cast_signed" "core.num.U32.cast_signed";
    (* file: "Aeneas/Std/Scalar/Ops/DivCeil.lean", line: 45 *)
    mk_fun "core::num::{u32}::div_ceil" "core.num.U32.div_ceil";
    (* file: "Aeneas/Std/Scalar/CoreConvertNum.lean", line: 780 *)
    mk_fun "core::num::{u32}::is_multiple_of" "core.num.U32.is_multiple_of";
    (* file: "Aeneas/Std/Scalar/Pow.lean", line: 23 *)
    mk_fun "core::num::{u32}::is_power_of_two" "core.num.U32.is_power_of_two";
    (* file: "Aeneas/Std/Scalar/WrappingOps/Shl.lean", line: 38 *)
    mk_fun "core::num::{u32}::wrapping_shl" "core.num.U32.wrapping_shl"
      ~can_fail:false;
    (* file: "Aeneas/Std/Scalar/WrappingOps/Shr.lean", line: 39 *)
    mk_fun "core::num::{u32}::wrapping_shr" "core.num.U32.wrapping_shr"
      ~can_fail:false;
    (* file: "Aeneas/Std/Scalar/CoreConvertNum.lean", line: 687 *)
    mk_fun "core::num::{u64}::cast_signed" "core.num.U64.cast_signed";
    (* file: "Aeneas/Std/Scalar/Ops/DivCeil.lean", line: 48 *)
    mk_fun "core::num::{u64}::div_ceil" "core.num.U64.div_ceil";
    (* file: "Aeneas/Std/Scalar/CoreConvertNum.lean", line: 783 *)
    mk_fun "core::num::{u64}::is_multiple_of" "core.num.U64.is_multiple_of";
    (* file: "Aeneas/Std/Scalar/Pow.lean", line: 26 *)
    mk_fun "core::num::{u64}::is_power_of_two" "core.num.U64.is_power_of_two";
    (* file: "Aeneas/Std/Scalar/WrappingOps/Shl.lean", line: 39 *)
    mk_fun "core::num::{u64}::wrapping_shl" "core.num.U64.wrapping_shl"
      ~can_fail:false;
    (* file: "Aeneas/Std/Scalar/WrappingOps/Shr.lean", line: 40 *)
    mk_fun "core::num::{u64}::wrapping_shr" "core.num.U64.wrapping_shr"
      ~can_fail:false;
    (* file: "Aeneas/Std/Scalar/CoreConvertNum.lean", line: 669 *)
    mk_fun "core::num::{u8}::cast_signed" "core.num.U8.cast_signed";
    (* file: "Aeneas/Std/Scalar/Ops/DivCeil.lean", line: 39 *)
    mk_fun "core::num::{u8}::div_ceil" "core.num.U8.div_ceil";
    (* file: "Aeneas/Std/Scalar/CoreConvertNum.lean", line: 774 *)
    mk_fun "core::num::{u8}::is_multiple_of" "core.num.U8.is_multiple_of";
    (* file: "Aeneas/Std/Scalar/Pow.lean", line: 17 *)
    mk_fun "core::num::{u8}::is_power_of_two" "core.num.U8.is_power_of_two";
    (* file: "Aeneas/Std/Scalar/WrappingOps/Shl.lean", line: 36 *)
    mk_fun "core::num::{u8}::wrapping_shl" "core.num.U8.wrapping_shl"
      ~can_fail:false;
    (* file: "Aeneas/Std/Scalar/WrappingOps/Shr.lean", line: 37 *)
    mk_fun "core::num::{u8}::wrapping_shr" "core.num.U8.wrapping_shr"
      ~can_fail:false;
    (* file: "Aeneas/Std/Scalar/CoreConvertNum.lean", line: 699 *)
    mk_fun "core::num::{usize}::cast_signed" "core.num.Usize.cast_signed";
    (* file: "Aeneas/Std/Scalar/Ops/DivCeil.lean", line: 54 *)
    mk_fun "core::num::{usize}::div_ceil" "core.num.Usize.div_ceil";
    (* file: "Aeneas/Std/Scalar/CoreConvertNum.lean", line: 789 *)
    mk_fun "core::num::{usize}::is_multiple_of" "core.num.Usize.is_multiple_of";
    (* file: "Aeneas/Std/Scalar/Pow.lean", line: 32 *)
    mk_fun "core::num::{usize}::is_power_of_two"
      "core.num.Usize.is_power_of_two";
    (* file: "Aeneas/Std/CoreMisc.lean", line: 96 *)
    mk_fun "core::num::{usize}::next_power_of_two"
      "core.num.Usize.next_power_of_two";
    (* file: "Aeneas/Std/Scalar/WrappingOps/Shl.lean", line: 41 *)
    mk_fun "core::num::{usize}::wrapping_shl" "core.num.Usize.wrapping_shl"
      ~can_fail:false;
    (* file: "Aeneas/Std/Scalar/WrappingOps/Shr.lean", line: 42 *)
    mk_fun "core::num::{usize}::wrapping_shr" "core.num.Usize.wrapping_shr"
      ~can_fail:false;
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 88 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Add<&'0 i128, i128, i128>}::add"
      "Shared0I128.Insts.CoreOpsArithAddI128I128.add";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 61 *)
    mk_fun "core::ops::arith::{core::ops::arith::Add<&'0 i16, i16, i16>}::add"
      "Shared0I16.Insts.CoreOpsArithAddI16I16.add";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 70 *)
    mk_fun "core::ops::arith::{core::ops::arith::Add<&'0 i32, i32, i32>}::add"
      "Shared0I32.Insts.CoreOpsArithAddI32I32.add";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 79 *)
    mk_fun "core::ops::arith::{core::ops::arith::Add<&'0 i64, i64, i64>}::add"
      "Shared0I64.Insts.CoreOpsArithAddI64I64.add";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 52 *)
    mk_fun "core::ops::arith::{core::ops::arith::Add<&'0 i8, i8, i8>}::add"
      "Shared0I8.Insts.CoreOpsArithAddI8I8.add";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 97 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Add<&'0 isize, isize, isize>}::add"
      "Shared0Isize.Insts.CoreOpsArithAddIsizeIsize.add";
    (* file: "Aeneas/Std/Scalar/Ops/Add.lean", line: 176 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Add<&'0 u128, u128, u128>}::add"
      "SharedU128.Insts.CoreOpsArithAddU128U128.add";
    (* file: "Aeneas/Std/Scalar/Ops/Add.lean", line: 170 *)
    mk_fun "core::ops::arith::{core::ops::arith::Add<&'0 u16, u16, u16>}::add"
      "SharedU16.Insts.CoreOpsArithAddU16U16.add";
    (* file: "Aeneas/Std/Scalar/Ops/Add.lean", line: 172 *)
    mk_fun "core::ops::arith::{core::ops::arith::Add<&'0 u32, u32, u32>}::add"
      "SharedU32.Insts.CoreOpsArithAddU32U32.add";
    (* file: "Aeneas/Std/Scalar/Ops/Add.lean", line: 174 *)
    mk_fun "core::ops::arith::{core::ops::arith::Add<&'0 u64, u64, u64>}::add"
      "SharedU64.Insts.CoreOpsArithAddU64U64.add";
    (* file: "Aeneas/Std/Scalar/Ops/Add.lean", line: 168 *)
    mk_fun "core::ops::arith::{core::ops::arith::Add<&'0 u8, u8, u8>}::add"
      "SharedU8.Insts.CoreOpsArithAddU8U8.add";
    (* file: "Aeneas/Std/Scalar/Ops/Add.lean", line: 178 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Add<&'0 usize, usize, usize>}::add"
      "SharedUsize.Insts.CoreOpsArithAddUsizeUsize.add";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 94 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Add<&'1 i128, &'0 i128, i128>}::add"
      "Shared1I128.Insts.CoreOpsArithAddShared0I128I128.add";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 67 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Add<&'1 i16, &'0 i16, i16>}::add"
      "Shared1I16.Insts.CoreOpsArithAddShared0I16I16.add";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 76 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Add<&'1 i32, &'0 i32, i32>}::add"
      "Shared1I32.Insts.CoreOpsArithAddShared0I32I32.add";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 85 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Add<&'1 i64, &'0 i64, i64>}::add"
      "Shared1I64.Insts.CoreOpsArithAddShared0I64I64.add";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 58 *)
    mk_fun "core::ops::arith::{core::ops::arith::Add<&'1 i8, &'0 i8, i8>}::add"
      "Shared1I8.Insts.CoreOpsArithAddShared0I8I8.add";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 103 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Add<&'1 isize, &'0 isize, \
       isize>}::add"
      "Shared1Isize.Insts.CoreOpsArithAddShared0IsizeIsize.add";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 43 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Add<&'1 u128, &'0 u128, u128>}::add"
      "Shared1U128.Insts.CoreOpsArithAddShared0U128U128.add";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 25 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Add<&'1 u16, &'0 u16, u16>}::add"
      "Shared1U16.Insts.CoreOpsArithAddShared0U16U16.add";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 31 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Add<&'1 u32, &'0 u32, u32>}::add"
      "Shared1U32.Insts.CoreOpsArithAddShared0U32U32.add";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 37 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Add<&'1 u64, &'0 u64, u64>}::add"
      "Shared1U64.Insts.CoreOpsArithAddShared0U64U64.add";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 19 *)
    mk_fun "core::ops::arith::{core::ops::arith::Add<&'1 u8, &'0 u8, u8>}::add"
      "Shared1U8.Insts.CoreOpsArithAddShared0U8U8.add";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 49 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Add<&'1 usize, &'0 usize, \
       usize>}::add"
      "Shared1Usize.Insts.CoreOpsArithAddShared0UsizeUsize.add";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 91 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Add<i128, &'0 i128, i128>}::add"
      "I128.Insts.CoreOpsArithAddShared0I128I128.add";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 64 *)
    mk_fun "core::ops::arith::{core::ops::arith::Add<i16, &'0 i16, i16>}::add"
      "I16.Insts.CoreOpsArithAddShared0I16I16.add";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 73 *)
    mk_fun "core::ops::arith::{core::ops::arith::Add<i32, &'0 i32, i32>}::add"
      "I32.Insts.CoreOpsArithAddShared0I32I32.add";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 82 *)
    mk_fun "core::ops::arith::{core::ops::arith::Add<i64, &'0 i64, i64>}::add"
      "I64.Insts.CoreOpsArithAddShared0I64I64.add";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 55 *)
    mk_fun "core::ops::arith::{core::ops::arith::Add<i8, &'0 i8, i8>}::add"
      "I8.Insts.CoreOpsArithAddShared0I8I8.add";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 100 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Add<isize, &'0 isize, isize>}::add"
      "Isize.Insts.CoreOpsArithAddShared0IsizeIsize.add";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 40 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Add<u128, &'0 u128, u128>}::add"
      "U128.Insts.CoreOpsArithAddShared0U128U128.add";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 22 *)
    mk_fun "core::ops::arith::{core::ops::arith::Add<u16, &'0 u16, u16>}::add"
      "U16.Insts.CoreOpsArithAddShared0U16U16.add";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 28 *)
    mk_fun "core::ops::arith::{core::ops::arith::Add<u32, &'0 u32, u32>}::add"
      "U32.Insts.CoreOpsArithAddShared0U32U32.add";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 34 *)
    mk_fun "core::ops::arith::{core::ops::arith::Add<u64, &'0 u64, u64>}::add"
      "U64.Insts.CoreOpsArithAddShared0U64U64.add";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 16 *)
    mk_fun "core::ops::arith::{core::ops::arith::Add<u8, &'0 u8, u8>}::add"
      "U8.Insts.CoreOpsArithAddShared0U8U8.add";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 46 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Add<usize, &'0 usize, usize>}::add"
      "Usize.Insts.CoreOpsArithAddShared0UsizeUsize.add";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 894 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::AddAssign<i128, &'0 \
       i128>}::add_assign"
      "I128.Insts.CoreOpsArithAddAssignShared0I128.add_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 885 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::AddAssign<i16, &'0 \
       i16>}::add_assign"
      "I16.Insts.CoreOpsArithAddAssignShared0I16.add_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 888 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::AddAssign<i32, &'0 \
       i32>}::add_assign"
      "I32.Insts.CoreOpsArithAddAssignShared0I32.add_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 891 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::AddAssign<i64, &'0 \
       i64>}::add_assign"
      "I64.Insts.CoreOpsArithAddAssignShared0I64.add_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 882 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::AddAssign<i8, &'0 i8>}::add_assign"
      "I8.Insts.CoreOpsArithAddAssignShared0I8.add_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 897 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::AddAssign<isize, &'0 \
       isize>}::add_assign"
      "Isize.Insts.CoreOpsArithAddAssignShared0Isize.add_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 876 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::AddAssign<u128, &'0 \
       u128>}::add_assign"
      "U128.Insts.CoreOpsArithAddAssignShared0U128.add_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 867 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::AddAssign<u16, &'0 \
       u16>}::add_assign"
      "U16.Insts.CoreOpsArithAddAssignShared0U16.add_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 870 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::AddAssign<u32, &'0 \
       u32>}::add_assign"
      "U32.Insts.CoreOpsArithAddAssignShared0U32.add_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 873 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::AddAssign<u64, &'0 \
       u64>}::add_assign"
      "U64.Insts.CoreOpsArithAddAssignShared0U64.add_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 864 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::AddAssign<u8, &'0 u8>}::add_assign"
      "U8.Insts.CoreOpsArithAddAssignShared0U8.add_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 879 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::AddAssign<usize, &'0 \
       usize>}::add_assign"
      "Usize.Insts.CoreOpsArithAddAssignShared0Usize.add_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 412 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Div<&'0 i128, i128, i128>}::div"
      "Shared0I128.Insts.CoreOpsArithDivI128I128.div";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 385 *)
    mk_fun "core::ops::arith::{core::ops::arith::Div<&'0 i16, i16, i16>}::div"
      "Shared0I16.Insts.CoreOpsArithDivI16I16.div";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 394 *)
    mk_fun "core::ops::arith::{core::ops::arith::Div<&'0 i32, i32, i32>}::div"
      "Shared0I32.Insts.CoreOpsArithDivI32I32.div";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 403 *)
    mk_fun "core::ops::arith::{core::ops::arith::Div<&'0 i64, i64, i64>}::div"
      "Shared0I64.Insts.CoreOpsArithDivI64I64.div";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 376 *)
    mk_fun "core::ops::arith::{core::ops::arith::Div<&'0 i8, i8, i8>}::div"
      "Shared0I8.Insts.CoreOpsArithDivI8I8.div";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 421 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Div<&'0 isize, isize, isize>}::div"
      "Shared0Isize.Insts.CoreOpsArithDivIsizeIsize.div";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 358 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Div<&'0 u128, u128, u128>}::div"
      "Shared0U128.Insts.CoreOpsArithDivU128U128.div";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 331 *)
    mk_fun "core::ops::arith::{core::ops::arith::Div<&'0 u16, u16, u16>}::div"
      "Shared0U16.Insts.CoreOpsArithDivU16U16.div";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 340 *)
    mk_fun "core::ops::arith::{core::ops::arith::Div<&'0 u32, u32, u32>}::div"
      "Shared0U32.Insts.CoreOpsArithDivU32U32.div";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 349 *)
    mk_fun "core::ops::arith::{core::ops::arith::Div<&'0 u64, u64, u64>}::div"
      "Shared0U64.Insts.CoreOpsArithDivU64U64.div";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 322 *)
    mk_fun "core::ops::arith::{core::ops::arith::Div<&'0 u8, u8, u8>}::div"
      "Shared0U8.Insts.CoreOpsArithDivU8U8.div";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 367 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Div<&'0 usize, usize, usize>}::div"
      "Shared0Usize.Insts.CoreOpsArithDivUsizeUsize.div";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 418 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Div<&'1 i128, &'0 i128, i128>}::div"
      "Shared1I128.Insts.CoreOpsArithDivShared0I128I128.div";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 391 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Div<&'1 i16, &'0 i16, i16>}::div"
      "Shared1I16.Insts.CoreOpsArithDivShared0I16I16.div";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 400 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Div<&'1 i32, &'0 i32, i32>}::div"
      "Shared1I32.Insts.CoreOpsArithDivShared0I32I32.div";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 409 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Div<&'1 i64, &'0 i64, i64>}::div"
      "Shared1I64.Insts.CoreOpsArithDivShared0I64I64.div";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 382 *)
    mk_fun "core::ops::arith::{core::ops::arith::Div<&'1 i8, &'0 i8, i8>}::div"
      "Shared1I8.Insts.CoreOpsArithDivShared0I8I8.div";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 427 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Div<&'1 isize, &'0 isize, \
       isize>}::div"
      "Shared1Isize.Insts.CoreOpsArithDivShared0IsizeIsize.div";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 364 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Div<&'1 u128, &'0 u128, u128>}::div"
      "Shared1U128.Insts.CoreOpsArithDivShared0U128U128.div";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 337 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Div<&'1 u16, &'0 u16, u16>}::div"
      "Shared1U16.Insts.CoreOpsArithDivShared0U16U16.div";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 346 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Div<&'1 u32, &'0 u32, u32>}::div"
      "Shared1U32.Insts.CoreOpsArithDivShared0U32U32.div";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 355 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Div<&'1 u64, &'0 u64, u64>}::div"
      "Shared1U64.Insts.CoreOpsArithDivShared0U64U64.div";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 328 *)
    mk_fun "core::ops::arith::{core::ops::arith::Div<&'1 u8, &'0 u8, u8>}::div"
      "Shared1U8.Insts.CoreOpsArithDivShared0U8U8.div";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 373 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Div<&'1 usize, &'0 usize, \
       usize>}::div"
      "Shared1Usize.Insts.CoreOpsArithDivShared0UsizeUsize.div";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 415 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Div<i128, &'0 i128, i128>}::div"
      "I128.Insts.CoreOpsArithDivShared0I128I128.div";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 388 *)
    mk_fun "core::ops::arith::{core::ops::arith::Div<i16, &'0 i16, i16>}::div"
      "I16.Insts.CoreOpsArithDivShared0I16I16.div";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 397 *)
    mk_fun "core::ops::arith::{core::ops::arith::Div<i32, &'0 i32, i32>}::div"
      "I32.Insts.CoreOpsArithDivShared0I32I32.div";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 406 *)
    mk_fun "core::ops::arith::{core::ops::arith::Div<i64, &'0 i64, i64>}::div"
      "I64.Insts.CoreOpsArithDivShared0I64I64.div";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 379 *)
    mk_fun "core::ops::arith::{core::ops::arith::Div<i8, &'0 i8, i8>}::div"
      "I8.Insts.CoreOpsArithDivShared0I8I8.div";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 424 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Div<isize, &'0 isize, isize>}::div"
      "Isize.Insts.CoreOpsArithDivShared0IsizeIsize.div";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 361 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Div<u128, &'0 u128, u128>}::div"
      "U128.Insts.CoreOpsArithDivShared0U128U128.div";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 334 *)
    mk_fun "core::ops::arith::{core::ops::arith::Div<u16, &'0 u16, u16>}::div"
      "U16.Insts.CoreOpsArithDivShared0U16U16.div";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 343 *)
    mk_fun "core::ops::arith::{core::ops::arith::Div<u32, &'0 u32, u32>}::div"
      "U32.Insts.CoreOpsArithDivShared0U32U32.div";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 352 *)
    mk_fun "core::ops::arith::{core::ops::arith::Div<u64, &'0 u64, u64>}::div"
      "U64.Insts.CoreOpsArithDivShared0U64U64.div";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 325 *)
    mk_fun "core::ops::arith::{core::ops::arith::Div<u8, &'0 u8, u8>}::div"
      "U8.Insts.CoreOpsArithDivShared0U8U8.div";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 370 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Div<usize, &'0 usize, usize>}::div"
      "Usize.Insts.CoreOpsArithDivShared0UsizeUsize.div";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1002 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::DivAssign<i128, &'0 \
       i128>}::div_assign"
      "I128.Insts.CoreOpsArithDivAssignShared0I128.div_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 993 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::DivAssign<i16, &'0 \
       i16>}::div_assign"
      "I16.Insts.CoreOpsArithDivAssignShared0I16.div_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 996 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::DivAssign<i32, &'0 \
       i32>}::div_assign"
      "I32.Insts.CoreOpsArithDivAssignShared0I32.div_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 999 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::DivAssign<i64, &'0 \
       i64>}::div_assign"
      "I64.Insts.CoreOpsArithDivAssignShared0I64.div_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 990 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::DivAssign<i8, &'0 i8>}::div_assign"
      "I8.Insts.CoreOpsArithDivAssignShared0I8.div_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1005 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::DivAssign<isize, &'0 \
       isize>}::div_assign"
      "Isize.Insts.CoreOpsArithDivAssignShared0Isize.div_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 984 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::DivAssign<u128, &'0 \
       u128>}::div_assign"
      "U128.Insts.CoreOpsArithDivAssignShared0U128.div_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 975 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::DivAssign<u16, &'0 \
       u16>}::div_assign"
      "U16.Insts.CoreOpsArithDivAssignShared0U16.div_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 978 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::DivAssign<u32, &'0 \
       u32>}::div_assign"
      "U32.Insts.CoreOpsArithDivAssignShared0U32.div_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 981 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::DivAssign<u64, &'0 \
       u64>}::div_assign"
      "U64.Insts.CoreOpsArithDivAssignShared0U64.div_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 972 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::DivAssign<u8, &'0 u8>}::div_assign"
      "U8.Insts.CoreOpsArithDivAssignShared0U8.div_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 987 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::DivAssign<usize, &'0 \
       usize>}::div_assign"
      "Usize.Insts.CoreOpsArithDivAssignShared0Usize.div_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 304 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Mul<&'0 i128, i128, i128>}::mul"
      "Shared0I128.Insts.CoreOpsArithMulI128I128.mul";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 277 *)
    mk_fun "core::ops::arith::{core::ops::arith::Mul<&'0 i16, i16, i16>}::mul"
      "Shared0I16.Insts.CoreOpsArithMulI16I16.mul";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 286 *)
    mk_fun "core::ops::arith::{core::ops::arith::Mul<&'0 i32, i32, i32>}::mul"
      "Shared0I32.Insts.CoreOpsArithMulI32I32.mul";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 295 *)
    mk_fun "core::ops::arith::{core::ops::arith::Mul<&'0 i64, i64, i64>}::mul"
      "Shared0I64.Insts.CoreOpsArithMulI64I64.mul";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 268 *)
    mk_fun "core::ops::arith::{core::ops::arith::Mul<&'0 i8, i8, i8>}::mul"
      "Shared0I8.Insts.CoreOpsArithMulI8I8.mul";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 313 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Mul<&'0 isize, isize, isize>}::mul"
      "Shared0Isize.Insts.CoreOpsArithMulIsizeIsize.mul";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 250 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Mul<&'0 u128, u128, u128>}::mul"
      "Shared0U128.Insts.CoreOpsArithMulU128U128.mul";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 223 *)
    mk_fun "core::ops::arith::{core::ops::arith::Mul<&'0 u16, u16, u16>}::mul"
      "Shared0U16.Insts.CoreOpsArithMulU16U16.mul";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 232 *)
    mk_fun "core::ops::arith::{core::ops::arith::Mul<&'0 u32, u32, u32>}::mul"
      "Shared0U32.Insts.CoreOpsArithMulU32U32.mul";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 241 *)
    mk_fun "core::ops::arith::{core::ops::arith::Mul<&'0 u64, u64, u64>}::mul"
      "Shared0U64.Insts.CoreOpsArithMulU64U64.mul";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 214 *)
    mk_fun "core::ops::arith::{core::ops::arith::Mul<&'0 u8, u8, u8>}::mul"
      "Shared0U8.Insts.CoreOpsArithMulU8U8.mul";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 259 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Mul<&'0 usize, usize, usize>}::mul"
      "Shared0Usize.Insts.CoreOpsArithMulUsizeUsize.mul";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 310 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Mul<&'1 i128, &'0 i128, i128>}::mul"
      "Shared1I128.Insts.CoreOpsArithMulShared0I128I128.mul";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 283 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Mul<&'1 i16, &'0 i16, i16>}::mul"
      "Shared1I16.Insts.CoreOpsArithMulShared0I16I16.mul";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 292 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Mul<&'1 i32, &'0 i32, i32>}::mul"
      "Shared1I32.Insts.CoreOpsArithMulShared0I32I32.mul";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 301 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Mul<&'1 i64, &'0 i64, i64>}::mul"
      "Shared1I64.Insts.CoreOpsArithMulShared0I64I64.mul";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 274 *)
    mk_fun "core::ops::arith::{core::ops::arith::Mul<&'1 i8, &'0 i8, i8>}::mul"
      "Shared1I8.Insts.CoreOpsArithMulShared0I8I8.mul";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 319 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Mul<&'1 isize, &'0 isize, \
       isize>}::mul"
      "Shared1Isize.Insts.CoreOpsArithMulShared0IsizeIsize.mul";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 256 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Mul<&'1 u128, &'0 u128, u128>}::mul"
      "Shared1U128.Insts.CoreOpsArithMulShared0U128U128.mul";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 229 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Mul<&'1 u16, &'0 u16, u16>}::mul"
      "Shared1U16.Insts.CoreOpsArithMulShared0U16U16.mul";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 238 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Mul<&'1 u32, &'0 u32, u32>}::mul"
      "Shared1U32.Insts.CoreOpsArithMulShared0U32U32.mul";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 247 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Mul<&'1 u64, &'0 u64, u64>}::mul"
      "Shared1U64.Insts.CoreOpsArithMulShared0U64U64.mul";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 220 *)
    mk_fun "core::ops::arith::{core::ops::arith::Mul<&'1 u8, &'0 u8, u8>}::mul"
      "Shared1U8.Insts.CoreOpsArithMulShared0U8U8.mul";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 265 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Mul<&'1 usize, &'0 usize, \
       usize>}::mul"
      "Shared1Usize.Insts.CoreOpsArithMulShared0UsizeUsize.mul";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 307 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Mul<i128, &'0 i128, i128>}::mul"
      "I128.Insts.CoreOpsArithMulShared0I128I128.mul";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 280 *)
    mk_fun "core::ops::arith::{core::ops::arith::Mul<i16, &'0 i16, i16>}::mul"
      "I16.Insts.CoreOpsArithMulShared0I16I16.mul";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 289 *)
    mk_fun "core::ops::arith::{core::ops::arith::Mul<i32, &'0 i32, i32>}::mul"
      "I32.Insts.CoreOpsArithMulShared0I32I32.mul";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 298 *)
    mk_fun "core::ops::arith::{core::ops::arith::Mul<i64, &'0 i64, i64>}::mul"
      "I64.Insts.CoreOpsArithMulShared0I64I64.mul";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 271 *)
    mk_fun "core::ops::arith::{core::ops::arith::Mul<i8, &'0 i8, i8>}::mul"
      "I8.Insts.CoreOpsArithMulShared0I8I8.mul";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 316 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Mul<isize, &'0 isize, isize>}::mul"
      "Isize.Insts.CoreOpsArithMulShared0IsizeIsize.mul";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 253 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Mul<u128, &'0 u128, u128>}::mul"
      "U128.Insts.CoreOpsArithMulShared0U128U128.mul";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 226 *)
    mk_fun "core::ops::arith::{core::ops::arith::Mul<u16, &'0 u16, u16>}::mul"
      "U16.Insts.CoreOpsArithMulShared0U16U16.mul";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 235 *)
    mk_fun "core::ops::arith::{core::ops::arith::Mul<u32, &'0 u32, u32>}::mul"
      "U32.Insts.CoreOpsArithMulShared0U32U32.mul";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 244 *)
    mk_fun "core::ops::arith::{core::ops::arith::Mul<u64, &'0 u64, u64>}::mul"
      "U64.Insts.CoreOpsArithMulShared0U64U64.mul";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 217 *)
    mk_fun "core::ops::arith::{core::ops::arith::Mul<u8, &'0 u8, u8>}::mul"
      "U8.Insts.CoreOpsArithMulShared0U8U8.mul";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 262 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Mul<usize, &'0 usize, usize>}::mul"
      "Usize.Insts.CoreOpsArithMulShared0UsizeUsize.mul";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 966 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::MulAssign<i128, &'0 \
       i128>}::mul_assign"
      "I128.Insts.CoreOpsArithMulAssignShared0I128.mul_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 957 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::MulAssign<i16, &'0 \
       i16>}::mul_assign"
      "I16.Insts.CoreOpsArithMulAssignShared0I16.mul_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 960 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::MulAssign<i32, &'0 \
       i32>}::mul_assign"
      "I32.Insts.CoreOpsArithMulAssignShared0I32.mul_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 963 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::MulAssign<i64, &'0 \
       i64>}::mul_assign"
      "I64.Insts.CoreOpsArithMulAssignShared0I64.mul_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 954 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::MulAssign<i8, &'0 i8>}::mul_assign"
      "I8.Insts.CoreOpsArithMulAssignShared0I8.mul_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 969 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::MulAssign<isize, &'0 \
       isize>}::mul_assign"
      "Isize.Insts.CoreOpsArithMulAssignShared0Isize.mul_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 948 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::MulAssign<u128, &'0 \
       u128>}::mul_assign"
      "U128.Insts.CoreOpsArithMulAssignShared0U128.mul_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 939 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::MulAssign<u16, &'0 \
       u16>}::mul_assign"
      "U16.Insts.CoreOpsArithMulAssignShared0U16.mul_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 942 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::MulAssign<u32, &'0 \
       u32>}::mul_assign"
      "U32.Insts.CoreOpsArithMulAssignShared0U32.mul_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 945 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::MulAssign<u64, &'0 \
       u64>}::mul_assign"
      "U64.Insts.CoreOpsArithMulAssignShared0U64.mul_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 936 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::MulAssign<u8, &'0 u8>}::mul_assign"
      "U8.Insts.CoreOpsArithMulAssignShared0U8.mul_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 951 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::MulAssign<usize, &'0 \
       usize>}::mul_assign"
      "Usize.Insts.CoreOpsArithMulAssignShared0Usize.mul_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 520 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Rem<&'0 i128, i128, i128>}::rem"
      "Shared0I128.Insts.CoreOpsArithRemI128I128.rem";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 493 *)
    mk_fun "core::ops::arith::{core::ops::arith::Rem<&'0 i16, i16, i16>}::rem"
      "Shared0I16.Insts.CoreOpsArithRemI16I16.rem";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 502 *)
    mk_fun "core::ops::arith::{core::ops::arith::Rem<&'0 i32, i32, i32>}::rem"
      "Shared0I32.Insts.CoreOpsArithRemI32I32.rem";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 511 *)
    mk_fun "core::ops::arith::{core::ops::arith::Rem<&'0 i64, i64, i64>}::rem"
      "Shared0I64.Insts.CoreOpsArithRemI64I64.rem";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 484 *)
    mk_fun "core::ops::arith::{core::ops::arith::Rem<&'0 i8, i8, i8>}::rem"
      "Shared0I8.Insts.CoreOpsArithRemI8I8.rem";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 529 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Rem<&'0 isize, isize, isize>}::rem"
      "Shared0Isize.Insts.CoreOpsArithRemIsizeIsize.rem";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 466 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Rem<&'0 u128, u128, u128>}::rem"
      "Shared0U128.Insts.CoreOpsArithRemU128U128.rem";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 439 *)
    mk_fun "core::ops::arith::{core::ops::arith::Rem<&'0 u16, u16, u16>}::rem"
      "Shared0U16.Insts.CoreOpsArithRemU16U16.rem";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 448 *)
    mk_fun "core::ops::arith::{core::ops::arith::Rem<&'0 u32, u32, u32>}::rem"
      "Shared0U32.Insts.CoreOpsArithRemU32U32.rem";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 457 *)
    mk_fun "core::ops::arith::{core::ops::arith::Rem<&'0 u64, u64, u64>}::rem"
      "Shared0U64.Insts.CoreOpsArithRemU64U64.rem";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 430 *)
    mk_fun "core::ops::arith::{core::ops::arith::Rem<&'0 u8, u8, u8>}::rem"
      "Shared0U8.Insts.CoreOpsArithRemU8U8.rem";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 475 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Rem<&'0 usize, usize, usize>}::rem"
      "Shared0Usize.Insts.CoreOpsArithRemUsizeUsize.rem";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 526 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Rem<&'1 i128, &'0 i128, i128>}::rem"
      "Shared1I128.Insts.CoreOpsArithRemShared0I128I128.rem";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 499 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Rem<&'1 i16, &'0 i16, i16>}::rem"
      "Shared1I16.Insts.CoreOpsArithRemShared0I16I16.rem";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 508 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Rem<&'1 i32, &'0 i32, i32>}::rem"
      "Shared1I32.Insts.CoreOpsArithRemShared0I32I32.rem";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 517 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Rem<&'1 i64, &'0 i64, i64>}::rem"
      "Shared1I64.Insts.CoreOpsArithRemShared0I64I64.rem";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 490 *)
    mk_fun "core::ops::arith::{core::ops::arith::Rem<&'1 i8, &'0 i8, i8>}::rem"
      "Shared1I8.Insts.CoreOpsArithRemShared0I8I8.rem";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 535 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Rem<&'1 isize, &'0 isize, \
       isize>}::rem"
      "Shared1Isize.Insts.CoreOpsArithRemShared0IsizeIsize.rem";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 472 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Rem<&'1 u128, &'0 u128, u128>}::rem"
      "Shared1U128.Insts.CoreOpsArithRemShared0U128U128.rem";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 445 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Rem<&'1 u16, &'0 u16, u16>}::rem"
      "Shared1U16.Insts.CoreOpsArithRemShared0U16U16.rem";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 454 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Rem<&'1 u32, &'0 u32, u32>}::rem"
      "Shared1U32.Insts.CoreOpsArithRemShared0U32U32.rem";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 463 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Rem<&'1 u64, &'0 u64, u64>}::rem"
      "Shared1U64.Insts.CoreOpsArithRemShared0U64U64.rem";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 436 *)
    mk_fun "core::ops::arith::{core::ops::arith::Rem<&'1 u8, &'0 u8, u8>}::rem"
      "Shared1U8.Insts.CoreOpsArithRemShared0U8U8.rem";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 481 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Rem<&'1 usize, &'0 usize, \
       usize>}::rem"
      "Shared1Usize.Insts.CoreOpsArithRemShared0UsizeUsize.rem";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 523 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Rem<i128, &'0 i128, i128>}::rem"
      "I128.Insts.CoreOpsArithRemShared0I128I128.rem";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 496 *)
    mk_fun "core::ops::arith::{core::ops::arith::Rem<i16, &'0 i16, i16>}::rem"
      "I16.Insts.CoreOpsArithRemShared0I16I16.rem";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 505 *)
    mk_fun "core::ops::arith::{core::ops::arith::Rem<i32, &'0 i32, i32>}::rem"
      "I32.Insts.CoreOpsArithRemShared0I32I32.rem";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 514 *)
    mk_fun "core::ops::arith::{core::ops::arith::Rem<i64, &'0 i64, i64>}::rem"
      "I64.Insts.CoreOpsArithRemShared0I64I64.rem";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 487 *)
    mk_fun "core::ops::arith::{core::ops::arith::Rem<i8, &'0 i8, i8>}::rem"
      "I8.Insts.CoreOpsArithRemShared0I8I8.rem";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 532 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Rem<isize, &'0 isize, isize>}::rem"
      "Isize.Insts.CoreOpsArithRemShared0IsizeIsize.rem";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 469 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Rem<u128, &'0 u128, u128>}::rem"
      "U128.Insts.CoreOpsArithRemShared0U128U128.rem";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 442 *)
    mk_fun "core::ops::arith::{core::ops::arith::Rem<u16, &'0 u16, u16>}::rem"
      "U16.Insts.CoreOpsArithRemShared0U16U16.rem";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 451 *)
    mk_fun "core::ops::arith::{core::ops::arith::Rem<u32, &'0 u32, u32>}::rem"
      "U32.Insts.CoreOpsArithRemShared0U32U32.rem";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 460 *)
    mk_fun "core::ops::arith::{core::ops::arith::Rem<u64, &'0 u64, u64>}::rem"
      "U64.Insts.CoreOpsArithRemShared0U64U64.rem";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 433 *)
    mk_fun "core::ops::arith::{core::ops::arith::Rem<u8, &'0 u8, u8>}::rem"
      "U8.Insts.CoreOpsArithRemShared0U8U8.rem";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 478 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Rem<usize, &'0 usize, usize>}::rem"
      "Usize.Insts.CoreOpsArithRemShared0UsizeUsize.rem";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1038 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::RemAssign<i128, &'0 \
       i128>}::rem_assign"
      "I128.Insts.CoreOpsArithRemAssignShared0I128.rem_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1029 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::RemAssign<i16, &'0 \
       i16>}::rem_assign"
      "I16.Insts.CoreOpsArithRemAssignShared0I16.rem_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1032 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::RemAssign<i32, &'0 \
       i32>}::rem_assign"
      "I32.Insts.CoreOpsArithRemAssignShared0I32.rem_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1035 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::RemAssign<i64, &'0 \
       i64>}::rem_assign"
      "I64.Insts.CoreOpsArithRemAssignShared0I64.rem_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1026 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::RemAssign<i8, &'0 i8>}::rem_assign"
      "I8.Insts.CoreOpsArithRemAssignShared0I8.rem_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1041 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::RemAssign<isize, &'0 \
       isize>}::rem_assign"
      "Isize.Insts.CoreOpsArithRemAssignShared0Isize.rem_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1020 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::RemAssign<u128, &'0 \
       u128>}::rem_assign"
      "U128.Insts.CoreOpsArithRemAssignShared0U128.rem_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1011 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::RemAssign<u16, &'0 \
       u16>}::rem_assign"
      "U16.Insts.CoreOpsArithRemAssignShared0U16.rem_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1014 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::RemAssign<u32, &'0 \
       u32>}::rem_assign"
      "U32.Insts.CoreOpsArithRemAssignShared0U32.rem_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1017 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::RemAssign<u64, &'0 \
       u64>}::rem_assign"
      "U64.Insts.CoreOpsArithRemAssignShared0U64.rem_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1008 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::RemAssign<u8, &'0 u8>}::rem_assign"
      "U8.Insts.CoreOpsArithRemAssignShared0U8.rem_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1023 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::RemAssign<usize, &'0 \
       usize>}::rem_assign"
      "Usize.Insts.CoreOpsArithRemAssignShared0Usize.rem_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 196 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Sub<&'0 i128, i128, i128>}::sub"
      "Shared0I128.Insts.CoreOpsArithSubI128I128.sub";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 169 *)
    mk_fun "core::ops::arith::{core::ops::arith::Sub<&'0 i16, i16, i16>}::sub"
      "Shared0I16.Insts.CoreOpsArithSubI16I16.sub";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 178 *)
    mk_fun "core::ops::arith::{core::ops::arith::Sub<&'0 i32, i32, i32>}::sub"
      "Shared0I32.Insts.CoreOpsArithSubI32I32.sub";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 187 *)
    mk_fun "core::ops::arith::{core::ops::arith::Sub<&'0 i64, i64, i64>}::sub"
      "Shared0I64.Insts.CoreOpsArithSubI64I64.sub";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 160 *)
    mk_fun "core::ops::arith::{core::ops::arith::Sub<&'0 i8, i8, i8>}::sub"
      "Shared0I8.Insts.CoreOpsArithSubI8I8.sub";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 205 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Sub<&'0 isize, isize, isize>}::sub"
      "Shared0Isize.Insts.CoreOpsArithSubIsizeIsize.sub";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 142 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Sub<&'0 u128, u128, u128>}::sub"
      "Shared0U128.Insts.CoreOpsArithSubU128U128.sub";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 115 *)
    mk_fun "core::ops::arith::{core::ops::arith::Sub<&'0 u16, u16, u16>}::sub"
      "Shared0U16.Insts.CoreOpsArithSubU16U16.sub";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 124 *)
    mk_fun "core::ops::arith::{core::ops::arith::Sub<&'0 u32, u32, u32>}::sub"
      "Shared0U32.Insts.CoreOpsArithSubU32U32.sub";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 133 *)
    mk_fun "core::ops::arith::{core::ops::arith::Sub<&'0 u64, u64, u64>}::sub"
      "Shared0U64.Insts.CoreOpsArithSubU64U64.sub";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 106 *)
    mk_fun "core::ops::arith::{core::ops::arith::Sub<&'0 u8, u8, u8>}::sub"
      "Shared0U8.Insts.CoreOpsArithSubU8U8.sub";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 151 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Sub<&'0 usize, usize, usize>}::sub"
      "Shared0Usize.Insts.CoreOpsArithSubUsizeUsize.sub";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 202 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Sub<&'1 i128, &'0 i128, i128>}::sub"
      "Shared1I128.Insts.CoreOpsArithSubShared0I128I128.sub";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 175 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Sub<&'1 i16, &'0 i16, i16>}::sub"
      "Shared1I16.Insts.CoreOpsArithSubShared0I16I16.sub";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 184 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Sub<&'1 i32, &'0 i32, i32>}::sub"
      "Shared1I32.Insts.CoreOpsArithSubShared0I32I32.sub";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 193 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Sub<&'1 i64, &'0 i64, i64>}::sub"
      "Shared1I64.Insts.CoreOpsArithSubShared0I64I64.sub";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 166 *)
    mk_fun "core::ops::arith::{core::ops::arith::Sub<&'1 i8, &'0 i8, i8>}::sub"
      "Shared1I8.Insts.CoreOpsArithSubShared0I8I8.sub";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 211 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Sub<&'1 isize, &'0 isize, \
       isize>}::sub"
      "Shared1Isize.Insts.CoreOpsArithSubShared0IsizeIsize.sub";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 148 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Sub<&'1 u128, &'0 u128, u128>}::sub"
      "Shared1U128.Insts.CoreOpsArithSubShared0U128U128.sub";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 121 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Sub<&'1 u16, &'0 u16, u16>}::sub"
      "Shared1U16.Insts.CoreOpsArithSubShared0U16U16.sub";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 130 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Sub<&'1 u32, &'0 u32, u32>}::sub"
      "Shared1U32.Insts.CoreOpsArithSubShared0U32U32.sub";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 139 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Sub<&'1 u64, &'0 u64, u64>}::sub"
      "Shared1U64.Insts.CoreOpsArithSubShared0U64U64.sub";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 112 *)
    mk_fun "core::ops::arith::{core::ops::arith::Sub<&'1 u8, &'0 u8, u8>}::sub"
      "Shared1U8.Insts.CoreOpsArithSubShared0U8U8.sub";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 157 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Sub<&'1 usize, &'0 usize, \
       usize>}::sub"
      "Shared1Usize.Insts.CoreOpsArithSubShared0UsizeUsize.sub";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 199 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Sub<i128, &'0 i128, i128>}::sub"
      "I128.Insts.CoreOpsArithSubShared0I128I128.sub";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 172 *)
    mk_fun "core::ops::arith::{core::ops::arith::Sub<i16, &'0 i16, i16>}::sub"
      "I16.Insts.CoreOpsArithSubShared0I16I16.sub";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 181 *)
    mk_fun "core::ops::arith::{core::ops::arith::Sub<i32, &'0 i32, i32>}::sub"
      "I32.Insts.CoreOpsArithSubShared0I32I32.sub";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 190 *)
    mk_fun "core::ops::arith::{core::ops::arith::Sub<i64, &'0 i64, i64>}::sub"
      "I64.Insts.CoreOpsArithSubShared0I64I64.sub";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 163 *)
    mk_fun "core::ops::arith::{core::ops::arith::Sub<i8, &'0 i8, i8>}::sub"
      "I8.Insts.CoreOpsArithSubShared0I8I8.sub";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 208 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Sub<isize, &'0 isize, isize>}::sub"
      "Isize.Insts.CoreOpsArithSubShared0IsizeIsize.sub";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 145 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Sub<u128, &'0 u128, u128>}::sub"
      "U128.Insts.CoreOpsArithSubShared0U128U128.sub";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 118 *)
    mk_fun "core::ops::arith::{core::ops::arith::Sub<u16, &'0 u16, u16>}::sub"
      "U16.Insts.CoreOpsArithSubShared0U16U16.sub";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 127 *)
    mk_fun "core::ops::arith::{core::ops::arith::Sub<u32, &'0 u32, u32>}::sub"
      "U32.Insts.CoreOpsArithSubShared0U32U32.sub";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 136 *)
    mk_fun "core::ops::arith::{core::ops::arith::Sub<u64, &'0 u64, u64>}::sub"
      "U64.Insts.CoreOpsArithSubShared0U64U64.sub";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 109 *)
    mk_fun "core::ops::arith::{core::ops::arith::Sub<u8, &'0 u8, u8>}::sub"
      "U8.Insts.CoreOpsArithSubShared0U8U8.sub";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 154 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::Sub<usize, &'0 usize, usize>}::sub"
      "Usize.Insts.CoreOpsArithSubShared0UsizeUsize.sub";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 930 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::SubAssign<i128, &'0 \
       i128>}::sub_assign"
      "I128.Insts.CoreOpsArithSubAssignShared0I128.sub_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 921 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::SubAssign<i16, &'0 \
       i16>}::sub_assign"
      "I16.Insts.CoreOpsArithSubAssignShared0I16.sub_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 924 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::SubAssign<i32, &'0 \
       i32>}::sub_assign"
      "I32.Insts.CoreOpsArithSubAssignShared0I32.sub_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 927 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::SubAssign<i64, &'0 \
       i64>}::sub_assign"
      "I64.Insts.CoreOpsArithSubAssignShared0I64.sub_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 918 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::SubAssign<i8, &'0 i8>}::sub_assign"
      "I8.Insts.CoreOpsArithSubAssignShared0I8.sub_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 933 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::SubAssign<isize, &'0 \
       isize>}::sub_assign"
      "Isize.Insts.CoreOpsArithSubAssignShared0Isize.sub_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 912 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::SubAssign<u128, &'0 \
       u128>}::sub_assign"
      "U128.Insts.CoreOpsArithSubAssignShared0U128.sub_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 903 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::SubAssign<u16, &'0 \
       u16>}::sub_assign"
      "U16.Insts.CoreOpsArithSubAssignShared0U16.sub_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 906 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::SubAssign<u32, &'0 \
       u32>}::sub_assign"
      "U32.Insts.CoreOpsArithSubAssignShared0U32.sub_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 909 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::SubAssign<u64, &'0 \
       u64>}::sub_assign"
      "U64.Insts.CoreOpsArithSubAssignShared0U64.sub_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 900 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::SubAssign<u8, &'0 u8>}::sub_assign"
      "U8.Insts.CoreOpsArithSubAssignShared0U8.sub_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 915 *)
    mk_fun
      "core::ops::arith::{core::ops::arith::SubAssign<usize, &'0 \
       usize>}::sub_assign"
      "Usize.Insts.CoreOpsArithSubAssignShared0Usize.sub_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 628 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitAnd<&'0 i128, i128, i128>}::bitand"
      "Shared0I128.Insts.CoreOpsBitBitAndI128I128.bitand";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 601 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitAnd<&'0 i16, i16, i16>}::bitand"
      "Shared0I16.Insts.CoreOpsBitBitAndI16I16.bitand";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 610 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitAnd<&'0 i32, i32, i32>}::bitand"
      "Shared0I32.Insts.CoreOpsBitBitAndI32I32.bitand";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 619 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitAnd<&'0 i64, i64, i64>}::bitand"
      "Shared0I64.Insts.CoreOpsBitBitAndI64I64.bitand";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 592 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitAnd<&'0 i8, i8, i8>}::bitand"
      "Shared0I8.Insts.CoreOpsBitBitAndI8I8.bitand";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 637 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitAnd<&'0 isize, isize, \
       isize>}::bitand"
      "Shared0Isize.Insts.CoreOpsBitBitAndIsizeIsize.bitand";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 574 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitAnd<&'0 u128, u128, u128>}::bitand"
      "Shared0U128.Insts.CoreOpsBitBitAndU128U128.bitand";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 547 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitAnd<&'0 u16, u16, u16>}::bitand"
      "Shared0U16.Insts.CoreOpsBitBitAndU16U16.bitand";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 556 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitAnd<&'0 u32, u32, u32>}::bitand"
      "Shared0U32.Insts.CoreOpsBitBitAndU32U32.bitand";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 565 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitAnd<&'0 u64, u64, u64>}::bitand"
      "Shared0U64.Insts.CoreOpsBitBitAndU64U64.bitand";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 538 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitAnd<&'0 u8, u8, u8>}::bitand"
      "Shared0U8.Insts.CoreOpsBitBitAndU8U8.bitand";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 583 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitAnd<&'0 usize, usize, \
       usize>}::bitand"
      "Shared0Usize.Insts.CoreOpsBitBitAndUsizeUsize.bitand";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 634 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitAnd<&'1 i128, &'0 i128, \
       i128>}::bitand"
      "Shared1I128.Insts.CoreOpsBitBitAndShared0I128I128.bitand";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 607 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitAnd<&'1 i16, &'0 i16, i16>}::bitand"
      "Shared1I16.Insts.CoreOpsBitBitAndShared0I16I16.bitand";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 616 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitAnd<&'1 i32, &'0 i32, i32>}::bitand"
      "Shared1I32.Insts.CoreOpsBitBitAndShared0I32I32.bitand";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 625 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitAnd<&'1 i64, &'0 i64, i64>}::bitand"
      "Shared1I64.Insts.CoreOpsBitBitAndShared0I64I64.bitand";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 598 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitAnd<&'1 i8, &'0 i8, i8>}::bitand"
      "Shared1I8.Insts.CoreOpsBitBitAndShared0I8I8.bitand";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 643 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitAnd<&'1 isize, &'0 isize, \
       isize>}::bitand"
      "Shared1Isize.Insts.CoreOpsBitBitAndShared0IsizeIsize.bitand";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 580 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitAnd<&'1 u128, &'0 u128, \
       u128>}::bitand"
      "Shared1U128.Insts.CoreOpsBitBitAndShared0U128U128.bitand";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 553 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitAnd<&'1 u16, &'0 u16, u16>}::bitand"
      "Shared1U16.Insts.CoreOpsBitBitAndShared0U16U16.bitand";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 562 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitAnd<&'1 u32, &'0 u32, u32>}::bitand"
      "Shared1U32.Insts.CoreOpsBitBitAndShared0U32U32.bitand";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 571 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitAnd<&'1 u64, &'0 u64, u64>}::bitand"
      "Shared1U64.Insts.CoreOpsBitBitAndShared0U64U64.bitand";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 544 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitAnd<&'1 u8, &'0 u8, u8>}::bitand"
      "Shared1U8.Insts.CoreOpsBitBitAndShared0U8U8.bitand";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 589 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitAnd<&'1 usize, &'0 usize, \
       usize>}::bitand"
      "Shared1Usize.Insts.CoreOpsBitBitAndShared0UsizeUsize.bitand";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 631 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitAnd<i128, &'0 i128, i128>}::bitand"
      "I128.Insts.CoreOpsBitBitAndShared0I128I128.bitand";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 604 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitAnd<i16, &'0 i16, i16>}::bitand"
      "I16.Insts.CoreOpsBitBitAndShared0I16I16.bitand";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 613 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitAnd<i32, &'0 i32, i32>}::bitand"
      "I32.Insts.CoreOpsBitBitAndShared0I32I32.bitand";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 622 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitAnd<i64, &'0 i64, i64>}::bitand"
      "I64.Insts.CoreOpsBitBitAndShared0I64I64.bitand";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 595 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitAnd<i8, &'0 i8, i8>}::bitand"
      "I8.Insts.CoreOpsBitBitAndShared0I8I8.bitand";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 640 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitAnd<isize, &'0 isize, \
       isize>}::bitand"
      "Isize.Insts.CoreOpsBitBitAndShared0IsizeIsize.bitand";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 577 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitAnd<u128, &'0 u128, u128>}::bitand"
      "U128.Insts.CoreOpsBitBitAndShared0U128U128.bitand";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 550 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitAnd<u16, &'0 u16, u16>}::bitand"
      "U16.Insts.CoreOpsBitBitAndShared0U16U16.bitand";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 559 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitAnd<u32, &'0 u32, u32>}::bitand"
      "U32.Insts.CoreOpsBitBitAndShared0U32U32.bitand";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 568 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitAnd<u64, &'0 u64, u64>}::bitand"
      "U64.Insts.CoreOpsBitBitAndShared0U64U64.bitand";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 541 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitAnd<u8, &'0 u8, u8>}::bitand"
      "U8.Insts.CoreOpsBitBitAndShared0U8U8.bitand";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 586 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitAnd<usize, &'0 usize, \
       usize>}::bitand"
      "Usize.Insts.CoreOpsBitBitAndShared0UsizeUsize.bitand";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1074 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitAndAssign<i128, &'0 \
       i128>}::bitand_assign"
      "I128.Insts.CoreOpsBitBitAndAssignShared0I128.bitand_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1065 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitAndAssign<i16, &'0 \
       i16>}::bitand_assign"
      "I16.Insts.CoreOpsBitBitAndAssignShared0I16.bitand_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1068 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitAndAssign<i32, &'0 \
       i32>}::bitand_assign"
      "I32.Insts.CoreOpsBitBitAndAssignShared0I32.bitand_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1071 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitAndAssign<i64, &'0 \
       i64>}::bitand_assign"
      "I64.Insts.CoreOpsBitBitAndAssignShared0I64.bitand_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1062 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitAndAssign<i8, &'0 \
       i8>}::bitand_assign"
      "I8.Insts.CoreOpsBitBitAndAssignShared0I8.bitand_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1077 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitAndAssign<isize, &'0 \
       isize>}::bitand_assign"
      "Isize.Insts.CoreOpsBitBitAndAssignShared0Isize.bitand_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1056 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitAndAssign<u128, &'0 \
       u128>}::bitand_assign"
      "U128.Insts.CoreOpsBitBitAndAssignShared0U128.bitand_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1047 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitAndAssign<u16, &'0 \
       u16>}::bitand_assign"
      "U16.Insts.CoreOpsBitBitAndAssignShared0U16.bitand_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1050 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitAndAssign<u32, &'0 \
       u32>}::bitand_assign"
      "U32.Insts.CoreOpsBitBitAndAssignShared0U32.bitand_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1053 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitAndAssign<u64, &'0 \
       u64>}::bitand_assign"
      "U64.Insts.CoreOpsBitBitAndAssignShared0U64.bitand_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1044 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitAndAssign<u8, &'0 \
       u8>}::bitand_assign"
      "U8.Insts.CoreOpsBitBitAndAssignShared0U8.bitand_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1059 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitAndAssign<usize, &'0 \
       usize>}::bitand_assign"
      "Usize.Insts.CoreOpsBitBitAndAssignShared0Usize.bitand_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 736 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitOr<&'0 i128, i128, i128>}::bitor"
      "Shared0I128.Insts.CoreOpsBitBitOrI128I128.bitor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 709 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitOr<&'0 i16, i16, i16>}::bitor"
      "Shared0I16.Insts.CoreOpsBitBitOrI16I16.bitor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 718 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitOr<&'0 i32, i32, i32>}::bitor"
      "Shared0I32.Insts.CoreOpsBitBitOrI32I32.bitor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 727 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitOr<&'0 i64, i64, i64>}::bitor"
      "Shared0I64.Insts.CoreOpsBitBitOrI64I64.bitor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 700 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitOr<&'0 i8, i8, i8>}::bitor"
      "Shared0I8.Insts.CoreOpsBitBitOrI8I8.bitor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 745 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitOr<&'0 isize, isize, isize>}::bitor"
      "Shared0Isize.Insts.CoreOpsBitBitOrIsizeIsize.bitor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 682 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitOr<&'0 u128, u128, u128>}::bitor"
      "Shared0U128.Insts.CoreOpsBitBitOrU128U128.bitor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 655 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitOr<&'0 u16, u16, u16>}::bitor"
      "Shared0U16.Insts.CoreOpsBitBitOrU16U16.bitor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 664 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitOr<&'0 u32, u32, u32>}::bitor"
      "Shared0U32.Insts.CoreOpsBitBitOrU32U32.bitor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 673 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitOr<&'0 u64, u64, u64>}::bitor"
      "Shared0U64.Insts.CoreOpsBitBitOrU64U64.bitor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 646 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitOr<&'0 u8, u8, u8>}::bitor"
      "Shared0U8.Insts.CoreOpsBitBitOrU8U8.bitor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 691 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitOr<&'0 usize, usize, usize>}::bitor"
      "Shared0Usize.Insts.CoreOpsBitBitOrUsizeUsize.bitor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 742 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitOr<&'1 i128, &'0 i128, i128>}::bitor"
      "Shared1I128.Insts.CoreOpsBitBitOrShared0I128I128.bitor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 715 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitOr<&'1 i16, &'0 i16, i16>}::bitor"
      "Shared1I16.Insts.CoreOpsBitBitOrShared0I16I16.bitor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 724 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitOr<&'1 i32, &'0 i32, i32>}::bitor"
      "Shared1I32.Insts.CoreOpsBitBitOrShared0I32I32.bitor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 733 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitOr<&'1 i64, &'0 i64, i64>}::bitor"
      "Shared1I64.Insts.CoreOpsBitBitOrShared0I64I64.bitor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 706 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitOr<&'1 i8, &'0 i8, i8>}::bitor"
      "Shared1I8.Insts.CoreOpsBitBitOrShared0I8I8.bitor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 751 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitOr<&'1 isize, &'0 isize, \
       isize>}::bitor"
      "Shared1Isize.Insts.CoreOpsBitBitOrShared0IsizeIsize.bitor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 688 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitOr<&'1 u128, &'0 u128, u128>}::bitor"
      "Shared1U128.Insts.CoreOpsBitBitOrShared0U128U128.bitor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 661 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitOr<&'1 u16, &'0 u16, u16>}::bitor"
      "Shared1U16.Insts.CoreOpsBitBitOrShared0U16U16.bitor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 670 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitOr<&'1 u32, &'0 u32, u32>}::bitor"
      "Shared1U32.Insts.CoreOpsBitBitOrShared0U32U32.bitor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 679 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitOr<&'1 u64, &'0 u64, u64>}::bitor"
      "Shared1U64.Insts.CoreOpsBitBitOrShared0U64U64.bitor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 652 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitOr<&'1 u8, &'0 u8, u8>}::bitor"
      "Shared1U8.Insts.CoreOpsBitBitOrShared0U8U8.bitor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 697 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitOr<&'1 usize, &'0 usize, \
       usize>}::bitor"
      "Shared1Usize.Insts.CoreOpsBitBitOrShared0UsizeUsize.bitor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 739 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitOr<i128, &'0 i128, i128>}::bitor"
      "I128.Insts.CoreOpsBitBitOrShared0I128I128.bitor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 712 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitOr<i16, &'0 i16, i16>}::bitor"
      "I16.Insts.CoreOpsBitBitOrShared0I16I16.bitor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 721 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitOr<i32, &'0 i32, i32>}::bitor"
      "I32.Insts.CoreOpsBitBitOrShared0I32I32.bitor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 730 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitOr<i64, &'0 i64, i64>}::bitor"
      "I64.Insts.CoreOpsBitBitOrShared0I64I64.bitor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 703 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitOr<i8, &'0 i8, i8>}::bitor"
      "I8.Insts.CoreOpsBitBitOrShared0I8I8.bitor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 748 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitOr<isize, &'0 isize, isize>}::bitor"
      "Isize.Insts.CoreOpsBitBitOrShared0IsizeIsize.bitor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 685 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitOr<u128, &'0 u128, u128>}::bitor"
      "U128.Insts.CoreOpsBitBitOrShared0U128U128.bitor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 658 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitOr<u16, &'0 u16, u16>}::bitor"
      "U16.Insts.CoreOpsBitBitOrShared0U16U16.bitor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 667 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitOr<u32, &'0 u32, u32>}::bitor"
      "U32.Insts.CoreOpsBitBitOrShared0U32U32.bitor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 676 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitOr<u64, &'0 u64, u64>}::bitor"
      "U64.Insts.CoreOpsBitBitOrShared0U64U64.bitor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 649 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitOr<u8, &'0 u8, u8>}::bitor"
      "U8.Insts.CoreOpsBitBitOrShared0U8U8.bitor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 694 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitOr<usize, &'0 usize, usize>}::bitor"
      "Usize.Insts.CoreOpsBitBitOrShared0UsizeUsize.bitor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1110 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitOrAssign<i128, &'0 \
       i128>}::bitor_assign"
      "I128.Insts.CoreOpsBitBitOrAssignShared0I128.bitor_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1101 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitOrAssign<i16, &'0 \
       i16>}::bitor_assign"
      "I16.Insts.CoreOpsBitBitOrAssignShared0I16.bitor_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1104 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitOrAssign<i32, &'0 \
       i32>}::bitor_assign"
      "I32.Insts.CoreOpsBitBitOrAssignShared0I32.bitor_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1107 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitOrAssign<i64, &'0 \
       i64>}::bitor_assign"
      "I64.Insts.CoreOpsBitBitOrAssignShared0I64.bitor_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1098 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitOrAssign<i8, &'0 i8>}::bitor_assign"
      "I8.Insts.CoreOpsBitBitOrAssignShared0I8.bitor_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1113 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitOrAssign<isize, &'0 \
       isize>}::bitor_assign"
      "Isize.Insts.CoreOpsBitBitOrAssignShared0Isize.bitor_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1092 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitOrAssign<u128, &'0 \
       u128>}::bitor_assign"
      "U128.Insts.CoreOpsBitBitOrAssignShared0U128.bitor_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1083 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitOrAssign<u16, &'0 \
       u16>}::bitor_assign"
      "U16.Insts.CoreOpsBitBitOrAssignShared0U16.bitor_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1086 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitOrAssign<u32, &'0 \
       u32>}::bitor_assign"
      "U32.Insts.CoreOpsBitBitOrAssignShared0U32.bitor_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1089 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitOrAssign<u64, &'0 \
       u64>}::bitor_assign"
      "U64.Insts.CoreOpsBitBitOrAssignShared0U64.bitor_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1080 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitOrAssign<u8, &'0 u8>}::bitor_assign"
      "U8.Insts.CoreOpsBitBitOrAssignShared0U8.bitor_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1095 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitOrAssign<usize, &'0 \
       usize>}::bitor_assign"
      "Usize.Insts.CoreOpsBitBitOrAssignShared0Usize.bitor_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 844 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitXor<&'0 i128, i128, i128>}::bitxor"
      "Shared0I128.Insts.CoreOpsBitBitXorI128I128.bitxor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 817 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitXor<&'0 i16, i16, i16>}::bitxor"
      "Shared0I16.Insts.CoreOpsBitBitXorI16I16.bitxor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 826 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitXor<&'0 i32, i32, i32>}::bitxor"
      "Shared0I32.Insts.CoreOpsBitBitXorI32I32.bitxor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 835 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitXor<&'0 i64, i64, i64>}::bitxor"
      "Shared0I64.Insts.CoreOpsBitBitXorI64I64.bitxor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 808 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitXor<&'0 i8, i8, i8>}::bitxor"
      "Shared0I8.Insts.CoreOpsBitBitXorI8I8.bitxor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 853 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitXor<&'0 isize, isize, \
       isize>}::bitxor"
      "Shared0Isize.Insts.CoreOpsBitBitXorIsizeIsize.bitxor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 790 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitXor<&'0 u128, u128, u128>}::bitxor"
      "Shared0U128.Insts.CoreOpsBitBitXorU128U128.bitxor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 763 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitXor<&'0 u16, u16, u16>}::bitxor"
      "Shared0U16.Insts.CoreOpsBitBitXorU16U16.bitxor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 772 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitXor<&'0 u32, u32, u32>}::bitxor"
      "Shared0U32.Insts.CoreOpsBitBitXorU32U32.bitxor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 781 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitXor<&'0 u64, u64, u64>}::bitxor"
      "Shared0U64.Insts.CoreOpsBitBitXorU64U64.bitxor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 754 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitXor<&'0 u8, u8, u8>}::bitxor"
      "Shared0U8.Insts.CoreOpsBitBitXorU8U8.bitxor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 799 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitXor<&'0 usize, usize, \
       usize>}::bitxor"
      "Shared0Usize.Insts.CoreOpsBitBitXorUsizeUsize.bitxor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 850 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitXor<&'1 i128, &'0 i128, \
       i128>}::bitxor"
      "Shared1I128.Insts.CoreOpsBitBitXorShared0I128I128.bitxor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 823 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitXor<&'1 i16, &'0 i16, i16>}::bitxor"
      "Shared1I16.Insts.CoreOpsBitBitXorShared0I16I16.bitxor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 832 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitXor<&'1 i32, &'0 i32, i32>}::bitxor"
      "Shared1I32.Insts.CoreOpsBitBitXorShared0I32I32.bitxor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 841 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitXor<&'1 i64, &'0 i64, i64>}::bitxor"
      "Shared1I64.Insts.CoreOpsBitBitXorShared0I64I64.bitxor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 814 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitXor<&'1 i8, &'0 i8, i8>}::bitxor"
      "Shared1I8.Insts.CoreOpsBitBitXorShared0I8I8.bitxor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 859 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitXor<&'1 isize, &'0 isize, \
       isize>}::bitxor"
      "Shared1Isize.Insts.CoreOpsBitBitXorShared0IsizeIsize.bitxor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 796 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitXor<&'1 u128, &'0 u128, \
       u128>}::bitxor"
      "Shared1U128.Insts.CoreOpsBitBitXorShared0U128U128.bitxor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 769 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitXor<&'1 u16, &'0 u16, u16>}::bitxor"
      "Shared1U16.Insts.CoreOpsBitBitXorShared0U16U16.bitxor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 778 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitXor<&'1 u32, &'0 u32, u32>}::bitxor"
      "Shared1U32.Insts.CoreOpsBitBitXorShared0U32U32.bitxor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 787 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitXor<&'1 u64, &'0 u64, u64>}::bitxor"
      "Shared1U64.Insts.CoreOpsBitBitXorShared0U64U64.bitxor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 760 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitXor<&'1 u8, &'0 u8, u8>}::bitxor"
      "Shared1U8.Insts.CoreOpsBitBitXorShared0U8U8.bitxor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 805 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitXor<&'1 usize, &'0 usize, \
       usize>}::bitxor"
      "Shared1Usize.Insts.CoreOpsBitBitXorShared0UsizeUsize.bitxor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 847 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitXor<i128, &'0 i128, i128>}::bitxor"
      "I128.Insts.CoreOpsBitBitXorShared0I128I128.bitxor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 820 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitXor<i16, &'0 i16, i16>}::bitxor"
      "I16.Insts.CoreOpsBitBitXorShared0I16I16.bitxor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 829 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitXor<i32, &'0 i32, i32>}::bitxor"
      "I32.Insts.CoreOpsBitBitXorShared0I32I32.bitxor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 838 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitXor<i64, &'0 i64, i64>}::bitxor"
      "I64.Insts.CoreOpsBitBitXorShared0I64I64.bitxor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 811 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitXor<i8, &'0 i8, i8>}::bitxor"
      "I8.Insts.CoreOpsBitBitXorShared0I8I8.bitxor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 856 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitXor<isize, &'0 isize, \
       isize>}::bitxor"
      "Isize.Insts.CoreOpsBitBitXorShared0IsizeIsize.bitxor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 793 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitXor<u128, &'0 u128, u128>}::bitxor"
      "U128.Insts.CoreOpsBitBitXorShared0U128U128.bitxor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 766 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitXor<u16, &'0 u16, u16>}::bitxor"
      "U16.Insts.CoreOpsBitBitXorShared0U16U16.bitxor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 775 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitXor<u32, &'0 u32, u32>}::bitxor"
      "U32.Insts.CoreOpsBitBitXorShared0U32U32.bitxor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 784 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitXor<u64, &'0 u64, u64>}::bitxor"
      "U64.Insts.CoreOpsBitBitXorShared0U64U64.bitxor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 757 *)
    mk_fun "core::ops::bit::{core::ops::bit::BitXor<u8, &'0 u8, u8>}::bitxor"
      "U8.Insts.CoreOpsBitBitXorShared0U8U8.bitxor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 802 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitXor<usize, &'0 usize, \
       usize>}::bitxor"
      "Usize.Insts.CoreOpsBitBitXorShared0UsizeUsize.bitxor";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1146 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitXorAssign<i128, &'0 \
       i128>}::bitxor_assign"
      "I128.Insts.CoreOpsBitBitXorAssignShared0I128.bitxor_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1137 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitXorAssign<i16, &'0 \
       i16>}::bitxor_assign"
      "I16.Insts.CoreOpsBitBitXorAssignShared0I16.bitxor_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1140 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitXorAssign<i32, &'0 \
       i32>}::bitxor_assign"
      "I32.Insts.CoreOpsBitBitXorAssignShared0I32.bitxor_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1143 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitXorAssign<i64, &'0 \
       i64>}::bitxor_assign"
      "I64.Insts.CoreOpsBitBitXorAssignShared0I64.bitxor_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1134 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitXorAssign<i8, &'0 \
       i8>}::bitxor_assign"
      "I8.Insts.CoreOpsBitBitXorAssignShared0I8.bitxor_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1149 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitXorAssign<isize, &'0 \
       isize>}::bitxor_assign"
      "Isize.Insts.CoreOpsBitBitXorAssignShared0Isize.bitxor_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1128 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitXorAssign<u128, &'0 \
       u128>}::bitxor_assign"
      "U128.Insts.CoreOpsBitBitXorAssignShared0U128.bitxor_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1119 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitXorAssign<u16, &'0 \
       u16>}::bitxor_assign"
      "U16.Insts.CoreOpsBitBitXorAssignShared0U16.bitxor_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1122 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitXorAssign<u32, &'0 \
       u32>}::bitxor_assign"
      "U32.Insts.CoreOpsBitBitXorAssignShared0U32.bitxor_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1125 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitXorAssign<u64, &'0 \
       u64>}::bitxor_assign"
      "U64.Insts.CoreOpsBitBitXorAssignShared0U64.bitxor_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1116 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitXorAssign<u8, &'0 \
       u8>}::bitxor_assign"
      "U8.Insts.CoreOpsBitBitXorAssignShared0U8.bitxor_assign";
    (* file: "Aeneas/Std/Scalar/Ops/RefOps.lean", line: 1131 *)
    mk_fun
      "core::ops::bit::{core::ops::bit::BitXorAssign<usize, &'0 \
       usize>}::bitxor_assign"
      "Usize.Insts.CoreOpsBitBitXorAssignShared0Usize.bitxor_assign";
    (* file: "Aeneas/Std/Core/Ops.lean", line: 53 *)
    mk_fun "core::ops::drop::Drop::drop" "core.ops.drop.Drop.drop.default";
    (* file: "Aeneas/Std/Core/IterOverrides.lean", line: 236 *)
    mk_fun
      "core::ops::range::{core::clone::Clone<core::ops::range::Range<@Idx>>}::clone"
      "core.ops.range.Range.Insts.CoreCloneClone.clone";
    (* file: "Aeneas/Std/Core/IterOverrides.lean", line: 242 *)
    mk_fun
      "core::ops::range::{core::clone::Clone<core::ops::range::RangeInclusive<@Idx>>}::clone"
      "core.ops.range.RangeInclusive.Insts.CoreCloneClone.clone";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 768 *)
    mk_fun
      "core::ops::range::{core::ops::range::RangeInclusive<@Idx>}::is_empty"
      "core.ops.range.RangeInclusive.is_empty";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 763 *)
    mk_fun "core::ops::range::{core::ops::range::RangeInclusive<@Idx>}::new"
      "core.ops.range.RangeInclusive.new";
    (* file: "Aeneas/Std/Core/IterOverrides.lean", line: 406 *)
    mk_fun
      "core::option::{core::cmp::Eq<core::option::Option<@T>>}::assert_fields_are_eq"
      "core.option.Option.Insts.CoreCmpEq.assert_fields_are_eq";
    (* file: "Aeneas/Std/CoreMisc.lean", line: 43 *)
    mk_fun "core::option::{core::cmp::Ord<core::option::Option<@T>>}::cmp"
      "core.option.Option.Insts.CoreCmpOrd.cmp";
    (* file: "Aeneas/Std/CoreMisc.lean", line: 26 *)
    mk_fun
      "core::option::{core::cmp::PartialEq<core::option::Option<@T>, \
       core::option::Option<@T>>}::eq"
      "core.option.Option.Insts.CoreCmpPartialEqOption.eq";
    (* file: "Aeneas/Std/CoreMisc.lean", line: 34 *)
    mk_fun
      "core::option::{core::cmp::PartialOrd<core::option::Option<@T>, \
       core::option::Option<@T>>}::partial_cmp"
      "core.option.Option.Insts.CoreCmpPartialOrdOption.partial_cmp";
    (* file: "Aeneas/Std/CoreMisc.lean", line: 76 *)
    mk_fun "core::option::{core::option::Option<&'0 @T>}::copied"
      "core.option.OptionShared0T.copied";
    (* file: "Aeneas/Std/Core/CoreOption.lean", line: 14 *)
    mk_fun "core::option::{core::option::Option<@T>}::expect"
      "core.option.Option.expect";
    (* file: "Aeneas/Std/Core/Core.lean", line: 119 *)
    mk_fun "core::option::{core::option::Option<@T>}::is_none"
      "core.option.Option.is_none" ~can_fail:false ~lift:false;
    (* file: "Aeneas/Std/Core/Core.lean", line: 123 *)
    mk_fun "core::option::{core::option::Option<@T>}::is_some"
      "core.option.Option.is_some" ~can_fail:false ~lift:false;
    (* file: "Aeneas/Std/Core/CoreOption.lean", line: 84 *)
    mk_fun "core::option::{core::option::Option<@T>}::is_some_and"
      "core.option.Option.is_some_and";
    (* file: "Aeneas/Std/Core/CoreOption.lean", line: 41 *)
    mk_fun "core::option::{core::option::Option<@T>}::map"
      "core.option.Option.map";
    (* file: "Aeneas/Std/Core/CoreOption.lean", line: 24 *)
    mk_fun "core::option::{core::option::Option<@T>}::ok_or"
      "core.option.Option.ok_or";
    (* file: "Aeneas/Std/Core/Core.lean", line: 116 *)
    mk_fun "core::option::{core::option::Option<@T>}::take"
      "core.option.Option.take" ~can_fail:false ~lift:false;
    (* file: "Aeneas/Std/Core/Core.lean", line: 95 *)
    mk_fun "core::option::{core::option::Option<@T>}::unwrap"
      "core.option.Option.unwrap";
    (* file: "Aeneas/Std/Core/Core.lean", line: 104 *)
    mk_fun "core::option::{core::option::Option<@T>}::unwrap_or"
      "core.option.Option.unwrap_or" ~can_fail:false;
    (* file: "Aeneas/Std/CoreMisc.lean", line: 81 *)
    mk_fun "core::option::{core::option::Option<@T>}::unwrap_or_default"
      "core.option.Option.unwrap_or_default";
    (* file: "Aeneas/Std/Core/IterOverrides.lean", line: 367 *)
    mk_fun
      "core::result::{core::iter::traits::collect::FromIterator<core::result::Result<@V, \
       @E>, core::result::Result<@T, @E>>}::from_iter"
      "core.result.Result.Insts.CoreIterTraitsCollectFromIteratorResult.from_iter";
    (* file: "Aeneas/Std/Core/Convert.lean", line: 113 *)
    mk_fun
      "core::result::{core::ops::try_trait::FromResidual<core::result::Result<@T, \
       @F>, core::result::Result<!, @E>>}::from_residual"
      "core.result.Result.Insts.CoreOpsTry_traitFromResidualResult.from_residual";
    (* file: "Aeneas/Std/Core/Convert.lean", line: 101 *)
    mk_fun
      "core::result::{core::ops::try_trait::Try<core::result::Result<@T, @E>, \
       @T, core::result::Result<!, @E>>}::branch"
      "core.result.Result.Insts.CoreOpsTry.branch";
    (* file: "Aeneas/Std/Core/Fmt.lean", line: 116 *)
    mk_fun "core::result::{core::result::Result<@T, @E>}::expect"
      "core.result.Result.expect";
    (* file: "Aeneas/Std/Core/Convert.lean", line: 81 *)
    mk_fun "core::result::{core::result::Result<@T, @E>}::is_ok"
      "core.result.Result.is_ok";
    (* file: "Aeneas/Std/Core/CoreResult.lean", line: 14 *)
    mk_fun "core::result::{core::result::Result<@T, @E>}::map_err"
      "core.result.Result.map_err";
    (* file: "Aeneas/Std/Core/Fmt.lean", line: 22 *)
    mk_fun "core::result::{core::result::Result<@T, @E>}::unwrap"
      "core.result.Result.unwrap";
    (* file: "Aeneas/Std/Core/CoreResult.lean", line: 41 *)
    mk_fun "core::result::{core::result::Result<@T, @E>}::unwrap_or"
      "core.result.Result.unwrap_or" ~can_fail:false;
    (* file: "Aeneas/Std/Array/ArraySlice.lean", line: 156 *)
    mk_fun "core::slice::cmp::{core::cmp::PartialEq<[@T], [@U]>}::eq"
      "core.slice.cmp.PartialEqSlice.eq";
    (* file: "Aeneas/Std/Array/ArraySlice.lean", line: 224 *)
    mk_fun "core::slice::cmp::{core::cmp::PartialEq<[@T], [@U]>}::ne"
      "core.slice.cmp.PartialEqSlice.ne";
    (* file: "Aeneas/Std/Slice.lean", line: 347 *)
    mk_fun "core::slice::index::{core::ops::index::Index<[@T], @I, @O>}::index"
      "core.slice.index.Slice.index";
    (* file: "Aeneas/Std/Slice.lean", line: 424 *)
    mk_fun
      "core::slice::index::{core::ops::index::IndexMut<[@T], @I, \
       @O>}::index_mut"
      "core.slice.index.Slice.index_mut";
    (* file: "Aeneas/Std/Slice.lean", line: 372 *)
    mk_fun
      "core::slice::index::{core::slice::index::SliceIndex<core::ops::range::Range<usize>, \
       [@T], [@T]>}::get"
      "core.slice.index.SliceIndexRangeUsizeSlice.get";
    (* file: "Aeneas/Std/Slice.lean", line: 379 *)
    mk_fun
      "core::slice::index::{core::slice::index::SliceIndex<core::ops::range::Range<usize>, \
       [@T], [@T]>}::get_mut"
      "core.slice.index.SliceIndexRangeUsizeSlice.get_mut";
    (* file: "Aeneas/Std/Slice.lean", line: 393 *)
    mk_fun
      "core::slice::index::{core::slice::index::SliceIndex<core::ops::range::Range<usize>, \
       [@T], [@T]>}::get_unchecked"
      "core.slice.index.SliceIndexRangeUsizeSlice.get_unchecked";
    (* file: "Aeneas/Std/Slice.lean", line: 399 *)
    mk_fun
      "core::slice::index::{core::slice::index::SliceIndex<core::ops::range::Range<usize>, \
       [@T], [@T]>}::get_unchecked_mut"
      "core.slice.index.SliceIndexRangeUsizeSlice.get_unchecked_mut";
    (* file: "Aeneas/Std/Slice.lean", line: 405 *)
    mk_fun
      "core::slice::index::{core::slice::index::SliceIndex<core::ops::range::Range<usize>, \
       [@T], [@T]>}::index"
      "core.slice.index.SliceIndexRangeUsizeSlice.index";
    (* file: "Aeneas/Std/Slice.lean", line: 411 *)
    mk_fun
      "core::slice::index::{core::slice::index::SliceIndex<core::ops::range::Range<usize>, \
       [@T], [@T]>}::index_mut"
      "core.slice.index.SliceIndexRangeUsizeSlice.index_mut";
    (* file: "Aeneas/Std/Slice.lean", line: 627 *)
    mk_fun
      "core::slice::index::{core::slice::index::SliceIndex<core::ops::range::RangeFrom<usize>, \
       [@T], [@T]>}::get"
      "core.slice.index.SliceIndexRangeFromUsizeSlice.get";
    (* file: "Aeneas/Std/Slice.lean", line: 633 *)
    mk_fun
      "core::slice::index::{core::slice::index::SliceIndex<core::ops::range::RangeFrom<usize>, \
       [@T], [@T]>}::get_mut"
      "core.slice.index.SliceIndexRangeFromUsizeSlice.get_mut";
    (* file: "Aeneas/Std/Slice.lean", line: 647 *)
    mk_fun
      "core::slice::index::{core::slice::index::SliceIndex<core::ops::range::RangeFrom<usize>, \
       [@T], [@T]>}::get_unchecked"
      "core.slice.index.SliceIndexRangeFromUsizeSlice.get_unchecked";
    (* file: "Aeneas/Std/Slice.lean", line: 653 *)
    mk_fun
      "core::slice::index::{core::slice::index::SliceIndex<core::ops::range::RangeFrom<usize>, \
       [@T], [@T]>}::get_unchecked_mut"
      "core.slice.index.SliceIndexRangeFromUsizeSlice.get_unchecked_mut";
    (* file: "Aeneas/Std/Slice.lean", line: 659 *)
    mk_fun
      "core::slice::index::{core::slice::index::SliceIndex<core::ops::range::RangeFrom<usize>, \
       [@T], [@T]>}::index"
      "core.slice.index.SliceIndexRangeFromUsizeSlice.index";
    (* file: "Aeneas/Std/Slice.lean", line: 666 *)
    mk_fun
      "core::slice::index::{core::slice::index::SliceIndex<core::ops::range::RangeFrom<usize>, \
       [@T], [@T]>}::index_mut"
      "core.slice.index.SliceIndexRangeFromUsizeSlice.index_mut";
    (* file: "Aeneas/Std/Slice.lean", line: 512 *)
    mk_fun
      "core::slice::index::{core::slice::index::SliceIndex<core::ops::range::RangeFull, \
       [@T], [@T]>}::get"
      "core.slice.index.SliceIndexRangeFullSlice.get";
    (* file: "Aeneas/Std/Slice.lean", line: 517 *)
    mk_fun
      "core::slice::index::{core::slice::index::SliceIndex<core::ops::range::RangeFull, \
       [@T], [@T]>}::get_mut"
      "core.slice.index.SliceIndexRangeFullSlice.get_mut";
    (* file: "Aeneas/Std/Slice.lean", line: 523 *)
    mk_fun
      "core::slice::index::{core::slice::index::SliceIndex<core::ops::range::RangeFull, \
       [@T], [@T]>}::get_unchecked"
      "core.slice.index.SliceIndexRangeFullSlice.get_unchecked";
    (* file: "Aeneas/Std/Slice.lean", line: 529 *)
    mk_fun
      "core::slice::index::{core::slice::index::SliceIndex<core::ops::range::RangeFull, \
       [@T], [@T]>}::get_unchecked_mut"
      "core.slice.index.SliceIndexRangeFullSlice.get_unchecked_mut";
    (* file: "Aeneas/Std/Slice.lean", line: 535 *)
    mk_fun
      "core::slice::index::{core::slice::index::SliceIndex<core::ops::range::RangeFull, \
       [@T], [@T]>}::index"
      "core.slice.index.SliceIndexRangeFullSlice.index";
    (* file: "Aeneas/Std/Slice.lean", line: 540 *)
    mk_fun
      "core::slice::index::{core::slice::index::SliceIndex<core::ops::range::RangeFull, \
       [@T], [@T]>}::index_mut"
      "core.slice.index.SliceIndexRangeFullSlice.index_mut";
    (* file: "Aeneas/Std/Slice.lean", line: 441 *)
    mk_fun
      "core::slice::index::{core::slice::index::SliceIndex<core::ops::range::RangeTo<usize>, \
       [@T], [@T]>}::get"
      "core.slice.index.SliceIndexRangeToUsizeSlice.get";
    (* file: "Aeneas/Std/Slice.lean", line: 448 *)
    mk_fun
      "core::slice::index::{core::slice::index::SliceIndex<core::ops::range::RangeTo<usize>, \
       [@T], [@T]>}::get_mut"
      "core.slice.index.SliceIndexRangeToUsizeSlice.get_mut";
    (* file: "Aeneas/Std/Slice.lean", line: 463 *)
    mk_fun
      "core::slice::index::{core::slice::index::SliceIndex<core::ops::range::RangeTo<usize>, \
       [@T], [@T]>}::get_unchecked"
      "core.slice.index.SliceIndexRangeToUsizeSlice.get_unchecked";
    (* file: "Aeneas/Std/Slice.lean", line: 469 *)
    mk_fun
      "core::slice::index::{core::slice::index::SliceIndex<core::ops::range::RangeTo<usize>, \
       [@T], [@T]>}::get_unchecked_mut"
      "core.slice.index.SliceIndexRangeToUsizeSlice.get_unchecked_mut";
    (* file: "Aeneas/Std/Slice.lean", line: 476 *)
    mk_fun
      "core::slice::index::{core::slice::index::SliceIndex<core::ops::range::RangeTo<usize>, \
       [@T], [@T]>}::index"
      "core.slice.index.SliceIndexRangeToUsizeSlice.index";
    (* file: "Aeneas/Std/Slice.lean", line: 483 *)
    mk_fun
      "core::slice::index::{core::slice::index::SliceIndex<core::ops::range::RangeTo<usize>, \
       [@T], [@T]>}::index_mut"
      "core.slice.index.SliceIndexRangeToUsizeSlice.index_mut";
    (* file: "Aeneas/Std/Slice.lean", line: 572 *)
    mk_fun
      "core::slice::index::{core::slice::index::SliceIndex<usize, [@T], \
       @T>}::get"
      "core.slice.index.Usize.get";
    (* file: "Aeneas/Std/Slice.lean", line: 577 *)
    mk_fun
      "core::slice::index::{core::slice::index::SliceIndex<usize, [@T], \
       @T>}::get_mut"
      "core.slice.index.Usize.get_mut";
    (* file: "Aeneas/Std/Slice.lean", line: 582 *)
    mk_fun
      "core::slice::index::{core::slice::index::SliceIndex<usize, [@T], \
       @T>}::get_unchecked"
      "core.slice.index.Usize.get_unchecked";
    (* file: "Aeneas/Std/Slice.lean", line: 588 *)
    mk_fun
      "core::slice::index::{core::slice::index::SliceIndex<usize, [@T], \
       @T>}::get_unchecked_mut"
      "core.slice.index.Usize.get_unchecked_mut";
    (* file: "Aeneas/Std/Slice.lean", line: 594 *)
    mk_fun
      "core::slice::index::{core::slice::index::SliceIndex<usize, [@T], \
       @T>}::index"
      "core.slice.index.Usize.index";
    (* file: "Aeneas/Std/Slice.lean", line: 598 *)
    mk_fun
      "core::slice::index::{core::slice::index::SliceIndex<usize, [@T], \
       @T>}::index_mut"
      "core.slice.index.Usize.index_mut";
    (* file: "Aeneas/Std/SliceIter.lean", line: 175 *)
    mk_fun
      "core::slice::iter::{core::iter::traits::collect::IntoIterator<&'a [@T], \
       &'a @T, core::slice::iter::Iter<'a, @T>>}::into_iter"
      "SharedSlice.Insts.CoreIterTraitsCollectIntoIteratorSharedIter.into_iter";
    (* file: "Aeneas/Std/SliceIter.lean", line: 101 *)
    mk_fun
      "core::slice::iter::{core::iter::traits::double_ended::DoubleEndedIterator<core::slice::iter::Iter<'a, \
       @T>, &'_ @T>}::next_back"
      "core.slice.iter.IteratorSliceIter.next_back";
    (* file: "Aeneas/Std/Core/IterOverrides.lean", line: 289 *)
    mk_fun
      "core::slice::iter::{core::iter::traits::iterator::Iterator<core::slice::iter::Chunks<'a, \
       @T>, &'a [@T]>}::count"
      "core.slice.iter.Chunks.Insts.CoreIterTraitsIteratorIteratorSharedASlice.count";
    (* file: "Aeneas/Std/Core/IterOverrides.lean", line: 263 *)
    mk_fun
      "core::slice::iter::{core::iter::traits::iterator::Iterator<core::slice::iter::Chunks<'a, \
       @T>, &'a [@T]>}::next"
      "core.slice.iter.Chunks.Insts.CoreIterTraitsIteratorIteratorSharedASlice.next";
    (* file: "Aeneas/Std/Core/IterOverrides.lean", line: 275 *)
    mk_fun
      "core::slice::iter::{core::iter::traits::iterator::Iterator<core::slice::iter::Chunks<'a, \
       @T>, &'a [@T]>}::size_hint"
      "core.slice.iter.Chunks.Insts.CoreIterTraitsIteratorIteratorSharedASlice.size_hint";
    (* file: "Aeneas/Std/SliceIter.lean", line: 201 *)
    mk_fun
      "core::slice::iter::{core::iter::traits::iterator::Iterator<core::slice::iter::ChunksExact<'a, \
       @T>, &'a [@T]>}::next"
      "core.slice.iter.IteratorChunksExact.next";
    (* file: "Aeneas/Std/SliceIter.lean", line: 211 *)
    mk_fun
      "core::slice::iter::{core::iter::traits::iterator::Iterator<core::slice::iter::ChunksExact<'a, \
       @T>, &'a [@T]>}::size_hint"
      "core.slice.iter.IteratorChunksExact.size_hint";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 624 *)
    mk_fun
      "core::slice::iter::{core::iter::traits::iterator::Iterator<core::slice::iter::Iter<'a, \
       @T>, &'a @T>}::any"
      "core.slice.iter.Iter.Insts.CoreIterTraitsIteratorIteratorSharedAT.any";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 618 *)
    mk_fun
      "core::slice::iter::{core::iter::traits::iterator::Iterator<core::slice::iter::Iter<'a, \
       @T>, &'a @T>}::count"
      "core.slice.iter.Iter.Insts.CoreIterTraitsIteratorIteratorSharedAT.count";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 610 *)
    mk_fun
      "core::slice::iter::{core::iter::traits::iterator::Iterator<core::slice::iter::Iter<'a, \
       @T>, &'a @T>}::fold"
      "core.slice.iter.Iter.Insts.CoreIterTraitsIteratorIteratorSharedAT.fold";
    (* file: "Aeneas/Std/SliceIter.lean", line: 87 *)
    mk_fun
      "core::slice::iter::{core::iter::traits::iterator::Iterator<core::slice::iter::Iter<'a, \
       @T>, &'a @T>}::next"
      "core.slice.iter.IteratorSliceIter.next";
    (* file: "Aeneas/Std/SliceIter.lean", line: 125 *)
    mk_fun
      "core::slice::iter::{core::iter::traits::iterator::Iterator<core::slice::iter::Iter<'a, \
       @T>, &'a @T>}::size_hint"
      "core.slice.iter.IteratorSliceIter.size_hint";
    (* file: "Aeneas/Std/Core/IterOverrides.lean", line: 308 *)
    mk_fun
      "core::slice::iter::{core::iter::traits::iterator::Iterator<core::slice::iter::IterMut<'a, \
       @T>, &'a mut @T>}::count"
      "core.slice.iter.IterMut.Insts.CoreIterTraitsIteratorIteratorMutAT.count";
    (* file: "Aeneas/Std/SliceIter.lean", line: 45 *)
    mk_fun
      "core::slice::iter::{core::iter::traits::iterator::Iterator<core::slice::iter::IterMut<'a, \
       @T>, &'a mut @T>}::next"
      "core.slice.iter.IteratorIterMut.next";
    (* file: "Aeneas/Std/Core/IterOverrides.lean", line: 300 *)
    mk_fun
      "core::slice::iter::{core::iter::traits::iterator::Iterator<core::slice::iter::IterMut<'a, \
       @T>, &'a mut @T>}::size_hint"
      "core.slice.iter.IterMut.Insts.CoreIterTraitsIteratorIteratorMutAT.size_hint";
    (* file: "Aeneas/Std/SliceIter.lean", line: 195 *)
    mk_fun
      "core::slice::iter::{core::slice::iter::ChunksExact<'a, @T>}::remainder"
      "core.slice.iter.ChunksExact.getRemainder";
    (* file: "Aeneas/Std/CoreMisc.lean", line: 102 *)
    mk_fun "core::slice::raw::from_ref" "core.slice.raw.from_ref";
    (* file: "Aeneas/Std/Core/IterOverrides.lean", line: 257 *)
    mk_fun "core::slice::{[@T]}::chunks" "core.slice.Slice.chunks";
    (* file: "Aeneas/Std/SliceIter.lean", line: 271 *)
    mk_fun "core::slice::{[@T]}::chunks_exact" "core.slice.Slice.chunks_exact";
    (* file: "Aeneas/Std/SliceIter.lean", line: 40 *)
    mk_fun "core::slice::{[@T]}::contains" "core.slice.Slice.contains";
    (* file: "Aeneas/Std/Slice.lean", line: 621 *)
    mk_fun "core::slice::{[@T]}::copy_from_slice"
      "core.slice.Slice.copy_from_slice";
    (* file: "Aeneas/Std/Slice.lean", line: 1047 *)
    mk_fun "core::slice::{[@T]}::fill" "core.slice.Slice.fill";
    (* file: "Aeneas/Std/Slice.lean", line: 353 *)
    mk_fun "core::slice::{[@T]}::get" "core.slice.Slice.get";
    (* file: "Aeneas/Std/Slice.lean", line: 366 *)
    mk_fun "core::slice::{[@T]}::get_mut" "core.slice.Slice.get_mut";
    (* file: "Aeneas/Std/Slice.lean", line: 359 *)
    mk_fun "core::slice::{[@T]}::get_unchecked" "core.slice.Slice.get_unchecked";
    (* file: "Aeneas/Std/Slice.lean", line: 123 *)
    mk_fun "core::slice::{[@T]}::is_empty" "core.slice.Slice.is_empty";
    (* file: "Aeneas/Std/SliceIter.lean", line: 36 *)
    mk_fun "core::slice::{[@T]}::iter" "core.slice.Slice.iter";
    (* file: "Aeneas/Std/SliceIter.lean", line: 82 *)
    mk_fun "core::slice::{[@T]}::iter_mut" "core.slice.Slice.iter_mut";
    (* file: "Aeneas/Std/Slice.lean", line: 52 *)
    mk_fun "core::slice::{[@T]}::len" "Slice.len" ~can_fail:false ~lift:false;
    (* file: "Aeneas/Std/Slice.lean", line: 334 *)
    mk_fun "core::slice::{[@T]}::reverse" "core.slice.Slice.reverse"
      ~can_fail:false;
    (* file: "Aeneas/Std/Slice.lean", line: 720 *)
    mk_fun "core::slice::{[@T]}::split_at" "core.slice.Slice.split_at";
    (* file: "Aeneas/Std/Slice.lean", line: 731 *)
    mk_fun "core::slice::{[@T]}::split_at_mut" "core.slice.Slice.split_at_mut";
    (* file: "Aeneas/Std/CoreMisc.lean", line: 106 *)
    mk_fun "core::slice::{[@T]}::split_first" "core.slice.Slice.split_first";
    (* file: "Aeneas/Std/Slice.lean", line: 791 *)
    mk_fun "core::slice::{[@T]}::swap" "core.slice.Slice.swap";
    (* file: "Aeneas/Std/StringIter.lean", line: 18 *)
    mk_fun
      "core::str::iter::{core::iter::traits::iterator::Iterator<core::str::iter::Chars<'a>, \
       char>}::collect"
      "core.str.iter.IteratorChars.collect";
    (* file: "Aeneas/Std/StringIter.lean", line: 14 *)
    mk_fun
      "core::str::iter::{core::iter::traits::iterator::Iterator<core::str::iter::Chars<'a>, \
       char>}::next"
      "core.str.iter.IteratorChars.next";
    (* file: "Aeneas/Std/StringIter.lean", line: 25 *)
    mk_fun
      "core::str::iter::{core::iter::traits::iterator::Iterator<core::str::iter::Chars<'a>, \
       char>}::size_hint"
      "core.str.iter.IteratorChars.size_hint";
    (* file: "Aeneas/Std/StringIter.lean", line: 41 *)
    mk_fun "core::str::{str}::chars" "core.str.Str.chars";
    (* file: "Aeneas/Std/CoreMisc.lean", line: 58 *)
    mk_fun "core::tuple::{core::cmp::Ord<(@U, @T)>}::cmp"
      "Pair.Insts.CoreCmpOrd.cmp";
    (* file: "Aeneas/Std/CoreMisc.lean", line: 52 *)
    mk_fun "core::tuple::{core::cmp::PartialEq<(@U, @T), (@U, @T)>}::eq"
      "Pair.Insts.CoreCmpPartialEqPair.eq";
    (* file: "Aeneas/Std/CoreMisc.lean", line: 66 *)
    mk_fun
      "core::tuple::{core::cmp::PartialOrd<(@U, @T), (@U, @T)>}::partial_cmp"
      "Pair.Insts.CoreCmpPartialOrdPair.partial_cmp";
    (* file: "Aeneas/Std/Std/Io.lean", line: 7 *)
    mk_fun "std::io::stdio::_print" "std.io.stdio._print";
  ]

let lean_builtin_trait_decls =
  [
    (* file: "Aeneas/Std/BTree.lean", line: 19 *)
    mk_trait_decl "core::alloc::AllocatorClone" "core.alloc.AllocatorClone"
      ~parent_clauses:[ "cloneCloneInst" ];
    (* file: "Aeneas/Std/Core/Ptr.lean", line: 85 *)
    mk_trait_decl "core::alloc::global::GlobalAlloc"
      "core.alloc.global.GlobalAlloc"
      ~methods:[ ("alloc", "alloc"); ("dealloc", "dealloc") ];
    (* file: "Aeneas/Std/BTree.lean", line: 27 *)
    mk_trait_decl "core::borrow::Borrow" "core.borrow.Borrow"
      ~methods:[ ("borrow", "borrow") ];
    (* file: "Aeneas/Std/Core/Core.lean", line: 27 *)
    mk_trait_decl "core::clone::Clone" "core.clone.Clone"
      ~methods:[ ("clone", "clone"); ("clone_from", "clone_from") ]
      ~default_methods:[ "clone_from" ];
    (* file: "Aeneas/Std/Core/Cmp.lean", line: 18 *)
    mk_trait_decl "core::cmp::Eq" "core.cmp.Eq"
      ~parent_clauses:[ "partialEqInst" ]
      ~methods:[ ("assert_fields_are_eq", "assert_fields_are_eq") ];
    (* file: "Aeneas/Std/Core/Cmp.lean", line: 164 *)
    mk_trait_decl "core::cmp::Ord" "core.cmp.Ord"
      ~parent_clauses:[ "eqInst"; "partialOrdInst" ]
      ~methods:
        [ ("cmp", "cmp"); ("max", "max"); ("min", "min"); ("clamp", "clamp") ];
    (* file: "Aeneas/Std/Core/Cmp.lean", line: 13 *)
    mk_trait_decl "core::cmp::PartialEq" "core.cmp.PartialEq"
      ~methods:[ ("eq", "eq"); ("ne", "ne") ];
    (* file: "Aeneas/Std/Core/Cmp.lean", line: 91 *)
    mk_trait_decl "core::cmp::PartialOrd" "core.cmp.PartialOrd"
      ~parent_clauses:[ "partialEqInst" ]
      ~methods:
        [
          ("partial_cmp", "partial_cmp");
          ("lt", "lt");
          ("le", "le");
          ("gt", "gt");
          ("ge", "ge");
        ];
    (* file: "Aeneas/Std/Core/Convert.lean", line: 71 *)
    mk_trait_decl "core::convert::AsMut" "core.convert.AsMut"
      ~methods:[ ("as_mut", "as_mut") ];
    (* file: "Aeneas/Std/Core/Convert.lean", line: 27 *)
    mk_trait_decl "core::convert::AsRef" "core.convert.AsRef"
      ~methods:[ ("as_ref", "as_ref") ];
    (* file: "Aeneas/Std/Core/Core.lean", line: 23 *)
    mk_trait_decl "core::convert::From" "core.convert.From"
      ~methods:[ ("from", "from") ];
    (* file: "Aeneas/Std/Core/Convert.lean", line: 12 *)
    mk_trait_decl "core::convert::Into" "core.convert.Into"
      ~methods:[ ("into", "into") ];
    (* file: "Aeneas/Std/Core/Convert.lean", line: 39 *)
    mk_trait_decl "core::convert::TryFrom" "core.convert.TryFrom"
      ~methods:[ ("try_from", "try_from") ];
    (* file: "Aeneas/Std/Core/Convert.lean", line: 49 *)
    mk_trait_decl "core::convert::TryInto" "core.convert.TryInto"
      ~methods:[ ("try_into", "try_into") ];
    (* file: "Aeneas/Std/Core/Default.lean", line: 8 *)
    mk_trait_decl "core::default::Default" "core.default.Default"
      ~methods:[ ("default", "default") ];
    (* file: "Aeneas/Std/Core/Error.lean", line: 7 *)
    mk_trait_decl "core::error::Error" "core.error.Error"
      ~parent_clauses:[ "fmtDebugInst"; "fmtDisplayInst" ];
    (* file: "Aeneas/Std/Core/Fmt.lean", line: 17 *)
    mk_trait_decl "core::fmt::Debug" "core.fmt.Debug"
      ~methods:[ ("fmt", "fmt") ];
    (* file: "Aeneas/Std/Core/Fmt.lean", line: 70 *)
    mk_trait_decl "core::fmt::Display" "core.fmt.Display"
      ~methods:[ ("fmt", "fmt") ];
    (* file: "Aeneas/Std/Core/Fmt.lean", line: 74 *)
    mk_trait_decl "core::fmt::LowerHex" "core.fmt.LowerHex"
      ~methods:[ ("fmt", "fmt") ];
    (* file: "Aeneas/Std/Core/Hash.lean", line: 13 *)
    mk_trait_decl "core::hash::Hash" "core.hash.Hash"
      ~methods:[ ("hash", "hash") ];
    (* file: "Aeneas/Std/Core/Hash.lean", line: 8 *)
    mk_trait_decl "core::hash::Hasher" "core.hash.Hasher"
      ~methods:[ ("finish", "finish"); ("write", "write") ];
    (* file: "Aeneas/Std/Core/Iter.lean", line: 29 *)
    mk_trait_decl "core::iter::adapters::zip::TrustedRandomAccessNoCoerce"
      "core.iter.adapters.zip.TrustedRandomAccessNoCoerce"
      ~consts:[ ("MAY_HAVE_SIDE_EFFECT", "MAY_HAVE_SIDE_EFFECT") ];
    (* file: "Aeneas/Std/Core/Iter.lean", line: 18 *)
    mk_trait_decl "core::iter::range::Step" "core.iter.range.Step"
      ~parent_clauses:[ "cloneInst"; "partialOrdInst" ]
      ~methods:
        [
          ("steps_between", "steps_between");
          ("forward_checked", "forward_checked");
          ("backward_checked", "backward_checked");
        ];
    (* file: "Aeneas/Std/Core/Iter.lean", line: 201 *)
    mk_trait_decl "core::iter::traits::accum::Product"
      "core.iter.traits.accum.Product"
      ~methods:[ ("product", "product") ];
    (* file: "Aeneas/Std/Core/Iter.lean", line: 197 *)
    mk_trait_decl "core::iter::traits::accum::Sum" "core.iter.traits.accum.Sum"
      ~methods:[ ("sum", "sum") ];
    (* file: "Aeneas/Std/Core/Iter.lean", line: 273 *)
    mk_trait_decl "core::iter::traits::collect::Extend"
      "core.iter.traits.collect.Extend"
      ~methods:[ ("extend", "extend") ];
    (* file: "Aeneas/Std/Core/Iter.lean", line: 212 *)
    mk_trait_decl "core::iter::traits::collect::FromIterator"
      "core.iter.traits.collect.FromIterator"
      ~methods:[ ("from_iter", "from_iter") ];
    (* file: "Aeneas/Std/Core/Iter.lean", line: 205 *)
    mk_trait_decl "core::iter::traits::collect::IntoIterator"
      "core.iter.traits.collect.IntoIterator" ~parent_clauses:[ "iteratorInst" ]
      ~methods:[ ("into_iter", "into_iter") ];
    (* file: "Aeneas/Std/Core/Iter.lean", line: 278 *)
    mk_trait_decl "core::iter::traits::double_ended::DoubleEndedIterator"
      "core.iter.traits.double_ended.DoubleEndedIterator"
      ~parent_clauses:[ "iteratorInst" ]
      ~methods:[ ("next_back", "next_back") ];
    (* file: "Aeneas/Std/Core/Iter.lean", line: 284 *)
    mk_trait_decl "core::iter::traits::exact_size::ExactSizeIterator"
      "core.iter.traits.exact_size.ExactSizeIterator"
      ~parent_clauses:[ "iteratorInst" ];
    (* file: "Aeneas/Std/Core/Iter.lean", line: 87 *)
    mk_trait_decl "core::iter::traits::iterator::Iterator"
      "core.iter.traits.iterator.Iterator"
      ~methods:
        [
          ("next", "next");
          ("size_hint", "size_hint");
          ("step_by", "step_by");
          ("enumerate", "enumerate");
          ("take", "take");
        ];
    (* file: "Aeneas/Std/Core/Core.lean", line: 63 *)
    mk_trait_decl "core::marker::Copy" "core.marker.Copy"
      ~parent_clauses:[ "cloneInst" ];
    (* file: "Aeneas/Std/Core/Discriminant.lean", line: 10 *)
    mk_trait_decl "core::marker::DiscriminantKind" "DiscriminantKind"
      ~parent_clauses:
        [
          "cloneInst";
          "copyInst";
          "debugInst";
          "partialEqInst";
          "eqInst";
          "hashInst";
        ]
      ~types:[ ("Discriminant", "Discriminant") ];
    (* file: "Aeneas/Std/Core/Marker.lean", line: 10 *)
    mk_trait_decl "core::marker::Freeze" "core.marker.Freeze";
    (* file: "Aeneas/Std/Core/Marker.lean", line: 7 *)
    mk_trait_decl "core::marker::StructuralPartialEq"
      "core.marker.StructuralPartialEq";
    (* file: "Aeneas/Std/Core/Ops.lean", line: 45 *)
    mk_trait_decl "core::ops::bit::BitAnd" "core.ops.bit.BitAnd"
      ~methods:[ ("bitand", "bitand") ];
    (* file: "Aeneas/Std/Core/Ops.lean", line: 21 *)
    mk_trait_decl "core::ops::deref::Deref" "core.ops.deref.Deref"
      ~methods:[ ("deref", "deref") ];
    (* file: "Aeneas/Std/Core/Ops.lean", line: 25 *)
    mk_trait_decl "core::ops::deref::DerefMut" "core.ops.deref.DerefMut"
      ~parent_clauses:[ "derefInst" ]
      ~methods:[ ("deref_mut", "deref_mut") ];
    (* file: "Aeneas/Std/Core/Ops.lean", line: 49 *)
    mk_trait_decl "core::ops::drop::Drop" "core.ops.drop.Drop"
      ~methods:[ ("drop", "drop") ];
    (* file: "Aeneas/Std/Core/Ops.lean", line: 67 *)
    mk_trait_decl "core::ops::function::Fn" "core.ops.function.Fn"
      ~parent_clauses:[ "FnMutInst" ]
      ~methods:[ ("call", "call") ];
    (* file: "Aeneas/Std/Core/Ops.lean", line: 62 *)
    mk_trait_decl "core::ops::function::FnMut" "core.ops.function.FnMut"
      ~parent_clauses:[ "FnOnceInst" ]
      ~methods:[ ("call_mut", "call_mut") ];
    (* file: "Aeneas/Std/Core/Ops.lean", line: 58 *)
    mk_trait_decl "core::ops::function::FnOnce" "core.ops.function.FnOnce"
      ~methods:[ ("call_once", "call_once") ];
    (* file: "Aeneas/Std/Core/Ops.lean", line: 12 *)
    mk_trait_decl "core::ops::index::Index" "core.ops.index.Index"
      ~methods:[ ("index", "index") ];
    (* file: "Aeneas/Std/Core/Ops.lean", line: 16 *)
    mk_trait_decl "core::ops::index::IndexMut" "core.ops.index.IndexMut"
      ~parent_clauses:[ "indexInst" ]
      ~methods:[ ("index_mut", "index_mut") ];
    (* file: "Aeneas/Std/Core/Ops.lean", line: 88 *)
    mk_trait_decl "core::ops::try_trait::FromResidual"
      "core.ops.try_trait.FromResidual"
      ~methods:[ ("from_residual", "from_residual") ];
    (* file: "Aeneas/Std/Core/Ops.lean", line: 103 *)
    mk_trait_decl "core::ops::try_trait::Residual" "core.ops.try_trait.Residual"
      ~parent_clauses:[ "TryInst" ];
    (* file: "Aeneas/Std/Core/Ops.lean", line: 97 *)
    mk_trait_decl "core::ops::try_trait::Try" "core.ops.try_trait.Try"
      ~parent_clauses:[ "FromResidualInst" ]
      ~methods:[ ("from_output", "from_output"); ("branch", "branch") ];
    (* file: "Aeneas/Std/Slice.lean", line: 338 *)
    mk_trait_decl "core::slice::index::SliceIndex" "core.slice.index.SliceIndex"
      ~methods:
        [
          ("get", "get");
          ("get_mut", "get_mut");
          ("get_unchecked", "get_unchecked");
          ("get_unchecked_mut", "get_unchecked_mut");
          ("index", "index");
          ("index_mut", "index_mut");
        ];
  ]

let lean_builtin_trait_impls =
  [
    (* file: "Aeneas/Std/BTree.lean", line: 23 *)
    mk_trait_impl "core::alloc::AllocatorClone<alloc::alloc::Global>"
      "alloc.alloc.Global.Insts.CoreAllocAllocatorClone";
    (* file: "Aeneas/Std/BTree.lean", line: 31 *)
    mk_trait_impl "core::borrow::Borrow<@T, @T>" "core.borrow.Borrow.Blanket";
    (* file: "Aeneas/Std/Core/Core.lean", line: 57 *)
    mk_trait_impl "core::clone::Clone<Box<@T>>" "core.clone.CloneBox"
      ~keep_params:(Some [ true; false ])
      ~keep_trait_clauses:(Some [ true; false ]);
    (* file: "Aeneas/Std/Array/Array.lean", line: 379 *)
    mk_trait_impl "core::clone::Clone<[@T; @N]>" "core.clone.CloneArray";
    (* file: "Aeneas/Std/Core/Core.lean", line: 37 *)
    mk_trait_impl "core::clone::Clone<alloc::alloc::Global>"
      "core.clone.CloneGlobal";
    (* file: "Aeneas/Std/Vec.lean", line: 614 *)
    mk_trait_impl "core::clone::Clone<alloc::vec::Vec<@T>>"
      "core.clone.CloneallocvecVec"
      ~keep_params:(Some [ true; false ])
      ~keep_trait_clauses:(Some [ true; false ]);
    (* file: "Aeneas/Std/Core/Core.lean", line: 46 *)
    mk_trait_impl "core::clone::Clone<bool>" "core.clone.CloneBool";
    (* file: "Aeneas/Std/Core/Cmp.lean", line: 254 *)
    mk_trait_impl "core::cmp::PartialEq<&'a @A, &'b @B>"
      "core.cmp.PartialEqShared";
    (* file: "Aeneas/Std/Core/Cmp.lean", line: 222 *)
    mk_trait_impl "core::cmp::PartialEq<(), ()>" "core.cmp.PartialEqUnit";
    (* file: "Aeneas/Std/Core/Cmp.lean", line: 302 *)
    mk_trait_impl "core::cmp::PartialEq<Box<@T>, Box<@T>>"
      "core.cmp.PartialEqBox"
      ~keep_params:(Some [ true; false ]);
    (* file: "Aeneas/Std/Vec.lean", line: 744 *)
    mk_trait_impl
      "core::cmp::PartialEq<alloc::vec::Vec<@T>, alloc::vec::Vec<@U>>"
      "core.cmp.PartialEqVec"
      ~keep_params:(Some [ true; true; false; false ]);
    (* file: "Aeneas/Std/Core/Cmp.lean", line: 239 *)
    mk_trait_impl "core::cmp::PartialEq<bool, bool>" "core.cmp.PartialEqBool";
    (* file: "Aeneas/Std/Core/Cmp.lean", line: 286 *)
    mk_trait_impl "core::cmp::PartialOrd<&'a @A, &'b @B>"
      "core.cmp.PartialOrdShared";
    (* file: "Aeneas/Std/Core/Convert.lean", line: 75 *)
    mk_trait_impl "core::convert::AsMut<Box<@T>, @T>" "core.convert.AsMutBox";
    (* file: "Aeneas/Std/Array/ArraySlice.lean", line: 486 *)
    mk_trait_impl "core::convert::AsMut<[@T; @N], [@T]>"
      "Array.Insts.CoreConvertAsMutSlice";
    (* file: "Aeneas/Std/Array/ArraySlice.lean", line: 480 *)
    mk_trait_impl "core::convert::AsRef<[@T; @N], [@T]>"
      "Array.Insts.CoreConvertAsRefSlice";
    (* file: "Aeneas/Std/Core/Convert.lean", line: 34 *)
    mk_trait_impl "core::convert::From<@Self, @Self>" "core.convert.FromSame";
    (* file: "Aeneas/Std/Vec.lean", line: 530 *)
    mk_trait_impl "core::convert::From<Box<[@T]>, alloc::vec::Vec<@T>>"
      "core.convert.FromBoxSliceVec"
      ~keep_params:(Some [ true; false ]);
    (* file: "Aeneas/Std/Vec.lean", line: 514 *)
    mk_trait_impl "core::convert::From<alloc::vec::Vec<@T>, [@T; @N]>"
      "core.convert.FromVecArray";
    (* file: "Aeneas/Std/Core/Convert.lean", line: 21 *)
    mk_trait_impl "core::convert::Into<@Self, @T>" "core.convert.IntoFrom";
    (* file: "Aeneas/Std/Array/ArraySlice.lean", line: 323 *)
    mk_trait_impl
      "core::convert::TryFrom<&'a [@T; @N], &'a [@T], \
       core::array::TryFromSliceError>"
      "core.convert.TryFromSharedArraySliceTryFromSliceError";
    (* file: "Aeneas/Std/Core/Convert.lean", line: 64 *)
    mk_trait_impl "core::convert::TryInto<@T, @U, @E>"
      "core.convert.TryInto.Blanket";
    (* file: "Aeneas/Std/Core/Convert.lean", line: 58 *)
    mk_trait_impl "core::convert::{core::convert::TryInto<@T, @U>}"
      "core.convert.TryIntoFrom";
    (* file: "Aeneas/Std/Array/Array.lean", line: 472 *)
    mk_trait_impl "core::default::Default<[@T; 0]>"
      "core.default.DefaultArrayEmpty";
    (* file: "Aeneas/Std/Array/Array.lean", line: 461 *)
    mk_trait_impl "core::default::Default<[@T; @N]>" "core.default.DefaultArray";
    (* file: "Aeneas/Std/Core/Fmt.lean", line: 179 *)
    mk_trait_impl "core::fmt::Debug<&'0 @T>" "core.fmt.DebugShared";
    (* file: "Aeneas/Std/Core/Fmt.lean", line: 185 *)
    mk_trait_impl "core::fmt::Debug<()>" "core.fmt.DebugUnit";
    (* file: "Aeneas/Std/Array/ArrayDebug.lean", line: 18 *)
    mk_trait_impl "core::fmt::Debug<[@T; @N]>" "Array.Insts.CoreFmtDebug";
    (* file: "Aeneas/Std/Vec.lean", line: 765 *)
    mk_trait_impl "core::fmt::Debug<alloc::vec::Vec<@T>>" "core.fmt.DebugVec"
      ~keep_params:(Some [ true; false ]);
    (* file: "Aeneas/Std/Core/Fmt.lean", line: 190 *)
    mk_trait_impl "core::fmt::Debug<bool>" "core.fmt.DebugBool";
    (* file: "Aeneas/Std/Array/ArraySlice.lean", line: 289 *)
    mk_trait_impl "core::fmt::Debug<core::array::TryFromSliceError>"
      "core.fmt.DebugTryFromSliceError";
    (* file: "Aeneas/Std/Scalar/Fmt.lean", line: 136 *)
    mk_trait_impl "core::fmt::Debug<i128>" "core.fmt.DebugI128";
    (* file: "Aeneas/Std/Scalar/Fmt.lean", line: 121 *)
    mk_trait_impl "core::fmt::Debug<i16>" "core.fmt.DebugI16";
    (* file: "Aeneas/Std/Scalar/Fmt.lean", line: 126 *)
    mk_trait_impl "core::fmt::Debug<i32>" "core.fmt.DebugI32";
    (* file: "Aeneas/Std/Scalar/Fmt.lean", line: 131 *)
    mk_trait_impl "core::fmt::Debug<i64>" "core.fmt.DebugI64";
    (* file: "Aeneas/Std/Scalar/Fmt.lean", line: 116 *)
    mk_trait_impl "core::fmt::Debug<i8>" "core.fmt.DebugI8";
    (* file: "Aeneas/Std/Scalar/Fmt.lean", line: 141 *)
    mk_trait_impl "core::fmt::Debug<isize>" "core.fmt.DebugIsize";
    (* file: "Aeneas/Std/Scalar/Fmt.lean", line: 70 *)
    mk_trait_impl "core::fmt::Debug<u128>" "core.fmt.DebugU128";
    (* file: "Aeneas/Std/Scalar/Fmt.lean", line: 55 *)
    mk_trait_impl "core::fmt::Debug<u16>" "core.fmt.DebugU16";
    (* file: "Aeneas/Std/Scalar/Fmt.lean", line: 60 *)
    mk_trait_impl "core::fmt::Debug<u32>" "core.fmt.DebugU32";
    (* file: "Aeneas/Std/Scalar/Fmt.lean", line: 65 *)
    mk_trait_impl "core::fmt::Debug<u64>" "core.fmt.DebugU64";
    (* file: "Aeneas/Std/Scalar/Fmt.lean", line: 50 *)
    mk_trait_impl "core::fmt::Debug<u8>" "core.fmt.DebugU8";
    (* file: "Aeneas/Std/Scalar/Fmt.lean", line: 75 *)
    mk_trait_impl "core::fmt::Debug<usize>" "core.fmt.DebugUsize";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 587 *)
    mk_trait_impl "core::iter::range::Step<i128>" "core.iter.range.StepI128";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 548 *)
    mk_trait_impl "core::iter::range::Step<i16>" "core.iter.range.StepI16";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 561 *)
    mk_trait_impl "core::iter::range::Step<i32>" "core.iter.range.StepI32";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 574 *)
    mk_trait_impl "core::iter::range::Step<i64>" "core.iter.range.StepI64";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 535 *)
    mk_trait_impl "core::iter::range::Step<i8>" "core.iter.range.StepI8";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 522 *)
    mk_trait_impl "core::iter::range::Step<isize>" "core.iter.range.StepIsize";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 509 *)
    mk_trait_impl "core::iter::range::Step<u128>" "core.iter.range.StepU128";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 470 *)
    mk_trait_impl "core::iter::range::Step<u16>" "core.iter.range.StepU16";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 483 *)
    mk_trait_impl "core::iter::range::Step<u32>" "core.iter.range.StepU32";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 496 *)
    mk_trait_impl "core::iter::range::Step<u64>" "core.iter.range.StepU64";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 457 *)
    mk_trait_impl "core::iter::range::Step<u8>" "core.iter.range.StepU8";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 444 *)
    mk_trait_impl "core::iter::range::Step<usize>" "core.iter.range.StepUsize";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 119 *)
    mk_trait_impl "core::iter::traits::accum::Sum<usize, usize>"
      "Usize.Insts.CoreIterTraitsAccumSumUsize";
    (* file: "Aeneas/Std/BTree.lean", line: 307 *)
    mk_trait_impl
      "core::iter::traits::collect::FromIterator<alloc::collections::btree::map::BTreeMap<@K, \
       @V, alloc::alloc::Global>, (@K, @V)>"
      "alloc.collections.btree.map.BTreeMapKVGlobal.Insts.CoreIterTraitsCollectFromIteratorPair";
    (* file: "Aeneas/Std/BTree.lean", line: 338 *)
    mk_trait_impl
      "core::iter::traits::collect::FromIterator<alloc::collections::btree::set::BTreeSet<@T, \
       alloc::alloc::Global>, @T>"
      "alloc.collections.btree.set.BTreeSetTGlobal.Insts.CoreIterTraitsCollectFromIterator";
    (* file: "Aeneas/Std/VecIter.lean", line: 102 *)
    mk_trait_impl
      "core::iter::traits::collect::FromIterator<alloc::vec::Vec<@T>, @T>"
      "core.iter.traits.collect.FromIteratorVec";
    (* file: "Aeneas/Std/Core/IterOverrides.lean", line: 383 *)
    mk_trait_impl
      "core::iter::traits::collect::FromIterator<core::result::Result<@V, @E>, \
       core::result::Result<@T, @E>>"
      "core.result.Result.Insts.CoreIterTraitsCollectFromIteratorResult";
    (* file: "Aeneas/Std/SliceIter.lean", line: 160 *)
    mk_trait_impl
      "core::iter::traits::collect::IntoIterator<&'a [@T; @N], &'a @T, \
       core::slice::iter::Iter<'a, @T>>"
      "SharedArray.Insts.CoreIterTraitsCollectIntoIteratorSharedIter";
    (* file: "Aeneas/Std/SliceIter.lean", line: 181 *)
    mk_trait_impl
      "core::iter::traits::collect::IntoIterator<&'a [@T], &'a @T, \
       core::slice::iter::Iter<'a, @T>>"
      "SharedSlice.Insts.CoreIterTraitsCollectIntoIteratorSharedIter";
    (* file: "Aeneas/Std/Core/IterOverrides.lean", line: 103 *)
    mk_trait_impl
      "core::iter::traits::collect::IntoIterator<&'a alloc::vec::Vec<@T>, &'a \
       @T, core::slice::iter::Iter<'a, @T>>"
      "SharedAVec.Insts.CoreIterTraitsCollectIntoIteratorSharedATIter"
      ~keep_params:(Some [ true; false ]);
    (* file: "Aeneas/Std/Core/Iter.lean", line: 226 *)
    mk_trait_impl "core::iter::traits::collect::IntoIterator<@I, @Item, @I>"
      "core.iter.traits.collect.IntoIterator.Blanket";
    (* file: "Aeneas/Std/Core/IterOverrides.lean", line: 55 *)
    mk_trait_impl
      "core::iter::traits::collect::IntoIterator<[@T; @N], @T, \
       core::array::iter::IntoIter<@T, @N>>"
      "Array.Insts.CoreIterTraitsCollectIntoIteratorTIntoIter";
    (* file: "Aeneas/Std/BTree.lean", line: 247 *)
    mk_trait_impl
      "core::iter::traits::collect::IntoIterator<alloc::collections::btree::map::BTreeMap<@K, \
       @V, @A>, (@K, @V), alloc::collections::btree::map::IntoIter<@K, @V, \
       @A>>"
      "alloc.collections.btree.map.BTreeMap.Insts.CoreIterTraitsCollectIntoIteratorPairIntoIter";
    (* file: "Aeneas/Std/BTree.lean", line: 380 *)
    mk_trait_impl
      "core::iter::traits::collect::IntoIterator<alloc::collections::btree::set::BTreeSet<@T, \
       @A>, @T, alloc::collections::btree::set::IntoIter<@T, @A>>"
      "alloc.collections.btree.set.BTreeSet.Insts.CoreIterTraitsCollectIntoIteratorTIntoIter";
    (* file: "Aeneas/Std/VecIter.lean", line: 51 *)
    mk_trait_impl
      "core::iter::traits::collect::IntoIterator<alloc::vec::Vec<@T>, @T, \
       alloc::vec::into_iter::IntoIter<@T, @A>>"
      "core.iter.traits.collect.IntoIteratorVec"
      ~keep_params:(Some [ true; false ]);
    (* file: "Aeneas/Std/RangeIter.lean", line: 555 *)
    mk_trait_impl
      "core::iter::traits::double_ended::DoubleEndedIterator<core::ops::range::Range<@A>, \
       @A>"
      "core.ops.range.Range.Insts.DoubleEndedIterator";
    (* file: "Aeneas/Std/BTree.lean", line: 238 *)
    mk_trait_impl
      "core::iter::traits::iterator::Iterator<alloc::collections::btree::map::IntoIter<@K, \
       @V, @A>, (@K, @V)>"
      "alloc.collections.btree.map.IntoIter.Insts.CoreIterTraitsIteratorIteratorPair";
    (* file: "Aeneas/Std/BTree.lean", line: 199 *)
    mk_trait_impl
      "core::iter::traits::iterator::Iterator<alloc::collections::btree::map::Iter<'a, \
       @K, @V>, (&'a @K, &'a @V)>"
      "alloc.collections.btree.map.Iter.Insts.CoreIterTraitsIteratorIteratorPairSharedAKSharedAV";
    (* file: "Aeneas/Std/BTree.lean", line: 372 *)
    mk_trait_impl
      "core::iter::traits::iterator::Iterator<alloc::collections::btree::set::IntoIter<@T, \
       @A>, @T>"
      "alloc.collections.btree.set.IntoIter.Insts.CoreIterTraitsIteratorIterator";
    (* file: "Aeneas/Std/VecIter.lean", line: 31 *)
    mk_trait_impl
      "core::iter::traits::iterator::Iterator<alloc::vec::into_iter::IntoIter<@T, \
       @A>, @T>"
      "core.iter.traits.iterator.IteratorVecIntoIter"
      ~keep_params:(Some [ true; false ]);
    (* file: "Aeneas/Std/Core/IterOverrides.lean", line: 48 *)
    mk_trait_impl
      "core::iter::traits::iterator::Iterator<core::array::iter::IntoIter<@T, \
       @N>, @T>"
      "core.array.iter.IntoIter.Insts.CoreIterTraitsIteratorIterator";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 398 *)
    mk_trait_impl
      "core::iter::traits::iterator::Iterator<core::iter::adapters::chain::Chain<@A, \
       @B>, @Clause0_Item>"
      "core.iter.adapters.chain.Chain.Insts.CoreIterTraitsIteratorIterator";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 618 *)
    mk_trait_impl
      "core::iter::traits::iterator::Iterator<core::iter::adapters::enumerate::Enumerate<@I>, \
       (usize, @Clause0_Item)>"
      "core.iter.traits.iterator.IteratorEnumerate";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 234 *)
    mk_trait_impl
      "core::iter::traits::iterator::Iterator<core::iter::adapters::filter::Filter<@I, \
       @P>, @Clause0_Item>"
      "core.iter.adapters.filter.Filter.Insts.CoreIterTraitsIteratorIterator";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 313 *)
    mk_trait_impl
      "core::iter::traits::iterator::Iterator<core::iter::adapters::filter_map::FilterMap<@I, \
       @F>, @B>"
      "core.iter.adapters.filter_map.FilterMap.Insts.CoreIterTraitsIteratorIterator";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 515 *)
    mk_trait_impl
      "core::iter::traits::iterator::Iterator<core::iter::adapters::flatten::FlatMap<@I, \
       @U, @F, @Clause1_Item, @Clause1_IntoIter>, @Clause1_Item>"
      "core.iter.adapters.flatten.FlatMap.Insts.CoreIterTraitsIteratorIterator";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 166 *)
    mk_trait_impl
      "core::iter::traits::iterator::Iterator<core::iter::adapters::map::Map<@I, \
       @F>, @B>"
      "core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 182 *)
    mk_trait_impl
      "core::iter::traits::iterator::Iterator<core::iter::adapters::step_by::StepBy<@I>, \
       @Clause0_Item>"
      "core.iter.traits.iterator.IteratorStepBy";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 668 *)
    mk_trait_impl
      "core::iter::traits::iterator::Iterator<core::iter::adapters::take::Take<@I>, \
       @Clause0_Item>"
      "core.iter.traits.iterator.IteratorTake";
    (* file: "Aeneas/Std/Core/IterOverrides.lean", line: 147 *)
    mk_trait_impl
      "core::iter::traits::iterator::Iterator<core::iter::adapters::zip::Zip<@A, \
       @B>, (@Clause0_Item, @Clause1_Item)>"
      "core.iter.adapters.zip.Zip.Insts.CoreIterTraitsIteratorIteratorPair";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 601 *)
    mk_trait_impl
      "core::iter::traits::iterator::Iterator<core::iter::sources::empty::Empty<@T>, \
       @T>"
      "core.iter.sources.empty.Empty.Insts.CoreIterTraitsIteratorIterator";
    (* file: "Aeneas/Std/Core/IterAdapters.lean", line: 575 *)
    mk_trait_impl
      "core::iter::traits::iterator::Iterator<core::iter::sources::once::Once<@T>, \
       @T>"
      "core.iter.sources.once.Once.Insts.CoreIterTraitsIteratorIterator";
    (* file: "Aeneas/Std/Core/Iter.lean", line: 707 *)
    mk_trait_impl
      "core::iter::traits::iterator::Iterator<core::ops::range::Range<@A>, @A>"
      "core.iter.traits.iterator.IteratorRange";
    (* file: "Aeneas/Std/RangeIter.lean", line: 583 *)
    mk_trait_impl
      "core::iter::traits::iterator::Iterator<core::ops::range::RangeInclusive<@A>, \
       @A>"
      "core.ops.range.RangeInclusive.Insts.CoreIterTraitsIteratorIterator";
    (* file: "Aeneas/Std/Core/IterOverrides.lean", line: 282 *)
    mk_trait_impl
      "core::iter::traits::iterator::Iterator<core::slice::iter::Chunks<'a, \
       @T>, &'a [@T]>"
      "core.slice.iter.Chunks.Insts.CoreIterTraitsIteratorIteratorSharedASlice";
    (* file: "Aeneas/Std/SliceIter.lean", line: 218 *)
    mk_trait_impl
      "core::iter::traits::iterator::Iterator<core::slice::iter::ChunksExact<'a, \
       @T>, &'a [@T]>"
      "core.iter.traits.iterator.IteratorChunksExact";
    (* file: "Aeneas/Std/SliceIter.lean", line: 133 *)
    mk_trait_impl
      "core::iter::traits::iterator::Iterator<core::slice::iter::Iter<'a, @T>, \
       &'a @T>"
      "core.iter.traits.iterator.IteratorSliceIter";
    (* file: "Aeneas/Std/StringIter.lean", line: 33 *)
    mk_trait_impl
      "core::iter::traits::iterator::Iterator<core::str::iter::Chars<'a>, char>"
      "core.iter.traits.iterator.IteratorChars";
    (* file: "Aeneas/Std/Array/Array.lean", line: 477 *)
    mk_trait_impl "core::marker::Copy<[@T; @N]>" "Array.Insts.CoreMarkerCopy";
    (* file: "Aeneas/Std/Core/Core.lean", line: 67 *)
    mk_trait_impl "core::marker::Copy<bool>" "core.marker.CopyBool";
    (* file: "Aeneas/Std/Core/Ops.lean", line: 31 *)
    mk_trait_impl "core::ops::deref::Deref<Box<@T>, @T>"
      "core.ops.deref.DerefBoxInst"
      ~keep_params:(Some [ true; false ]);
    (* file: "Aeneas/Std/Vec.lean", line: 431 *)
    mk_trait_impl "core::ops::deref::Deref<alloc::vec::Vec<@T>, [@T]>"
      "core.ops.deref.DerefVec"
      ~keep_params:(Some [ true; false ]);
    (* file: "Aeneas/Std/Core/Ops.lean", line: 38 *)
    mk_trait_impl "core::ops::deref::DerefMut<Box<@T>, @T>"
      "core.ops.deref.DerefMutBoxInst"
      ~keep_params:(Some [ true; false ]);
    (* file: "Aeneas/Std/Vec.lean", line: 442 *)
    mk_trait_impl "core::ops::deref::DerefMut<alloc::vec::Vec<@T>, [@T]>"
      "core.ops.deref.DerefMutVec"
      ~keep_params:(Some [ true; false ]);
    (* file: "Aeneas/Std/Array/ArraySlice.lean", line: 111 *)
    mk_trait_impl "core::ops::index::Index<[@T; @N], @I, @O>"
      "core.ops.index.IndexArray";
    (* file: "Aeneas/Std/Slice.lean", line: 557 *)
    mk_trait_impl "core::ops::index::Index<[@T], @I, @O>"
      "core.ops.index.IndexSlice";
    (* file: "Aeneas/Std/Vec.lean", line: 248 *)
    mk_trait_impl "core::ops::index::Index<alloc::vec::Vec<@T>, @T, @O>"
      "alloc.vec.Vec.Index"
      ~keep_params:(Some [ true; true; false; true ]);
    (* file: "Aeneas/Std/Array/ArraySlice.lean", line: 118 *)
    mk_trait_impl "core::ops::index::IndexMut<[@T; @N], @I, @O>"
      "core.ops.index.IndexMutArray";
    (* file: "Aeneas/Std/Slice.lean", line: 564 *)
    mk_trait_impl "core::ops::index::IndexMut<[@T], @I, @O>"
      "core.ops.index.IndexMutSlice";
    (* file: "Aeneas/Std/Vec.lean", line: 256 *)
    mk_trait_impl "core::ops::index::IndexMut<alloc::vec::Vec<@T>, @T, @O>"
      "alloc.vec.Vec.IndexMut"
      ~keep_params:(Some [ true; true; false; true ]);
    (* file: "Aeneas/Std/Slice.lean", line: 430 *)
    mk_trait_impl
      "core::slice::index::SliceIndex<core::ops::range::Range<usize>, [@T], \
       [@T]>"
      "core.slice.index.SliceIndexRangeUsizeSlice";
    (* file: "Aeneas/Std/Slice.lean", line: 687 *)
    mk_trait_impl
      "core::slice::index::SliceIndex<core::ops::range::RangeFrom<usize>, \
       [@T], [@T]>"
      "core.slice.index.SliceIndexRangeFromUsizeSlice";
    (* file: "Aeneas/Std/Slice.lean", line: 546 *)
    mk_trait_impl
      "core::slice::index::SliceIndex<core::ops::range::RangeFull, [@T], [@T]>"
      "core.slice.index.SliceIndexRangeFullSlice";
    (* file: "Aeneas/Std/Slice.lean", line: 496 *)
    mk_trait_impl
      "core::slice::index::SliceIndex<core::ops::range::RangeTo<usize>, [@T], \
       [@T]>"
      "core.slice.index.SliceIndexRangeToUsizeSlice";
    (* file: "Aeneas/Std/Slice.lean", line: 603 *)
    mk_trait_impl "core::slice::index::SliceIndex<usize, [@T], @T>"
      "core.slice.index.SliceIndexUsizeSlice";
  ]
