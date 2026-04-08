import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  String id;
  String name;
  String unit; // e.g., 'liter', 'packet', 'quantity'
  double pricePerUnit;

  ProductModel({
    required this.id,
    required this.name,
    required this.unit,
    required this.pricePerUnit,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      unit: data['unit'] ?? '',
      pricePerUnit: (data['pricePerUnit'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'unit': unit,
      'pricePerUnit': pricePerUnit,
    };
  }
}
