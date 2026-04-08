import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/services/customer_service.dart';

class CustomerManagementController extends GetxController {
  final CustomerService _customerService = Get.find<CustomerService>();
  RxList<CustomerModel> customers = <CustomerModel>[].obs;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final emailController = TextEditingController();

  CustomerModel? editingCustomer;

  @override
  void onInit() {
    super.onInit();
    customers.bindStream(_customerService.getCustomers());
  }

  void openForm([CustomerModel? customer]) {
    editingCustomer = customer;
    if (customer != null) {
      nameController.text = customer.name;
      phoneController.text = customer.phone;
      addressController.text = customer.address;
      emailController.text = customer.email;
    } else {
      nameController.clear();
      phoneController.clear();
      addressController.clear();
      emailController.clear();
    }
  }

  void saveCustomer() {
    if (formKey.currentState!.validate()) {
      final customer = CustomerModel(
        id: editingCustomer?.id ?? '', 
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        email: emailController.text.trim(),
      );

      if (editingCustomer == null) {
        _customerService.addCustomer(customer);
      } else {
        _customerService.updateCustomer(customer);
      }
      Get.back();
    }
  }

  void deleteCustomer(String id) {
    _customerService.deleteCustomer(id);
  }
}
