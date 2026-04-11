import 'package:flutter/material.dart';
import 'package:p_v_j/core/constants/app_colors.dart';
import 'package:p_v_j/core/constants/app_styles.dart';

class CatalogHeader extends StatelessWidget {
  final int activeProducts;
  
  const CatalogHeader({super.key, required this.activeProducts});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Catalog",
                style: AppStyles.displayLg(context).copyWith(fontSize: 40),
              ),
              const SizedBox(height: 4),
              Text(
                "Manage your daily fresh inventory and pricing.",
                style: AppStyles.bodyMd(context).copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        
        // Stats Grid
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              _buildStatCard(
                context, 
                "Active Products", 
                "$activeProducts", 
                Icons.inventory_2_outlined, 
                AppColors.primary,
                isPrimary: true,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                context, 
                "Top Performer", 
                "Full Cream Milk", 
                Icons.trending_up, 
                AppColors.primary,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                context, 
                "Low Stock", 
                "3 Items", 
                Icons.warning_amber_rounded, 
                Colors.orange,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, 
    String label, 
    String value, 
    IconData icon, 
    Color color,
    {bool isPrimary = false}
  ) {
    return Container(
      width: 160,
      height: 160,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.primary : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(32),
        boxShadow: isPrimary ? AppStyles.ambientShadow : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            icon, 
            color: isPrimary ? Colors.white : color, 
            size: 32
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: AppStyles.labelSmall(context).copyWith(
                  color: isPrimary ? Colors.white.withOpacity(0.7) : AppColors.onSurfaceVariant,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w800,
                  fontSize: 8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.headlineSm(context).copyWith(
                  color: isPrimary ? Colors.white : AppColors.onSurface,
                  fontSize: 18,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
