import 'dart:async';
import '../models/subscription_model.dart';
import '../../domain/repositories/i_subscription_repository.dart';

class MockSubscriptionRepository implements ISubscriptionRepository {
  final _subscriptionsController = StreamController<List<SubscriptionModel>>.broadcast();
  
  final List<SubscriptionModel> _dummySubscriptions = [
    SubscriptionModel(
      id: 'sub_1',
      customerId: 'cust_1',
      productId: 'prod_1', // Milk
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      selectedDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
      defaultQuantity: 2,
      subscriptionType: 'Daily',
    ),
    SubscriptionModel(
      id: 'sub_2',
      customerId: 'cust_2',
      productId: 'prod_2', // Bread
      startDate: DateTime.now().subtract(const Duration(days: 15)),
      selectedDays: ['Monday', 'Wednesday', 'Friday'],
      defaultQuantity: 1,
      subscriptionType: 'Alternate',
    ),
  ];

  @override
  Stream<List<SubscriptionModel>> getSubscriptions() {
    Timer(const Duration(milliseconds: 300), () {
      _subscriptionsController.add(_dummySubscriptions);
    });
    return _subscriptionsController.stream;
  }

  @override
  Future<void> addSubscription(SubscriptionModel sub) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newSub = SubscriptionModel(
      id: 'sub_${_dummySubscriptions.length + 1}',
      customerId: sub.customerId,
      productId: sub.productId,
      startDate: sub.startDate,
      endDate: sub.endDate,
      selectedDays: sub.selectedDays,
      defaultQuantity: sub.defaultQuantity,
      subscriptionType: sub.subscriptionType,
    );
    _dummySubscriptions.add(newSub);
    _subscriptionsController.add(_dummySubscriptions);
  }

  @override
  Future<void> updateSubscription(SubscriptionModel sub) async {
    await Future.delayed(const Duration(milliseconds: 500));
    int index = _dummySubscriptions.indexWhere((s) => s.id == sub.id);
    if (index != -1) {
      _dummySubscriptions[index] = sub;
      _subscriptionsController.add(_dummySubscriptions);
    }
  }

  @override
  Future<void> deleteSubscription(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _dummySubscriptions.removeWhere((s) => s.id == id);
    _subscriptionsController.add(_dummySubscriptions);
  }
}
