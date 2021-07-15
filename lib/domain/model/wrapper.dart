class Val<T> {
  final T value;
  Val(this.value);

  @override
  String toString() => "Val<$T>(value=$value)";

  @override
  bool operator ==(Object other) => other is Val<T> && value == other.value;
}

class Var<T> extends Val<T> {
  @override
  T value;
  Var(this.value) : super(value);

  @override
  String toString() => "Var<$T>(value=$value)";

  @override
  bool operator ==(Object other) => other is Var<T> && value == other.value;
}