import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/di/service_locator.dart';
import 'firebase_options.dart'; // Correct generated file

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
  
  try {
    // Using the actual generated class name from FlutterFire CLI
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase init failed: $e. Using fallback initialization.");
    await Firebase.initializeApp();
  }
  
  await setupServiceLocator();
  runApp(const MyApp());
}
