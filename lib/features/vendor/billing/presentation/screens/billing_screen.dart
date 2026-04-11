import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'controller/billing_controller.dart';
import '/core/constants/app_colors.dart';
import '/core/constants/app_styles.dart';
import 'package:p_v_j/features/vendor/customers/data/models/customer_model.dart';
import 'package:p_v_j/features/vendor/billing/data/models/bill_model.dart';
import 'package:collection/collection.dart';

class BillingScreen extends StatelessWidget {
  BillingScreen({super.key});

  final BillingController controller = Get.put(BillingController());

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMonthSelector(context),
        Expanded(
          child: Obx(() {
                final filtered = controller.filteredCustomers;
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 64, color: AppColors.indigoPrimary.withOpacity(0.1)),
                        const SizedBox(height: 16),
                        Text("No active subscriptions found for this month.",
                            textAlign: TextAlign.center,
                            style: AppStyles.premiumCardBody(context)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final customer = filtered[index];
                    return _buildCustomerBillCard(context, customer);
                  },
                );
          }),
        ),
      ],
    );
  }

  Widget _buildMonthSelector(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.indigoPrimary),
            onPressed: () => controller.changeMonth(-1),
          ),
          Row(
            children: [
              const Icon(Icons.calendar_month,
                  color: AppColors.indigoPrimary, size: 20),
              const SizedBox(width: 8),
              Obx(() => Text(
                    DateFormat('MMMM yyyy').format(DateFormat('yyyy-MM')
                        .parse(controller.selectedMonthYear.value)),
                    style: AppStyles.premiumCardTitle(context),
                  )),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppColors.indigoPrimary),
            onPressed: () => controller.changeMonth(1),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerBillCard(BuildContext context, CustomerModel customer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        collapsedShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: CircleAvatar(
            backgroundColor: AppColors.indigoPrimary.withOpacity(0.1),
            child: const Icon(Icons.person, color: AppColors.indigoPrimary)),
        title: Text(customer.name,
            style: AppStyles.premiumCardTitle(context)),
        subtitle: Text('View history & status', style: AppStyles.premiumCardBody(context).copyWith(fontSize: 12)),
        children: [
          Obx(() {
            final monthStr = controller.selectedMonthYear.value;
            final currentMonthLabel = DateFormat('MMMM yyyy')
                .format(DateFormat('yyyy-MM').parse(monthStr));

            return StreamBuilder<List<BillModel>>(
              stream: controller.getCustomerBills(customer.id),
              builder: (context, snapshot) {
                final bills = snapshot.data ?? [];
                final currentMonthBill =
                    bills.firstWhereOrNull((b) => b.monthYear == monthStr);
                final bool hasBill = currentMonthBill != null;

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('CURRENT MONTH',
                              style: AppStyles.premiumCardBody(context).copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                  color: AppColors.textHint)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: hasBill
                                  ? AppColors.success.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              hasBill ? "GENERATED" : "PENDING",
                              style: TextStyle(
                                  color: hasBill
                                      ? AppColors.success
                                      : Colors.orange,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (hasBill) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: AppColors.indigoPrimary.withOpacity(0.05),
                              border: Border.all(
                                  color:
                                      AppColors.indigoPrimary.withOpacity(0.1)),
                              borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(currentMonthLabel,
                                  style: AppStyles.premiumCardTitle(context).copyWith(fontSize: 14)),
                              Text(
                                  "₹${currentMonthBill!.totalAmount.toStringAsFixed(2)}",
                                  style: AppStyles.premiumCardTitle(context).copyWith(
                                      fontSize: 18,
                                      color: AppColors.indigoPrimary)),
                            ],
                          ),
                        ),
                      ] else ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                controller.generateBill(customer.id),
                            icon: const Icon(Icons.receipt_long,
                                color: Colors.white, size: 20),
                            label: Text('Generate for $currentMonthLabel',
                                style: AppStyles.premiumButton(context)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.indigoPrimary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      const Text('BILLING HISTORY',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                              color: AppColors.textHint)),
                      const SizedBox(height: 8),
                      if (bills.isEmpty)
                        const Text('No past records found.',
                            style: TextStyle(fontSize: 12, color: Colors.grey))
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: bills.length > 3 ? 3 : bills.length,
                          separatorBuilder: (context, i) =>
                              const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final bill = bills[i];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              title: Text(bill.monthYear,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500)),
                              trailing: Text("₹${bill.totalAmount}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.success)),
                            );
                          },
                        ),
                    ],
                  ),
                );
              },
            );
          })
        ],
      ),
    );
  }
}
