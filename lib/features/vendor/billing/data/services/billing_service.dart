import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:p_v_j/core/services/auth_service.dart';
import 'package:p_v_j/features/vendor/daily_entries/data/models/daily_entry_model.dart';
import 'package:p_v_j/features/vendor/billing/data/models/bill_model.dart';
import 'package:p_v_j/core/utils/snackbar_utils.dart';

class BillingService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();

  CollectionReference get _vendorBills {
    String? uid = _authService.firebaseUser.value?.uid;
    if (uid == null) throw Exception('User not logged in');
    return _firestore.collection('vendors').doc(uid).collection('bills');
  }

  // Generate a bill for a customer for a given month (YYYY-MM)
  Future<BillModel?> generateMonthlyBill(
      String customerId, String monthYear) async {
    try {
      // 0. Path to current vendor
      final vendorDoc = _firestore
          .collection('vendors')
          .doc(_authService.firebaseUser.value!.uid);

      // 1. Get all entries for that month delivered to this customer
      QuerySnapshot snapshot = await vendorDoc
          .collection('daily_entries')
          .doc(monthYear)
          .collection('entries')
          .where('customerId', isEqualTo: customerId)
          .where('isDelivered', isEqualTo: true)
          .get();

      List<DailyEntryModel> deliveredEntries = snapshot.docs
          .map((doc) => DailyEntryModel.fromFirestore(doc))
          .toList();

      if (deliveredEntries.isEmpty) {
        SnackbarUtils.showError('No deliveries found for this month');
        return null;
      }

      // Check for existing bill to prevent duplicates
      final existingBills = await _vendorBills
          .where('customerId', isEqualTo: customerId)
          .where('monthYear', isEqualTo: monthYear)
          .get();
      if (existingBills.docs.isNotEmpty) {
        SnackbarUtils.showError('Bill already generated for this month');
        return null;
      }

      // 2. Fetch current prices of products
      final productsSnapshot = await vendorDoc.collection('products').get();
      Map<String, double> productPrices = {};
      for (var doc in productsSnapshot.docs) {
        productPrices[doc.id] = (doc.get('pricePerUnit') ?? 0.0).toDouble();
      }

      // 3. Fetch subscriptions to map subId to productId
      final subscriptionsSnapshot =
          await vendorDoc.collection('subscriptions').get();
      Map<String, String> subToProduct = {};
      for (var doc in subscriptionsSnapshot.docs) {
        subToProduct[doc.id] = doc.get('productId');
      }

      double totalAmount = 0;
      Map<String, int> productQuantities = {};

      for (var entry in deliveredEntries) {
        String? productId = subToProduct[entry.subscriptionId];
        if (productId != null) {
          double price = productPrices[productId] ?? 0.0;
          totalAmount += entry.quantity * price;
          productQuantities[productId] =
              (productQuantities[productId] ?? 0) + entry.quantity;
        }
      }

      final bill = BillModel(
        id: '',
        customerId: customerId,
        monthYear: monthYear,
        totalAmount: totalAmount,
        details: {
          'quantities': productQuantities,
        },
      );

      // 4. Save to Firestore
      await _vendorBills.add(bill.toJson());
      SnackbarUtils.showSuccess('Bill generated for $monthYear');

      return bill;
    } catch (e) {
      SnackbarUtils.showError('Failed to generate bill: $e');
      return null;
    }
  }

  Stream<List<BillModel>> getBillsForCustomer(String customerId) {
    return _vendorBills
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => BillModel.fromFirestore(doc)).toList();
    });
  }
}
