import 'package:get/get.dart';

import '../services/auth_service.dart';
import '../localization/localization_service.dart';

Future<void> setupServiceLocator() async {
  // Authentication & Localization Services
  Get.put<AuthService>(AuthService(), permanent: true);
  Get.put<LocalizationService>(LocalizationService(), permanent: true);
}
