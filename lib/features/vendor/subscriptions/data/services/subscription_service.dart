import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '/core/services/auth_service.dart';
import '../models/subscription_model.dart';
import '/core/utils/snackbar_utils.dart';

class SubscriptionService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();

  CollectionReference get _vendorSubscriptions {
    String? uid = _authService.firebaseUser.value?.uid;
    if (uid == null) throw Exception('User not logged in');
    return _firestore
        .collection('vendors')
        .doc(uid)
        .collection('subscriptions');
  }

  Stream<List<SubscriptionModel>> getSubscriptions() {
    String? uid = _authService.firebaseUser.value?.uid;
    if (uid == null) return Stream.value([]);

    return _firestore
        .collection('vendors')
        .doc(uid)
        .collection('subscriptions')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SubscriptionModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> addSubscription(SubscriptionModel sub) async {
    try {
      await _vendorSubscriptions.add(sub.toJson());
      SnackbarUtils.showSuccess('Subscription linked successfully');
    } catch (e) {
      SnackbarUtils.showError(e.toString());
    }
  }

  Future<void> updateSubscription(SubscriptionModel sub) async {
    try {
      await _vendorSubscriptions.doc(sub.id).update(sub.toJson());
      SnackbarUtils.showSuccess('Subscription updated successfully');
    } catch (e) {
      SnackbarUtils.showError(e.toString());
    }
  }

  Future<void> deleteSubscription(String subId) async {
    try {
      await _vendorSubscriptions.doc(subId).delete();
      SnackbarUtils.showSuccess('Subscription deleted successfully');
    } catch (e) {
      SnackbarUtils.showError(e.toString());
    }
  }
}
