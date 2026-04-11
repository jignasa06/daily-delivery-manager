import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller/product_controller.dart';
import '../widgets/catalog_header.dart';
import '../widgets/product_list_item.dart';
import '/core/constants/app_colors.dart';
import '/core/constants/app_styles.dart';
import '/core/widgets/common_text_field.dart';

class ProductsScreen extends StatelessWidget {
  ProductsScreen({super.key});

  final ProductController controller = Get.put(ProductController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Inherit from Dashboard background
      body: Stack(
        children: [
          Obx(() {
            if (controller.products.isEmpty) {
              return _buildEmptyState(context);
            }
            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 120), // Space for FAB and Nav
              itemCount: controller.products.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return CatalogHeader(activeProducts: controller.products.length);
                }
                final product = controller.products[index - 1];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ProductListItem(
                    product: product,
                    onEdit: () => _showProductDialog(context, product),
                  ),
                );
              },
            );
          }),
          
          // FAB
          Positioned(
            bottom: 32,
            right: 24,
            child: GestureDetector(
              onTap: () => _showProductDialog(context),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 80,
                color: AppColors.primary.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "Your Catalog is Empty",
              style: AppStyles.displayLg(context).copyWith(fontSize: 24),
            ),
            const SizedBox(height: 12),
            Text(
              "Define your product inventory to start managing deliveries and subscriptions.",
              textAlign: TextAlign.center,
              style: AppStyles.bodyMd(context).copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => _showProductDialog(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
              child: const Text("CREATE FIRST PRODUCT"),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductDialog(BuildContext context, [product]) {
    controller.openForm(product);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 32,
            right: 32,
            top: 32,
          ),
          child: Form(
            key: controller.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product == null ? 'New Product' : 'Edit Product',
                  style: AppStyles.headlineSm(context).copyWith(fontSize: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  "Enter product details accurately for your catalog.",
                  style: AppStyles.bodySm(context),
                ),
                const SizedBox(height: 32),
                CommonTextField(
                  controller: controller.nameController,
                  hint: 'Product Name (e.g. Buffalo Milk)',
                  icon: Icons.label_outline,
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                CommonTextField(
                  controller: controller.unitController,
                  hint: 'Unit (e.g. 1L Bottle, 500g)',
                  icon: Icons.straighten_outlined,
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                CommonTextField(
                  controller: controller.priceController,
                  hint: 'Price per Unit',
                  icon: Icons.attach_money,
                  isNumber: true,
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: controller.saveProduct,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('SAVE PRODUCT'),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}
