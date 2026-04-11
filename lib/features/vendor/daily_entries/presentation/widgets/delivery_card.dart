import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:p_v_j/core/constants/app_colors.dart';
import 'package:p_v_j/core/constants/app_styles.dart';
import 'package:p_v_j/features/vendor/subscriptions/data/models/subscription_model.dart';
import 'package:p_v_j/features/vendor/customers/data/models/customer_model.dart';
import 'package:p_v_j/features/vendor/daily_entries/data/models/daily_entry_model.dart';

class DeliveryCard extends StatelessWidget {
  final SubscriptionModel subscription;
  final CustomerModel? customer;
  final DailyEntryModel entry;
  final String productName;
  final bool isOnLeave;
  final VoidCallback onTap;
  final VoidCallback onConfirm;
  final bool isLoading;

  const DeliveryCard({
    super.key,
    required this.subscription,
    this.customer,
    required this.entry,
    required this.productName,
    required this.isOnLeave,
    required this.onTap,
    required this.onConfirm,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isOnLeave ? AppColors.surfaceContainerLow.withOpacity(0.5) : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            // 1. Profile Photo
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                shape: BoxShape.circle,
                image: customer?.profileImageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(customer!.profileImageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: customer?.profileImageUrl == null
                  ? Icon(Icons.person_outline, color: AppColors.onSurfaceVariant.withOpacity(0.5))
                  : null,
            ),
            const SizedBox(width: 16),
            
            // 2. Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        customer?.name ?? "Unknown",
                        style: AppStyles.headlineSm(context).copyWith(
                          fontSize: 16,
                          color: isOnLeave ? AppColors.onSurfaceVariant : AppColors.onSurface,
                        ),
                      ),
                      if (isOnLeave) ...[
                        const SizedBox(width: 8),
                        _buildStatusPill("SKIPPED", Colors.orange),
                      ],
                      if (entry.isDelivered) ...[
                        const SizedBox(width: 8),
                        _buildStatusPill("DONE", AppColors.success),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    customer?.address ?? "No address",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.bodySm(context).copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$productName (${entry.quantity} ${subscription.unit})",
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            
            // 3. Status Action
            _buildActionIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildActionIcon() {
    if (isLoading) {
      return const SizedBox(
        width: 48,
        height: 48,
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
        ),
      );
    }

    if (isOnLeave) {
      return const Icon(Icons.event_busy_outlined, color: AppColors.outlineVariant);
    }

    return GestureDetector(
      onTap: onConfirm,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: entry.isDelivered ? AppColors.success : AppColors.surfaceContainerLow,
          shape: BoxShape.circle,
          boxShadow: entry.isDelivered 
            ? [BoxShadow(color: AppColors.success.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] 
            : null,
        ),
        child: Icon(
          entry.isDelivered ? Icons.check : Icons.local_shipping_outlined,
          color: entry.isDelivered ? Colors.white : AppColors.onSurfaceVariant,
          size: 20,
        ),
      ),
    );
  }
}
