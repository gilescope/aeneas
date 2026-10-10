import HashmapCollectIndex.Funs

/-!
The map is collected from the pairs and indexed by key: `lookup [1, 2] [10, 20] 2` is `Ok 20`,
and a zero value short-circuits the `collect` with its key.
-/

open Aeneas Aeneas.Std Result

namespace hashmap_collect_index

set_option maxHeartbeats 1000000 in
theorem lookup_spec :
    lookup (Slice.from [1#u32, 2#u32] (by scalar_tac)) (Slice.from [10#u32, 20#u32] (by scalar_tac))
      2#u32 = ok (.Ok 20#u32) := by
  unfold lookup
  simp only [core.iter.traits.iterator.Iterator.zip.trait_default,
    core.iter.traits.iterator.Iterator.zip.default, ZipShape.ofZip,
    core.iter.traits.collect.IntoIterator.Blanket,
    core.iter.traits.collect.IntoIterator.Blanket.into_iter,
    core.iter.traits.iterator.Iterator.map.default, MapShape.ofMap,
    core.iter.traits.iterator.Iterator.collect.default, CollectShape.collect,
    core.slice.Slice.iter, bind_tc_ok, bind_ok]
  simp only [core.result.Result.Insts.CoreIterTraitsCollectFromIteratorResult.from_iter,
    std.collections.hash.map.HashMapKVSGlobal.Insts.CoreIterTraitsCollectFromIteratorPair.from_iter,
    alloc.collections.btree.toList, core.iter.adapters.GenericShunt.firstErr,
    core.iter.traits.collect.IntoIterator.Blanket.into_iter, id, bind_tc_ok, bind_ok]
  iterate 12 all_goals
    try unfold loop
    simp only [core.iter.adapters.GenericShunt.next,
      core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator,
      core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator.next,
      core.iter.adapters.zip.Zip.Insts.CoreIterTraitsIteratorIteratorPair,
      core.iter.adapters.zip.Zip.nextPlain, core.iter.traits.iterator.IteratorSliceIter,
      core.slice.iter.IteratorSliceIter.next,
      lookup.closure.Insts.CoreOpsFunctionFnMutTuplePairShared0U32Shared1U32ResultPairU32U32U32,
      lookup.closure.Insts.CoreOpsFunctionFnMutTuplePairShared0U32Shared1U32ResultPairU32U32U32.call_mut,
      std.collections.hash.map.HashMap.insertList, core.cmp.EqU32, core.cmp.PartialEqU32,
      List.foldlM, core.result.Result.Insts.CoreOpsTry.branch,
      std.collections.hash.map.HashMap.Insts.CoreOpsIndexIndexShared0QV.index,
      std.collections.hash.map.HashMap.lookup, core.borrow.Borrow.Blanket,
      core.borrow.Borrow.Blanket.borrow, bind_tc_ok, bind_ok]
    try simp (config := { decide := true })

end hashmap_collect_index
