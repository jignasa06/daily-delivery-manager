import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_v_j/features/vendor/leaves/data/models/leave_model.dart';
import 'package:p_v_j/features/vendor/leaves/domain/repositories/i_leave_repository.dart';
import 'package:p_v_j/features/vendor/customers/domain/repositories/i_customer_repository.dart';
import 'package:p_v_j/features/vendor/customers/data/models/customer_model.dart';

class LeaveController extends GetxController {
  final ILeaveRepository _leaveRepository = Get.find<ILeaveRepository>();
  final ICustomerRepository _customerRepository = Get.find<ICustomerRepository>();

  RxList<LeaveModel> leaves = <LeaveModel>[].obs;
  RxList<CustomerModel> customers = <CustomerModel>[].obs;

  final formKey = GlobalKey<FormState>();
  Rx<String?> selectedCustomerId = Rx<String?>(null);
  Rx<DateTime> startDate = DateTime.now().obs;
  Rx<DateTime> endDate = DateTime.now().add(const Duration(days: 1)).obs;

  @override
  void onInit() {
    super.onInit();
    leaves.bindStream(_leaveRepository.getVendorLeaves());
    customers.bindStream(_customerRepository.getCustomers());
  }

  void openForm() {
    selectedCustomerId.value = null;
    startDate.value = DateTime.now();
    endDate.value = DateTime.now().add(const Duration(days: 1));
  }

  Future<void> saveLeave() async {
    final leave = LeaveModel(
      id: '',
      targetId: selectedCustomerId.value ?? 'vendor',
      startDate: startDate.value,
      endDate: endDate.value,
      type: selectedCustomerId.value == null ? 'vendor' : 'customer',
    );

    await _leaveRepository.addVendorLeave(leave);
  }

  Future<void> deleteLeave(String id) async {
    await _leaveRepository.deleteVendorLeave(id);
  }

  String getCustomerName(String customerId) {
    return customers.firstWhereOrNull((c) => c.id == customerId)?.name ??
        "Unknown";
  }
}
