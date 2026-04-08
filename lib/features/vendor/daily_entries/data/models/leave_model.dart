import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveModel {
  String id;
  String targetId; // could be customerId or vendorId (if globally true)
  DateTime startDate;
  DateTime endDate;
  String type; // 'customer' or 'vendor'

  LeaveModel({
    required this.id,
    required this.targetId,
    required this.startDate,
    required this.endDate,
    required this.type,
  });

  factory LeaveModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return LeaveModel(
      id: doc.id,
      targetId: data['targetId'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      type: data['type'] ?? 'customer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'targetId': targetId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'type': type,
    };
  }
}
