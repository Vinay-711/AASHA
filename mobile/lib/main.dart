import 'package:flutter/material.dart';
import 'app.dart';
import 'di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Dependency injection — registers all singletons and factories
  await configureDependencies();

  runApp(const AashaApp());
}
