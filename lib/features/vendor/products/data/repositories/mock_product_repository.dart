import 'dart:async';
import 'package:p_v_j/features/vendor/products/data/models/product_model.dart';
import '../../domain/repositories/i_product_repository.dart';

class MockProductRepository implements IProductRepository {
  final _productsController = StreamController<List<ProductModel>>.broadcast();
  
  // Dummy Initial Data from Stitch Reference UI
  final List<ProductModel> _dummyProducts = [
    ProductModel(
      id: "1",
      name: "Full Cream Milk",
      pricePerUnit: 4.50,
      unit: "1L Bottle",
      category: "Dairy & Eggs",
      imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuAIFu6k7TrD_NLJLSdhZSHLg4V0kRftOMKX5epoWRq5H0jIAqgE1MuiCXPWCxeiO8hndoLXxZxmGFjNsZ353IrvwsvO1_t9rrK25YXyKSBkdL2HoZimg1kx9W8csecMlW4rPHkDCSNjzsNOvMSDNzw-D85dyLljKeOiSuxemkWOLSey5hDi4rVryuW-41PVwctdZynH4tssiOCDxDKi-b6xT7NC-Qj0CfORhBSXZNrziblrJnZ0IDtPI3e8aBtcJGY_Udq0FGkrGNBM",
    ),
    ProductModel(
      id: "2",
      name: "Buttermilk",
      pricePerUnit: 3.25,
      unit: "500ml Unit",
      category: "Traditional Dairy",
      imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuBxyMMJBL8CICp-WTF97mCdsEW65nolrfghj8TbuwffVSvJ_wiMePfmBCgc-ZJB5JAZ_v_6BDx6vTLwSzAsHJxRttBryGxRs6EpkqYO36oqVpCUpp2ZIUDuK5PkLhasCfNmXsTQqFXu_t38bKrIlQ2GToddRXIsNtj8SBHIxigO8uG2j4_653-BXz9QoyZlq6qmBRGM6_aqo6AZ1FlPzJY2ePBxs62-xMrboTLEYYTYswwfbyeZ23mAbORcMOYk9yjDiN_2JN_-a9Ns",
    ),
    ProductModel(
      id: "3",
      name: "Orange Juice",
      pricePerUnit: 5.90,
      unit: "750ml Unit",
      category: "Beverages",
      imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuD0M4WjSxgUQdgyljrDqVeFUUEh4CAu3KJBPCtpUM7LAVYybN6wAUAHBmUIyq175bcXzQZutuHxnpvgS4AfiJen4MLjfUcGUXqvlPx_pR2sDQdKBWAwL8dWr-jcS7hx-Ce1fG4JUeIOTsgMqf4Kcmuv1xMf5E0z_Pc1JvUWNokzJz1RK9_HL0f7oKq2MvyTBGSxAZKk7dYk6P3F10XnTXksIO9foLr_MmTuccM0z_mHgTWNEDJ0oD6jaUaEuCf1q6Qu3f_cuPZow6hH",
    ),
    ProductModel(
      id: "4",
      name: "Apple Juice",
      pricePerUnit: 5.50,
      unit: "1L Unit",
      category: "Beverages",
      imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuD0YAdI1b9MBOQZSHqIgjmjUb3emC9ITCfZ3WeJiliQ5luZjBQIjfm1KXwRoAAmN9dvOF6Lf_G43g9UCGhLvD6Qw4_PT_r5COABspGGYAJej5-dbAVTcHJnHC1O9uGmXF2GnrUVUplJzwaqWOlraXpqYUFEDQzTuDV3d1RG7MnZA5f84tieDJgKYJTnyNG1uoJrqQYvxkG1TaInY6Kg3Z0RLBR5zD0H1ow1xlsZW8DVXfRwWWCUcjWRB-GPRM8ge-Q3kl9LBz2S-Ypd",
    ),
  ];

  @override
  Stream<List<ProductModel>> getProducts() {
    Timer(const Duration(milliseconds: 500), () {
      _productsController.add(_dummyProducts);
    });
    return _productsController.stream;
  }

  @override
  Future<void> addProduct(ProductModel product) async {
    await Future.delayed(const Duration(seconds: 1));
    _dummyProducts.add(product.copyWith(id: DateTime.now().toString()));
    _productsController.add(_dummyProducts);
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    await Future.delayed(const Duration(seconds: 1));
    int index = _dummyProducts.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _dummyProducts[index] = product;
      _productsController.add(_dummyProducts);
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await Future.delayed(const Duration(seconds: 1));
    _dummyProducts.removeWhere((p) => p.id == productId);
    _productsController.add(_dummyProducts);
  }
}
