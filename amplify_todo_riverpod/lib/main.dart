import "package:amplify_todo_riverpod/app.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:hive_flutter/hive_flutter.dart";

/// This is a reimplementation of the default
/// Flutter application using [Riverpod].
void main() async {
  // if macos
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  runApp(const ProviderScope(child: MyApp()));
}
