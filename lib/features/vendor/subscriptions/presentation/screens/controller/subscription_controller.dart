import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../subscriptions/data/models/subscription_model.dart';
import '../../../../subscriptions/data/services/subscription_service.dart';
import '/core/utils/snackbar_utils.dart';
import 'package:p_v_j/features/vendor/customers/data/models/customer_model.dart';
import 'package:p_v_j/features/vendor/customers/data/services/customer_service.dart';
import '../../../../products/data/models/product_model.dart';
import '../../../../products/data/services/product_service.dart';

class SubscriptionController extends GetxController {
  final SubscriptionService _subscriptionService =
      Get.find<SubscriptionService>();
  final CustomerService _customerService = Get.find<CustomerService>();
  final ProductService _productService = Get.find<ProductService>();

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
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  void onInit() {
    super.onInit();
    subscriptions.bindStream(_subscriptionService.getSubscriptions());
    customers.bindStream(_customerService.getCustomers());
    products.bindStream(_productService.getProducts());
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
    selectedStartDate.value =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    selectedEndDate.value = null;
    defaultQuantityController.text = '1';
    selectedDays.value = List.from(weekDays); // Default to all days
  }

  void toggleDay(String day) {
    if (selectedDays.contains(day)) {
      selectedDays.remove(day);
    } else {
      selectedDays.add(day);
    }
  }

  void saveSubscription() {
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
        defaultQuantity:
            int.tryParse(defaultQuantityController.text.trim()) ?? 1,
        subscriptionType: 'monthly',
      );

      _subscriptionService.addSubscription(sub);
      Get.back();
    }
  }

  void deleteSubscription(String id) {
    _subscriptionService.deleteSubscription(id);
  }
}
