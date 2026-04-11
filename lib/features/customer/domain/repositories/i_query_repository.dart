import 'package:p_v_j/features/customer/data/models/query_model.dart';

abstract class IQueryRepository {
  Future<void> submitQuery(QueryModel query);
  Stream<List<QueryModel>> getCustomerQueries(String customerId);
  Stream<List<QueryModel>> getAllQueries();
  Future<void> resolveQuery(String queryId);
}
