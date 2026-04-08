import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'controller/subscription_controller.dart';
import '/core/constants/app_colors.dart';
import '/core/widgets/common_text_field.dart';

import 'package:p_v_j/features/vendor/dashboard/presentation/widgets/setup_progress_widget.dart';

class SubscriptionsScreen extends StatelessWidget {
  SubscriptionsScreen({super.key});

  final SubscriptionController controller = Get.put(SubscriptionController());

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SetupProgressWidget(),
        Expanded(
          child: Obx(() {
            if (controller.subscriptions.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sync_alt,
                          size: 80,
                          color: AppColors.primary.withValues(alpha: 0.2)),
                      const SizedBox(height: 24),
                      const Text(
                        "No Subscriptions Yet",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Connect your products to your customers by defining how often they should be delivered.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () => _showSubscriptionDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text("Create First Subscription",
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
                  itemCount: controller.subscriptions.length,
                  itemBuilder: (context, index) {
                    final sub = controller.subscriptions[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const CircleAvatar(
                            backgroundColor: AppColors.primaryLight,
                            child:
                                Icon(Icons.sync_alt, color: AppColors.primary)),
                        title: Text(
                            "${controller.getCustomerName(sub.customerId)} - ${controller.getProductName(sub.productId)}",
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            "Qty: ${sub.defaultQuantity} ${controller.getProductUnit(sub.productId)} \nDays: ${sub.selectedDays.map((d) => d.substring(0, 3)).join(', ')}"),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: AppColors.error),
                          onPressed: () =>
                              controller.deleteSubscription(sub.id),
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    backgroundColor: AppColors.primary,
                    onPressed: () => _showSubscriptionDialog(context),
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

  void _showSubscriptionDialog(BuildContext context) {
    controller.openForm();
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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('New Subscription',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    // Customer Dropdown
                    Obx(() => DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              labelText: 'Select Customer',
                              border: OutlineInputBorder()),
                          initialValue: controller.selectedCustomerId,
                          items: controller.customers
                              .map((c) => DropdownMenuItem(
                                  value: c.id, child: Text(c.name)))
                              .toList(),
                          onChanged: (val) =>
                              controller.selectedCustomerId = val,
                          validator: (val) => val == null ? 'Required' : null,
                        )),
                    const SizedBox(height: 12),

                    // Product Dropdown
                    Obx(() => DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              labelText: 'Select Product',
                              border: OutlineInputBorder()),
                          initialValue: controller.selectedProductId,
                          items: controller.products
                              .map((p) => DropdownMenuItem(
                                  value: p.id, child: Text(p.name)))
                              .toList(),
                          onChanged: (val) =>
                              controller.selectedProductId = val,
                          validator: (val) => val == null ? 'Required' : null,
                        )),
                    const SizedBox(height: 12),

                    CommonTextField(
                      controller: controller.defaultQuantityController,
                      hint: 'Default Daily Quantity',
                      icon: Icons.numbers_outlined,
                      validator: (val) => val!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    const Text('Delivery Days',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Obx(() => Wrap(
                          spacing: 8,
                          children: controller.weekDays.map((day) {
                            final isSelected =
                                controller.selectedDays.contains(day);
                            return ChoiceChip(
                              label: Text(day.substring(0, 3)),
                              selected: isSelected,
                              onSelected: (_) => controller.toggleDay(day),
                              selectedColor: AppColors.primaryLight,
                            );
                          }).toList(),
                        )),
                    const SizedBox(height: 24),

                    const Text('Starting From',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: controller.selectedStartDate.value,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          controller.selectedStartDate.value = picked;
                        }
                      },
                      child: _datePickerTrigger(
                          controller.selectedStartDate.value),
                    ),
                    const SizedBox(height: 16),

                    const Text('Ending on (Optional)',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Obx(() => InkWell(
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: controller.selectedEndDate.value ??
                                  controller.selectedStartDate.value
                                      .add(const Duration(days: 30)),
                              firstDate: controller.selectedStartDate.value,
                              lastDate: DateTime(2100),
                            );
                            controller.selectedEndDate.value = picked;
                          },
                          child: _datePickerTrigger(
                              controller.selectedEndDate.value),
                        )),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                        onPressed: controller.saveSubscription,
                        child: const Text('Save Subscription',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget _datePickerTrigger(DateTime? date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(
            date == null
                ? 'No end date (Ongoing)'
                : DateFormat('EEEE, MMM d, yyyy').format(date),
            style: TextStyle(
                color: date == null
                    ? AppColors.textSecondary
                    : AppColors.textMain),
          ),
        ],
      ),
    );
  }
}
