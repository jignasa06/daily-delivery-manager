import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '/core/services/auth_service.dart';
import '../models/customer_model.dart';
import '/core/utils/snackbar_utils.dart';

class CustomerService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();

  CollectionReference get _vendorCustomers {
    String? uid = _authService.firebaseUser.value?.uid;
    if (uid == null) throw Exception('User not logged in');
    return _firestore.collection('vendors').doc(uid).collection('customers');
  }

  Stream<List<CustomerModel>> getCustomers() {
    return _vendorCustomers.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CustomerModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> addCustomer(CustomerModel customer) async {
    try {
      final docRef = await _vendorCustomers.add(customer.toJson());

      // Create a global invite if email is present
      if (customer.email.isNotEmpty) {
        String vendorId = _authService.firebaseUser.value!.uid;
        await _firestore.collection('invites').doc(customer.email).set({
          'email': customer.email,
          'vendorId': vendorId,
          'customerId': docRef.id,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      SnackbarUtils.showSuccess('Customer added successfully');
    } catch (e) {
      SnackbarUtils.showError(e.toString());
    }
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    try {
      await _vendorCustomers.doc(customer.id).update(customer.toJson());

      // Update global invite if email is present
      if (customer.email.isNotEmpty) {
        String vendorId = _authService.firebaseUser.value!.uid;
        await _firestore.collection('invites').doc(customer.email).set({
          'email': customer.email,
          'vendorId': vendorId,
          'customerId': customer.id,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      SnackbarUtils.showSuccess('Customer updated successfully');
    } catch (e) {
      SnackbarUtils.showError(e.toString());
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    try {
      // We need the email to delete the invite record
      final doc = await _vendorCustomers.doc(customerId).get();
      final data = doc.data() as Map<String, dynamic>?;
      final String? email = data?['email'];

      await _vendorCustomers.doc(customerId).delete();

      if (email != null && email.isNotEmpty) {
        await _firestore.collection('invites').doc(email).delete();
      }

      SnackbarUtils.showSuccess('Customer deleted successfully');
    } catch (e) {
      SnackbarUtils.showError(e.toString());
    }
  }
}
