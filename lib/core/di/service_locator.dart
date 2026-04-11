import 'package:get/get.dart';
import 'package:p_v_j/core/services/auth_service.dart';
import 'package:p_v_j/core/localization/localization_service.dart';

// --- Domain Repositories ---
import 'package:p_v_j/features/vendor/products/domain/repositories/i_product_repository.dart';
import 'package:p_v_j/features/vendor/dashboard/domain/repositories/i_vendor_repository.dart';
import 'package:p_v_j/features/vendor/daily_entries/domain/repositories/i_daily_entry_repository.dart';
import 'package:p_v_j/features/vendor/subscriptions/domain/repositories/i_subscription_repository.dart';
import 'package:p_v_j/features/vendor/billing/domain/repositories/i_billing_repository.dart';
import 'package:p_v_j/features/vendor/customers/domain/repositories/i_customer_repository.dart';
import 'package:p_v_j/features/vendor/leaves/domain/repositories/i_leave_repository.dart';
import 'package:p_v_j/features/customer/domain/repositories/i_query_repository.dart';

// --- Data Implementations ---
import 'package:p_v_j/features/vendor/products/data/repositories/firebase_product_repository.dart';
import 'package:p_v_j/features/vendor/products/data/repositories/mock_product_repository.dart';
import 'package:p_v_j/features/vendor/dashboard/data/repositories/firebase_vendor_repository.dart';
import 'package:p_v_j/features/vendor/dashboard/data/repositories/mock_vendor_repository.dart';
import 'package:p_v_j/features/vendor/daily_entries/data/repositories/firebase_daily_entry_repository.dart';
import 'package:p_v_j/features/vendor/daily_entries/data/repositories/mock_daily_entry_repository.dart';
import 'package:p_v_j/features/vendor/subscriptions/data/repositories/firebase_subscription_repository.dart';
import 'package:p_v_j/features/vendor/subscriptions/data/repositories/mock_subscription_repository.dart';
import 'package:p_v_j/features/vendor/billing/data/repositories/firebase_billing_repository.dart';
import 'package:p_v_j/features/vendor/billing/data/repositories/mock_billing_repository.dart';
import 'package:p_v_j/features/vendor/customers/data/repositories/firebase_customer_repository.dart';
import 'package:p_v_j/features/vendor/customers/data/repositories/mock_customer_repository.dart';
import 'package:p_v_j/features/vendor/leaves/data/repositories/firebase_leave_repository.dart';
import 'package:p_v_j/features/vendor/leaves/data/repositories/mock_leave_repository.dart';
import 'package:p_v_j/features/customer/data/repositories/firebase_query_repository.dart';
import 'package:p_v_j/features/customer/data/repositories/mock_query_repository.dart';

Future<void> setupServiceLocator() async {
  // --- CORE SERVICES ---
  final authService = Get.put<AuthService>(AuthService(), permanent: true);
  Get.put<LocalizationService>(LocalizationService(), permanent: true);

  // --- REPOSITORY SELECTION (ENVIRONMENT SWITCH) ---
  
  // Set this to TRUE to use dummy data without a live Firebase connection.
  // Set this to FALSE once you have live Firebase data.
  const bool useMockData = true; 

  if (useMockData) {
    // Inject Mock Implementations
    Get.lazyPut<IProductRepository>(() => MockProductRepository());
    Get.lazyPut<IVendorRepository>(() => MockVendorRepository());
    Get.lazyPut<IDailyEntryRepository>(() => MockDailyEntryRepository());
    Get.lazyPut<ISubscriptionRepository>(() => MockSubscriptionRepository());
    Get.lazyPut<IBillingRepository>(() => MockBillingRepository());
    Get.lazyPut<ICustomerRepository>(() => MockCustomerRepository());
    Get.lazyPut<ILeaveRepository>(() => MockLeaveRepository());
    Get.lazyPut<IQueryRepository>(() => MockQueryRepository());
  } else {
    // Inject Firebase Implementations
    String vendorId = authService.currentVendorId.value;
    
    Get.lazyPut<IProductRepository>(() => FirebaseProductRepository(vendorId: vendorId));
    Get.lazyPut<IVendorRepository>(() => FirebaseVendorRepository());
    Get.lazyPut<IDailyEntryRepository>(() => FirebaseDailyEntryRepository(vendorId: vendorId));
    Get.lazyPut<ISubscriptionRepository>(() => FirebaseSubscriptionRepository(vendorId: vendorId));
    Get.lazyPut<IBillingRepository>(() => FirebaseBillingRepository(vendorId: vendorId));
    Get.lazyPut<ICustomerRepository>(() => FirebaseCustomerRepository(vendorId: vendorId));
    Get.lazyPut<ILeaveRepository>(() => FirebaseLeaveRepository(vendorId: vendorId));
    Get.lazyPut<IQueryRepository>(() => FirebaseQueryRepository(vendorId: vendorId));
  }
}
