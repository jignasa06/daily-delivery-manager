import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_v_j/core/constants/app_colors.dart';
import 'package:p_v_j/core/constants/app_strings.dart';
import 'package:p_v_j/core/localization/localization_service.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Stack(
          children: [
            // Decorative background elements for premium feel
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              left: -80,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => _showLanguageDialog(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.g_translate, size: 16, color: Colors.white),
                                const SizedBox(width: 6),
                                Text(
                                  AppStrings.selectLanguage,
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            AppStrings.step1of2.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          Text(
                            AppStrings.tellUsAboutYou,
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.8,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppStrings.chooseAppUse,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white.withValues(alpha: 0.85),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 48),
                          _buildRoleCard(
                            title: AppStrings.imVendor,
                            description: AppStrings.vendorDesc,
                            icon: Icons.business_center_rounded,
                            role: AppStrings.roleAdmin,
                            accentColor: AppColors.primary,
                          ),
                          const SizedBox(height: 20),
                          _buildRoleCard(
                            title: AppStrings.imCustomer,
                            description: AppStrings.customerDesc,
                            icon: Icons.person_rounded,
                            role: AppStrings.roleUser,
                            // accentColor: const Color.fromARGB(
                            //     255, 136, 41, 133),
                            accentColor: AppColors.primary,
                            // Premium Coral accent
                          ),
                          const Spacer(),
                          _buildFooter(),
                          const SizedBox(height: 20),
                        ],
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
    required String title,
    required String description,
    required IconData icon,
    required String role,
    required Color accentColor,
  }) {
    return GestureDetector(
      onTap: () => Get.toNamed('/signup', arguments: {'role': role}),
      child: Container(
        padding: const EdgeInsets.all(24),
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
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: accentColor, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppStrings.haveAccountText,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 15,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(width: 4),
          TextButton(
            onPressed: () => Get.offAllNamed('/login'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
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
