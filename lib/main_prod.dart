import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/di/service_locator.dart';
// import 'firebase_options_prod.dart'; // User needs to run `flutterfire configure` for Prod

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.initialize(
    AppConfig(
      environment: Environment.prod,
      appName: "Subscription App",
      apiBaseUrl: "https://api.example.com",
    ),
  );
  
  // await Firebase.initializeApp(options: DefaultFirebaseOptionsProd.currentPlatform);
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase init failed: $e. Did you run flutterfire configure?");
  }

  await setupServiceLocator();
  runApp(const MyApp());
}
