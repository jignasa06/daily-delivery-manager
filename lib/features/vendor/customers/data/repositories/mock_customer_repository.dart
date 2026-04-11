import 'package:p_v_j/features/vendor/customers/data/models/customer_model.dart';
import 'package:p_v_j/features/vendor/customers/domain/repositories/i_customer_repository.dart';

class MockCustomerRepository implements ICustomerRepository {
  final List<CustomerModel> _dummyCustomers = [
    CustomerModel(
      id: 'cust_1',
      name: 'Rahul Sharma',
      phone: '+91 91234 56789',
      address: 'Apt 4B, Skyview Towers, Mohali',
      email: 'rahul@example.com',
    ),
    CustomerModel(
      id: 'cust_2',
      name: 'Priya Verma',
      phone: '+91 98765 43210',
      address: 'H-12, Sector 22, Chandigarh',
      email: 'priya@example.com',
    ),
    CustomerModel(
      id: 'cust_3',
      name: 'Amit Patel',
      phone: '+91 99887 76655',
      address: 'Flat 201, Green Meadows, Zirakpur',
      email: 'amit@example.com',
    ),
  ];

  @override
  Stream<List<CustomerModel>> getCustomers() {
    return Stream.value(_dummyCustomers);
  }

  @override
  Future<void> addCustomer(CustomerModel customer) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _dummyCustomers.add(customer);
  }

  @override
  Future<void> updateCustomer(CustomerModel customer) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _dummyCustomers.indexWhere((c) => c.id == customer.id);
    if (index != -1) {
      _dummyCustomers[index] = customer;
    }
  }

  @override
  Future<void> deleteCustomer(String customerId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _dummyCustomers.removeWhere((c) => c.id == customerId);
  }
}
