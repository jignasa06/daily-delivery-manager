import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'controller/leave_controller.dart';
import '/core/constants/app_colors.dart';

class LeavesScreen extends StatelessWidget {
  LeavesScreen({super.key});

  final LeaveController controller = Get.put(LeaveController());

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildLegend(),
        Expanded(
          child: Obx(() {
            if (controller.leaves.isEmpty) {
              return const Center(
                  child: Text("No leaves or holidays found.",
                      style: TextStyle(color: AppColors.textSecondary)));
            }
            return ListView.builder(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: controller.leaves.length,
              itemBuilder: (context, index) {
                final leave = controller.leaves[index];
                bool isGlobal = leave.type == 'vendor';

                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isGlobal
                          ? Colors.orange.withValues(alpha: 0.1)
                          : AppColors.primaryLight,
                      child: Icon(
                          isGlobal ? Icons.beach_access : Icons.person_off,
                          color: isGlobal ? Colors.orange : AppColors.primary),
                    ),
                    title: Text(
                        isGlobal
                            ? "Vendor Holiday"
                            : controller.getCustomerName(leave.targetId),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        "${DateFormat('MMM d').format(leave.startDate)} - ${DateFormat('MMM d, y').format(leave.endDate)}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: AppColors.error),
                      onPressed: () => controller.deleteLeave(leave.id),
                    ),
                  ),
                );
              },
            );
          }),
        ),
        _buildFab(context),
      ],
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: const Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
          SizedBox(width: 8),
          Expanded(
              child: Text(
                  "Holidays skip deliveries and billing for the selected dates.",
                  style:
                      TextStyle(fontSize: 12, color: AppColors.textSecondary))),
        ],
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: () => _showLeaveDialog(context),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text("Add Holiday / Leave",
              style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
        ),
      ),
    );
  }

  void _showLeaveDialog(BuildContext context) {
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Add Holiday / Leave',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Obx(() => DropdownButtonFormField<String?>(
                      decoration: const InputDecoration(
                          labelText: 'Who is on leave?',
                          border: OutlineInputBorder()),
                      initialValue: controller.selectedCustomerId.value,
                      items: [
                        const DropdownMenuItem<String?>(
                            value: null,
                            child: Text("Entire Shop (Vendor Holiday)")),
                        ...controller.customers.map((c) =>
                            DropdownMenuItem<String?>(
                                value: c.id, child: Text(c.name))),
                      ],
                      onChanged: (val) =>
                          controller.selectedCustomerId.value = val,
                    )),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text("Select Date Range"),
                  subtitle: Obx(() => Text(
                      "${DateFormat('MMM d, y').format(controller.startDate.value)} - ${DateFormat('MMM d, y').format(controller.endDate.value)}")),
                  trailing: const Icon(Icons.calendar_month),
                  onTap: () async {
                    DateTimeRange? picked = await showDateRangePicker(
                      context: context,
                      initialDateRange: DateTimeRange(
                          start: controller.startDate.value,
                          end: controller.endDate.value),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      controller.startDate.value = picked.start;
                      controller.endDate.value = picked.end;
                    }
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    onPressed: () {
                      controller.saveLeave();
                      Get.back();
                    },
                    child: const Text('Save Holiday',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        });
  }
}
