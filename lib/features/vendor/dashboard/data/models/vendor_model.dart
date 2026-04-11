import 'package:cloud_firestore/cloud_firestore.dart';

class VendorModel {
  final String id;
  final String businessName;
  final String email;
  final String phone;
  final String address;
  final String? profileImage;
  final bool isProfileSetup;
  final DateTime? createdAt;

  VendorModel({
    required this.id,
    required this.businessName,
    required this.email,
    required this.phone,
    required this.address,
    this.profileImage,
    this.isProfileSetup = false,
    this.createdAt,
  });

  factory VendorModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return VendorModel(
      id: doc.id,
      businessName: data['businessName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phoneNumber'] ?? '', // Mapping phoneNumber to phone for consistency
      address: data['address'] ?? '',
      profileImage: data['profileImage'],
      isProfileSetup: data['isProfileSetup'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'businessName': businessName,
      'email': email,
      'phoneNumber': phone,
      'address': address,
      'profileImage': profileImage,
      'isProfileSetup': isProfileSetup,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  VendorModel copyWith({
    String? businessName,
    String? email,
    String? phone,
    String? address,
    String? profileImage,
    bool? isProfileSetup,
  }) {
    return VendorModel(
      id: id,
      businessName: businessName ?? this.businessName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profileImage: profileImage ?? this.profileImage,
      isProfileSetup: isProfileSetup ?? this.isProfileSetup,
      createdAt: createdAt,
    );
  }
}
