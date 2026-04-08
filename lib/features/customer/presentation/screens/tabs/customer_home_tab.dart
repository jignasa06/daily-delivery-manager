import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/customer_controller.dart';
import 'package:p_v_j/core/constants/app_colors.dart';
import 'package:p_v_j/core/services/auth_service.dart';

class CustomerHomeTab extends StatelessWidget {
  final CustomerPortalController controller;
  const CustomerHomeTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();
    return Container(
      color: AppColors.surfaceOffWhite,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            _buildPremiumHeader(auth),
            _buildActionCenter(context),
            _buildActiveSection(),
            _buildVendorSupportCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(AuthService auth) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 30),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const CircleAvatar(radius: 40, backgroundColor: Colors.white24, child: Icon(Icons.person, size: 50, color: Colors.white)),
          const SizedBox(height: 16),
          Obx(() => Text(
            auth.firebaseUser.value?.displayName ?? auth.firebaseUser.value?.email ?? 'Customer',
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          )),
          const Text('Trusted Subscriber', style: TextStyle(color: Colors.white70, fontSize: 13, letterSpacing: 1.1)),
        ],
      ),
    );
  }

  Widget _buildActionCenter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Expanded(
            child: _actionButton(
              'Request Leave', 'Pause delivery', Icons.beach_access, Colors.orange, 
              () => _showLeaveDialog(context)
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _actionButton(
              'Any Issue?', 'Report problem', Icons.help_outline, Colors.blue, 
              () => _showIssueDialog(context)
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String title, String sub, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            Text(sub, style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.stars, color: Colors.amber, size: 20),
              SizedBox(width: 8),
              Text('My Subscriptions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.mySubscriptions.isEmpty) return const Center(child: Text('No active subscriptions.', style: TextStyle(color: AppColors.textSecondary)));
            return Column(
              children: controller.mySubscriptions.map((sub) {
                final productName = controller.getProductName(sub.productId);
                final bool isEndingSoon = sub.endDate != null && sub.endDate!.difference(DateTime.now()).inDays < 7;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1), 
                        blurRadius: 20, 
                        offset: const Offset(0, 8)
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.textMain)),
                                  const SizedBox(height: 4),
                                  _statusChip(sub.endDate == null ? 'Active' : (isEndingSoon ? 'Ending Soon' : 'Planned')),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${sub.defaultQuantity}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: AppColors.primary)),
                                const Text('Units', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, indent: 20, endIndent: 20),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Expanded(child: _dateItem('Start Date', DateFormat('d MMM, yyyy').format(sub.startDate), Icons.calendar_today)),
                            Container(width: 1, height: 30, color: AppColors.surfaceLightGrey),
                            Expanded(child: _dateItem('End Date', sub.endDate == null ? 'Ongoing' : DateFormat('d MMM, yyyy').format(sub.endDate!), Icons.event_available, isEnd: true)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _statusChip(String label) {
    Color color = AppColors.primary;
    if (label == 'Ending Soon') color = Colors.orange;
    if (label == 'Active') color = AppColors.success;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
      ),
    );
  }

  Widget _dateItem(String label, String date, IconData icon, {bool isEnd = false}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          date, 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 14, 
            color: isEnd && date != 'Ongoing' ? AppColors.error : AppColors.textMain
          )
        ),
      ],
    );
  }

  void _showLeaveDialog(BuildContext context) {
    DateTimeRange? selectedRange;
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Request Holiday'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select your dates to pause delivery'),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    initialDateRange: selectedRange,
                  );
                  if (picked != null) {
                    setState(() => selectedRange = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.primary.withValues(alpha: 0.05),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          selectedRange == null 
                            ? 'Tap to select dates' 
                            : '${DateFormat('d MMM').format(selectedRange!.start)} - ${DateFormat('d MMM').format(selectedRange!.end)}',
                          style: TextStyle(
                            color: selectedRange == null ? AppColors.textSecondary : AppColors.textMain,
                            fontWeight: selectedRange == null ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason (Optional)', 
                  border: OutlineInputBorder(),
                  hintText: 'e.g. Going out of town',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: selectedRange == null ? null : () {
                controller.submitLeaveRequest(
                  selectedRange!.start, 
                  selectedRange!.end, 
                  reasonController.text
                );
                Navigator.pop(context);
              }, 
              child: const Text('Submit Request')
            ),
          ],
        ),
      ),
    );
  }

  void _showIssueDialog(BuildContext context) {
    final messageController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Raise Query'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('What went wrong today?'),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'e.g. Milk bottle leaked', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              controller.reportIssue(DateTime.now(), messageController.text);
              Get.back();
            }, 
            child: const Text('Report')
          ),
        ],
      ),
    );
  }

  Widget _buildVendorSupportCard() {
    return Obx(() {
      final data = controller.vendorInfo.value;
      if (data == null) return const SizedBox.shrink();

      final businessName = data['businessName'] ?? 'Verified Provider';
      final phone = data['phone'] ?? 'N/A';
      final email = data['email'] ?? 'N/A';

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.1), width: 2),
            boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 30, offset: const Offset(0, 15))],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: const CircleAvatar(
                      radius: 20, 
                      backgroundColor: Colors.white, 
                      child: Icon(Icons.business_center, color: AppColors.primary, size: 20)
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(businessName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.textMain)),
                        const Text('Official Service Provider', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _contactRow(Icons.phone_in_talk, 'Call Support', phone, onTap: phone != 'N/A' ? () => _makeCall(phone) : null, color: AppColors.primary),
              const SizedBox(height: 12),
              _contactRow(Icons.alternate_email, 'Email Support', email, onTap: email != 'N/A' ? () => _sendEmail(email) : null, color: Colors.blue),
            ],
          ),
        ),
      );
    });
  }

  Widget _contactRow(IconData icon, String label, String value, {VoidCallback? onTap, Color? color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceOffWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceLightGrey),
        ),
        child: Row(
          children: [
            Icon(icon, color: color ?? AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                  Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textMain)),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.arrow_right_alt, color: (color ?? AppColors.primary).withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }

  Future<void> _makeCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }
}
