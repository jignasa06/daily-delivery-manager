import 'package:cloud_firestore/cloud_firestore.dart';

class BillModel {
  String id;
  String customerId;
  String monthYear; // "YYYY-MM" format
  double totalAmount;
  Map<String, dynamic> details;

  BillModel({
    required this.id,
    required this.customerId,
    required this.monthYear,
    required this.totalAmount,
    required this.details,
  });

  factory BillModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return BillModel(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      monthYear: data['monthYear'] ?? '',
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      details: data['details'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'monthYear': monthYear,
      'totalAmount': totalAmount,
      'details': details,
    };
  }
}
