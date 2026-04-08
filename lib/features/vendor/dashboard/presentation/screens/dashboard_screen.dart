import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/core/constants/app_colors.dart';
import '/core/services/auth_service.dart';
import 'controller/dashboard_controller.dart';
import '../../../products/presentation/screens/products_screen.dart';
import '../../../customers/presentation/screens/customers_screen.dart';
import '../../../daily_entries/presentation/screens/daily_entry_screen.dart';
import '../../../billing/presentation/screens/billing_screen.dart';
import '../../../leaves/presentation/screens/leaves_screen.dart';
import '../../../subscriptions/presentation/screens/subscriptions_screen.dart';
import 'admin_requests_screen.dart';
import 'vendor_profile_screen.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final DashboardController controller = Get.put(DashboardController());

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title:
            const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('CANCEL',
                style: TextStyle(
                    color: Colors.grey[600], fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.find<AuthService>().signOut();
            },
            child: const Text('LOGOUT',
                style: TextStyle(
                    color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          appBar: AppBar(
            title: Text(controller.appBarTitles[controller.currentIndex.value],
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: AppColors.primary,
            elevation: 0,
          ),
          drawer: Drawer(
            child: ListView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(color: AppColors.primary),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.business_center,
                          color: Colors.white, size: 48),
                      SizedBox(height: 12),
                      Text('Vendor Dashboard',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.sync_alt, color: AppColors.primary),
                  title: const Text('Manage Subscriptions'),
                  onTap: () {
                    Get.back();
                    controller.changePage(3); // New index for Subscriptions
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.beach_access, color: Colors.orange),
                  title: const Text('Holidays & Leaves'),
                  onTap: () {
                    Get.back();
                    controller.changePage(5); // New index for Leaves
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.mark_chat_unread_outlined,
                      color: Colors.blue),
                  title: const Text('Customer Requests'),
                  onTap: () {
                    Get.back();
                    Get.to(() => const AdminRequestsScreen());
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.business_outlined,
                      color: AppColors.primary),
                  title: const Text('Business Profile'),
                  onTap: () {
                    Get.back();
                    Get.to(() => const VendorProfileScreen());
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.error),
                  title: const Text('Logout'),
                  onTap: () {
                    _showLogoutDialog(context);
                  },
                ),
              ],
            ),
          ),
          body: IndexedStack(
            index: controller.currentIndex.value,
            children: [
              ProductsScreen(), // Index 0
              CustomersScreen(), // Index 1
              SubscriptionsScreen(), // Index 2
              DailyEntryScreen(), // Index 3
              BillingScreen(), // Index 4
              LeavesScreen(), // Index 5
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: controller.currentIndex.value > 4
                ? 3
                : controller.currentIndex.value,
            onTap: (index) => controller.changePage(index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textHint,
            backgroundColor: AppColors.backgroundWhite,
            elevation: 10,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.inventory_2_outlined), label: 'Products'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.people_outline), label: 'Customers'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.sync_alt), label: 'Subs'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.fact_check_outlined), label: 'Daily'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_outlined), label: 'Billing'),
            ],
          ),
        ));
  }
}
