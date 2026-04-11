import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:p_v_j/features/vendor/daily_entries/data/models/daily_entry_model.dart';
import '../models/bill_model.dart';
import '../../domain/repositories/i_billing_repository.dart';

class FirebaseBillingRepository implements IBillingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String vendorId;

  FirebaseBillingRepository({required this.vendorId});

  DocumentReference get _vendorDoc => _firestore.collection('vendors').doc(vendorId);
  CollectionReference get _vendorBills => _vendorDoc.collection('bills');

  @override
  Stream<List<BillModel>> getBillsForCustomer(String customerId) {
    return _vendorBills
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => BillModel.fromFirestore(doc)).toList();
    });
  }

  @override
  Future<void> generateMonthlyBill(String customerId, String monthYear) async {
    // 1. Get all entries for that month delivered to this customer
    QuerySnapshot snapshot = await _vendorDoc
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
      throw Exception('No deliveries found for this month');
    }

    // 2. Fetch current prices of products & subscriptions
    final productsSnapshot = await _vendorDoc.collection('products').get();
    Map<String, double> productPrices = {};
    for (var doc in productsSnapshot.docs) {
      productPrices[doc.id] = (doc.get('pricePerUnit') ?? 0.0).toDouble();
    }

    final subscriptionsSnapshot = await _vendorDoc.collection('subscriptions').get();
    Map<String, String> subToProduct = {};
    for (var doc in subscriptionsSnapshot.docs) {
      subToProduct[doc.id] = doc.get('productId');
    }

    // 3. Calculate total
    double totalAmount = 0;
    Map<String, int> productQuantities = {};

    for (var entry in deliveredEntries) {
      String? productId = subToProduct[entry.subscriptionId];
      if (productId != null) {
        double price = productPrices[productId] ?? 0.0;
        totalAmount += entry.quantity * price;
        productQuantities[productId] = (productQuantities[productId] ?? 0) + entry.quantity;
      }
    }

    final bill = BillModel(
      id: '',
      customerId: customerId,
      monthYear: monthYear,
      totalAmount: totalAmount,
      details: {'quantities': productQuantities},
    );

    // 4. Save to Firestore
    await _vendorBills.add(bill.toJson());
  }
}
