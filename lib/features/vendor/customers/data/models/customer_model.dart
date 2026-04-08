import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  String id;
  String name;
  String phone;
  String address;
  String email;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.email,
  });

  factory CustomerModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return CustomerModel(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      email: data['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'email': email,
    };
  }
}
