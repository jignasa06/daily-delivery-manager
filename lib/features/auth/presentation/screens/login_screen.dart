import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/localization/localization_service.dart';

import '../../../../core/widgets/common_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    emailController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final isValid = GetUtils.isEmail(email) && password.isNotEmpty;
    if (isValid != _isFormValid) {
      setState(() => _isFormValid = isValid);
    }
  }

  void _forgotPassword() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      SnackbarUtils.showError('enterEmailFirst'.tr);
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      SnackbarUtils.showSuccess('passwordResetSent'.tr);
    } on FirebaseAuthException catch (e) {
      SnackbarUtils.showError(e.message ?? 'failedSendReset'.tr);
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final authService = Get.find<AuthService>();
      final result = await authService.signInWithEmail(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (mounted) setState(() => _isLoading = false);

      if (result != null) {
        debugPrint("LoginScreen: Login successful for ${result.user?.email}");
        // AuthService._setInitialScreen() handles role-based routing via ever()
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Stack(
          children: [
            // Decorative background elements for premium feel (Outside SafeArea to prevent clipping)
            Positioned(
              top: -50,
              right: -60,
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
              bottom: 50,
              left: -80,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    top: 10,
                    right: 20,
                    child: GestureDetector(
                      onTap: () => _showLanguageDialog(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.g_translate,
                                size: 14, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              AppStrings.selectLanguage,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.loginHeader,
                              style: AppStyles.headerDisplay,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppStrings.loginSubheader,
                              style: AppStyles.subheader,
                            ),
                            const SizedBox(height: 40),
                            Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundWhite,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel(AppStrings.emailLabel),
                                    const SizedBox(height: 8),
                                    CommonTextField(
                                      controller: emailController,
                                      hint: AppStrings.emailHint,
                                      icon: Icons.email_outlined,
                                      validator: (val) =>
                                          val != null && val.isNotEmpty
                                              ? null
                                              : AppStrings.requiredField,
                                    ),
                                    const SizedBox(height: 20),
                                    _buildLabel(AppStrings.passwordLabel),
                                    const SizedBox(height: 8),
                                    CommonTextField(
                                      controller: passwordController,
                                      hint: AppStrings.passwordHint,
                                      icon: Icons.lock_outline,
                                      isPassword: true,
                                      validator: (val) =>
                                          val != null && val.isNotEmpty
                                              ? null
                                              : AppStrings.requiredField,
                                    ),
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: _forgotPassword,
                                        child: Text(
                                          'forgotPassword'.tr,
                                          style: const TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildSubmitButton(),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            _buildFooter(),
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
                  setState(() {});
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppStyles.inputLabel,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: (_isFormValid && !_isLoading) ? _submit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.3),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: _isFormValid ? 2 : 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    color: AppColors.backgroundWhite, strokeWidth: 2))
            : Text(
                AppStrings.btnSignIn,
                style: AppStyles.primaryButton.copyWith(
                  color: _isFormValid ? Colors.white : Colors.white.withValues(alpha: 0.6),
                ),
              ),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.noAccountText,
          style: AppStyles.textLinkPlain,
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () => Get.toNamed('/role-selection'),
          child: Text(
            AppStrings.linkSignUp,
            style: AppStyles.textLink,
          ),
        )
      ],
    );
  }
}
