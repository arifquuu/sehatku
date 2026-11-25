import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

bool _ffiInitialized = false;

void ensureDesktopSqliteInitialized() {
  if (_ffiInitialized) return;
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    _ffiInitialized = true;
  }
}
