import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:p_v_j/features/vendor/billing/data/models/bill_model.dart';
import 'package:p_v_j/features/vendor/billing/data/services/billing_service.dart';
import 'package:p_v_j/features/vendor/customers/data/models/customer_model.dart';
import 'package:p_v_j/features/vendor/customers/data/services/customer_service.dart';
import 'package:p_v_j/features/vendor/daily_entries/data/models/daily_entry_model.dart';
import 'package:p_v_j/features/vendor/daily_entries/data/services/daily_entry_service.dart';
import 'package:p_v_j/features/vendor/subscriptions/data/models/subscription_model.dart';
import 'package:p_v_j/features/vendor/subscriptions/data/services/subscription_service.dart';

class BillingController extends GetxController {
  final BillingService _billingService = Get.put(BillingService());
  final CustomerService _customerService = Get.find<CustomerService>();
  final SubscriptionService _subService = Get.put(SubscriptionService());
  final DailyEntryService _dailyService = Get.put(DailyEntryService());

  RxList<CustomerModel> customers = <CustomerModel>[].obs;
  RxList<SubscriptionModel> subscriptions = <SubscriptionModel>[].obs;
  RxList<DailyEntryModel> monthEntries = <DailyEntryModel>[].obs;

  // Selected state
  RxString selectedMonthYear = DateFormat('yyyy-MM').format(DateTime.now()).obs;
  Rx<CustomerModel?> selectedCustomer = Rx<CustomerModel?>(null);

  RxList<BillModel> bills = <BillModel>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    customers.bindStream(_customerService.getCustomers());
    subscriptions.bindStream(_subService.getSubscriptions());

    // Bind entries based on selected month
    ever(selectedMonthYear, (String my) {
      DateTime date = DateFormat('yyyy-MM').parse(my);
      monthEntries.bindStream(_dailyService.getEntriesForMonth(date));
    });

    // Initial binding
    DateTime initial = DateFormat('yyyy-MM').parse(selectedMonthYear.value);
    monthEntries.bindStream(_dailyService.getEntriesForMonth(initial));
  }

  void changeMonth(int delta) {
    DateTime current = DateFormat('yyyy-MM').parse(selectedMonthYear.value);
    DateTime nextMonth = DateTime(current.year, current.month + delta);
    selectedMonthYear.value = DateFormat('yyyy-MM').format(nextMonth);
  }

  List<CustomerModel> get filteredCustomers {
    final now = DateTime.now();
    final String currentMonthYear = DateFormat('yyyy-MM').format(now);

    // 1. FUTURE: If selected month is AFTER current month (e.g. Next Month), hide everyone
    if (selectedMonthYear.value.compareTo(currentMonthYear) > 0) return [];

    // 2. PRESENT: If selected month IS current month, show all who have a subscription
    // that starts on or before the LAST DAY of this month.
    if (selectedMonthYear.value == currentMonthYear) {
      DateTime monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      return customers.where((customer) {
        return subscriptions.any((sub) {
          if (sub.customerId != customer.id) return false;
          // Compare dates only (scrub time)
          DateTime scrubbedStart = DateTime(
              sub.startDate.year, sub.startDate.month, sub.startDate.day);
          DateTime scrubbedEnd =
              DateTime(monthEnd.year, monthEnd.month, monthEnd.day);
          return scrubbedStart.isBefore(scrubbedEnd) ||
              scrubbedStart.isAtSameMomentAs(scrubbedEnd);
        });
      }).toList();
    }

    // 3. PAST: If selected month is in PAST, only show customers who had at least 1 delivery entry
    // or who already have a bill record for that month (to stay consistent with history).
    final Set<String> activeIdsForMonth =
        monthEntries.map((e) => e.customerId).toSet();
    return customers
        .where((customer) => activeIdsForMonth.contains(customer.id))
        .toList();
  }

  Stream<List<BillModel>> getCustomerBills(String customerId) {
    return _billingService.getBillsForCustomer(customerId);
  }

  void onCustomerSelected(CustomerModel? customer) {
    selectedCustomer.value = customer;
    if (customer != null) {
      bills.bindStream(_billingService.getBillsForCustomer(customer.id));
    }
  }

  double get totalRevenueForMonth {
    return bills
        .where((b) => b.monthYear == selectedMonthYear.value)
        .fold(0.0, (sum, b) => sum + b.totalAmount);
  }

  Future<void> generateBill(String customerId) async {
    isLoading.value = true;
    await _billingService.generateMonthlyBill(
        customerId, selectedMonthYear.value);
    // After generating, the bills list will be automatically updated by the stream
    isLoading.value = false;
  }
}
