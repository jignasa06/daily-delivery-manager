import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_v_j/core/utils/snackbar_utils.dart';
import 'package:p_v_j/features/vendor/customers/data/models/customer_model.dart';
import 'package:p_v_j/features/vendor/customers/domain/repositories/i_customer_repository.dart';
import 'package:p_v_j/features/vendor/products/data/models/product_model.dart';
import 'package:p_v_j/features/vendor/products/domain/repositories/i_product_repository.dart';
import 'package:p_v_j/features/vendor/subscriptions/data/models/subscription_model.dart';
import 'package:p_v_j/features/vendor/subscriptions/domain/repositories/i_subscription_repository.dart';

class SubscriptionController extends GetxController {
  // --- REPOSITORY INJECTION ---
  final ISubscriptionRepository _subscriptionRepository = Get.find<ISubscriptionRepository>();
  final IProductRepository _productRepository = Get.find<IProductRepository>();
  final ICustomerRepository _customerRepository = Get.find<ICustomerRepository>();

  RxList<SubscriptionModel> subscriptions = <SubscriptionModel>[].obs;
  RxList<CustomerModel> customers = <CustomerModel>[].obs;
  RxList<ProductModel> products = <ProductModel>[].obs;

  final formKey = GlobalKey<FormState>();
  String? selectedCustomerId;
  String? selectedProductId;
  Rx<DateTime> selectedStartDate = DateTime.now().obs;
  Rx<DateTime?> selectedEndDate = Rx<DateTime?>(null);
  final defaultQuantityController = TextEditingController(text: '1');

  RxList<String> selectedDays = <String>[].obs;
  final List<String> weekDays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  @override
  void onInit() {
    super.onInit();
    subscriptions.bindStream(_subscriptionRepository.getSubscriptions());
    customers.bindStream(_customerRepository.getCustomers());
    products.bindStream(_productRepository.getProducts());
  }

  String getCustomerName(String id) =>
      customers.firstWhereOrNull((c) => c.id == id)?.name ?? 'Unknown Customer';
  String getProductName(String id) =>
      products.firstWhereOrNull((p) => p.id == id)?.name ?? 'Unknown Product';
  String getProductUnit(String id) =>
      products.firstWhereOrNull((p) => p.id == id)?.unit ?? '';

  void openForm() {
    selectedCustomerId = null;
    selectedProductId = null;
    selectedStartDate.value = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    selectedEndDate.value = null;
    defaultQuantityController.text = '1';
    selectedDays.value = List.from(weekDays); 
  }

  void toggleDay(String day) {
    if (selectedDays.contains(day)) {
      selectedDays.remove(day);
    } else {
      selectedDays.add(day);
    }
  }

  Future<void> saveSubscription() async {
    if (formKey.currentState!.validate()) {
      if (selectedCustomerId == null || selectedProductId == null) {
        SnackbarUtils.showError('Please select both Customer and Product');
        return;
      }
      if (selectedDays.isEmpty) {
        SnackbarUtils.showError('Select at least one delivery day');
        return;
      }

      final sub = SubscriptionModel(
        id: '',
        customerId: selectedCustomerId!,
        productId: selectedProductId!,
        startDate: selectedStartDate.value,
        endDate: selectedEndDate.value,
        selectedDays: selectedDays,
        defaultQuantity: int.tryParse(defaultQuantityController.text.trim()) ?? 1,
        subscriptionType: 'monthly',
      );

      try {
        await _subscriptionRepository.addSubscription(sub);
        SnackbarUtils.showSuccess('Subscription linked successfully');
        Get.back();
      } catch (e) {
        SnackbarUtils.showError(e.toString());
      }
    }
  }

  Future<void> deleteSubscription(String id) async {
    try {
      await _subscriptionRepository.deleteSubscription(id);
      SnackbarUtils.showSuccess('Subscription deleted successfully');
    } catch (e) {
      SnackbarUtils.showError(e.toString());
    }
  }
}
