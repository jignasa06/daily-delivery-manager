import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionModel {
  String id;
  String customerId;
  String productId;
  DateTime startDate;
  DateTime? endDate;
  List<String> selectedDays; // e.g., ['Monday', 'Wednesday']
  int defaultQuantity;
  String unit; // e.g., 'Ltr', 'Pkt'
  String subscriptionType; // e.g., 'monthly', 'custom', 'on-demand'

  SubscriptionModel({
    required this.id,
    required this.customerId,
    required this.productId,
    required this.startDate,
    this.endDate,
    required this.selectedDays,
    required this.defaultQuantity,
    this.unit = 'Pkt',
    required this.subscriptionType,
  });

  factory SubscriptionModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return SubscriptionModel(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      productId: data['productId'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: data['endDate'] != null ? (data['endDate'] as Timestamp).toDate() : null,
      selectedDays: List<String>.from(data['selectedDays'] ?? []),
      defaultQuantity: data['defaultQuantity'] ?? 1,
      unit: data['unit'] ?? 'Pkt',
      subscriptionType: data['subscriptionType'] ?? 'monthly',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'productId': productId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'selectedDays': selectedDays,
      'defaultQuantity': defaultQuantity,
      'unit': unit,
      'subscriptionType': subscriptionType,
    };
  }
}
