import 'package:cloud_firestore/cloud_firestore.dart';

class DailyEntryModel {
  String id;
  String customerId;
  String subscriptionId;
  DateTime date;
  int quantity;
  bool isDelivered;

  DailyEntryModel({
    required this.id,
    required this.customerId,
    required this.subscriptionId,
    required this.date,
    required this.quantity,
    required this.isDelivered,
  });

  factory DailyEntryModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return DailyEntryModel(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      subscriptionId: data['subscriptionId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      quantity: data['quantity'] ?? 0,
      isDelivered: data['isDelivered'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'subscriptionId': subscriptionId,
      'date': Timestamp.fromDate(date),
      'quantity': quantity,
      'isDelivered': isDelivered,
    };
  }
}
