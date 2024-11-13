import './write.dart';
import './clear.dart';
import 'dart:io';

exitImpl(int code, {bool withNewLine = true, bool withClearing = false}) {
  if (withClearing) {
    clearImpl();
  } else if (withNewLine) {
    writeSpaceImpl();
  }
  exit(code);
}
