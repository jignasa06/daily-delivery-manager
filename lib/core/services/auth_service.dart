import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:p_v_j/core/utils/snackbar_utils.dart';
import 'package:p_v_j/core/constants/app_strings.dart';
import 'package:p_v_j/core/constants/app_roles.dart';
import 'package:flutter/foundation.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Rx<User?> firebaseUser = Rx<User?>(null);
  RxBool isLoggedIn = false.obs;
  RxString currentUserRole = ''.obs;
  RxString currentVendorId = ''.obs;
  RxString currentCustomerId = ''.obs;

  bool _isRegistering = false;

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _setInitialScreen);
    
    // Initial check on startup
    Future.microtask(() => _setInitialScreen(_auth.currentUser));
  }

  Future<void> _setInitialScreen(User? user) async {
    if (_isRegistering) return;

    try {
      // Small delay ensures GetX router is ready for the first transition
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (user == null) {
        isLoggedIn.value = false;
        currentUserRole.value = '';
        currentVendorId.value = '';
        currentCustomerId.value = '';
        Get.offAllNamed('/login');
      } else {
        isLoggedIn.value = true;
        await fetchUserRole(user.uid);
        if (currentUserRole.value == AppRoles.user) {
          Get.offAllNamed('/customer-home');
        } else {
          Get.offAllNamed('/home');
        }
      }
    } catch (e) {
      isLoggedIn.value = false;
      Get.offAllNamed('/login');
    }
  }

  Future<void> fetchUserRole(String uid) async {
    try {
      // First check the global users registry
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      
      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data() as Map<String, dynamic>;
        String rawRole = data['role'] ?? AppRoles.user;
        
        // Normalize role for robustness (Legacy support for localized strings in DB)
        if (AppRoles.isUser(rawRole)) {
          currentUserRole.value = AppRoles.user;
        } else if (AppRoles.isAdmin(rawRole)) {
          currentUserRole.value = AppRoles.admin;
        } else {
          currentUserRole.value = AppRoles.user;
        }

        // If normalized role is different from DB, update DB for future-proofing
        if (rawRole != currentUserRole.value) {
          await _firestore.collection('users').doc(uid).update({'role': currentUserRole.value});
        }

        currentVendorId.value = data['vendorId'] ?? '';
        currentCustomerId.value = data['customerId'] ?? '';
      } else {
        // Fallback for legacy users in the vendors collection
        DocumentSnapshot legacyDoc = await _firestore.collection('vendors').doc(uid).get();
        if (legacyDoc.exists) {
          currentUserRole.value = AppRoles.admin;
          currentVendorId.value = uid;
          currentCustomerId.value = '';
          
          // Migrate to users collection with new role constant
          await _firestore.collection('users').doc(uid).set({
            'role': AppRoles.admin,
            'vendorId': uid,
            'email': legacyDoc.get('email'),
          }, SetOptions(merge: true));
        } else {
          currentUserRole.value = AppRoles.user;
        }
      }
    } catch (e) {
      currentUserRole.value = AppRoles.user;
    }
  }

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      await fetchUserRole(userCredential.user!.uid);
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      SnackbarUtils.showError(e.message ?? 'Login Failed', title: 'Auth Error');
      return null;
    } catch (e) {
      SnackbarUtils.showError(e.toString(), title: 'Error');
      return null;
    }
  }

  Future<UserCredential?> signUpWithEmail({
    required String email, 
    required String password, 
    required String name, 
    required String role,
    String? businessName,
  }) async {
    _isRegistering = true;
    try {
      // 1. Check for an active invite first (priority)
      DocumentSnapshot inviteDoc = await _firestore.collection('invites').doc(email).get();
      
      String finalRole = role; // Use user-selected role by default
      String? vendorId;
      String? customerId;

      if (inviteDoc.exists) {
        // FORCE role to Customer if they were invited as one
        final inviteData = inviteDoc.data() as Map<String, dynamic>;
        finalRole = AppRoles.user;
        vendorId = inviteData['vendorId'];
        customerId = inviteData['customerId'];
      }

      // 2. Create the Auth User
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      // Update Firebase Auth Display Name
      await userCredential.user!.updateDisplayName(name);
      
      // 3. Save to global user registry
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'businessName': businessName ?? name,
        'email': email,
        'role': finalRole,
        'vendorId': vendorId ?? (finalRole == AppRoles.admin ? userCredential.user!.uid : ''),
        'customerId': customerId ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // 4. Legacy support: If vendor, also keep the vendor document
      if (finalRole == AppRoles.admin) {
        await _firestore.collection('vendors').doc(userCredential.user!.uid).set({
          'businessName': businessName ?? name,
          'email': email,
          'role': finalRole,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      
      // Direct State Update: Set local state variables immediately to avoid race conditions with Firestore propagation
      currentUserRole.value = finalRole;
      currentVendorId.value = vendorId ?? (finalRole == AppRoles.admin ? userCredential.user!.uid : '');
      currentCustomerId.value = customerId ?? '';
      
      debugPrint("AuthService: Manual set after Signup. Role: ${currentUserRole.value}, VendorID: ${currentVendorId.value}");

      _isRegistering = false;
      await _setInitialScreen(userCredential.user);
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      _isRegistering = false;
      SnackbarUtils.showError(e.message ?? 'Registration Failed', title: 'Sign Up Error');
      return null;
    } catch (e) {
      _isRegistering = false;
      SnackbarUtils.showError(e.toString(), title: 'Error');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
