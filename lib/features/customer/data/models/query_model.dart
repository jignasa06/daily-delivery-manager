import 'package:cloud_firestore/cloud_firestore.dart';

class QueryModel {
  final String id;
  final String customerId;
  final String customerName;
  final String vendorId;
  final DateTime deliveryDate;
  final String message;
  final String status; // 'Open', 'Resolved'
  final DateTime createdAt;

  QueryModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.vendorId,
    required this.deliveryDate,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  factory QueryModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return QueryModel(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? 'Customer',
      vendorId: data['vendorId'] ?? '',
      deliveryDate: (data['deliveryDate'] as Timestamp).toDate(),
      message: data['message'] ?? '',
      status: data['status'] ?? 'Open',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'vendorId': vendorId,
      'deliveryDate': Timestamp.fromDate(deliveryDate),
      'message': message,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
