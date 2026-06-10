import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smartops/core/models/project_request_model.dart';
import 'package:smartops/core/provider/auth_provider.dart';
import 'package:smartops/core/services/request_service.dart';
import 'package:smartops/core/widgets/app_button.dart';
import 'package:smartops/core/widgets/app_drawer.dart';
import 'package:smartops/core/widgets/app_footer.dart';
import 'package:smartops/core/widgets/app_top_bar.dart';
import 'package:smartops/features/requests/widgets/rejection_dialog.dart';
import 'package:smartops/features/requests/widgets/request_card.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  final TextEditingController searchController = TextEditingController();

  List<ProjectRequestModel> requests = [];

  bool isLoading = true;
  String errorMessage = '';
  String statusFilter = 'all';
  int? actionLoadingId;

  @override
  void initState() {
    super.initState();
    loadRequests();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  String _cleanErrorMessage(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  Future<void> loadRequests() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final data = await RequestService.getProjectRequests();

      setState(() {
        requests = data
            .map((item) => ProjectRequestModel.fromJson(
          Map<String, dynamic>.from(item),
        ))
            .toList();
      });
    } catch (error) {
      setState(() {
        errorMessage = _cleanErrorMessage(error);
      });
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  List<ProjectRequestModel> get filteredRequests {
    final query = searchController.text.trim().toLowerCase();

    return requests.where((request) {
      final matchesSearch = query.isEmpty ||
          [
            request.requestId.toString(),
            request.name,
            request.description,
            request.category,
            request.status,
            request.clientName,
            request.templateName,
            request.rejectionReason,
          ].whereType<String>().join(' ').toLowerCase().contains(query);

      final matchesStatus =
          statusFilter == 'all' || request.status == statusFilter;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  List<ProjectRequestModel> get pendingRequests {
    return filteredRequests
        .where((request) => request.status == 'pending')
        .toList();
  }

  List<ProjectRequestModel> get reviewedRequests {
    return filteredRequests
        .where((request) => request.status != 'pending')
        .toList();
  }

  int get approvedCount {
    return requests.where((request) => request.status == 'approved').length;
  }

  int get rejectedCount {
    return requests.where((request) => request.status == 'rejected').length;
  }

  int get pendingCount {
    return requests.where((request) => request.status == 'pending').length;
  }

  Future<void> _approveRequest(ProjectRequestModel request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Approve request?',
            style: TextStyle(
              color: Color(0xFF0B2E59),
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            'Are you sure you want to approve "${request.name}"? This will convert it into an active project.',
            style: const TextStyle(
              color: Color(0xFF667085),
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B2E59),
                foregroundColor: Colors.white,
              ),
              child: const Text('Approve'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() => actionLoadingId = request.requestId);

    try {
      await RequestService.approveRequest(request.requestId);

      await loadRequests();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request approved successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_cleanErrorMessage(error)),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => actionLoadingId = null);
      }
    }
  }

  Future<void> _rejectRequest(ProjectRequestModel request) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) {
        return RejectionDialog(
          onConfirm: (reason) async {
            await RequestService.rejectRequest(
              requestId: request.requestId,
              rejectionReason: reason,
            );
          },
        );
      },
    );

    if (result == true) {
      await loadRequests();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request rejected successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _deleteRequest(ProjectRequestModel request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Delete request?',
            style: TextStyle(
              color: Color(0xFF0B2E59),
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${request.name}"? This action cannot be undone.',
            style: const TextStyle(
              color: Color(0xFF667085),
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() => actionLoadingId = request.requestId);

    try {
      await RequestService.deleteRequest(request.requestId);

      setState(() {
        requests.removeWhere((item) => item.requestId == request.requestId);
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request deleted successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_cleanErrorMessage(error)),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => actionLoadingId = null);
      }
    }
  }

  void _resetFilters() {
    searchController.clear();

    setState(() {
      statusFilter = 'all';
    });
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        TextField(
          controller: searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search requests by project, client, category, status...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
              onPressed: () {
                searchController.clear();
                setState(() {});
              },
              icon: const Icon(Icons.close),
            )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE9EEF5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE9EEF5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF0B2E59)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _StatusFilterChip(label: 'All', value: 'all'),
                    _StatusFilterChip(label: 'Pending', value: 'pending'),
                    _StatusFilterChip(label: 'Approved', value: 'approved'),
                    _StatusFilterChip(label: 'Rejected', value: 'rejected'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _resetFilters,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFE9EEF5)),
              ),
              icon: const Icon(Icons.restart_alt),
            ),
          ],
        ),
      ],
    );
  }

  Widget _StatusFilterChip({
    required String label,
    required String value,
  }) {
    final isActive = statusFilter == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selected: isActive,
        label: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF0B2E59),
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
        selectedColor: const Color(0xFF0B2E59),
        backgroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFFE9EEF5)),
        onSelected: (_) {
          setState(() {
            statusFilter = value;
          });
        },
      ),
    );
  }

  Widget _buildMetrics() {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            title: 'TOTAL',
            value: '${requests.length}',
            icon: Icons.assignment_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            title: 'PENDING',
            value: '$pendingCount',
            icon: Icons.pending_actions,
            color: Colors.orange.shade700,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            title: 'APPROVED',
            value: '$approvedCount',
            icon: Icons.check_circle_outline,
            color: Colors.green.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 38),
          const SizedBox(height: 10),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.red.shade700,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          AppButton(
            text: 'Try Again',
            icon: Icons.refresh,
            onPressed: loadRequests,
            backgroundColor: Colors.red.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(String title, String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9EEF5)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.inbox_outlined,
            color: Color(0xFF98A2B3),
            size: 44,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0B2E59),
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF667085),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList({
    required bool isAdmin,
    required bool isClient,
  }) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF0B2E59)),
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return _buildError();
    }

    if (filteredRequests.isEmpty) {
      return _buildEmpty(
        'No matching requests found',
        'Try changing the search text or status filter.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pendingRequests.isNotEmpty) ...[
          Text(
            isAdmin ? 'Pending Approval' : 'Pending Requests',
            style: const TextStyle(
              color: Color(0xFF0B2E59),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          ...pendingRequests.map(
                (request) => RequestCard(
              request: request,
              isAdmin: isAdmin,
              isClient: isClient,
              isLoading: actionLoadingId == request.requestId,
              onApprove: isAdmin ? () => _approveRequest(request) : null,
              onReject: isAdmin ? () => _rejectRequest(request) : null,
              onDelete: isClient ? () => _deleteRequest(request) : null,
            ),
          ),
        ],
        if (reviewedRequests.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text(
            'Reviewed Requests',
            style: TextStyle(
              color: Color(0xFF0B2E59),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          ...reviewedRequests.map(
                (request) => RequestCard(
              request: request,
              isAdmin: isAdmin,
              isClient: isClient,
              isLoading: actionLoadingId == request.requestId,
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    final bool isAdmin = authProvider.isAdmin;
    final bool isClient = authProvider.isClient;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: const AppDrawer(activePage: 'requests'),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            return RefreshIndicator(
              onRefresh: loadRequests,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTopBar(
                      title: 'Requests',
                      onMenuTap: () => _openDrawer(context),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      isAdmin ? 'Project Requests' : 'My Requests',
                      style: const TextStyle(
                        color: Color(0xFF0B2E59),
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isAdmin
                          ? 'Review, approve, or reject client project requests.'
                          : 'Track your submitted project requests and review their status.',
                      style: const TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildMetrics(),
                    const SizedBox(height: 18),
                    _buildSearchAndFilters(),
                    const SizedBox(height: 22),
                    _buildRequestsList(
                      isAdmin: isAdmin,
                      isClient: isClient,
                    ),
                    const SizedBox(height: 28),
                    AppFooter(
                      text: 'Need help?',
                      actionText: 'Contact Support',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    this.color = const Color(0xFF0B2E59),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 106,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9EEF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF98A2B3),
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}