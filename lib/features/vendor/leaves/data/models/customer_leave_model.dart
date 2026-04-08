import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerLeaveModel {
  final String id;
  final String customerId;
  final String customerName;
  final String vendorId;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'Pending', 'Approved', 'Rejected'
  final String reason;
  final DateTime createdAt;

  CustomerLeaveModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.vendorId,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.reason = '',
    required this.createdAt,
  });

  factory CustomerLeaveModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return CustomerLeaveModel(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? 'Customer',
      vendorId: data['vendorId'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'Pending',
      reason: data['reason'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'vendorId': vendorId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'status': status,
      'reason': reason,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
