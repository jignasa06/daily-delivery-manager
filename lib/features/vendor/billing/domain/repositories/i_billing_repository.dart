import '../../data/models/bill_model.dart';

abstract class IBillingRepository {
  Stream<List<BillModel>> getBillsForCustomer(String customerId);
  Future<void> generateMonthlyBill(String customerId, String monthYear);
}
