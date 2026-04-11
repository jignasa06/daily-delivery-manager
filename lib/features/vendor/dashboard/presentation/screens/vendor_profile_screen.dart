import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_v_j/features/vendor/dashboard/data/models/vendor_model.dart';
import 'package:p_v_j/features/vendor/dashboard/domain/repositories/i_vendor_repository.dart';
import '/core/constants/app_colors.dart';
import '/core/constants/app_styles.dart';
import 'package:p_v_j/core/services/auth_service.dart';
import 'package:p_v_j/core/utils/snackbar_utils.dart';
import 'package:p_v_j/core/constants/app_strings.dart';
import 'package:p_v_j/core/localization/localization_service.dart';
import 'package:p_v_j/core/widgets/pvj_underline_tf.dart';

class VendorProfileScreen extends StatefulWidget {
  const VendorProfileScreen({super.key});

  @override
  State<VendorProfileScreen> createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  final IVendorRepository _vendorRepository = Get.find<IVendorRepository>();
  final AuthService _auth = Get.find<AuthService>();
  
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      String uid = _auth.currentVendorId.value;
      if (uid.isEmpty) return;
      
      final vendor = await _vendorRepository.getVendorInfo(uid).first;
      
      if (vendor != null) {
        nameController.text = vendor.businessName;
        phoneController.text = vendor.phone;
        emailController.text = vendor.email.isEmpty ? (_auth.firebaseUser.value?.email ?? '') : vendor.email;
      }
    } catch (e) {
      SnackbarUtils.showError('Failed to load profile');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (mounted) setState(() => isLoading = true);
    try {
      String uid = _auth.currentVendorId.value;
      await _vendorRepository.updateVendorProfile(uid, {
        'businessName': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'email': emailController.text.trim(),
      });
      
      SnackbarUtils.showSuccess('Profile updated successfully');
      Get.back();
    } catch (e) {
      SnackbarUtils.showError('Failed to save profile');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text('Business Profile', style: AppStyles.dashboardHeading(context).copyWith(color: Colors.white)),
        backgroundColor: AppColors.indigoPrimary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading 
        ? Center(child: CircularProgressIndicator(color: AppColors.indigoPrimary))
        : Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Business Identity',
                      style: AppStyles.dashboardHeading(context),
                    ),
                    Text(
                      'This information will be visible to your customers.',
                      style: AppStyles.premiumCardBody(context).copyWith(fontSize: 12),
                    ),
                    const SizedBox(height: 32),
                    
                    PvjUnderlineTf(
                      controller: nameController,
                      labelText: 'Business Name',
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 24),
                    
                    PvjUnderlineTf(
                      controller: phoneController,
                      labelText: 'Support Phone Number',
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 24),
                    
                    PvjUnderlineTf(
                      controller: emailController,
                      labelText: 'Support Email (Read Only)',
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _saveProfile,
                        child: Text('Save Business Profile', style: AppStyles.premiumButton(context)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.indigoPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.g_translate, color: AppColors.indigoPrimary, size: 20),
                      ),
                      title: Text(AppStrings.changeLanguage, style: AppStyles.premiumCardTitle(context)),
                      subtitle: Text(Get.find<LocalizationService>().getCurrentLang(), style: AppStyles.premiumCardBody(context)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.indigoPrimary),
                      onTap: () => _showLanguageDialog(context),
                    ),
                  ],
                ),
              ),
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
                trailing: Get.find<LocalizationService>().getCurrentLang() == lang
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
