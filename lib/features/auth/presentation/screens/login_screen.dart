import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';

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

  void _forgotPassword() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      SnackbarUtils.showError('Enter your email first');
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      SnackbarUtils.showSuccess('Password reset email sent!');
    } on FirebaseAuthException catch (e) {
      SnackbarUtils.showError(e.message ?? 'Failed to send reset email');
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
    } else {
      SnackbarUtils.showError(AppStrings.fixErrors);
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
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                              validator: (val) => val != null && val.isNotEmpty ? null : AppStrings.requiredField,
                            ),
                            const SizedBox(height: 20),
                            _buildLabel(AppStrings.passwordLabel),
                            const SizedBox(height: 8),
                            CommonTextField(
                              controller: passwordController,
                              hint: AppStrings.passwordHint,
                              icon: Icons.lock_outline,
                              isPassword: true,
                              validator: (val) => val != null && val.isNotEmpty ? null : AppStrings.requiredField,
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _forgotPassword,
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
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
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24, height: 24,
                child: CircularProgressIndicator(color: AppColors.backgroundWhite, strokeWidth: 2))
            : Text(
                AppStrings.btnSignIn,
                style: AppStyles.primaryButton,
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
          onTap: () => Get.offAllNamed('/signup'),
          child: Text(
            AppStrings.linkSignUp,
            style: AppStyles.textLink,
          ),
        )
      ],
    );
  }
}
