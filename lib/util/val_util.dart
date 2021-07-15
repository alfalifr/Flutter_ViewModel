import 'package:viewmodel/domain/model/result.dart';

T? tryGetResultValue<T>(Result<T> result, { T? Function(Fail<T>)? onError }) => result is Success<T>
    ? result.data
    : onError == null
      ? null
      : onError(result as Fail<T>);

T getResultValue<T>(Result<T> result, { T Function(Fail<T>)? onError }) => result is Success<T>
    ? result.data
    : onError == null
      ? throw "Can't get result from `${result.runtimeType}`"
      : onError(result as Fail<T>);