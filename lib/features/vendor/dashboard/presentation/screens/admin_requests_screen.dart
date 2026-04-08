import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '/core/constants/app_colors.dart';
import 'package:p_v_j/features/vendor/leaves/data/services/leave_service.dart';
import 'package:p_v_j/features/customer/data/services/query_service.dart';
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
  final LeaveService _leaveService = Get.find<LeaveService>();
  final QueryService _queryService = Get.find<QueryService>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Requests',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Leave Requests', icon: Icon(Icons.beach_access)),
            Tab(text: 'Delivery Queries', icon: Icon(Icons.help_outline)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLeaveRequestsTab(),
          _buildQueriesTab(),
        ],
      ),
    );
  }

  Widget _buildLeaveRequestsTab() {
    return StreamBuilder<List<CustomerLeaveModel>>(
      stream: _leaveService.getAdminLeaveRequests(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data;
        if (data == null) return const Center(child: Text('No data found.'));

        final requests = data.where((r) => r.status == 'Pending').toList();

        if (requests.isEmpty) {
          return const Center(child: Text('No pending leave requests.'));
        }

        return ListView.builder(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final req = requests[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                title: Text(req.customerName,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                    'Dates: ${DateFormat('d MMM').format(req.startDate)} to ${DateFormat('d MMM').format(req.endDate)}\nReason: ${req.reason}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline,
                          color: AppColors.success),
                      onPressed: () =>
                          _leaveService.updateLeaveStatus(req.id, 'Approved'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel_outlined,
                          color: AppColors.error),
                      onPressed: () =>
                          _leaveService.updateLeaveStatus(req.id, 'Rejected'),
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

  Widget _buildQueriesTab() {
    return StreamBuilder<List<QueryModel>>(
      stream: _queryService.getAdminQueries(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data;
        if (data == null) return const Center(child: Text('No queries found.'));

        final queries = data.where((q) => q.status == 'Open').toList();

        if (queries.isEmpty) {
          return const Center(child: Text('All queries resolved!'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: queries.length,
          itemBuilder: (context, index) {
            final q = queries[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                title: Text(q.customerName,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                    'Date: ${DateFormat('d MMM').format(q.deliveryDate)}\nIssue: ${q.message}'),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  onPressed: () => _queryService.resolveQuery(q.id),
                  child: const Text('Resolve',
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
