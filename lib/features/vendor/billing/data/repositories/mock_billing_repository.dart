import 'dart:async';
import '../models/bill_model.dart';
import '../../domain/repositories/i_billing_repository.dart';

class MockBillingRepository implements IBillingRepository {
  final _billsController = StreamController<List<BillModel>>.broadcast();
  
  final List<BillModel> _dummyBills = [
    BillModel(
      id: 'bill_1',
      customerId: 'cust_1',
      monthYear: '2024-03',
      totalAmount: 1250.0,
      details: {'quantities': {'prod_1': 30}},
    ),
    BillModel(
      id: 'bill_2',
      customerId: 'cust_2',
      monthYear: '2024-03',
      totalAmount: 540.0,
      details: {'quantities': {'prod_2': 15}},
    ),
  ];

  @override
  Stream<List<BillModel>> getBillsForCustomer(String customerId) {
    Timer(const Duration(milliseconds: 300), () {
      _billsController.add(_dummyBills.where((b) => b.customerId == customerId).toList());
    });
    return _billsController.stream;
  }

  @override
  Future<void> generateMonthlyBill(String customerId, String monthYear) async {
    await Future.delayed(const Duration(seconds: 1));
    final newBill = BillModel(
      id: 'bill_${DateTime.now().millisecondsSinceEpoch}',
      customerId: customerId,
      monthYear: monthYear,
      totalAmount: 980.0, // Mock fixed price
      details: {'quantities': {'mock_prod': 20}},
    );
    _dummyBills.add(newBill);
    _billsController.add(_dummyBills.where((b) => b.customerId == customerId).toList());
  }
}
