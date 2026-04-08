import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller/product_controller.dart';
import '/core/constants/app_colors.dart';
import '/core/widgets/common_text_field.dart';

import 'package:p_v_j/features/vendor/dashboard/presentation/widgets/setup_progress_widget.dart';

class ProductsScreen extends StatelessWidget {
  ProductsScreen({super.key});

  final ProductController controller = Get.put(ProductController());

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SetupProgressWidget(),
        Expanded(
          child: Obx(() {
            if (controller.products.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          size: 80,
                          color: AppColors.primary.withValues(alpha: 0.2)),
                      const SizedBox(height: 24),
                      const Text(
                        "No Products Yet",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Before you can add customers or subscriptions, you need to define what you're selling.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () => _showProductDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text("Add My First Product",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Stack(
              children: [
                ListView.builder(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.products.length,
                  itemBuilder: (context, index) {
                    final product = controller.products[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const CircleAvatar(
                            backgroundColor: AppColors.primaryLight,
                            child: Icon(Icons.inventory_2,
                                color: AppColors.primary)),
                        title: Text(product.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle:
                            Text("${product.pricePerUnit} / ${product.unit}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: AppColors.error),
                          onPressed: () => controller.deleteProduct(product.id),
                        ),
                        onTap: () => _showProductDialog(context, product),
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    backgroundColor: AppColors.primary,
                    onPressed: () => _showProductDialog(context),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                )
              ],
            );
          }),
        ),
      ],
    );
  }

  void _showProductDialog(BuildContext context, [product]) {
    controller.openForm(product);
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24),
            child: Form(
              key: controller.formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product == null ? 'Add Product' : 'Edit Product',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  CommonTextField(
                    controller: controller.nameController,
                    hint: 'Product Name (e.g. Buffalo Milk)',
                    icon: Icons.label_outline,
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  CommonTextField(
                    controller: controller.unitController,
                    hint: 'Unit (e.g. Liter, Pkt)',
                    icon: Icons.straighten_outlined,
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  CommonTextField(
                    controller: controller.priceController,
                    hint: 'Price per Unit',
                    icon: Icons.currency_rupee,
                    isNumber: true,
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      onPressed: controller.saveProduct,
                      child: const Text('Save',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        });
  }
}
