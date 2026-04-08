import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_roles.dart';
import '../../../../core/constants/app_styles.dart';
import 'package:p_v_j/core/localization/localization_service.dart';
import '../../../../core/utils/responsive_helper.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Stack(
          children: [
            // Decorative background elements
            Positioned(
              top: -context.ph(5),
              right: -context.pw(15),
              child: Container(
                width: context.pw(65),
                height: context.pw(65),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              bottom: context.ph(5),
              left: -context.pw(20),
              child: Container(
                width: context.pw(55),
                height: context.pw(55),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: context.pw(7.5)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: context.ph(1)),
                            // Back Button
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: context.sp(20)),
                              onPressed: () => Get.back(),
                            ),
                            SizedBox(height: context.ph(5)),
                            Text(
                              AppStrings.tellUsAboutYou,
                              style: AppStyles.headerDisplay(context).copyWith(
                                fontSize: context.sp(32),
                              ),
                            ),
                            SizedBox(height: context.ph(1)),
                            Text(
                              AppStrings.chooseAppUse,
                              style: TextStyle(
                                fontSize: context.sp(15),
                                color: Colors.white.withValues(alpha: 0.85),
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: context.ph(6)),
                            _buildRoleCard(
                              context: context,
                              title: AppStrings.imVendor,
                              description: AppStrings.vendorDesc,
                              icon: Icons.storefront_rounded,
                              role: AppRoles.admin,
                              accentColor: AppColors.primary,
                            ),
                            SizedBox(height: context.ph(2)),
                            _buildRoleCard(
                              context: context,
                              title: AppStrings.imCustomer,
                              description: AppStrings.customerDesc,
                              icon: Icons.person_rounded,
                              role: AppRoles.user,
                              accentColor: AppColors.primary,
                            ),
                            SizedBox(height: context.ph(4)),
                            _buildFooter(context),
                            SizedBox(height: context.ph(4)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required String role,
    required Color accentColor,
  }) {
    return GestureDetector(
      onTap: () => Get.toNamed('/signup', arguments: {'role': role}),
      child: Container(
        padding: EdgeInsets.all(context.pw(6)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 15),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(context.pw(4)),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: accentColor, size: context.sp(32)),
            ),
            SizedBox(width: context.pw(5)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: context.sp(18),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                  SizedBox(height: context.ph(0.5)),
                  Text(
                    description,
                    style: TextStyle(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              AppStrings.btnSignIn,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.selectLanguage,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 20),
            ...List.generate(LocalizationService.langs.length, (index) {
              final lang = LocalizationService.langs[index];
              return ListTile(
                title: Text(lang),
                onTap: () {
                  Get.find<LocalizationService>().changeLocale(lang);
                  Get.back();
                },
                trailing: Get.find<LocalizationService>().getCurrentLang() ==
                        lang
                    ? const Icon(Icons.check_circle, color: AppColors.primary)
                    : null,
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
