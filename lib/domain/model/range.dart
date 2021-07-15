import 'dart:core';

/// [end] is inclusive.
mixin NumRange {
  num get start;
  num get end;

  void _checkRange() {
    if(start > end){
      throw "`start` ($start) must not be greater than `end` ($end)";
    }
  }

  //NumRange(this.start, this.end);

  bool isInRange(num other) => start <= other && other <= end;
}

class IntRange extends Iterable<int> with NumRange {

  @override
  final int start;
  @override
  final int end;

  IntRange(this.start, this.end) {
    _checkRange();
  }

  @override
  Iterator<int> get iterator => _IntIterator(start, end);
}

class _IntIterator extends Iterator<int> {
  _IntIterator(this._start, this._end): _current = _start -1;
  final int _start;
  final int _end;
  int _current;

  @override
  int get current => _current;

  @override
  bool moveNext() => ++_current <= _end;
}

class DoubleRange with NumRange {
  @override
  final double start;
  @override
  final double end;

  DoubleRange(this.start, this.end) {
    _checkRange();
  }
}

/// [end] is exclusive.
/// If [end] is null, then [startOrStep] act as exclusive end.
IntRange range(int end, {
  int start = 0,
}) {
  //final usedStart = end != null ? start :
  //int inclusiveEnd = end != null ? end - 1 : startOrStep -1;
  return IntRange(start, end-1);
}