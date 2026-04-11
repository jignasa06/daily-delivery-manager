import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '/core/constants/app_colors.dart';
import '/core/constants/app_styles.dart';
import '/core/utils/responsive_helper.dart';
import 'controller/dashboard_controller.dart';

class DashboardOverviewScreen extends StatelessWidget {
  const DashboardOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find<DashboardController>();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 16, bottom: 100), // Extra bottom padding for nav
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Dashboard Greeting & Filter Section
          _buildHeader(context),

          // 2. High-Impact Metric Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _buildTotalDeliveriesCard(context, controller),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildPendingCard(context, controller)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildCompletedCard(context, controller)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // 3. Operational Summary Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _buildEarningsGoalCard(context),
                const SizedBox(height: 16),
                _buildActiveRouteSummaryCard(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hello, Central Hub",
            style: AppStyles.displayLg(context).copyWith(fontSize: 32),
          ),
          const SizedBox(height: 4),
          Text(
            "Today's delivery performance overview.",
            style: AppStyles.bodyMd(context).copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          // Period Selector Toggle
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.outlineVariant.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFilterButton("Today", isSelected: true),
                _buildFilterButton("Weekly"),
                const SizedBox(width: 8),
                const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        boxShadow: isSelected ? AppStyles.ambientShadow : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTotalDeliveriesCard(BuildContext context, DashboardController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppStyles.radiusXL * 1.5),
        boxShadow: AppStyles.ambientShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.local_shipping,
              size: 120,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "TOTAL DELIVERIES",
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withOpacity(0.8),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => Text(
                "${controller.todayTotalCount.value}",
                style: AppStyles.displayLg(context).copyWith(color: Colors.white, fontSize: 56),
              )),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "+12% from yesterday",
                  style: GoogleFonts.inter(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPendingCard(BuildContext context, DashboardController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppStyles.radiusXL * 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.pending_actions, color: Colors.amber, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            "PENDING",
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Obx(() {
            final pending = controller.todayTotalCount.value - controller.todayDeliveredCount.value;
            return Text(
              "$pending",
              style: AppStyles.displayLg(context).copyWith(fontSize: 40),
            );
          }),
          const SizedBox(height: 16),
          // Radial Progress mock with linear bar
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: 0.3,
              backgroundColor: AppColors.outlineVariant.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedCard(BuildContext context, DashboardController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppStyles.radiusXL * 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.task_alt, color: Colors.teal, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            "COMPLETED",
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Obx(() => Text(
            "${controller.todayDeliveredCount.value}",
            style: AppStyles.displayLg(context).copyWith(fontSize: 40),
          )),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.teal, size: 14),
              const SizedBox(width: 4),
              Text(
                "On schedule",
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.teal),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsGoalCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppStyles.radiusXL * 2),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Earnings Today", style: AppStyles.headlineSm(context)),
                const SizedBox(height: 4),
                Text("Revenue collected so far", style: AppStyles.bodySm(context)),
                const SizedBox(height: 16),
                Text("\$1,450", style: AppStyles.displayLg(context).copyWith(fontSize: 32, color: AppColors.primary)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    minimumSize: const Size(0, 40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                  ),
                  child: const Text("View Details"),
                ),
              ],
            ),
          ),
          // Circular Progress Mock
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  value: 0.75,
                  strokeWidth: 10,
                  backgroundColor: AppColors.surfaceContainerHigh,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                children: [
                  Text("75%", style: AppStyles.headlineSm(context).copyWith(fontSize: 18)),
                  Text("GOAL", style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.onSurfaceVariant)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveRouteSummaryCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppStyles.radiusXL * 2),
        boxShadow: AppStyles.ambientShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.map_outlined, color: AppColors.primary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.onSurface.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  "ACTIVE ROUTE",
                  style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text("Downtown Express B-4", style: AppStyles.headlineSm(context).copyWith(fontSize: 22)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.primary, size: 18),
              const SizedBox(width: 4),
              Text("12 Drops", style: AppStyles.bodyMd(context).copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(width: 24),
              const Icon(Icons.schedule, color: AppColors.primary, size: 18),
              const SizedBox(width: 4),
              Text("45 mins", style: AppStyles.bodyMd(context).copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Avatar Stack
              SizedBox(
                width: 100,
                height: 40,
                child: Stack(
                  children: [
                    _buildAvatar("https://lh3.googleusercontent.com/aida-public/AB6AXuCX0a3yrMf9ZF03SqN0U44pDIkgBWOM9iY9Nx7ra1V4kdu1F--BOp1RGg2OVNnZtitG_P0M0kWUaM7nZhUQDsXZ0JndusNZ3JD5JiAY8TORdRqeThqwWdd0fnDz_U3CDfxagCuzr3mLkw-BR7a0s7cNykwNky4vH_Bg0F4iAw8lq4G9mDOuX94t0YEh03yjqC-rq1UYfyxXWLRjaN9Q34fp8l5lgSCp9Gm6wODZAlYc_YTGkdauPtZAqY4MjU82_ab73aO0WxREVQZX", 0),
                    _buildAvatar("https://lh3.googleusercontent.com/aida-public/AB6AXuAEkJq-3j-YxjuSwhMnTw7nWjS-rIGriH95QHxEVi4JrnjHwzJnAGgbKdsrjewuRlIrFO0IaFZ8P9pSHBGIRxw27IvdAO0cjNPHMsaj5BLMkub4GFCMKrHIodr4tW-a_gkeALPoIpSuBVEvwu7r0uaKAV3NsP5qVHA9LutTXWHAPFZKRj4o_cfCcaGk1RW6TXWiYiuTlo_dmufmvRaYCPH-emuYBTpC7SVxIz2nBmtwJyTV1ziCYZqiRNma32tAwnJz-cy_4kewhdS_", 24),
                    Positioned(
                      left: 48,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        alignment: Alignment.center,
                        child: Text("+9", style: AppStyles.bodySm(context).copyWith(fontWeight: FontWeight.w800, fontSize: 10)),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String url, double left) {
    return Positioned(
      left: left,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
        ),
      ),
    );
  }
}
