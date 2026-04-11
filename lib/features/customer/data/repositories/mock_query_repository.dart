import 'package:p_v_j/features/customer/data/models/query_model.dart';
import 'package:p_v_j/features/customer/domain/repositories/i_query_repository.dart';

class MockQueryRepository implements IQueryRepository {
  final List<QueryModel> _queries = [
    QueryModel(
      id: 'q_1',
      customerId: 'cust_1',
      customerName: 'Rahul Sharma',
      vendorId: 'vendor_1',
      deliveryDate: DateTime.now().subtract(const Duration(days: 1)),
      message: 'Milk packet was slightly leaked today.',
      status: 'Pending',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    QueryModel(
      id: 'q_2',
      customerId: 'cust_2',
      customerName: 'Priya Verma',
      vendorId: 'vendor_1',
      deliveryDate: DateTime.now().subtract(const Duration(days: 2)),
      message: 'Need to add extra curd for tomorrow.',
      status: 'Resolved',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  Future<void> submitQuery(QueryModel query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _queries.add(query);
  }

  @override
  Stream<List<QueryModel>> getCustomerQueries(String customerId) {
    return Stream.value(_queries.where((q) => q.customerId == customerId).toList());
  }

  @override
  Stream<List<QueryModel>> getAllQueries() {
    return Stream.value(_queries);
  }

  @override
  Future<void> resolveQuery(String queryId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _queries.indexWhere((q) => q.id == queryId);
    if (index != -1) {
      _queries[index] = QueryModel(
        id: _queries[index].id,
        customerId: _queries[index].customerId,
        customerName: _queries[index].customerName,
        vendorId: _queries[index].vendorId,
        deliveryDate: _queries[index].deliveryDate,
        message: _queries[index].message,
        status: 'Resolved',
        createdAt: _queries[index].createdAt,
      );
    }
  }
}
