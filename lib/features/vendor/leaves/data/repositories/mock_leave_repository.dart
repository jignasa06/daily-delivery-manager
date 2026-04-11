import 'package:p_v_j/features/vendor/leaves/data/models/leave_model.dart';
import 'package:p_v_j/features/vendor/leaves/data/models/customer_leave_model.dart';
import 'package:p_v_j/features/vendor/leaves/domain/repositories/i_leave_repository.dart';

class MockLeaveRepository implements ILeaveRepository {
  final List<LeaveModel> _vendorLeaves = [
    LeaveModel(
      id: 'v_leave_1',
      targetId: 'vendor_1',
      startDate: DateTime.now().add(const Duration(days: 5)),
      endDate: DateTime.now().add(const Duration(days: 7)),
      type: 'vendor',
    ),
  ];

  final List<CustomerLeaveModel> _customerRequests = [
    CustomerLeaveModel(
      id: 'req_1',
      customerId: 'cust_1',
      customerName: 'Rahul Sharma',
      vendorId: 'vendor_1',
      startDate: DateTime.now().add(const Duration(days: 2)),
      endDate: DateTime.now().add(const Duration(days: 4)),
      status: 'Pending',
      reason: 'Going out of town',
      createdAt: DateTime.now(),
    ),
  ];

  @override
  Stream<List<LeaveModel>> getVendorLeaves() {
    return Stream.value(_vendorLeaves);
  }

  @override
  Future<void> addVendorLeave(LeaveModel leave) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _vendorLeaves.add(leave);
  }

  @override
  Future<void> deleteVendorLeave(String leaveId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _vendorLeaves.removeWhere((l) => l.id == leaveId);
  }

  @override
  Future<void> submitCustomerLeaveRequest(CustomerLeaveModel request) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _customerRequests.add(request);
  }

  @override
  Stream<List<CustomerLeaveModel>> getCustomerLeaves(String customerId) {
    return Stream.value(_customerRequests.where((r) => r.customerId == customerId).toList());
  }

  @override
  Stream<List<CustomerLeaveModel>> getAllCustomerLeaveRequests() {
    return Stream.value(_customerRequests);
  }

  @override
  Future<void> updateCustomerLeaveStatus(String requestId, String status) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _customerRequests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      _customerRequests[index] = CustomerLeaveModel(
        id: _customerRequests[index].id,
        customerId: _customerRequests[index].customerId,
        customerName: _customerRequests[index].customerName,
        vendorId: _customerRequests[index].vendorId,
        startDate: _customerRequests[index].startDate,
        endDate: _customerRequests[index].endDate,
        status: status,
        reason: _customerRequests[index].reason,
        createdAt: _customerRequests[index].createdAt,
      );
    }
  }
}
