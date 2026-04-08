import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/di/service_locator.dart';
// import 'firebase_options_dev.dart'; // User needs to run `flutterfire configure` to generate this

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  AppConfig.initialize(
    AppConfig(
      environment: Environment.dev,
      appName: "Subscription App (Dev)",
      apiBaseUrl: "https://dev.api.example.com",
    ),
  );
  
  // Initialize default Firebase (from current firebase_options.dart)
  // In a real environment split, you'd use Dev options here:
  // await Firebase.initializeApp(options: DefaultFirebaseOptionsDev.currentPlatform);
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase init failed: $e. Did you run flutterfire configure?");
  }
  
  await setupServiceLocator();
  runApp(const MyApp());
}
