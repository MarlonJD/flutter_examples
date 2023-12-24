import "package:demo_amplify/app.dart";
import "package:flutter/material.dart";
import "package:hive_flutter/hive_flutter.dart";

/// This is a reimplementation of the default
void main() async {
  // if macos
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  runApp(const MyApp());
}
