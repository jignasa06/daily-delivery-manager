import 'dart:async';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:p_v_j/core/utils/snackbar_utils.dart';
import 'package:p_v_j/features/vendor/customers/data/models/customer_model.dart';
import 'package:p_v_j/features/vendor/customers/data/services/customer_service.dart';
import 'package:p_v_j/features/vendor/daily_entries/data/models/daily_entry_model.dart';
import 'package:p_v_j/features/vendor/leaves/data/models/leave_model.dart';
import 'package:p_v_j/features/vendor/daily_entries/data/services/daily_entry_service.dart';
import 'package:p_v_j/features/vendor/leaves/data/models/customer_leave_model.dart';
import 'package:p_v_j/features/vendor/leaves/data/services/leave_service.dart';
import 'package:p_v_j/features/vendor/products/data/models/product_model.dart';
import 'package:p_v_j/features/vendor/products/data/services/product_service.dart';
import 'package:p_v_j/features/vendor/subscriptions/data/models/subscription_model.dart';
import 'package:p_v_j/features/vendor/subscriptions/data/services/subscription_service.dart';

class DailyEntryController extends GetxController {
  final DailyEntryService _dailyService = Get.put(DailyEntryService());
  final SubscriptionService _subService = Get.find<SubscriptionService>();
  final CustomerService _customerService = Get.find<CustomerService>();
  final ProductService _productService = Get.find<ProductService>();
  final LeaveService _leaveService = Get.put(LeaveService());

  Rx<DateTime> selectedDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
          .obs;
  StreamSubscription<List<DailyEntryModel>>? _entriesSubscription;

  // Data streams
  RxList<SubscriptionModel> allSubscriptions = <SubscriptionModel>[].obs;
  RxMap<String, DailyEntryModel> todayEntries = <String, DailyEntryModel>{}.obs;
  RxBool isLoadingEntries = false.obs;
  RxString loadingSubId = ''.obs;
  RxList<CustomerModel> customers = <CustomerModel>[].obs;
  RxList<ProductModel> products = <ProductModel>[].obs;
  RxList<LeaveModel> leaves = <LeaveModel>[].obs;
  RxList<CustomerLeaveModel> customerLeaves = <CustomerLeaveModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    allSubscriptions.bindStream(_subService.getSubscriptions());
    customers.bindStream(_customerService.getCustomers());
    products.bindStream(_productService.getProducts());
    leaves.bindStream(_leaveService.getLeaves());
    customerLeaves.bindStream(_leaveService.getAdminLeaveRequests());

    // Reactively load entries when date changes
    ever(selectedDate, (DateTime date) => _subscribeToEntries(date));

    // Trigger initial load
    _subscribeToEntries(selectedDate.value);
  }

  void _subscribeToEntries(DateTime date) {
    _entriesSubscription?.cancel();
    isLoadingEntries.value = true;
    todayEntries.clear();

    _entriesSubscription =
        _dailyService.getEntriesForDay(date).listen((entries) {
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

  // Check if the vendor is on holiday for the selected date
  bool isVendorOnHoliday() {
    String currentDayStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);
    return leaves.any((leave) {
      if (leave.type != 'vendor') return false;
      String startStr = DateFormat('yyyy-MM-dd').format(leave.startDate);
      String endStr = DateFormat('yyyy-MM-dd').format(leave.endDate);
      return currentDayStr.compareTo(startStr) >= 0 &&
          currentDayStr.compareTo(endStr) <= 0;
    });
  }

  // Check if a specific customer is on leave for the selected date
  bool isCustomerOnLeave(String customerId) {
    String currentDayStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);

    // 1. Check vendor's private per-customer holidays
    final bool onVendorCustomerHoliday = leaves.any((leave) {
      if (leave.targetId != customerId) return false;
      String startStr = DateFormat('yyyy-MM-dd').format(leave.startDate);
      String endStr = DateFormat('yyyy-MM-dd').format(leave.endDate);
      return currentDayStr.compareTo(startStr) >= 0 &&
          currentDayStr.compareTo(endStr) <= 0;
    });
    if (onVendorCustomerHoliday) return true;

    // 2. Check approved customer leave requests
    return customerLeaves.any((req) {
      if (req.customerId != customerId || req.status != 'Approved') return false;
      String startStr = DateFormat('yyyy-MM-dd').format(req.startDate);
      String endStr = DateFormat('yyyy-MM-dd').format(req.endDate);
      return currentDayStr.compareTo(startStr) >= 0 &&
          currentDayStr.compareTo(endStr) <= 0;
    });
  }

  // Legacy wrapper — kept for backward compatibility
  bool isOnLeave(String? customerId) {
    if (customerId == null) return isVendorOnHoliday();
    return isVendorOnHoliday() || isCustomerOnLeave(customerId);
  }

  List<SubscriptionModel> get activeSubscriptionsForDay {
    String dayName = DateFormat('EEEE').format(selectedDate.value);
    return allSubscriptions.where((sub) {
      // 1. Must match the day of week
      bool matchesDay = sub.selectedDays.contains(dayName);

      // 2. Must be on or after the subscription's start date
      DateTime scrubbedSubStart =
          DateTime(sub.startDate.year, sub.startDate.month, sub.startDate.day);
      bool isAfterStart = selectedDate.value.isAfter(scrubbedSubStart) ||
          selectedDate.value.isAtSameMomentAs(scrubbedSubStart);

      // 3. Must be on or before the subscription's end date (if defined)
      bool isBeforeEnd = true;
      if (sub.endDate != null) {
        DateTime scrubbedSubEnd =
            DateTime(sub.endDate!.year, sub.endDate!.month, sub.endDate!.day);
        isBeforeEnd = selectedDate.value.isBefore(scrubbedSubEnd) ||
            selectedDate.value.isAtSameMomentAs(scrubbedSubEnd);
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

  String getCustomerName(String id) =>
      customers.firstWhereOrNull((c) => c.id == id)?.name ?? 'Unknown';
  String getProductName(String id) =>
      products.firstWhereOrNull((p) => p.id == id)?.name ?? 'Unknown';
  String getProductUnit(String id) =>
      products.firstWhereOrNull((p) => p.id == id)?.unit ?? '';

  Future<void> toggleDelivery(
      SubscriptionModel sub, DailyEntryModel currentEntry) async {
    if (isOnLeave(null)) {
      SnackbarUtils.showInfo('No deliveries today - Vendor is on holiday!');
      return;
    }
    if (isOnLeave(sub.customerId)) {
      SnackbarUtils.showInfo('Customer is currently on leave!');
      return;
    }

    final updatedEntry = DailyEntryModel(
      id: currentEntry.id,
      customerId: currentEntry.customerId,
      subscriptionId: currentEntry.subscriptionId,
      date: currentEntry.date,
      quantity: currentEntry.quantity,
      isDelivered: !currentEntry.isDelivered,
    );

    loadingSubId.value = sub.id; // Show localized spinner
    try {
      await _dailyService.upsertEntry(updatedEntry);
      HapticFeedback.lightImpact();
    } finally {
      loadingSubId.value = ''; // Hide spinner
    }
  }

  Future<void> updateQuantity(
      SubscriptionModel sub, DailyEntryModel currentEntry, int newQty) async {
    if (newQty < 1) return;

    if (isOnLeave(null)) {
      SnackbarUtils.showInfo('Cannot change quantity - Vendor is on holiday!');
      return;
    }
    if (isOnLeave(sub.customerId)) {
      SnackbarUtils.showInfo('Cannot change quantity - Customer is on leave!');
      return;
    }

    final updatedEntry = DailyEntryModel(
      id: currentEntry.id,
      customerId: currentEntry.customerId,
      subscriptionId: currentEntry.subscriptionId,
      date: currentEntry.date,
      quantity: newQty,
      isDelivered: currentEntry.isDelivered,
    );

    loadingSubId.value = sub.id; // Show localized spinner
    try {
      await _dailyService.upsertEntry(updatedEntry);
      HapticFeedback.lightImpact();
    } finally {
      loadingSubId.value = ''; // Hide spinner
    }
  }
}
