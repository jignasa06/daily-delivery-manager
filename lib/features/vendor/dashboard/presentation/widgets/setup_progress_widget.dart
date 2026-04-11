import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/core/constants/app_colors.dart';
import '/core/constants/app_styles.dart';
import '/core/utils/responsive_helper.dart';
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.indigoPrimary.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 20,
              offset: const Offset(0, 8),
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
                      Text(
                        'Setup in Progress',
                        style: AppStyles.dashboardSubheading(context),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        nextAction['hint']!,
                        style: AppStyles.premiumCardBody(context).copyWith(fontSize: context.sp(12)),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: AppStyles.dashboardHeading(context).copyWith(
                      color: AppColors.indigoPrimary,
                      fontSize: context.sp(18)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.surfaceCloud,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.indigoPrimary),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: nextAction['onTap'] as VoidCallback,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.indigoPrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(nextAction['icon'] as IconData,
                        size: 16, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      nextAction['action']!,
                      style: AppStyles.premiumButton(context),
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
    if (controller.totalCustomers > 0) count++;
    if (controller.totalSubscriptions > 0) count++;
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
    } else if (controller.totalCustomers == 0) {
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
