import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controller/customer_controller.dart';
import 'package:p_v_j/core/constants/app_colors.dart';
import 'package:p_v_j/features/vendor/daily_entries/data/models/daily_entry_model.dart';

class CustomerActivityTab extends StatelessWidget {
  final CustomerPortalController controller;
  const CustomerActivityTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Delivery History',
            style: TextStyle(
                color: AppColors.textMain,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Obx(() {
        if (controller.myHistory.isEmpty) {
          return const Center(child: Text('No recent deliveries.'));
        }

        final sorted = List<DailyEntryModel>.from(controller.myHistory)
          ..sort((a, b) => b.date.compareTo(a.date));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          itemCount: sorted.length,
          itemBuilder: (context, index) {
            final entry = sorted[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceOffWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceLightGrey),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (entry.isDelivered
                              ? AppColors.success
                              : AppColors.error)
                          .withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      entry.isDelivered ? Icons.local_shipping : Icons.block,
                      color: entry.isDelivered
                          ? AppColors.success
                          : AppColors.error,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE, MMM d').format(entry.date),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          entry.isDelivered
                              ? 'Successfully Delivered'
                              : 'Delivery Missed',
                          style: TextStyle(
                            color: entry.isDelivered
                                ? AppColors.textSecondary
                                : AppColors.error,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Qty: ${entry.quantity}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary),
                      ),
                      const Text('Units',
                          style: TextStyle(
                              fontSize: 10, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
