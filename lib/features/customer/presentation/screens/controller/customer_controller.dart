import 'package:get/get.dart';
import 'package:p_v_j/core/services/auth_service.dart';
import 'package:p_v_j/features/vendor/subscriptions/data/models/subscription_model.dart';
import 'package:p_v_j/features/vendor/billing/data/models/bill_model.dart';
import 'package:p_v_j/features/vendor/daily_entries/data/models/daily_entry_model.dart';
import 'package:p_v_j/features/customer/domain/repositories/i_query_repository.dart';
import 'package:p_v_j/features/vendor/leaves/domain/repositories/i_leave_repository.dart';
import 'package:p_v_j/features/vendor/products/data/models/product_model.dart';
import 'package:p_v_j/features/vendor/products/domain/repositories/i_product_repository.dart';
import 'package:p_v_j/features/vendor/subscriptions/domain/repositories/i_subscription_repository.dart';
import 'package:p_v_j/features/vendor/billing/domain/repositories/i_billing_repository.dart';
import 'package:p_v_j/features/vendor/daily_entries/domain/repositories/i_daily_entry_repository.dart';
import 'package:p_v_j/features/vendor/leaves/data/models/customer_leave_model.dart';
import 'package:p_v_j/features/customer/data/models/query_model.dart';
import 'package:p_v_j/features/vendor/dashboard/domain/repositories/i_vendor_repository.dart';
import 'package:p_v_j/features/vendor/dashboard/data/models/vendor_model.dart';

class CustomerPortalController extends GetxController {
  // --- REPOSITORY INJECTION ---
  final IProductRepository _productRepository = Get.find<IProductRepository>();
  final ISubscriptionRepository _subscriptionRepository = Get.find<ISubscriptionRepository>();
  final IBillingRepository _billingRepository = Get.find<IBillingRepository>();
  final IDailyEntryRepository _dailyRepository = Get.find<IDailyEntryRepository>();
  final IVendorRepository _vendorRepository = Get.find<IVendorRepository>();
  final ILeaveRepository _leaveRepository = Get.find<ILeaveRepository>();
  final IQueryRepository _queryRepository = Get.find<IQueryRepository>();
  
  final AuthService _auth = Get.find<AuthService>();

  RxList<SubscriptionModel> mySubscriptions = <SubscriptionModel>[].obs;
  RxList<BillModel> myBills = <BillModel>[].obs;
  RxList<DailyEntryModel> myHistory = <DailyEntryModel>[].obs;
  RxList<CustomerLeaveModel> myLeaves = <CustomerLeaveModel>[].obs;
  RxList<QueryModel> myQueries = <QueryModel>[].obs;
  RxList<ProductModel> allProducts = <ProductModel>[].obs;
  Rxn<VendorModel> vendorInfo = Rxn();
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    ever(_auth.currentVendorId, (_) => _loadAllData());
    ever(_auth.currentCustomerId, (_) => _loadAllData());
    _loadAllData();
  }

  void _loadAllData() {
    String vendorId = _auth.currentVendorId.value;
    String customerId = _auth.currentCustomerId.value;

    if (vendorId.isEmpty || customerId.isEmpty) return;

    // 0. Bind Vendor Info
    vendorInfo.bindStream(_vendorRepository.getVendorInfo(vendorId));

    // 1. Bind Products
    allProducts.bindStream(_productRepository.getProducts());

    // 2. Bind Subscriptions (Filtered to this customer)
    mySubscriptions.bindStream(_subscriptionRepository.getSubscriptions().map(
      (list) => list.where((sub) => sub!.customerId == customerId).toList()
    ));

    // 3. Bind Bills
    myBills.bindStream(_billingRepository.getBillsForCustomer(customerId));

    // 4. Bind History (Current Month)
    myHistory.bindStream(_dailyRepository.getEntriesForMonth(DateTime.now()).map(
      (list) => list.where((e) => e!.customerId == customerId).toList()
    ));

    // 5. Bind Personal Leaves
    myLeaves.bindStream(_leaveRepository.getCustomerLeaves(customerId));
    
    // 6. Bind Personal Queries
    myQueries.bindStream(_queryRepository.getCustomerQueries(customerId));
  }

  String getProductName(String id) =>
      allProducts.firstWhereOrNull((p) => p.id == id)?.name ?? 'Product';

  Future<void> submitLeaveRequest(DateTime start, DateTime end, String reason) async {
    final newLeave = CustomerLeaveModel(
      id: '',
      customerId: _auth.currentCustomerId.value,
      customerName: _auth.firebaseUser.value?.displayName ?? _auth.firebaseUser.value?.email ?? 'Customer',
      vendorId: _auth.currentVendorId.value,
      startDate: start,
      endDate: end,
      status: 'Pending',
      reason: reason,
      createdAt: DateTime.now(),
    );
    await _leaveRepository.submitCustomerLeaveRequest(newLeave);
  }

  Future<void> reportIssue(DateTime date, String message) async {
    final query = QueryModel(
      id: '',
      customerId: _auth.currentCustomerId.value,
      customerName: _auth.firebaseUser.value?.displayName ?? _auth.firebaseUser.value?.email ?? 'Customer',
      vendorId: _auth.currentVendorId.value,
      deliveryDate: date,
      message: message,
      status: 'Open',
      createdAt: DateTime.now(),
    );
    await _queryRepository.submitQuery(query);
  }
}
