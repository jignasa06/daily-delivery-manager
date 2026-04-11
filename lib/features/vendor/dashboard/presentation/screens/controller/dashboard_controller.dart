import 'package:get/get.dart';
import 'package:p_v_j/core/services/auth_service.dart';
import 'package:p_v_j/features/vendor/daily_entries/presentation/screens/controller/daily_entry_controller.dart';
import 'package:p_v_j/features/vendor/dashboard/domain/repositories/i_vendor_repository.dart';
import 'package:p_v_j/features/vendor/products/domain/repositories/i_product_repository.dart';
import 'package:p_v_j/features/vendor/dashboard/data/models/vendor_model.dart';

class DashboardController extends GetxController {
  // --- REPOSITORY INJECTION (Backend Agnostic) ---
  final IProductRepository _productRepository = Get.find<IProductRepository>();
  final IVendorRepository _vendorRepository = Get.find<IVendorRepository>();

  // App Services
  final DailyEntryController _dailyController = Get.put(DailyEntryController());
  final AuthService _auth = Get.find<AuthService>();

  // Observable State
  Rxn<VendorModel> vendorInfo = Rxn();
  RxInt currentIndex = 0.obs;

  // High-Impact Metrics
  RxInt totalProducts = 0.obs;
  RxInt todayDeliveredCount = 0.obs;
  RxInt todayTotalCount = 0.obs;

  // Derived Summary Stats (for SetupProgressWidget)
  bool get isSetupComplete => vendorInfo.value?.isProfileSetup ?? false;
  int get totalCustomers => _dailyController.customers.length;
  int get totalSubscriptions => _dailyController.allSubscriptions.length;

  final List<String> appBarTitles = [
    'Dashboard Overview',
    'My Customers',
    'Daily Deliveries',
    'Business Profile',
    'Product Catalog',
    'Subscriptions',
    'Billing & Invoices',
    'Holidays & Leaves',
  ];

  @override
  void onInit() {
    super.onInit();

    // 1. Bind Product Metrics via Repository
    totalProducts.bindStream(
        _productRepository.getProducts().map((list) => list.length));

    // 2. Bind Vendor Info via Repository
    ever(_auth.currentVendorId, (String vendorId) {
      if (vendorId.isNotEmpty) {
        vendorInfo.bindStream(_vendorRepository.getVendorInfo(vendorId));
      }
    });

    // Initial bind if vendorId is already present
    if (_auth.currentVendorId.value.isNotEmpty) {
      vendorInfo.bindStream(
          _vendorRepository.getVendorInfo(_auth.currentVendorId.value));
    }

    // 3. Bind Delivery Metrics (Derived from DailyController)
    ever(_dailyController.todayEntries, (_) => _updateDeliveryMetrics());
    ever(_dailyController.allSubscriptions, (_) => _updateDeliveryMetrics());
    ever(_dailyController.selectedDate, (_) => _updateDeliveryMetrics());

    // Initial update
    _updateDeliveryMetrics();
  }

  void _updateDeliveryMetrics() {
    final active = _dailyController.activeSubscriptionsForDay;
    todayTotalCount.value = active.length;

    int delivered = 0;
    for (var sub in active) {
      if (_dailyController.todayEntries[sub.id]?.isDelivered ?? false) {
        delivered++;
      }
    }
    todayDeliveredCount.value = delivered;
  }

  void changePage(int index) {
    currentIndex.value = index;
  }
}
