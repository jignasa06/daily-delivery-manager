import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_v_j/core/constants/app_colors.dart';
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
      DocumentSnapshot doc = await _firestore.collection('vendors').doc(uid).get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        nameController.text = data['businessName'] ?? '';
        phoneController.text = data['phone'] ?? '';
        emailController.text = data['email'] ?? _auth.firebaseUser.value?.email ?? '';
      }
    } catch (e) {
      SnackbarUtils.showError('Failed to load profile');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => isLoading = true);
    try {
      String uid = _auth.currentVendorId.value;
      await _firestore.collection('vendors').doc(uid).set({
        'businessName': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'email': emailController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      SnackbarUtils.showSuccess('Profile updated successfully');
      Get.back();
    } catch (e) {
      SnackbarUtils.showError('Failed to save profile');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text('Business Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Business Identity',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain),
                    ),
                    const Text(
                      'This information will be visible to your customers.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
                        child: const Text('Save Business Profile', style: TextStyle(color: Colors.white, fontSize: 16)),
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
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.g_translate, color: AppColors.primary, size: 20),
                      ),
                      title: Text(AppStrings.changeLanguage, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(Get.find<LocalizationService>().getCurrentLang()),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
