import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controller/customer_controller.dart';
import 'package:p_v_j/core/constants/app_colors.dart';

class CustomerRequestsTab extends StatelessWidget {
  final CustomerPortalController controller;
  const CustomerRequestsTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Holiday History', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Obx(() {
        if (controller.myLeaves.isEmpty) {
          return const Center(child: Text('No holiday requests yet.'));
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.myLeaves.length,
          itemBuilder: (context, index) {
            final leave = controller.myLeaves[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceLightGrey),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getStatusColor(leave.status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.beach_access, color: _getStatusColor(leave.status), size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${DateFormat('d MMM').format(leave.startDate)} - ${DateFormat('d MMM, yyyy').format(leave.endDate)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              'Service Pause Request',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      _statusChip(leave.status),
                    ],
                  ),
                  if (leave.reason.isNotEmpty) ...[
                    const Divider(height: 24),
                    Text(
                      'Reason: ${leave.reason}',
                      style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      }),
    );
  }

  Widget _statusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: _getStatusColor(status), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'Approved') return AppColors.success;
    if (status == 'Rejected') return AppColors.error;
    return Colors.orange;
  }
}
