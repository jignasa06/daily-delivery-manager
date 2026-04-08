import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:p_v_j/core/utils/snackbar_utils.dart';
import 'package:p_v_j/core/constants/app_strings.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Rx<User?> firebaseUser = Rx<User?>(null);
  RxBool isLoggedIn = false.obs;
  RxString currentUserRole = ''.obs;
  RxString currentVendorId = ''.obs;
  RxString currentCustomerId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _setInitialScreen);
    
    // Initial check on startup
    Future.microtask(() => _setInitialScreen(_auth.currentUser));
  }

  Future<void> _setInitialScreen(User? user) async {
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
        if (currentUserRole.value == AppStrings.roleUser) {
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
        currentUserRole.value = data['role'] ?? AppStrings.roleUser;
        currentVendorId.value = data['vendorId'] ?? '';
        currentCustomerId.value = data['customerId'] ?? '';
      } else {
        // Fallback for legacy users in the vendors collection
        DocumentSnapshot legacyDoc = await _firestore.collection('vendors').doc(uid).get();
        if (legacyDoc.exists) {
          currentUserRole.value = AppStrings.roleAdmin;
          currentVendorId.value = uid;
          currentCustomerId.value = '';
          
          // Optionally migrate to users collection here
          await _firestore.collection('users').doc(uid).set({
            'role': AppStrings.roleAdmin,
            'vendorId': uid,
            'email': legacyDoc.get('email'),
          }, SetOptions(merge: true));
        } else {
          currentUserRole.value = AppStrings.roleUser;
        }
      }
    } catch (e) {
      currentUserRole.value = AppStrings.roleUser;
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

  Future<UserCredential?> signUpWithEmail(String email, String password, String name, [String role = AppStrings.roleAdmin]) async {
    try {
      // 1. Check for an active invite first
      DocumentSnapshot inviteDoc = await _firestore.collection('invites').doc(email).get();
      
      String finalRole = role;
      String? vendorId;
      String? customerId;

      if (inviteDoc.exists) {
        final inviteData = inviteDoc.data() as Map<String, dynamic>;
        finalRole = AppStrings.roleUser;
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
        'email': email,
        'role': finalRole,
        'vendorId': vendorId ?? (finalRole == AppStrings.roleAdmin ? userCredential.user!.uid : ''),
        'customerId': customerId ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // 4. Legacy support: If vendor, also keep the vendor document
      if (finalRole == AppStrings.roleAdmin) {
        await _firestore.collection('vendors').doc(userCredential.user!.uid).set({
          'name': name,
          'email': email,
          'role': finalRole,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      
      await fetchUserRole(userCredential.user!.uid);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      SnackbarUtils.showError(e.message ?? 'Registration Failed', title: 'Sign Up Error');
      return null;
    } catch (e) {
      SnackbarUtils.showError(e.toString(), title: 'Error');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
