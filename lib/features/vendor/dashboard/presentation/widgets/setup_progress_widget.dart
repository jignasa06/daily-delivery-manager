import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_v_j/core/constants/app_colors.dart';
import '../screens/controller/dashboard_controller.dart';

class SetupProgressWidget extends StatelessWidget {
  const SetupProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find<DashboardController>();

    return Obx(() {
      if (controller.isSetupComplete) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 5))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Getting Started', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    Text('Complete these steps to start billing', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
                Text('${_getCompletedSteps(controller)}/3', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 20),
            _buildStep(
              0, 'Add your first Product', 
              controller.totalProducts.value > 0, 
              Icons.inventory_2_outlined,
              () => controller.changePage(0)
            ),
            _buildStep(
              1, 'Create a Customer', 
              controller.totalCustomers.value > 0, 
              Icons.people_outline,
              () => controller.changePage(1)
            ),
            _buildStep(
              2, 'Set up a Subscription', 
              controller.totalSubscriptions.value > 0, 
              Icons.sync_alt,
              () => controller.changePage(2)
            ),
          ],
        ),
      );
    });
  }

  int _getCompletedSteps(DashboardController controller) {
    int count = 0;
    if (controller.totalProducts.value > 0) count++;
    if (controller.totalCustomers.value > 0) count++;
    if (controller.totalSubscriptions.value > 0) count++;
    return count;
  }

  Widget _buildStep(int index, String title, bool isDone, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: isDone ? AppColors.success.withValues(alpha: 0.1) : AppColors.surfaceOffWhite,
              child: Icon(isDone ? Icons.check : icon, size: 18, color: isDone ? AppColors.success : AppColors.textHint),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title, 
                style: TextStyle(
                  fontSize: 14, 
                  fontWeight: isDone ? FontWeight.normal : FontWeight.bold,
                  color: isDone ? AppColors.textHint : AppColors.textMain,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                )
              ),
            ),
            if (!isDone) 
              const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
