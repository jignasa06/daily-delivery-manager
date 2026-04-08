import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:p_v_j/core/constants/app_colors.dart';
import 'controller/daily_entry_controller.dart';

class DailyEntryScreen extends StatelessWidget {
  DailyEntryScreen({super.key});

  final DailyEntryController controller = Get.put(DailyEntryController());

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDateSelector(context),
        Expanded(child: _buildEntryList()),
      ],
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.primary),
            onPressed: () => controller.changeDate(controller.selectedDate.value.subtract(const Duration(days: 1))),
          ),
          InkWell(
            onTap: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: controller.selectedDate.value,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) controller.changeDate(picked);
            },
            child: Obx(() => Text(
              DateFormat('EEEE, MMM d, yyyy').format(controller.selectedDate.value),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain),
            )),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppColors.primary),
            onPressed: () => controller.changeDate(controller.selectedDate.value.add(const Duration(days: 1))),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryList() {
    return Obx(() {
      if (controller.isLoadingEntries.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }

      final subs = controller.activeSubscriptionsForDay;
      bool isVendorOnLeave = controller.isOnLeave(null);
      
      if (isVendorOnLeave) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.beach_access, size: 64, color: Colors.orange),
              SizedBox(height: 16),
              Text("Vendor Holiday!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text("No deliveries for anyone today.", style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        );
      }

      if (subs.isEmpty) {
        return const Center(child: Text("No deliveries scheduled for this day.", style: TextStyle(color: AppColors.textSecondary)));
      }

      return ListView.builder(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: subs.length,
        itemBuilder: (context, index) {
          final sub = subs[index];
          
          return Obx(() {
            final entry = controller.getEntryForSubscription(sub);
            bool isCustomerOnLeave = controller.isOnLeave(sub.customerId);
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isCustomerOnLeave ? Colors.grey[100] : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
                border: Border.all(color: entry.isDelivered ? AppColors.success.withValues(alpha: 0.3) : Colors.transparent, width: 2),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Row(
                  children: [
                    Text(controller.getCustomerName(sub.customerId), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isCustomerOnLeave ? Colors.grey : AppColors.textMain)),
                    if (isCustomerOnLeave) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                        child: const Text("ON LEAVE", style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                      )
                    ]
                  ],
                ),
                subtitle: Text("${controller.getProductName(sub.productId)} (${controller.getProductUnit(sub.productId)})"),
                trailing: isCustomerOnLeave ? const Icon(Icons.do_not_disturb_on_outlined, color: Colors.grey) : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(color: AppColors.surfaceOffWhite, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                            icon: const Icon(Icons.remove, size: 20, color: AppColors.textSecondary),
                            onPressed: () => controller.updateQuantity(sub, entry, entry.quantity - 1),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('${entry.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                            icon: const Icon(Icons.add, size: 20, color: AppColors.primary),
                            onPressed: () => controller.updateQuantity(sub, entry, entry.quantity + 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: () => controller.toggleDelivery(sub, entry),
                      borderRadius: BorderRadius.circular(30),
                      child: Obx(() {
                        if (controller.loadingSubId.value == sub.id) {
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(color: AppColors.surfaceOffWhite, shape: BoxShape.circle),
                            width: 48, height: 48,
                            child: const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                            ),
                          );
                        }
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: entry.isDelivered ? AppColors.success : AppColors.surfaceOffWhite,
                            shape: BoxShape.circle,
                            boxShadow: entry.isDelivered ? [BoxShadow(color: AppColors.success.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))] : [],
                          ),
                          child: Icon(
                            entry.isDelivered ? Icons.check : Icons.delivery_dining, 
                            color: entry.isDelivered ? Colors.white : AppColors.textHint,
                          ),
                        );
                      }),
                    )
                  ],
                ),
              ),
            );
          });
        },
      );
    });
  }
}
