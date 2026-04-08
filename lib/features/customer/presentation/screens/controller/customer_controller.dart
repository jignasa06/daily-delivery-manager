import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:p_v_j/core/services/auth_service.dart';
import 'package:p_v_j/features/vendor/subscriptions/data/models/subscription_model.dart';
import 'package:p_v_j/features/vendor/billing/data/models/bill_model.dart';
import 'package:p_v_j/features/vendor/daily_entries/data/models/daily_entry_model.dart';
import 'package:p_v_j/features/vendor/leaves/data/models/customer_leave_model.dart';
import 'package:p_v_j/features/vendor/leaves/data/services/leave_service.dart';
import 'package:p_v_j/features/customer/data/models/query_model.dart';
import 'package:p_v_j/features/customer/data/services/query_service.dart';
import 'package:p_v_j/features/vendor/products/data/models/product_model.dart';

class CustomerPortalController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _auth = Get.find<AuthService>();
  final LeaveService _leaveService = Get.put(LeaveService());
  final QueryService _queryService = Get.put(QueryService());

  RxList<SubscriptionModel> mySubscriptions = <SubscriptionModel>[].obs;
  RxList<BillModel> myBills = <BillModel>[].obs;
  RxList<DailyEntryModel> myHistory = <DailyEntryModel>[].obs;
  RxList<CustomerLeaveModel> myLeaves = <CustomerLeaveModel>[].obs;
  RxList<QueryModel> myQueries = <QueryModel>[].obs;
  RxList<ProductModel> allProducts = <ProductModel>[].obs;
  Rxn<Map<String, dynamic>> vendorInfo = Rxn();
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Reactively load data when IDs are fetched
    ever(_auth.currentVendorId, (_) => _loadAllData());
    ever(_auth.currentCustomerId, (_) => _loadAllData());

    _loadAllData();
  }

  void _loadAllData() {
    String vendorId = _auth.currentVendorId.value;
    String customerId = _auth.currentCustomerId.value;

    if (vendorId.isEmpty || customerId.isEmpty) return;

    // 0. Bind Vendor Info
    vendorInfo.bindStream(_firestore
        .collection('vendors')
        .doc(vendorId)
        .snapshots()
        .map((doc) => doc.data()));

    // 1. Bind Products
    allProducts.bindStream(_firestore
        .collection('vendors')
        .doc(vendorId)
        .collection('products')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromFirestore(doc))
            .toList()));

    // 1. Bind Subscriptions
    mySubscriptions.bindStream(_firestore
        .collection('vendors')
        .doc(vendorId)
        .collection('subscriptions')
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SubscriptionModel.fromFirestore(doc))
            .toList()));

    // 2. Bind Bills
    myBills.bindStream(_firestore
        .collection('vendors')
        .doc(vendorId)
        .collection('bills')
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => BillModel.fromFirestore(doc)).toList()));

    // 3. Bind History
    _loadCurrentMonthHistory(vendorId, customerId);

    // 4. Bind Personal Leaves
    myLeaves.bindStream(_leaveService.getCustomerLeaves(customerId));

    // 5. Bind Personal Queries
    myQueries.bindStream(_queryService.getCustomerQueries(customerId));
  }

  String getProductName(String id) =>
      allProducts.firstWhereOrNull((p) => p.id == id)?.name ?? 'Product';

  void _loadCurrentMonthHistory(String vendorId, String customerId) {
    String currentMonth = DateTime.now().toString().substring(0, 7);
    myHistory.bindStream(_firestore
        .collection('vendors')
        .doc(vendorId)
        .collection('daily_entries')
        .doc(currentMonth)
        .collection('entries')
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DailyEntryModel.fromFirestore(doc))
            .toList()));
  }

  Future<void> submitLeaveRequest(
      DateTime start, DateTime end, String reason) async {
    final newLeave = CustomerLeaveModel(
      id: '',
      customerId: _auth.currentCustomerId.value,
      customerName: _auth.firebaseUser.value?.displayName ??
          _auth.firebaseUser.value?.email ??
          'Customer',
      vendorId: _auth.currentVendorId.value,
      startDate: start,
      endDate: end,
      status: 'Pending',
      reason: reason,
      createdAt: DateTime.now(),
    );
    await _leaveService.requestCustomerLeave(newLeave);
  }

  Future<void> reportIssue(DateTime date, String message) async {
    final query = QueryModel(
      id: '',
      customerId: _auth.currentCustomerId.value,
      customerName: _auth.firebaseUser.value?.displayName ??
          _auth.firebaseUser.value?.email ??
          'Customer',
      vendorId: _auth.currentVendorId.value,
      deliveryDate: date,
      message: message,
      status: 'Open',
      createdAt: DateTime.now(),
    );
    await _queryService.submitQuery(query);
  }
}
