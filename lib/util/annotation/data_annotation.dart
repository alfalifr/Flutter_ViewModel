class _StaticData {
  const _StaticData();
}
/// Mark methods (usually of repos) that the data they return is probably static.
/// It means the probability of data to change is so small.
/// So it seems the methods marked by this [staticData] are dummy although the repos are real.
const staticData = _StaticData();


class Note {
  final String msg;
  const Note({
    this.msg = "",
  });
}


/// Marks any element that it is not used yet in the mean time.
const notUsedYet = Note(msg: "notUsedYet");

/// Marks any element that it may change in future.
const mayChangeInFuture = Note(msg: "mayChangeInFuture");

/// Marks any element that it is not dummy.
const notDummy = Note(msg: "notDummy");

/// Marks any element that it is a 'probable' heavy computation.
const probableHeavyComputation = Note(msg: "probableHeavyComputation");

