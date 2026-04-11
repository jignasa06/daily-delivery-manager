import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/localization/localization_service.dart';
import '../../../../core/utils/responsive_helper.dart';
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
      backgroundColor: Colors.transparent, // Background handled by container
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
              top: -context.ph(5),
              right: -context.pw(15),
              child: Container(
                width: context.pw(65),
                height: context.pw(65),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
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
                  color: Colors.white.withOpacity(0.05),
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
                        padding: EdgeInsets.symmetric(horizontal: context.pw(6.5)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: context.ph(2)),
                            // Language Switcher (Moved inside scroll view to prevent overlap/squashing)
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () => _showLanguageDialog(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.g_translate, size: 14, color: Colors.white),
                                      const SizedBox(width: 4),
                                      Text(
                                        AppStrings.selectLanguage,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: context.sp(10),
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: context.ph(8)),
                            Text(
                              AppStrings.loginHeader,
                              style: AppStyles.headerDisplay(context),
                            ),
                            SizedBox(height: context.ph(1)),
                            Text(
                              AppStrings.loginSubheader,
                              style: AppStyles.subheader(context),
                            ),
                            SizedBox(height: context.ph(5)),
                            Container(
                              padding: EdgeInsets.all(context.pw(7)),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundWhite,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
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
                                    SizedBox(height: context.ph(1)),
                                    CommonTextField(
                                      controller: emailController,
                                      hint: AppStrings.emailHint,
                                      icon: Icons.email_outlined,
                                      validator: (val) =>
                                          val != null && val.isNotEmpty
                                              ? null
                                              : AppStrings.requiredField,
                                    ),
                                    SizedBox(height: context.ph(2.5)),
                                    _buildLabel(AppStrings.passwordLabel),
                                    SizedBox(height: context.ph(1)),
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
                                    SizedBox(height: context.ph(0.5)),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: _forgotPassword,
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: const Size(50, 30),
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text(
                                          'forgotPassword'.tr,
                                          style: TextStyle(
                                              color: AppColors.primary,
                                              fontSize: context.sp(13),
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: context.ph(2)),
                                    _buildSubmitButton(),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: context.ph(4)),
                            _buildFooter(),
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
      style: AppStyles.inputLabel(context),
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
          disabledBackgroundColor: AppColors.primary.withOpacity(0.3),
          disabledForegroundColor: Colors.white.withOpacity(0.6),
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
                style: AppStyles.primaryButton(context).copyWith(
                  color: _isFormValid ? Colors.white : Colors.white.withOpacity(0.6),
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
          style: AppStyles.textLinkPlain(context),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () => Get.toNamed('/role-selection'),
          child: Text(
            AppStrings.linkSignUp,
            style: AppStyles.textLink(context),
          ),
        )
      ],
    );
  }
}
