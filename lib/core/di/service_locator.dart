import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';

Future<void> setupServiceLocator() async {
  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  Get.put<SharedPreferences>(sharedPreferences, permanent: true);

  // Authentication Service
  Get.put<AuthService>(AuthService(), permanent: true);
}
