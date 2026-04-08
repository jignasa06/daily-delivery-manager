import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:p_v_j/core/services/auth_service.dart';
import 'package:p_v_j/features/customer/data/models/query_model.dart';
import 'package:p_v_j/core/utils/snackbar_utils.dart';

class QueryService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();

  CollectionReference get _queries {
    String vendorId = _authService.currentVendorId.value;
    if (vendorId.isEmpty) throw Exception('Vendor not identified');
    return _firestore.collection('vendors').doc(vendorId).collection('queries');
  }

  Future<void> submitQuery(QueryModel query) async {
    try {
      await _queries.add(query.toJson());
      SnackbarUtils.showSuccess('Report submitted. We will look into it.');
    } catch (e) {
      SnackbarUtils.showError(e.toString());
    }
  }

  Stream<List<QueryModel>> getCustomerQueries(String customerId) {
    return _queries
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => QueryModel.fromFirestore(doc)).toList();
    });
  }

  Stream<List<QueryModel>> getAdminQueries() {
    return _queries.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => QueryModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> resolveQuery(String queryId) async {
    try {
      await _queries.doc(queryId).update({'status': 'Resolved'});
      SnackbarUtils.showSuccess('Issue marked as resolved');
    } catch (e) {
      SnackbarUtils.showError(e.toString());
    }
  }
}
