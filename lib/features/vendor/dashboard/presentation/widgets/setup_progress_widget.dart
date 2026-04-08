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

      final completedSteps = _getCompletedSteps(controller);
      final progress = completedSteps / 3.0;
      final nextAction = _getNextAction(controller);

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.85)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Setup in Progress',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        nextAction['hint']!,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: nextAction['onTap'] as VoidCallback,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(nextAction['icon'] as IconData,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      nextAction['action']!,
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
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

  Map<String, dynamic> _getNextAction(DashboardController controller) {
    if (controller.totalProducts.value == 0) {
      return {
        'hint': 'Add your products to begin.',
        'action': 'Add My First Product',
        'icon': Icons.inventory_2_outlined,
        'onTap': () => controller.changePage(0),
      };
    } else if (controller.totalCustomers.value == 0) {
      return {
        'hint': 'Great! Now register your customers.',
        'action': 'Create First Customer',
        'icon': Icons.people_outline,
        'onTap': () => controller.changePage(1),
      };
    } else {
      return {
        'hint': 'Final step: Set up their subscriptions.',
        'action': 'Setup Subscriptions',
        'icon': Icons.sync_alt,
        'onTap': () => controller.changePage(2),
      };
    }
  }
}
