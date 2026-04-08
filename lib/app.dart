import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/signup_screen.dart';
import 'features/auth/presentation/screens/role_selection_screen.dart';

import 'features/vendor/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:p_v_j/features/customer/presentation/screens/customer_main_screen.dart';

import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/app_translations.dart';
import 'core/localization/localization_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConfig.instance.appName,
      debugShowCheckedModeBanner: !AppConfig.instance.isProduction,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      translations: AppTranslations(),
      locale: Get.find<LocalizationService>().locale,
      fallbackLocale: const Locale('en', 'US'),
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/role-selection', page: () => const RoleSelectionScreen()),
        GetPage(name: '/signup', page: () => const SignupScreen()),
        GetPage(name: '/home', page: () => DashboardScreen()),
        GetPage(name: '/customer-home', page: () => const CustomerMainScreen()),
      ],
    );
  }
}
