import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:p_v_j/features/vendor/dashboard/data/models/vendor_model.dart';
import 'package:p_v_j/features/vendor/dashboard/domain/repositories/i_vendor_repository.dart';

class FirebaseVendorRepository implements IVendorRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<VendorModel?> getVendorInfo(String vendorId) {
    return _firestore
        .collection('vendors')
        .doc(vendorId)
        .snapshots()
        .map((doc) => doc.exists ? VendorModel.fromFirestore(doc) : null);
  }

  @override
  Future<void> updateVendorProfile(String vendorId, Map<String, dynamic> data) async {
    await _firestore.collection('vendors').doc(vendorId).update(data);
  }
}
