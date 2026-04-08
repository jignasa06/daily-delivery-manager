import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_v_j/features/vendor/daily_entries/data/models/leave_model.dart';
import 'package:p_v_j/features/vendor/leaves/data/services/leave_service.dart';
import 'package:p_v_j/features/vendor/customers/data/models/customer_model.dart';
import 'package:p_v_j/features/vendor/customers/data/services/customer_service.dart';

class LeaveController extends GetxController {
  final LeaveService _leaveService = Get.put(LeaveService());
  final CustomerService _customerService = Get.find<CustomerService>();

  RxList<LeaveModel> leaves = <LeaveModel>[].obs;
  RxList<CustomerModel> customers = <CustomerModel>[].obs;

  final formKey = GlobalKey<FormState>();
  Rx<String?> selectedCustomerId = Rx<String?>(null);
  Rx<DateTime> startDate = DateTime.now().obs;
  Rx<DateTime> endDate = DateTime.now().add(const Duration(days: 1)).obs;

  @override
  void onInit() {
    super.onInit();
    leaves.bindStream(_leaveService.getLeaves());
    customers.bindStream(_customerService.getCustomers());
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

    await _leaveService.addLeave(leave);
  }

  Future<void> deleteLeave(String id) async {
    await _leaveService.deleteLeave(id);
  }

  String getCustomerName(String customerId) {
    return customers.firstWhereOrNull((c) => c.id == customerId)?.name ??
        "Unknown";
  }
}
