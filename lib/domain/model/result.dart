
import 'package:equatable/equatable.dart';

abstract class Result<T> extends Equatable {
  final int code;
  Result([this.code = 0]);

  @override
  List<Object?> get props => [code];
}

class Success<T> extends Result<T> {
  @override
  final int code;
  final T data;

  Success(
    this.data,
  [
    this.code = 0,
  ]) : super(code);

  @override
  List<Object?> get props => [code, data];
}

class Fail<T> extends Result<T> {
  final String? msg;
  final error;
  final data;

  Fail({
    int? code,
    this.msg,
    this.error,
    this.data,
  }) : super(code ?? 1);

  @override
  List<Object?> get props => [code, msg, error, data];

  Fail<O> copy<O>({
    int? code,
    String? msg,
    error,
    data,
  }) => Fail(
    code: code ?? this.code,
    msg: msg ?? this.msg,
    error: error ?? this.error,
    data: data ?? this.data,
  );
}

/*
class Loading<T> extends Result<T> {
  Loading([int code = 0]): super(code);
}
 */
