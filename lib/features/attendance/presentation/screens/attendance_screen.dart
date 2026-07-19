import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/attendance_controller.dart';
import '../../../../core/themes/app_colors.dart';
import 'qr_scanner_screen.dart';


class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(attendanceControllerProvider);
    final today = state.todayRecord;

    ref.listen<AttendanceState>(attendanceControllerProvider, (previous, current) {
      if (current.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(current.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline),
            const SizedBox(width: 8),
            Text('Attendance Portal'),
          ],
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                ref.read(attendanceControllerProvider.notifier).loadTodayStatus();
                ref.read(attendanceControllerProvider.notifier).loadHistory();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Date & Time Banner
                    _buildTimeBanner(context),
                    const SizedBox(height: 20),

                    // Big interactive Check-in Check-out status card
                    _buildActionCard(context, ref, today),
                    const SizedBox(height: 28),

                    // Title for History log
                    Text(
                      'Attendance Logs',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),

                    // List of logs
                    if (state.history.isEmpty)
                      _buildEmptyState(context)
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.history.length,
                        itemBuilder: (context, index) {
                          final log = state.history[index];
                          return _buildHistoryItem(context, log);
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTimeBanner(BuildContext context) {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateStr = '${now.day} ${months[now.month - 1]}, ${now.year}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Today\'s Date',
            style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w500),
          ),
          Text(
            dateStr,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, WidgetRef ref, dynamic today) {
    final hasClockedIn = today != null;
    final hasClockedOut = today?.clockOut != null;

    Color statusColor = AppColors.error;
    String statusText = 'Not Logged';
    String actionLabel = 'Clock In';
    IconData actionIcon = Icons.fingerprint;

    if (hasClockedIn && !hasClockedOut) {
      statusColor = AppColors.success;
      statusText = 'Logged In';
      actionLabel = 'Clock Out';
      actionIcon = Icons.exit_to_app;
    } else if (hasClockedOut) {
      statusColor = Colors.grey;
      statusText = 'Completed';
      actionLabel = 'Shift Over';
      actionIcon = Icons.done_all;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Shift Tracker',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Circular action trigger
            Center(
              child: InkWell(
                onTap: hasClockedOut
                    ? null
                    : () {
                        final controller = ref.read(attendanceControllerProvider.notifier);
                        if (!hasClockedIn) {
                          // Mocking GPS Lat/Lng lookup check-in
                          controller.clockIn(lat: 37.7749, lng: -122.4194);
                        } else {
                          controller.clockOut(lat: 37.7749, lng: -122.4194);
                        }
                      },
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: hasClockedOut 
                        ? Colors.grey.withOpacity(0.1) 
                        : (hasClockedIn ? AppColors.error.withOpacity(0.1) : AppColors.success.withOpacity(0.1)),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: hasClockedOut 
                          ? Colors.grey 
                          : (hasClockedIn ? AppColors.error : AppColors.success),
                      width: 4,
                    ),
                  ),
                  child: Icon(
                    actionIcon,
                    size: 48,
                    color: hasClockedOut 
                        ? Colors.grey 
                        : (hasClockedIn ? AppColors.error : AppColors.success),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              actionLabel,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            if (hasClockedIn) ...[
              Text(
                'In: ${_formatTime(today.clockIn)}' + (hasClockedOut ? ' | Out: ${_formatTime(today.clockOut)}' : ''),
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ] else ...[
              const Text(
                'Requires Location (GPS Fenced)',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const QrScannerScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Clock In via Terminal QR'),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, dynamic log) {
    Color badgeColor = AppColors.success;
    if (log.status == 'late') badgeColor = AppColors.warning;
    if (log.status == 'absent') badgeColor = AppColors.error;

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
                  log.date,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Clock In: ${_formatTime(log.clockIn)}' + (log.clockOut != null ? ' - Out: ${_formatTime(log.clockOut)}' : ' (Active)'),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                log.status.toUpperCase(),
                style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.history, size: 48, color: Colors.grey[600]),
          const SizedBox(height: 12),
          const Text(
            'No history found for this period',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final min = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$min';
  }
}
