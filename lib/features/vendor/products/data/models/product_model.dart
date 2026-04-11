import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String unit; 
  final double pricePerUnit;
  final String? category;
  final String? imageUrl;

  ProductModel({
    required this.id,
    required this.name,
    required this.unit,
    required this.pricePerUnit,
    this.category,
    this.imageUrl,
  });

  ProductModel copyWith({
    String? id,
    String? name,
    String? unit,
    double? pricePerUnit,
    String? category,
    String? imageUrl,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      unit: data['unit'] ?? '',
      pricePerUnit: (data['pricePerUnit'] ?? 0.0).toDouble(),
      category: data['category'],
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'unit': unit,
      'pricePerUnit': pricePerUnit,
      'category': category,
      'imageUrl': imageUrl,
    };
  }
}
