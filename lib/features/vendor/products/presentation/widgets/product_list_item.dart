import 'package:flutter/material.dart';
import 'package:p_v_j/features/vendor/products/data/models/product_model.dart';
import 'package:p_v_j/core/constants/app_colors.dart';
import 'package:p_v_j/core/constants/app_styles.dart';

class ProductListItem extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  const ProductListItem({
    super.key,
    required this.product,
    required this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              image: product.imageUrl != null 
                ? DecorationImage(
                    image: NetworkImage(product.imageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
            ),
            child: product.imageUrl == null 
              ? Icon(Icons.inventory_2_outlined, color: AppColors.primary.withOpacity(0.4))
              : null,
          ),
          const SizedBox(width: 20),
          
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: AppStyles.headlineSm(context).copyWith(fontSize: 18),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.category_outlined, size: 12, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      product.category ?? "General",
                      style: AppStyles.bodySm(context).copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Price & Edit
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "\$${product.pricePerUnit.toStringAsFixed(2)}",
                style: AppStyles.displayLg(context).copyWith(
                  fontSize: 20, 
                  color: AppColors.primary,
                  height: 1,
                ),
              ),
              Text(
                product.unit.toUpperCase(),
                style: AppStyles.labelSmall(context).copyWith(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit_outlined, size: 16, color: AppColors.onSurface),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
