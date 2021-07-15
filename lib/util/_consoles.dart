import 'dart:io';

const ansi_reset = "\u001B[0m";
const ansi_white = "\u001B[37m";
const ansi_black = "\u001B[30m";
const ansi_red = "\u001B[31m";
const ansi_green = "\u001B[32m";
const ansi_yellow = "\u001B[33m";
const ansi_blue = "\u001B[34m";
const ansi_purple = "\u001B[35m";
const ansi_cyan = "\u001B[36m";


class IoConfig {
  IoConfig._();

  static const canPrint = true;

  static bool _canPrintDebug = true;
  static set canPrintDebug(v) => _canPrintDebug = v;
  static bool get canPrintDebug => canPrint && _canPrintDebug;

  static bool _canPrintResult = true;
  static set canPrintResult(v) => _canPrintResult = v;
  static bool get canPrintResult => canPrint && _canPrintResult;

  static bool _canPrintWarning = true;
  static set canPrintWarning(v) => _canPrintWarning = v;
  static bool get canPrintWarning => canPrint && _canPrintWarning;

  static bool _canPrintError = true;
  static set canPrintError(v) => _canPrintError = v;
  static bool get canPrintError => canPrint && _canPrintError;
}


prin(dynamic any, {
  String colorAnsi = ansi_reset,
  bool endWithNewLine = true,
}) {
  if(!IoConfig.canPrint) return;
  String str;
  switch(colorAnsi) {
    case ansi_reset:
    case ansi_white:
      str = "$any";
      break;
    default:
      str = "$colorAnsi$any$ansi_reset";
      break;
  }

  if(endWithNewLine) {
    print(str);
  } else {
    stdout.write(str);
  }
}

prind(dynamic any,{
  bool endWithNewLine = true,
}) {
  if(IoConfig.canPrintDebug) {
    prin(any, colorAnsi: ansi_cyan, endWithNewLine: endWithNewLine);
  }
}

prinr(dynamic any,{
  bool endWithNewLine = true,
}) {
  if(IoConfig.canPrintResult) {
    prin(any, colorAnsi: ansi_green, endWithNewLine: endWithNewLine);
  }
}

prinw(dynamic any,{
  bool endWithNewLine = true,
}) {
  if(IoConfig.canPrintWarning) {
    prin(any, colorAnsi: ansi_yellow, endWithNewLine: endWithNewLine);
  }
}

prine(dynamic any,{
  bool endWithNewLine = true,
}) {
  if(IoConfig.canPrintError) {
    prin(any, colorAnsi: ansi_red, endWithNewLine: endWithNewLine);
  }
}

prinp(dynamic any,{
  bool endWithNewLine = true,
}) {
  if(IoConfig.canPrintError) {
    prin(any, colorAnsi: ansi_purple, endWithNewLine: endWithNewLine);
  }
}
