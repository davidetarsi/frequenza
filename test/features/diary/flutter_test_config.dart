import 'dart:async';
import 'dart:ffi';

import 'package:sqlite3/open.dart';

/// The diary tests use the system SQLite, which Linux ships as
/// `libsqlite3.so.0` (no `-dev` package on the VPS or on GitHub runners).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  open.overrideFor(OperatingSystem.linux, () {
    for (final name in ['libsqlite3.so', 'libsqlite3.so.0']) {
      try {
        return DynamicLibrary.open(name);
      } on ArgumentError {
        continue;
      }
    }
    throw UnsupportedError('SQLite is not installed');
  });
  await testMain();
}
