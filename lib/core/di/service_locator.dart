import 'package:get/get.dart';

import '../services/auth_service.dart';

Future<void> setupServiceLocator() async {
  // Authentication Service
  Get.put<AuthService>(AuthService(), permanent: true);
}
