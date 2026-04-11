import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:p_v_j/features/vendor/leaves/data/models/leave_model.dart';
import 'package:p_v_j/features/vendor/leaves/data/models/customer_leave_model.dart';
import 'package:p_v_j/features/vendor/leaves/domain/repositories/i_leave_repository.dart';
import 'package:p_v_j/core/utils/snackbar_utils.dart';

class FirebaseLeaveRepository implements ILeaveRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String vendorId;

  FirebaseLeaveRepository({required this.vendorId});

  CollectionReference get _vendorHolidays => 
      _firestore.collection('vendors').doc(vendorId).collection('leaves');

  CollectionReference get _leaveRequests => 
      _firestore.collection('vendors').doc(vendorId).collection('leave_requests');

  @override
  Stream<List<LeaveModel>> getVendorLeaves() {
    return _vendorHolidays.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => LeaveModel.fromFirestore(doc)).toList();
    });
  }

  @override
  Future<void> addVendorLeave(LeaveModel leave) async {
    try {
      await _vendorHolidays.add(leave.toJson());
      SnackbarUtils.showSuccess('Holiday recorded');
    } catch (e) {
      SnackbarUtils.showError(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> deleteVendorLeave(String leaveId) async {
    try {
      await _vendorHolidays.doc(leaveId).delete();
      SnackbarUtils.showSuccess('Holiday removed');
    } catch (e) {
      SnackbarUtils.showError(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> submitCustomerLeaveRequest(CustomerLeaveModel request) async {
    try {
      await _leaveRequests.add(request.toJson());
      SnackbarUtils.showSuccess('Request submitted for approval');
    } catch (e) {
      SnackbarUtils.showError(e.toString());
      rethrow;
    }
  }

  @override
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

  @override
  Stream<List<CustomerLeaveModel>> getAllCustomerLeaveRequests() {
    return _leaveRequests.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CustomerLeaveModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Future<void> updateCustomerLeaveStatus(String requestId, String status) async {
    try {
      await _leaveRequests.doc(requestId).update({'status': status});
      SnackbarUtils.showSuccess('Request $status');
    } catch (e) {
      SnackbarUtils.showError(e.toString());
      rethrow;
    }
  }
}
