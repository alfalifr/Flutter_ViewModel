import 'package:viewmodel/util/_consoles.dart';

T also<T>(T any, [void Function(T)? operation]) {
  operation?.call(any);
  return any;
}

O let<I, O>(I input, O Function(I) mapper) => mapper(input);


T alsoPrin<T>(T any, {
  String colorAnsi = ansi_reset,
  bool endWithNewLine = true,
}) => also(any, (any) => prin(any, colorAnsi: colorAnsi, endWithNewLine: endWithNewLine));