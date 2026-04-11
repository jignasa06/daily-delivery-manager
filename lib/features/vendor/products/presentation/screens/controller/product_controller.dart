import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/product_model.dart';
import '../../../domain/repositories/i_product_repository.dart';

class ProductController extends GetxController {
  // --- REPOSITORY INJECTION (Backend Agnostic) ---
  final IProductRepository _productRepository = Get.find<IProductRepository>();
  
  RxList<ProductModel> products = <ProductModel>[].obs;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final unitController = TextEditingController();
  final priceController = TextEditingController();

  ProductModel? editingProduct;

  @override
  void onInit() {
    super.onInit();
    // Bind stream from repository (could be Firebase or Mock)
    products.bindStream(_productRepository.getProducts());
  }

  void openForm([ProductModel? product]) {
    editingProduct = product;
    if (product != null) {
      nameController.text = product.name;
      unitController.text = product.unit;
      priceController.text = product.pricePerUnit.toString();
    } else {
      nameController.clear();
      unitController.clear();
      priceController.clear();
    }
  }

  void saveProduct() {
    if (formKey.currentState!.validate()) {
      final product = ProductModel(
        id: editingProduct?.id ?? '', 
        name: nameController.text.trim(),
        unit: unitController.text.trim(),
        pricePerUnit: double.tryParse(priceController.text.trim()) ?? 0.0,
      );

      if (editingProduct == null) {
        _productRepository.addProduct(product);
      } else {
        _productRepository.updateProduct(product);
      }
      Get.back(); // close dialog/bottomsheet
    }
  }

  void deleteProduct(String id) {
    _productRepository.deleteProduct(id);
  }
}
