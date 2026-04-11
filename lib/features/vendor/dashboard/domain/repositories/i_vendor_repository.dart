import 'package:p_v_j/features/vendor/dashboard/data/models/vendor_model.dart';

abstract class IVendorRepository {
  Stream<VendorModel?> getVendorInfo(String vendorId);
  Future<void> updateVendorProfile(String vendorId, Map<String, dynamic> data);
}
