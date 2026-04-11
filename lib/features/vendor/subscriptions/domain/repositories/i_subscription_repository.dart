import '../../data/models/subscription_model.dart';

abstract class ISubscriptionRepository {
  Stream<List<SubscriptionModel>> getSubscriptions();
  Future<void> addSubscription(SubscriptionModel sub);
  Future<void> updateSubscription(SubscriptionModel sub);
  Future<void> deleteSubscription(String id);
}
