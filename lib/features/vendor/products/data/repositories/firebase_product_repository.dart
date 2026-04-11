import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/i_product_repository.dart';
import '../../data/models/product_model.dart';

class FirebaseProductRepository implements IProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String vendorId;

  FirebaseProductRepository({required this.vendorId});

  CollectionReference get _vendorProducts => 
      _firestore.collection('vendors').doc(vendorId).collection('products');

  @override
  Stream<List<ProductModel>> getProducts() {
    return _vendorProducts.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Future<void> addProduct(ProductModel product) async {
    await _vendorProducts.add(product.toJson());
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    await _vendorProducts.doc(product.id).update(product.toJson());
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await _vendorProducts.doc(productId).delete();
  }
}
