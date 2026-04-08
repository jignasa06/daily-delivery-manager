import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_roles.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/widgets/common_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late String role;
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final businessNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    // Get role from arguments, fallback to Vendor if missing (using internal code constant)
    role = Get.arguments?['role'] ?? AppRoles.admin;

    // Add listeners for reactive validation
    nameController.addListener(_validateForm);
    businessNameController.addListener(_validateForm);
    emailController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    nameController.dispose();
    businessNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final name = nameController.text.trim();
    final businessName = businessNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    bool isValid = name.isNotEmpty && GetUtils.isEmail(email) && password.length >= 6;

    if (role == AppRoles.admin) {
      isValid = isValid && businessName.isNotEmpty;
    }

    if (isValid != _isFormValid) {
      setState(() => _isFormValid = isValid);
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final authService = Get.find<AuthService>();

      await authService.signUpWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        name: nameController.text.trim(),
        role: role,
        businessName: role == AppRoles.admin
            ? businessNameController.text.trim()
            : null,
      );

      if (mounted) setState(() => _isLoading = false);
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
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  Expanded(
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
                              const SizedBox(height: 32),
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    )
                                  ],
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              role == AppRoles.admin ? 'sellerRegistration'.tr : 'customerRegistration'.tr,
                                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () => Get.back(),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                                              ),
                                              child: Text(
                                                'change'.tr,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'signupFillDetails'.tr,
                                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                      ),
                                      const SizedBox(height: 32),
                                      CommonTextField(
                                        controller: nameController,
                                        hint: 'fullNameHint'.tr,
                                        icon: Icons.person_outline,
                                        validator: (val) => val!.isEmpty ? 'requiredField'.tr : null,
                                      ),
                                      if (role == AppStrings.roleAdmin) ...[
                                        const SizedBox(height: 16),
                                        CommonTextField(
                                          controller: businessNameController,
                                          hint: 'businessNameHint'.tr,
                                          icon: Icons.business_outlined,
                                          validator: (val) => val!.isEmpty ? 'requiredField'.tr : null,
                                        ),
                                      ],
                                      const SizedBox(height: 16),
                                      CommonTextField(
                                        controller: emailController,
                                        hint: AppStrings.emailHint,
                                        icon: Icons.email_outlined,
                                        validator: (val) => GetUtils.isEmail(val!) ? null : 'invalidEmail'.tr,
                                      ),
                                      const SizedBox(height: 16),
                                      CommonTextField(
                                        controller: passwordController,
                                        hint: AppStrings.createPasswordHint,
                                        icon: Icons.lock_outline,
                                        isPassword: true,
                                        validator: (val) => val!.length >= 6 ? null : 'passwordTooShort'.tr,
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
                ],
              ),
            ),
          ],
        ),
      ),
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
                AppStrings.btnRegister,
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
