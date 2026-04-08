import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_colors.dart';
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

  @override
  void initState() {
    super.initState();
    // Get role from arguments, fallback to Vendor if missing
    role = Get.arguments?['role'] ?? AppStrings.roleAdmin;
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
        businessName: role == AppStrings.roleAdmin ? businessNameController.text.trim() : null,
      );
      
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
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                                          role == AppStrings.roleAdmin ? 'Vendor Registration' : 'Customer Registration',
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => Get.back(),
                                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30)),
                                        child: const Text('Change', style: TextStyle(fontSize: 11, color: AppColors.textHint, decoration: TextDecoration.underline)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Please fill in your details to create your account.',
                                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                  ),
                                  const SizedBox(height: 32),
                                  CommonTextField(
                                    controller: nameController,
                                    hint: 'Full Name',
                                    icon: Icons.person_outline,
                                    validator: (val) => val!.isEmpty ? 'Required' : null,
                                  ),
                                  if (role == AppStrings.roleAdmin) ...[
                                    const SizedBox(height: 16),
                                    CommonTextField(
                                      controller: businessNameController,
                                      hint: 'Business Name',
                                      icon: Icons.business_outlined,
                                      validator: (val) => val!.isEmpty ? 'Required' : null,
                                    ),
                                  ],
                                  const SizedBox(height: 16),
                                  CommonTextField(
                                    controller: emailController,
                                    hint: AppStrings.emailHint,
                                    icon: Icons.email_outlined,
                                    validator: (val) => GetUtils.isEmail(val!) ? null : 'Invalid Email',
                                  ),
                                  const SizedBox(height: 16),
                                  CommonTextField(
                                    controller: passwordController,
                                    hint: AppStrings.createPasswordHint,
                                    icon: Icons.lock_outline,
                                    isPassword: true,
                                    validator: (val) => val!.length >= 6 ? null : 'Min 6 chars',
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
      ),
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
