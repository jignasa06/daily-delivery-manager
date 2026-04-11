import 'package:p_v_j/features/vendor/customers/data/models/customer_model.dart';

abstract class ICustomerRepository {
  Stream<List<CustomerModel>> getCustomers();
  Future<void> addCustomer(CustomerModel customer);
  Future<void> updateCustomer(CustomerModel customer);
  Future<void> deleteCustomer(String customerId);
}
