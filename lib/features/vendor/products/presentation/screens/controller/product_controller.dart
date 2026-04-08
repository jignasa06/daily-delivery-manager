import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/product_service.dart';

class ProductController extends GetxController {
  final ProductService _productService = Get.put(ProductService());
  RxList<ProductModel> products = <ProductModel>[].obs;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final unitController = TextEditingController();
  final priceController = TextEditingController();

  ProductModel? editingProduct;

  @override
  void onInit() {
    super.onInit();
    products.bindStream(_productService.getProducts());
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
        id: editingProduct?.id ?? '', // Service will ignore empty id on insert if handled, but wait, add doesn't pass ID. 
        name: nameController.text.trim(),
        unit: unitController.text.trim(),
        pricePerUnit: double.tryParse(priceController.text.trim()) ?? 0.0,
      );

      if (editingProduct == null) {
        _productService.addProduct(product);
      } else {
        _productService.updateProduct(product);
      }
      Get.back(); // close dialog/bottomsheet
    }
  }

  void deleteProduct(String id) {
    _productService.deleteProduct(id);
  }
}
