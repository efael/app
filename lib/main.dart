import 'package:messenger/application.dart';
import 'package:rinf/rinf.dart';
import 'src/bindings/bindings.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  /*
    TODO:
    Logging, notifications, cross platform, i18n
  */
  await initializeRust(assignRustSignal);
  runApp(const Application());
}

