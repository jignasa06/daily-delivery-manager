import 'package:p_v_j/features/vendor/products/data/models/product_model.dart';

abstract class IProductRepository {
  Stream<List<ProductModel>> getProducts();
  Future<void> addProduct(ProductModel product);
  Future<void> updateProduct(ProductModel product);
  Future<void> deleteProduct(String productId);
}
