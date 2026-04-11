import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '/core/constants/app_colors.dart';
import '/core/constants/app_styles.dart';
import 'package:p_v_j/features/vendor/leaves/domain/repositories/i_leave_repository.dart';
import 'package:p_v_j/features/customer/domain/repositories/i_query_repository.dart';
import 'package:p_v_j/features/vendor/leaves/data/models/customer_leave_model.dart';
import 'package:p_v_j/features/customer/data/models/query_model.dart';

class AdminRequestsScreen extends StatefulWidget {
  const AdminRequestsScreen({super.key});

  @override
  State<AdminRequestsScreen> createState() => _AdminRequestsScreenState();
}

class _AdminRequestsScreenState extends State<AdminRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ILeaveRepository _leaveRepository = Get.find<ILeaveRepository>();
  final IQueryRepository _queryRepository = Get.find<IQueryRepository>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text('Customer Requests',
            style: AppStyles.dashboardHeading(context).copyWith(color: Colors.white)),
        backgroundColor: AppColors.indigoPrimary,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          labelStyle: AppStyles.premiumCardBody(context).copyWith(fontWeight: FontWeight.bold),
          unselectedLabelStyle: AppStyles.premiumCardBody(context),
          tabs: const [
            Tab(text: 'Leave Requests', icon: Icon(Icons.beach_access)),
            Tab(text: 'Delivery Queries', icon: Icon(Icons.help_outline)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLeaveRequestsTab(context),
          _buildQueriesTab(context),
        ],
      ),
    );
  }

  Widget _buildLeaveRequestsTab(BuildContext context) {
    return StreamBuilder<List<CustomerLeaveModel>>(
      stream: _leaveRepository.getAllCustomerLeaveRequests(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator(color: AppColors.indigoPrimary));
        }
        final data = snapshot.data;
        if (data == null) return const Center(child: Text('No data found.'));

        final requests = data.where((r) => r.status == 'Pending').toList();

        if (requests.isEmpty) {
          return Center(child: Text('No pending leave requests.', style: AppStyles.premiumCardBody(context)));
        }

        return ListView.builder(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final req = requests[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: ListTile(
                title: Text(req.customerName,
                    style: AppStyles.premiumCardTitle(context)),
                subtitle: Text(
                    'Dates: ${DateFormat('d MMM').format(req.startDate)} to ${DateFormat('d MMM').format(req.endDate)}\nReason: ${req.reason}',
                    style: AppStyles.premiumCardBody(context)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline,
                          color: AppColors.success),
                      onPressed: () =>
                          _leaveRepository.updateCustomerLeaveStatus(req.id, 'Approved'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel_outlined,
                          color: AppColors.error),
                      onPressed: () =>
                          _leaveRepository.updateCustomerLeaveStatus(req.id, 'Rejected'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQueriesTab(BuildContext context) {
    return StreamBuilder<List<QueryModel>>(
      stream: _queryRepository.getAllQueries(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator(color: AppColors.indigoPrimary));
        }
        final data = snapshot.data;
        if (data == null) return const Center(child: Text('No queries found.'));

        final queries = data.where((q) => q.status == 'Open').toList();

        if (queries.isEmpty) {
          return Center(child: Text('All queries resolved!', style: AppStyles.premiumCardBody(context)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: queries.length,
          itemBuilder: (context, index) {
            final q = queries[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: ListTile(
                title: Text(q.customerName,
                    style: AppStyles.premiumCardTitle(context)),
                subtitle: Text(
                    'Date: ${DateFormat('d MMM').format(q.deliveryDate)}\nIssue: ${q.message}',
                    style: AppStyles.premiumCardBody(context)),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.indigoPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  onPressed: () => _queryRepository.resolveQuery(q.id),
                  child: Text('Resolve',
                      style: AppStyles.premiumButton(context).copyWith(fontSize: 12)),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
