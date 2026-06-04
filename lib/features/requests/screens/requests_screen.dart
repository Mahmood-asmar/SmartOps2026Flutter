import 'package:flutter/material.dart';
import 'package:smartops/core/widgets/app_drawer.dart';
import 'package:smartops/core/widgets/app_footer.dart';
import 'package:smartops/core/widgets/app_text_field.dart';
import 'package:smartops/core/widgets/app_top_bar.dart';
import 'package:smartops/features/requests/widgets/request_card.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  final TextEditingController rejectionReasonController =
      TextEditingController();

  void _openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  @override
  void dispose() {
    rejectionReasonController.dispose();
    super.dispose();
  }

  void _showRejectDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Reason For Rejection',
            style: TextStyle(
              color: Colors.red,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
          content: TextField(
            controller: rejectionReasonController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Provide specific architectural concern or reason...',
              hintStyle: const TextStyle(
                color: Color(0xFF98A2B3),
                fontSize: 13,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFFFC9C9),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.red,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                rejectionReasonController.clear();
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF0B2E59),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                rejectionReasonController.clear();
                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Request rejected successfully'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Confirm Rejection',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }

  void _approveRequest() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Request approved successfully'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: const AppDrawer(activePage: 'requests'),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTopBar(
                    title: 'Requests',
                    onMenuTap: () => _openDrawer(context),
                  ),
                  const SizedBox(height: 16),
                  const AppTextField(
                    label: 'Search',
                    hint: 'Search requests...',
                    prefixIcon: Icons.search,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Pending Approvals',
                    style: TextStyle(
                      color: Color(0xFF0B2E59),
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Administrative console for reviewing architectural project intakes and system proposals.',
                    style: TextStyle(
                      color: Color(0xFF667085),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 22),
                  RequestCard(
                    title: 'Solaris Atrium Expansion',
                    client: 'Global Arch Corp',
                    timeline: '4 months',
                    budget: '\$204k',
                    status: 'Pending',
                    statusColor: Colors.orange.shade700,
                    onReject: _showRejectDialog,
                    onApprove: _approveRequest,
                  ),
                  RequestCard(
                    title: 'Grid Integration v2',
                    client: 'Crispr. Powerlink',
                    timeline: '8 weeks',
                    budget: '\$128k',
                    status: 'Pending',
                    statusColor: Colors.orange.shade700,
                    onReject: _showRejectDialog,
                    onApprove: _approveRequest,
                  ),
                  RequestCard(
                    title: 'Hydro-Tower Cooling',
                    client: 'AquaForm Ltd',
                    timeline: '6 weeks',
                    budget: '\$92k',
                    status: 'Pending',
                    statusColor: Colors.orange.shade700,
                    onReject: _showRejectDialog,
                    onApprove: _approveRequest,
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B2E59),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL REQUESTS',
                          style: TextStyle(
                            color: Color(0xFFBFD4EA),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '124',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  AppFooter(
                   text: 'Need help?',
                   actionText: 'Contact Support',
                   onTap: () {},
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}