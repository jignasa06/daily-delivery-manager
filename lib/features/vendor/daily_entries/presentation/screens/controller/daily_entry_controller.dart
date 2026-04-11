import 'dart:async';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:p_v_j/core/utils/snackbar_utils.dart';
import 'package:p_v_j/features/vendor/customers/data/models/customer_model.dart';
import 'package:p_v_j/features/vendor/customers/domain/repositories/i_customer_repository.dart';
import 'package:p_v_j/features/vendor/daily_entries/data/models/daily_entry_model.dart';
import 'package:p_v_j/features/vendor/daily_entries/domain/repositories/i_daily_entry_repository.dart';
import 'package:p_v_j/features/vendor/leaves/data/models/leave_model.dart';
import 'package:p_v_j/features/vendor/leaves/data/models/customer_leave_model.dart';
import 'package:p_v_j/features/vendor/leaves/domain/repositories/i_leave_repository.dart';
import 'package:p_v_j/features/vendor/products/domain/repositories/i_product_repository.dart';
import 'package:p_v_j/features/vendor/subscriptions/data/models/subscription_model.dart';
import 'package:p_v_j/features/vendor/subscriptions/domain/repositories/i_subscription_repository.dart';
import 'package:p_v_j/features/vendor/products/presentation/screens/controller/product_controller.dart';

class DailyEntryController extends GetxController {
  // --- REPOSITORY INJECTION (Backend Agnostic) ---
  final IDailyEntryRepository _dailyRepository = Get.find<IDailyEntryRepository>();
  final IProductRepository _productRepository = Get.find<IProductRepository>();
  final ISubscriptionRepository _subscriptionRepository = Get.find<ISubscriptionRepository>();
  final ICustomerRepository _customerRepository = Get.find<ICustomerRepository>();
  final ILeaveRepository _leaveRepository = Get.find<ILeaveRepository>();

  Rx<DateTime> selectedDate = DateTime(
    DateTime.now().year, 
    DateTime.now().month, 
    DateTime.now().day
  ).obs;

  StreamSubscription<List<DailyEntryModel>>? _entriesSubscription;

  // Data streams
  RxList<SubscriptionModel> allSubscriptions = <SubscriptionModel>[].obs;
  RxMap<String, DailyEntryModel> todayEntries = <String, DailyEntryModel>{}.obs;
  RxBool isLoadingEntries = false.obs;
  RxString loadingSubId = ''.obs;
  RxList<CustomerModel> customers = <CustomerModel>[].obs;
  RxList<LeaveModel> leaves = <LeaveModel>[].obs;
  RxList<CustomerLeaveModel> customerLeaves = <CustomerLeaveModel>[].obs;

  // Search & Filtering State
  RxString searchQuery = ''.obs;
  RxString selectedFilter = 'All'.obs; 

  @override
  void onInit() {
    super.onInit();
    allSubscriptions.bindStream(_subscriptionRepository.getSubscriptions());
    customers.bindStream(_customerRepository.getCustomers());
    leaves.bindStream(_leaveRepository.getVendorLeaves());
    customerLeaves.bindStream(_leaveRepository.getAllCustomerLeaveRequests());

    ever(selectedDate, (DateTime date) => _subscribeToEntries(date));
    _subscribeToEntries(selectedDate.value);
  }

  void _subscribeToEntries(DateTime date) {
    _entriesSubscription?.cancel();
    isLoadingEntries.value = true;
    todayEntries.clear();

    _entriesSubscription = _dailyRepository.getEntriesForDay(date).listen((entries) {
      Map<String, DailyEntryModel> entryMap = {};
      for (var e in entries) {
        entryMap[e.subscriptionId] = e;
      }
      todayEntries.assignAll(entryMap);
      isLoadingEntries.value = false;
    });
  }

  @override
  void onClose() {
    _entriesSubscription?.cancel();
    super.onClose();
  }

  void changeDate(DateTime date) {
    selectedDate.value = DateTime(date.year, date.month, date.day);
  }

  List<SubscriptionModel> get filteredSubscriptions {
    List<SubscriptionModel> baseList = activeSubscriptionsForDay;
    if (searchQuery.isNotEmpty) {
      baseList = baseList.where((sub) {
        final customer = customers.firstWhereOrNull((c) => c.id == sub.customerId);
        if (customer == null) return false;
        return customer.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
               customer.address.toLowerCase().contains(searchQuery.value.toLowerCase());
      }).toList();
    }

    if (selectedFilter.value != 'All') {
      baseList = baseList.where((sub) {
        final entry = getEntryForSubscription(sub);
        final bool isLeave = isCustomerOnLeave(sub.customerId);
        if (selectedFilter.value == 'Delivered') return entry.isDelivered;
        if (selectedFilter.value == 'Pending') return !entry.isDelivered && !isLeave;
        if (selectedFilter.value == 'Skipped') return isLeave;
        return true;
      }).toList();
    }
    return baseList;
  }

  bool isVendorOnHoliday() {
    String currentDayStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);
    return leaves.any((leave) {
      if (leave.type != 'vendor') return false;
      String startStr = DateFormat('yyyy-MM-dd').format(leave.startDate);
      String endStr = DateFormat('yyyy-MM-dd').format(leave.endDate);
      return currentDayStr.compareTo(startStr) >= 0 && currentDayStr.compareTo(endStr) <= 0;
    });
  }

  bool isCustomerOnLeave(String customerId) {
    String currentDayStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);
    final bool onVendorCustomerHoliday = leaves.any((leave) {
      if (leave.targetId != customerId) return false;
      String startStr = DateFormat('yyyy-MM-dd').format(leave.startDate);
      String endStr = DateFormat('yyyy-MM-dd').format(leave.endDate);
      return currentDayStr.compareTo(startStr) >= 0 && currentDayStr.compareTo(endStr) <= 0;
    });
    if (onVendorCustomerHoliday) return true;

    return customerLeaves.any((req) {
      if (req.customerId != customerId || req.status != 'Approved') return false;
      String startStr = DateFormat('yyyy-MM-dd').format(req.startDate);
      String endStr = DateFormat('yyyy-MM-dd').format(req.endDate);
      return currentDayStr.compareTo(startStr) >= 0 && currentDayStr.compareTo(endStr) <= 0;
    });
  }

  bool isOnLeave(String? customerId) {
    if (customerId == null) return isVendorOnHoliday();
    return isVendorOnHoliday() || isCustomerOnLeave(customerId);
  }

  List<SubscriptionModel> get activeSubscriptionsForDay {
    String dayName = DateFormat('EEEE').format(selectedDate.value);
    return allSubscriptions.where((sub) {
      bool matchesDay = sub.selectedDays.contains(dayName);
      DateTime scrubbedSubStart = DateTime(sub.startDate.year, sub.startDate.month, sub.startDate.day);
      bool isAfterStart = selectedDate.value.isAfter(scrubbedSubStart) || selectedDate.value.isAtSameMomentAs(scrubbedSubStart);
      bool isBeforeEnd = true;
      if (sub.endDate != null) {
        DateTime scrubbedSubEnd = DateTime(sub.endDate!.year, sub.endDate!.month, sub.endDate!.day);
        isBeforeEnd = selectedDate.value.isBefore(scrubbedSubEnd) || selectedDate.value.isAtSameMomentAs(scrubbedSubEnd);
      }
      return matchesDay && isAfterStart && isBeforeEnd;
    }).toList();
  }

  DailyEntryModel getEntryForSubscription(SubscriptionModel sub) {
    if (todayEntries.containsKey(sub.id)) {
      return todayEntries[sub.id]!;
    }
    return DailyEntryModel(
      id: '',
      customerId: sub.customerId,
      subscriptionId: sub.id,
      date: selectedDate.value,
      quantity: sub.defaultQuantity,
      isDelivered: false,
    );
  }

  String getCustomerName(String id) => customers.firstWhereOrNull((c) => c.id == id)?.name ?? 'Unknown';
  String getProductName(String id) => _productRepository.getProducts().map((list) => list.firstWhereOrNull((p) => p.id == id)?.name ?? 'Unknown').toString(); // Simple fallback for now
  
  // Refined Product Name getter (Re-implemented for repo compatibility)
  String getProductNameSync(String id) {
     final products = Get.find<ProductController>().products;
     return products.firstWhereOrNull((p) => p.id == id)?.name ?? 'Unknown';
  }

  Future<void> toggleDelivery(SubscriptionModel sub, DailyEntryModel currentEntry) async {
    if (isOnLeave(null) || isOnLeave(sub.customerId)) return;
    final updatedEntry = DailyEntryModel(
      id: currentEntry.id,
      customerId: currentEntry.customerId,
      subscriptionId: currentEntry.subscriptionId,
      date: currentEntry.date,
      quantity: currentEntry.quantity,
      isDelivered: !currentEntry.isDelivered,
    );
    loadingSubId.value = sub.id;
    try {
      await _dailyRepository.upsertEntry(updatedEntry);
      HapticFeedback.lightImpact();
    } finally {
      loadingSubId.value = '';
    }
  }

  Future<void> updateQuantity(SubscriptionModel sub, DailyEntryModel currentEntry, int newQty) async {
    if (newQty < 1 || isOnLeave(null) || isOnLeave(sub.customerId)) return;
    final updatedEntry = DailyEntryModel(
      id: currentEntry.id,
      customerId: currentEntry.customerId,
      subscriptionId: currentEntry.subscriptionId,
      date: currentEntry.date,
      quantity: newQty,
      isDelivered: currentEntry.isDelivered,
    );
    loadingSubId.value = sub.id;
    try {
      await _dailyRepository.upsertEntry(updatedEntry);
      HapticFeedback.lightImpact();
    } finally {
      loadingSubId.value = '';
    }
  }
}
