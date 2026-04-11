import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'controller/daily_entry_controller.dart';
import '/features/vendor/subscriptions/data/models/subscription_model.dart';
import '/core/constants/app_colors.dart';
import '/core/constants/app_styles.dart';

class DeliveryDetailsScreen extends StatelessWidget {
  final SubscriptionModel subscription;
  
  const DeliveryDetailsScreen({super.key, required this.subscription});

  @override
  Widget build(BuildContext context) {
    final DailyEntryController controller = Get.find<DailyEntryController>();
    final customer = controller.customers.firstWhereOrNull((c) => c.id == subscription.customerId);
    final entry = controller.getEntryForSubscription(subscription);
    final bool isOnLeave = controller.isOnLeave(subscription.customerId);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(context, customer?.name ?? "Recipient"),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Recipient Info
                      _buildRecipientSection(context, customer),
                      const SizedBox(height: 32),
                      
                      // 2. Address Card
                      _buildAddressCard(context, customer),
                      const SizedBox(height: 40),
                      
                      // 3. Delivery Breakdown
                      _buildBreakdownHeader(context),
                      const SizedBox(height: 16),
                      _buildItemsGrid(context, controller),
                      const SizedBox(height: 40),
                      
                      // 4. Customer Note
                      _buildCustomerNote(context),
                      const SizedBox(height: 120), // Padding for CTA
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // 5. Floating confirmation button
          _buildConfirmationCTA(context, controller, entry, isOnLeave),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, String name) {
    return SliverAppBar(
      backgroundColor: AppColors.surface.withOpacity(0.8),
      floating: true,
      pinned: true,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.primary),
        onPressed: () => Get.back(),
      ),
      title: Text(
        "DailyFresh",
        style: AppStyles.headlineSm(context).copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w900,
          letterSpacing: -1,
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
    );
  }

  Widget _buildRecipientSection(BuildContext context, dynamic customer) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "RECIPIENT",
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              customer?.name ?? "Sarah Jenkins",
              style: AppStyles.displayLg(context).copyWith(fontSize: 32, height: 1.1),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer.withOpacity(0.2),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            "Priority #04",
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressCard(BuildContext context, dynamic customer) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.location_on, color: Colors.white),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer?.address ?? "Apt 402, Willow Creek",
                  style: AppStyles.headlineSm(context).copyWith(fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  "Gate Code: 5521 • Ring twice",
                  style: AppStyles.bodySm(context).copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
            ),
            child: const Icon(Icons.map_outlined, color: AppColors.primary, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Delivery Breakdown", style: AppStyles.headlineSm(context).copyWith(fontSize: 22)),
        Text(
          "Items Total",
          style: AppStyles.labelSmall(context).copyWith(color: AppColors.primary, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  Widget _buildItemsGrid(BuildContext context, DailyEntryController controller) {
    // For now, we take the primary subscription item. In a real app, 
    // a delivery might have multiple subscription items for the same customer.
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.8,
      children: [
        _buildProductCard(
          context,
          "Full Cream Milk",
          "Glass Bottle • Cold Store",
          "x1",
          "https://lh3.googleusercontent.com/aida-public/AB6AXuAIFu6k7TrD_NLJLSdhZSHLg4V0kRftOMKX5epoWRq5H0jIAqgE1MuiCXPWCxeiO8hndoLXxZxmGFjNsZ353IrvwsvO1_t9rrK25YXyKSBkdL2HoZimg1kx9W8csecMlW4rPHkDCSNjzsNOvMSDNzw-D85dyLljKeOiSuxemkWOLSey5hDi4rVryuW-41PVwctdZynH4tssiOCDxDKi-b6xT7NC-Qj0CfORhBSXZNrziblrJnZ0IDtPI3e8aBtcJGY_Udq0FGkrGNBM",
        ),
        _buildProductCard(
          context,
          "Fresh Buttermilk",
          "Tetra Pack • Sustainable",
          "x1",
          "https://lh3.googleusercontent.com/aida-public/AB6AXuBxyMMJBL8CICp-WTF97mCdsEW65nolrfghj8TbuwffVSvJ_wiMePfmBCgc-ZJB5JAZ_v_6BDx6vTLwSzAsHJxRttBryGxRs6EpkqYO36oqVpCUpp2ZIUDuK5PkLhasCfNmXsTQqFXu_t38bKrIlQ2GToddRXIsNtj8SBHIxigO8uG2j4_653-BXz9QoyZlq6qmBRGM6_aqo6AZ1FlPzJY2ePBxs62-xMrboTLEYYTYswwfbyeZ23mAbORcMOYk9yjDiN_2JN_-a9Ns",
        ),
      ],
    );
  }

  Widget _buildProductCard(BuildContext context, String name, String sub, String qty, String url) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(url, fit: BoxFit.cover, width: double.infinity),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppStyles.bodyMd(context).copyWith(fontWeight: FontWeight.w800, height: 1.1)),
                    const SizedBox(height: 2),
                    Text(sub, style: AppStyles.labelSmall(context).copyWith(fontSize: 8)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primaryContainer.withOpacity(0.2), borderRadius: BorderRadius.circular(99)),
                child: Text(qty, style: AppStyles.labelSmall(context).copyWith(color: AppColors.primary, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerNote(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border(left: BorderSide(color: Colors.orange.withOpacity(0.3), width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: Colors.orange, size: 16),
              const SizedBox(width: 8),
              Text(
                "CUSTOMER NOTE",
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.orange, letterSpacing: 2),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "\"Please leave the milk bottles inside the insulated box by the door. Thank you!\"",
            style: AppStyles.bodyMd(context).copyWith(fontStyle: FontStyle.italic, color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationCTA(BuildContext context, DailyEntryController controller, dynamic entry, bool isOnLeave) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            Obx(() {
              final isDelivered = entry.isDelivered;
              final isLoading = controller.loadingSubId.value == subscription.id;
              
              return ElevatedButton(
                onPressed: (isOnLeave || isLoading) ? null : () => controller.toggleDelivery(subscription, entry),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDelivered ? AppColors.success : AppColors.primary,
                  minimumSize: const Size(double.infinity, 64),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  elevation: 8,
                  shadowColor: (isDelivered ? AppColors.success : AppColors.primary).withOpacity(0.3),
                ),
                child: isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(isDelivered ? Icons.check_circle : Icons.local_shipping, color: Colors.white),
                        const SizedBox(width: 12),
                        Text(
                          isDelivered ? "DELIVERY CONFIRMED" : "CONFIRM DELIVERY",
                          style: AppStyles.premiumButton(context).copyWith(fontSize: 16),
                        ),
                      ],
                    ),
              );
            }),
            const SizedBox(height: 12),
            Text(
              "By confirming, the customer will be notified instantly.",
              style: AppStyles.labelSmall(context).copyWith(fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
