import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';

import '../../../../core/widgets/common_text_field.dart';
import '../../../../core/widgets/common_role_selector.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  String? role; // No default role
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (role == null) {
        SnackbarUtils.showError("Please select your Account Type (Vendor or Customer)");
        return;
      }
      setState(() => _isLoading = true);
      final authService = Get.find<AuthService>();
      await authService.signUpWithEmail(
        emailController.text.trim(),
        passwordController.text.trim(),
        nameController.text.trim(),
        role!,
      );
      
      // AuthService._setInitialScreen will handle role-based redirection
      if (mounted) setState(() => _isLoading = false);
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
                      AppStrings.signupHeader,
                      style: AppStyles.headerDisplay,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.signupSubheader,
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
                            _buildLabel(AppStrings.fullNameLabel),
                            const SizedBox(height: 8),
                            CommonTextField(
                              controller: nameController,
                              hint: AppStrings.fullNameHint,
                              icon: Icons.person_outline,
                              validator: (val) => val == null || val.isEmpty ? AppStrings.requiredField : null,
                            ),
                            const SizedBox(height: 20),
                            _buildLabel(AppStrings.emailLabel),
                            const SizedBox(height: 8),
                            CommonTextField(
                              controller: emailController,
                              hint: AppStrings.emailHint,
                              icon: Icons.email_outlined,
                              validator: (val) {
                                if (val == null || val.isEmpty) return AppStrings.requiredField;
                                if (!GetUtils.isEmail(val)) return AppStrings.invalidEmail;
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            _buildLabel(AppStrings.createPasswordLabel),
                            const SizedBox(height: 8),
                            CommonTextField(
                              controller: passwordController,
                              hint: AppStrings.createPasswordHint,
                              icon: Icons.lock_outline,
                              isPassword: true,
                              validator: (val) => val != null && val.length >= 6
                                  ? null
                                  : AppStrings.passwordTooShort,
                            ),
                            const SizedBox(height: 24),
                            _buildLabel(AppStrings.roleSelectorSignup),
                            const SizedBox(height: 12),
                            CommonRoleSelector(
                              currentRole: role ?? '',
                              onRoleChanged: (newRole) => setState(() => role = newRole),
                            ),
                            const SizedBox(height: 32),
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
                AppStrings.btnRegister,
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
          AppStrings.haveAccountText,
          style: AppStyles.textLinkPlain,
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () => Get.offAllNamed('/login'),
          child: Text(
            AppStrings.linkSignIn,
            style: AppStyles.textLink,
          ),
        )
      ],
    );
  }
}
