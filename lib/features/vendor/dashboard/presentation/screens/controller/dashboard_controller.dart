import 'package:get/get.dart';
import 'package:p_v_j/features/vendor/products/data/services/product_service.dart';
import 'package:p_v_j/features/vendor/customers/data/services/customer_service.dart';
import 'package:p_v_j/features/vendor/subscriptions/data/services/subscription_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:p_v_j/core/services/auth_service.dart';

class DashboardController extends GetxController {
  final ProductService _productService = Get.put(ProductService());
  final CustomerService _customerService = Get.put(CustomerService());
  final SubscriptionService _subscriptionService =
      Get.put(SubscriptionService());
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _auth = Get.find<AuthService>();

  Rxn<Map<String, dynamic>> vendorInfo = Rxn();

  RxInt currentIndex = 0.obs;
  RxInt totalProducts = 0.obs;
  RxInt totalCustomers = 0.obs;
  RxInt totalSubscriptions = 0.obs;

  final List<String> appBarTitles = [
    'My Products',
    'My Customers',
    'Manage Subscriptions',
    'Daily Check-in',
    'Bills & Reports',
    'Holidays & Leaves',
  ];

  @override
  void onInit() {
    super.onInit();

    // Bind counts for the setup checklist
    totalProducts
        .bindStream(_productService.getProducts().map((list) => list.length));
    totalCustomers
        .bindStream(_customerService.getCustomers().map((list) => list.length));
    totalSubscriptions.bindStream(
        _subscriptionService.getSubscriptions().map((list) => list.length));

    // Bind Vendor Info
    ever(_auth.currentVendorId, (String vendorId) {
      if (vendorId.isNotEmpty) {
        vendorInfo.bindStream(_firestore
            .collection('vendors')
            .doc(vendorId)
            .snapshots()
            .map((doc) => doc.data()));
      }
    });

    // Initial bind if vendorId is already present
    if (_auth.currentVendorId.value.isNotEmpty) {
      vendorInfo.bindStream(_firestore
          .collection('vendors')
          .doc(_auth.currentVendorId.value)
          .snapshots()
          .map((doc) => doc.data()));
    }
  }

  bool get isSetupComplete =>
      totalProducts.value > 0 &&
      totalCustomers.value > 0 &&
      totalSubscriptions.value > 0;

  void changePage(int index) {
    currentIndex.value = index;
  }
}
