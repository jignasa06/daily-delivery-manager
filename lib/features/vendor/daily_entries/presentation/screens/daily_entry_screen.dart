import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'controller/daily_entry_controller.dart';
import '../widgets/delivery_card.dart';
import 'delivery_details_screen.dart';
import '/core/constants/app_colors.dart';
import '/core/constants/app_styles.dart';

class DailyEntryScreen extends StatelessWidget {
  DailyEntryScreen({super.key});

  final DailyEntryController controller = Get.put(DailyEntryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Uses Dashboard background
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header with Active Route title & Date Selector
          _buildHeader(context),

          // 2. Search Bar
          _buildSearchBar(context),

          // 3. Status Filters (Horizontal Pills)
          _buildFilterPills(),

          const SizedBox(height: 24),

          // 4. Delivery List
          Expanded(child: _buildRouteList(context)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Active Route",
                style: AppStyles.displayLg(context).copyWith(fontSize: 32),
              ),
              const SizedBox(height: 4),
              Obx(() => Text(
                _getFormattedDate(controller.selectedDate.value),
                style: AppStyles.bodySm(context).copyWith(fontWeight: FontWeight.w700, color: AppColors.primary),
              )),
            ],
          ),
          _buildDatePaginator(context),
        ],
      ),
    );
  }

  String _getFormattedDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return "TODAY, ${_formatShortDate(date)}";
    }
    return _formatShortDate(date).toUpperCase();
  }

  String _formatShortDate(DateTime date) {
    final months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
    return "${date.day} ${months[date.month - 1]}";
  }

  Widget _buildDatePaginator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _dateIconButton(Icons.chevron_left, () => controller.changeDate(controller.selectedDate.value.subtract(const Duration(days: 1)))),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: controller.selectedDate.value,
                firstDate: DateTime(2024),
                lastDate: DateTime(2026),
              );
              if (picked != null) controller.changeDate(picked);
            },
            child: const Icon(Icons.calendar_month_outlined, size: 20, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(width: 8),
          _dateIconButton(Icons.chevron_right, () => controller.changeDate(controller.selectedDate.value.add(const Duration(days: 1)))),
        ],
      ),
    );
  }

  Widget _dateIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextField(
          onChanged: (val) => controller.searchQuery.value = val,
          style: AppStyles.bodyMd(context),
          decoration: InputDecoration(
            hintText: "Search customer or address...",
            icon: const Icon(Icons.search, color: AppColors.onSurfaceVariant),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPills() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Obx(() => Row(
        children: [
          _filterPill("All"),
          _filterPill("Pending"),
          _filterPill("Delivered"),
          _filterPill("Skipped"),
        ],
      )),
    );
  }

  Widget _filterPill(String label) {
    bool isSelected = controller.selectedFilter.value == label;
    return GestureDetector(
      onTap: () => controller.selectedFilter.value = label,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildRouteList(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingEntries.value) {
        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
      }

      final subscriptions = controller.filteredSubscriptions;

      if (subscriptions.isEmpty) {
        return _buildEmptyRoute(context);
      }

      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
        itemCount: subscriptions.length,
        itemBuilder: (context, index) {
          final sub = subscriptions[index];
          final customer = controller.customers.firstWhereOrNull((c) => c.id == sub.customerId);
          final entry = controller.getEntryForSubscription(sub);
          final bool isOnLeave = controller.isOnLeave(sub.customerId);

          return DeliveryCard(
            subscription: sub,
            customer: customer,
            entry: entry,
            productName: controller.getProductName(sub.productId),
            isOnLeave: isOnLeave,
            isLoading: controller.loadingSubId.value == sub.id,
            onTap: () => Get.to(() => DeliveryDetailsScreen(subscription: sub)),
            onConfirm: () => controller.toggleDelivery(sub, entry),
          );
        },
      );
    });
  }

  Widget _buildEmptyRoute(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.route_outlined, size: 64, color: AppColors.onSurfaceVariant.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            "Quick Break!",
            style: AppStyles.headlineSm(context).copyWith(color: AppColors.onSurfaceVariant),
          ),
          Text(
            "No matching deliveries scheduled.",
            style: AppStyles.bodySm(context),
          ),
        ],
      ),
    );
  }
}
