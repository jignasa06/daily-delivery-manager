import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/customer_controller.dart';
import 'package:p_v_j/core/constants/app_colors.dart';

class CustomerBillingTab extends StatelessWidget {
  final CustomerPortalController controller;
  const CustomerBillingTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Bills', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Obx(() {
        if (controller.myBills.isEmpty) {
          return const Center(child: Text('No billing history yet.'));
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.myBills.length,
          itemBuilder: (context, index) {
            final bill = controller.myBills[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceLightGrey),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.receipt_long, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bill.monthYear,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const Text(
                          'Monthly Invoice',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${bill.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
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
