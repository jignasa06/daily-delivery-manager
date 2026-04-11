import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:p_v_j/core/utils/snackbar_utils.dart';
import 'package:p_v_j/features/vendor/billing/data/models/bill_model.dart';
import 'package:p_v_j/features/vendor/billing/domain/repositories/i_billing_repository.dart';
import 'package:p_v_j/features/vendor/customers/data/models/customer_model.dart';
import 'package:p_v_j/features/vendor/customers/domain/repositories/i_customer_repository.dart';
import 'package:p_v_j/features/vendor/daily_entries/data/models/daily_entry_model.dart';
import 'package:p_v_j/features/vendor/daily_entries/domain/repositories/i_daily_entry_repository.dart';
import 'package:p_v_j/features/vendor/subscriptions/data/models/subscription_model.dart';
import 'package:p_v_j/features/vendor/subscriptions/domain/repositories/i_subscription_repository.dart';

class BillingController extends GetxController {
  // --- REPOSITORY INJECTION ---
  final IBillingRepository _billingRepository = Get.find<IBillingRepository>();
  final IDailyEntryRepository _dailyRepository = Get.find<IDailyEntryRepository>();
  final ISubscriptionRepository _subscriptionRepository = Get.find<ISubscriptionRepository>();
  final ICustomerRepository _customerRepository = Get.find<ICustomerRepository>();

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
    customers.bindStream(_customerRepository.getCustomers());
    subscriptions.bindStream(_subscriptionRepository.getSubscriptions());

    // Bind entries based on selected month
    ever(selectedMonthYear, (String my) {
      DateTime date = DateFormat('yyyy-MM').parse(my);
      monthEntries.bindStream(_dailyRepository.getEntriesForMonth(date));
    });

    // Initial binding
    DateTime initial = DateFormat('yyyy-MM').parse(selectedMonthYear.value);
    monthEntries.bindStream(_dailyRepository.getEntriesForMonth(initial));
  }

  void changeMonth(int delta) {
    DateTime current = DateFormat('yyyy-MM').parse(selectedMonthYear.value);
    DateTime nextMonth = DateTime(current.year, current.month + delta);
    selectedMonthYear.value = DateFormat('yyyy-MM').format(nextMonth);
  }

  List<CustomerModel> get filteredCustomers {
    final now = DateTime.now();
    final String currentMonthYear = DateFormat('yyyy-MM').format(now);

    if (selectedMonthYear.value.compareTo(currentMonthYear) > 0) return [];

    if (selectedMonthYear.value == currentMonthYear) {
      DateTime monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      return customers.where((customer) {
        return subscriptions.any((sub) {
          if (sub.customerId != customer.id) return false;
          DateTime scrubbedStart = DateTime(sub.startDate.year, sub.startDate.month, sub.startDate.day);
          DateTime scrubbedEnd = DateTime(monthEnd.year, monthEnd.month, monthEnd.day);
          return scrubbedStart.isBefore(scrubbedEnd) || scrubbedStart.isAtSameMomentAs(scrubbedEnd);
        });
      }).toList();
    }

    final Set<String> activeIdsForMonth = monthEntries.map((e) => e.customerId).toSet();
    return customers.where((customer) => activeIdsForMonth.contains(customer.id)).toList();
  }

  void onCustomerSelected(CustomerModel? customer) {
    selectedCustomer.value = customer;
    if (customer != null) {
      bills.bindStream(_billingRepository.getBillsForCustomer(customer.id));
    }
  }

  double get totalRevenueForMonth {
    return bills
        .where((b) => b.monthYear == selectedMonthYear.value)
        .fold(0.0, (sum, b) => sum + b.totalAmount);
  }

  Future<void> generateBill(String customerId) async {
    isLoading.value = true;
    try {
      await _billingRepository.generateMonthlyBill(customerId, selectedMonthYear.value);
      SnackbarUtils.showSuccess('Bill generated for ${selectedMonthYear.value}');
    } catch (e) {
      SnackbarUtils.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Proxy for UI StreamBuilder
  Stream<List<BillModel>> getCustomerBills(String customerId) => 
      _billingRepository.getBillsForCustomer(customerId);
}
