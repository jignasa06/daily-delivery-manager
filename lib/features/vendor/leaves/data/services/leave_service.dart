import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '/core/services/auth_service.dart';
import '../models/leave_model.dart';
import '../models/customer_leave_model.dart';
import '/core/utils/snackbar_utils.dart';

class LeaveService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();

  // 1. Vendor's private holidays (self-imposed)
  CollectionReference get _vendorHolidays {
    String? uid = _authService.firebaseUser.value?.uid;
    if (uid == null) throw Exception('User not logged in');
    return _firestore.collection('vendors').doc(uid).collection('leaves');
  }

  // 2. Customer-requested leaves (Approval-based)
  CollectionReference get _leaveRequests {
    String? vendorId = _authService.currentVendorId.value;
    if (vendorId.isEmpty) throw Exception('Vendor not identified');
    return _firestore
        .collection('vendors')
        .doc(vendorId)
        .collection('leave_requests');
  }

  // --- Vendor Private Holidays ---
  Stream<List<LeaveModel>> getLeaves() {
    String? uid = _authService.firebaseUser.value?.uid;
    if (uid == null) return Stream.value([]);

    return _firestore
        .collection('vendors')
        .doc(uid)
        .collection('leaves')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => LeaveModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> addLeave(LeaveModel leave) async {
    try {
      await _vendorHolidays.add(leave.toJson());
      SnackbarUtils.showSuccess('Holiday recorded successfully');
    } catch (e) {
      SnackbarUtils.showError(e.toString());
    }
  }

  Future<void> deleteLeave(String leaveId) async {
    try {
      await _vendorHolidays.doc(leaveId).delete();
      SnackbarUtils.showSuccess('Holiday removed');
    } catch (e) {
      SnackbarUtils.showError(e.toString());
    }
  }

  // --- Customer Leave Requests ---
  Future<void> requestCustomerLeave(CustomerLeaveModel request) async {
    try {
      await _leaveRequests.add(request.toJson());
      SnackbarUtils.showSuccess('Leave request submitted for approval');
    } catch (e) {
      SnackbarUtils.showError(e.toString());
    }
  }

  Stream<List<CustomerLeaveModel>> getCustomerLeaves(String customerId) {
    return _leaveRequests
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CustomerLeaveModel.fromFirestore(doc))
          .toList();
    });
  }

  Stream<List<CustomerLeaveModel>> getAdminLeaveRequests() {
    return _leaveRequests.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CustomerLeaveModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> updateLeaveStatus(String requestId, String status) async {
    try {
      await _leaveRequests.doc(requestId).update({'status': status});
      SnackbarUtils.showSuccess('Request $status');
    } catch (e) {
      SnackbarUtils.showError(e.toString());
    }
  }
}
