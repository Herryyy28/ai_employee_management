import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/controllers/auth_state.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../controllers/leaves_controller.dart';
import '../../data/models/leave_model.dart';
import '../../../../core/themes/app_colors.dart';

class LeavesScreen extends ConsumerStatefulWidget {
  const LeavesScreen({super.key});

  @override
  ConsumerState<LeavesScreen> createState() => _LeavesScreenState();
}

class _LeavesScreenState extends ConsumerState<LeavesScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    // Tab controller will be initialized dynamically in build once user role is loaded
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _showApplyLeaveSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ApplyLeaveBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final state = ref.watch(leavesControllerProvider);
    
    final user = authState is AuthAuthenticated ? authState.user : null;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isAdmin = user.role == UserRole.superAdmin || user.role == UserRole.companyAdmin || user.role == UserRole.manager;

    if (isAdmin && _tabController == null) {
      _tabController = TabController(length: 2, vsync: this);
    }

    ref.listen<LeavesState>(leavesControllerProvider, (previous, current) {
      if (current.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(current.errorMessage!), backgroundColor: AppColors.error),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.time_to_leave_outlined),
            SizedBox(width: 8),
            Text('Leave Manager'),
          ],
        ),
        bottom: isAdmin
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'My Requests'),
                  Tab(text: 'Review Board'),
                ],
              )
            : null,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : (isAdmin
              ? TabBarView(
                  controller: _tabController,
                  children: [
                    _buildEmployeeLeaveView(context, state.employeeLeaves),
                    _buildAdminReviewView(context, state.companyLeaves, user.id),
                  ],
                )
              : _buildEmployeeLeaveView(context, state.employeeLeaves)),
      floatingActionButton: !isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showApplyLeaveSheet(context),
              icon: const Icon(Icons.add),
              label: const Text('Apply Leave'),
            )
          : null,
    );
  }

  Widget _buildEmployeeLeaveView(BuildContext context, List<LeaveModel> leaves) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Balances Overview Cards
          _buildLeaveBalances(context),
          const SizedBox(height: 24),
          
          Text(
            'Request Log',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          
          if (leaves.isEmpty)
            _buildEmptyState(context, 'No leave requests submitted yet.')
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: leaves.length,
              itemBuilder: (context, index) {
                final leave = leaves[index];
                return _buildLeaveItem(context, leave);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLeaveBalances(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.1,
      children: [
        _buildBalanceCard(context, 'Casual', '12 / 15', Colors.blue),
        _buildBalanceCard(context, 'Sick', '4 / 8', Colors.orange),
        _buildBalanceCard(context, 'Earned', '8 / 20', Colors.green),
      ],
    );
  }

  Widget _buildBalanceCard(BuildContext context, String label, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminReviewView(BuildContext context, List<LeaveModel> leaves, String adminId) {
    final pendingLeaves = leaves.where((l) => l.status == 'pending').toList();

    if (pendingLeaves.isEmpty) {
      return _buildEmptyState(context, 'No pending reviews at this moment.');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pendingLeaves.length,
      itemBuilder: (context, index) {
        final leave = pendingLeaves[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Leave Type: ${leave.leaveType.toUpperCase()}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${leave.startDate.toIso8601String().substring(0, 10)} to ${leave.endDate.toIso8601String().substring(0, 10)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Reason: "${leave.reason}"',
                  style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        ref.read(leavesControllerProvider.notifier).reviewLeave(
                              id: leave.id!,
                              status: 'rejected',
                              reviewerId: adminId,
                              comments: 'Request rejected by Manager.',
                            );
                      },
                      icon: const Icon(Icons.close, color: Colors.red, size: 18),
                      label: const Text('Reject', style: TextStyle(color: Colors.red)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.read(leavesControllerProvider.notifier).reviewLeave(
                              id: leave.id!,
                              status: 'approved',
                              reviewerId: adminId,
                              comments: 'Approved.',
                            );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Approve'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeaveItem(BuildContext context, LeaveModel leave) {
    Color statusColor = Colors.orange;
    if (leave.status == 'approved') statusColor = AppColors.success;
    if (leave.status == 'rejected') statusColor = AppColors.error;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${leave.leaveType.toUpperCase()} LEAVE',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '${leave.startDate.toIso8601String().substring(0, 10)} to ${leave.endDate.toIso8601String().substring(0, 10)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                leave.status.toUpperCase(),
                style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.history_toggle_off, size: 48, color: Colors.grey[600]),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class ApplyLeaveBottomSheet extends ConsumerStatefulWidget {
  const ApplyLeaveBottomSheet({super.key});

  @override
  ConsumerState<ApplyLeaveBottomSheet> createState() => _ApplyLeaveBottomSheetState();
}

class _ApplyLeaveBottomSheetState extends ConsumerState<ApplyLeaveBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  String _selectedType = 'casual';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(leavesControllerProvider.notifier).applyLeave(
            leaveType: _selectedType,
            startDate: _startDate,
            endDate: _endDate,
            reason: _reasonController.text.trim(),
          );
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Leave application submitted successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Apply for Leave',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Leave Type'),
              items: const [
                DropdownMenuItem(value: 'casual', child: Text('Casual Leave')),
                DropdownMenuItem(value: 'sick', child: Text('Sick Leave')),
                DropdownMenuItem(value: 'earned', child: Text('Earned Leave')),
                DropdownMenuItem(value: 'unpaid', child: Text('Unpaid Leave')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedType = val);
              },
            ),
            const SizedBox(height: 16),
            // Start Date picker
            ListTile(
              title: const Text('Start Date'),
              subtitle: Text('${_startDate.toIso8601String().substring(0, 10)}'),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    _startDate = date;
                    if (_endDate.isBefore(_startDate)) {
                      _endDate = _startDate.add(const Duration(days: 1));
                    }
                  });
                }
              },
            ),
            // End Date picker
            ListTile(
              title: const Text('End Date'),
              subtitle: Text('${_endDate.toIso8601String().substring(0, 10)}'),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _endDate,
                  firstDate: _startDate,
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => _endDate = date);
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for leave',
                hintText: 'Brief description...',
              ),
              maxLines: 3,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please provide a reason';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Submit Application'),
            ),
          ],
        ),
      ),
    );
  }
}
