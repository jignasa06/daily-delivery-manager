import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '/core/services/auth_service.dart';
import '../models/product_model.dart';
import '/core/utils/snackbar_utils.dart';

class ProductService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();

  CollectionReference get _vendorProducts {
    String? uid = _authService.firebaseUser.value?.uid;
    if (uid == null) throw Exception('User not logged in');
    return _firestore.collection('vendors').doc(uid).collection('products');
  }

  Stream<List<ProductModel>> getProducts() {
    return _vendorProducts.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> addProduct(ProductModel product) async {
    try {
      await _vendorProducts.add(product.toJson());
      SnackbarUtils.showSuccess('Product added successfully');
    } catch (e) {
      SnackbarUtils.showError(e.toString());
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      await _vendorProducts.doc(product.id).update(product.toJson());
      SnackbarUtils.showSuccess('Product updated successfully');
    } catch (e) {
      SnackbarUtils.showError(e.toString());
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _vendorProducts.doc(productId).delete();
      SnackbarUtils.showSuccess('Product deleted successfully');
    } catch (e) {
      SnackbarUtils.showError(e.toString());
    }
  }
}
