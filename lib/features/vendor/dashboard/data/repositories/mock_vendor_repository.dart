import 'dart:async';
import '../../data/models/vendor_model.dart';
import '../../domain/repositories/i_vendor_repository.dart';

class MockVendorRepository implements IVendorRepository {
  @override
  Stream<VendorModel?> getVendorInfo(String vendorId) {
    return Stream.value(VendorModel(
      id: vendorId,
      businessName: 'Indigo Premium Dairy',
      email: 'contact@indigodairy.com',
      phone: '+91 98765 43210',
      address: 'Near City Park, Sector 15, Chandigarh',
      isProfileSetup: true,
      createdAt: DateTime.now(),
    ));
  }

  @override
  Future<void> updateVendorProfile(String vendorId, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
