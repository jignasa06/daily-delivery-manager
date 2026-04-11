import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '/core/constants/app_colors.dart';
import '/core/constants/app_styles.dart';
import '/core/utils/responsive_helper.dart';
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
import 'dashboard_overview_screen.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final DashboardController controller = Get.put(DashboardController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppStyles.radiusXL)),
        title: Text('Logout', style: AppStyles.headlineSm(context)),
        content: Text('Are you sure you want to logout of your vendor portal?', style: AppStyles.bodyMd(context)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('CANCEL', style: AppStyles.labelMedium(context).copyWith(color: AppColors.onSurfaceVariant)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(100, 40),
            ),
            onPressed: () {
              Get.back();
              Get.find<AuthService>().signOut();
            },
            child: const Text('LOGOUT'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.surface,
          extendBody: true, // Allow body to flow under bottom nav blur
          appBar: _buildAppBar(context),
          drawer: _buildDrawer(context),
          body: IndexedStack(
            index: controller.currentIndex.value,
            children: [
              const DashboardOverviewScreen(), // Index 0
              CustomersScreen(),               // Index 1
              DailyEntryScreen(),              // Index 2
              VendorProfileScreen(),           // Index 3
              ProductsScreen(),                // Index 4 (Hidden from BottomNav)
              SubscriptionsScreen(),           // Index 5 (Hidden)
              BillingScreen(),                 // Index 6 (Hidden)
              LeavesScreen(),                  // Index 7 (Hidden)
            ],
          ),
          bottomNavigationBar: _buildBottomNav(context),
        ));
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AppBar(
            backgroundColor: AppColors.surface.withOpacity(0.8),
            elevation: 0,
            centerTitle: false,
            leading: IconButton(
              icon: const Icon(Icons.menu, color: AppColors.primary),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            title: Text(
              controller.currentIndex.value == 0 ? "Vendor Portal" : controller.appBarTitles[controller.currentIndex.value],
              style: AppStyles.headlineSm(context).copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 2),
                    image: const DecorationImage(
                      image: NetworkImage("https://lh3.googleusercontent.com/aida-public/AB6AXuAMx_9qZXRykQ-8G08MQ7aKTOWeLVSucDs0VJU7gbhSOsY-hZenephqB_VY1bqtdEtADzwYrsM9g3Jd1V6X4wzs1WC4S9jQK0KIpO1p5_nFo8SBe18DhGLmvshJKbkFiXg5rOxcm_I37u55UjYAiuiHnTxmOzqR6CWL9lE6cc9rkpRH5hIpEJB9PIFoGKsX0xrlMZTo-_BymkdbJkUUXldD4LLEqBTdQj85zq-mOnuO-xToy7TAmeUgNQXd7RB0CS5ViQl_-Ew3Zh5F"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(AppStyles.radiusXL)),
      ),
      child: Column(
        children: [
          // Drawer Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withOpacity(0.2),
                    shape: BoxShape.circle,
                    image: const DecorationImage(
                      image: NetworkImage("https://lh3.googleusercontent.com/aida-public/AB6AXuAMx_9qZXRykQ-8G08MQ7aKTOWeLVSucDs0VJU7gbhSOsY-hZenephqB_VY1bqtdEtADzwYrsM9g3Jd1V6X4wzs1WC4S9jQK0KIpO1p5_nFo8SBe18DhGLmvshJKbkFiXg5rOxcm_I37u55UjYAiuiHnTxmOzqR6CWL9lE6cc9rkpRH5hIpEJB9PIFoGKsX0xrlMZTo-_BymkdbJkUUXldD4LLEqBTdQj85zq-mOnuO-xToy7TAmeUgNQXd7RB0CS5ViQl_-Ew3Zh5F"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Store Admin",
                        style: AppStyles.headlineMd(context).copyWith(
                          fontSize: 18, 
                          color: AppColors.primary,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Premium Vendor",
                        style: AppStyles.bodySm(context).copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _drawerItem(context, Icons.account_circle_outlined, "Profile", () => controller.changePage(3)),
                _drawerItem(context, Icons.card_membership_outlined, "Subscription Plans", () => controller.changePage(5)),
                _drawerItem(context, Icons.receipt_long_outlined, "Billing History", () => controller.changePage(6)),
                _drawerItem(context, Icons.contact_support_outlined, "Support", () {}),
                const Divider(height: 32),
                _drawerItem(context, Icons.mark_chat_unread_outlined, "Customer Requests", () => Get.to(() => const AdminRequestsScreen())),
              ],
            ),
          ),
          
          // Version info
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "V2.4.0",
                style: AppStyles.bodySm(context).copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: AppColors.outlineVariant,
                ),
              ),
            ),
          ),
          
          _drawerItem(context, Icons.logout, "Logout", () => _showLogoutDialog(context), isError: true),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String label, VoidCallback onTap, {bool isError = false}) {
    return ListTile(
      onTap: () {
        Get.back();
        onTap();
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Icon(icon, color: isError ? AppColors.error : AppColors.primary),
      title: Text(
        label,
        style: AppStyles.bodyMd(context).copyWith(
          fontWeight: FontWeight.w600,
          color: isError ? AppColors.error : AppColors.onSurfaceVariant,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 16, color: AppColors.outlineVariant),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      height: 80 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppStyles.radiusXL)),
        boxShadow: AppStyles.ambientShadow,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppStyles.radiusXL)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(context, 0, Icons.dashboard_outlined, Icons.dashboard, "Dashboard"),
              _navItem(context, 2, Icons.local_shipping_outlined, Icons.local_shipping, "Deliveries"),
              _navItem(context, 1, Icons.groups_outlined, Icons.groups, "Customers"),
              _navItem(context, 4, Icons.import_contacts_outlined, Icons.import_contacts, "Catalog"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, int index, IconData icon, IconData activeIcon, String label) {
    bool isSelected = controller.currentIndex.value == index;
    
    return GestureDetector(
      onTap: () => controller.changePage(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon, 
              color: isSelected ? Colors.white : AppColors.onSurfaceVariant, 
              size: 24
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isSelected ? Colors.white : AppColors.onSurfaceVariant, 
                fontSize: 10, 
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
