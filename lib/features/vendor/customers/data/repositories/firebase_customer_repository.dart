import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:p_v_j/features/vendor/customers/data/models/customer_model.dart';
import 'package:p_v_j/features/vendor/customers/domain/repositories/i_customer_repository.dart';
import 'package:p_v_j/core/utils/snackbar_utils.dart';

class FirebaseCustomerRepository implements ICustomerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String vendorId;

  FirebaseCustomerRepository({required this.vendorId});

  CollectionReference get _vendorCustomers => 
      _firestore.collection('vendors').doc(vendorId).collection('customers');

  @override
  Stream<List<CustomerModel>> getCustomers() {
    return _vendorCustomers.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CustomerModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Future<void> addCustomer(CustomerModel customer) async {
    try {
      final docRef = await _vendorCustomers.add(customer.toJson());

      // Create a global invite if email is present
      if (customer.email.isNotEmpty) {
        await _firestore.collection('invites').doc(customer.email).set({
          'email': customer.email,
          'vendorId': vendorId,
          'customerId': docRef.id,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      SnackbarUtils.showSuccess('Customer added successfully');
    } catch (e) {
      SnackbarUtils.showError('Failed to add customer: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateCustomer(CustomerModel customer) async {
    try {
      await _vendorCustomers.doc(customer.id).update(customer.toJson());

      // Update global invite if email is present
      if (customer.email.isNotEmpty) {
        await _firestore.collection('invites').doc(customer.email).set({
          'email': customer.email,
          'vendorId': vendorId,
          'customerId': customer.id,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      SnackbarUtils.showSuccess('Customer updated successfully');
    } catch (e) {
      SnackbarUtils.showError('Failed to update customer: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteCustomer(String customerId) async {
    try {
      final doc = await _vendorCustomers.doc(customerId).get();
      final data = doc.data() as Map<String, dynamic>?;
      final String? email = data?['email'];

      await _vendorCustomers.doc(customerId).delete();

      if (email != null && email.isNotEmpty) {
        await _firestore.collection('invites').doc(email).delete();
      }
      SnackbarUtils.showSuccess('Customer deleted');
    } catch (e) {
      SnackbarUtils.showError('Failed to delete customer: $e');
      rethrow;
    }
  }
}
