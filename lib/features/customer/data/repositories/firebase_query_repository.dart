import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:p_v_j/features/customer/data/models/query_model.dart';
import 'package:p_v_j/features/customer/domain/repositories/i_query_repository.dart';
import 'package:p_v_j/core/utils/snackbar_utils.dart';

class FirebaseQueryRepository implements IQueryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String vendorId;

  FirebaseQueryRepository({required this.vendorId});

  CollectionReference get _queries => 
      _firestore.collection('vendors').doc(vendorId).collection('queries');

  @override
  Future<void> submitQuery(QueryModel query) async {
    try {
      await _queries.add(query.toJson());
      SnackbarUtils.showSuccess('Report submitted. We will look into it.');
    } catch (e) {
      SnackbarUtils.showError(e.toString());
      rethrow;
    }
  }

  @override
  Stream<List<QueryModel>> getCustomerQueries(String customerId) {
    return _queries
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => QueryModel.fromFirestore(doc)).toList();
    });
  }

  @override
  Stream<List<QueryModel>> getAllQueries() {
    return _queries.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => QueryModel.fromFirestore(doc)).toList();
    });
  }

  @override
  Future<void> resolveQuery(String queryId) async {
    try {
      await _queries.doc(queryId).update({'status': 'Resolved'});
      SnackbarUtils.showSuccess('Issue marked as resolved');
    } catch (e) {
      SnackbarUtils.showError(e.toString());
      rethrow;
    }
  }
}
