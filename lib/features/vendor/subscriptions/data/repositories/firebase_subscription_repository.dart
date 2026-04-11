import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subscription_model.dart';
import '../../domain/repositories/i_subscription_repository.dart';

class FirebaseSubscriptionRepository implements ISubscriptionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String vendorId;

  FirebaseSubscriptionRepository({required this.vendorId});

  CollectionReference get _subscriptions => 
    _firestore.collection('vendors').doc(vendorId).collection('subscriptions');

  @override
  Stream<List<SubscriptionModel>> getSubscriptions() {
    return _subscriptions.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => SubscriptionModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Future<void> addSubscription(SubscriptionModel sub) async {
    await _subscriptions.add(sub.toJson());
  }

  @override
  Future<void> updateSubscription(SubscriptionModel sub) async {
    await _subscriptions.doc(sub.id).update(sub.toJson());
  }

  @override
  Future<void> deleteSubscription(String id) async {
    await _subscriptions.doc(id).delete();
  }
}
