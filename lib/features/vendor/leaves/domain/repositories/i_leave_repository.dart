import 'package:p_v_j/features/vendor/leaves/data/models/leave_model.dart';
import 'package:p_v_j/features/vendor/leaves/data/models/customer_leave_model.dart';

abstract class ILeaveRepository {
  // Vendor-side Holidays
  Stream<List<LeaveModel>> getVendorLeaves();
  Future<void> addVendorLeave(LeaveModel leave);
  Future<void> deleteVendorLeave(String leaveId);

  // Customer-side Requests
  Future<void> submitCustomerLeaveRequest(CustomerLeaveModel request);
  Stream<List<CustomerLeaveModel>> getCustomerLeaves(String customerId);
  Stream<List<CustomerLeaveModel>> getAllCustomerLeaveRequests();
  Future<void> updateCustomerLeaveStatus(String requestId, String status);
}
