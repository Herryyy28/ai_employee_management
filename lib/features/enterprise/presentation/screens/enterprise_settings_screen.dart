import 'package:flutter/material.dart';
import '../../../../core/themes/app_colors.dart';

class EnterpriseSettingsScreen extends StatefulWidget {
  const EnterpriseSettingsScreen({super.key});

  @override
  State<EnterpriseSettingsScreen> createState() => _EnterpriseSettingsScreenState();
}

class _EnterpriseSettingsScreenState extends State<EnterpriseSettingsScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  // Customization variables
  String _portalTitle = 'Enterprise Portal';
  Color _brandColor = AppColors.indigoAccent;
  String _language = 'English';
  bool _isRtl = false;
  String _currency = 'USD (\$)';
  String _timezone = 'UTC (GMT+0)';

  // Security variables
  bool _twoFactorEnabled = false;
  final List<Map<String, String>> _sessions = [
    {'device': 'Chrome / Windows 11', 'ip': '192.168.1.104', 'loc': 'San Francisco, USA', 'status': 'Current Session'},
    {'device': 'iPhone 15 / iOS', 'ip': '172.56.24.12', 'loc': 'London, UK', 'status': 'Active 2h ago'}
  ];

  // Offline variables
  bool _isOnline = true;
  final List<Map<String, String>> _offlineQueue = [
    {'action': 'Attendance Check-in', 'time': '10:05 AM', 'payload': 'lat: 37.77, lng: -122.41'},
    {'action': 'New Kanban Task', 'time': '11:15 AM', 'payload': 'title: "Audit RLS config"'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _revokeSession(int idx) {
    setState(() {
      _sessions.removeAt(idx);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session revoked successfully!'), backgroundColor: AppColors.success),
    );
  }

  void _forceSync() {
    setState(() {
      _offlineQueue.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Local offline cache synchronized with Supabase!'), backgroundColor: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_portalTitle),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'White Label'),
              Tab(text: 'Security'),
              Tab(text: 'Offline Sync'),
              Tab(text: 'BI Telemetry'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildWhiteLabelTab(context, isDark),
            _buildSecurityTab(context, isDark),
            _buildOfflineTab(context, isDark),
            _buildTelemetryTab(context, isDark),
          ],
        ),
      ),
    );
  }

  // TAB 1: White Label Customizer
  Widget _buildWhiteLabelTab(BuildContext context, bool isDark) {
    final colors = [AppColors.indigoAccent, AppColors.electricViolet, Colors.teal, Colors.deepOrange, Colors.purple];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Dynamic Brand Customization', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: _portalTitle,
                  decoration: const InputDecoration(labelText: 'Portal Brand Title'),
                  onChanged: (val) {
                    setState(() {
                      _portalTitle = val.trim().isEmpty ? 'Enterprise Portal' : val;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text('Primary Accent Branding Color', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  children: colors.map((col) {
                    final isSelected = _brandColor == col;
                    return GestureDetector(
                      onTap: () => setState(() => _brandColor = col),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          color: col,
                          shape: BoxShape.circle,
                          border: Border.all(color: isSelected ? (isDark ? Colors.white : Colors.black87) : Colors.transparent, width: 2),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _language,
                  decoration: const InputDecoration(labelText: 'Portal Language'),
                  items: const [
                    DropdownMenuItem(value: 'English', child: Text('English')),
                    DropdownMenuItem(value: 'Spanish', child: Text('Spanish')),
                    DropdownMenuItem(value: 'Arabic (RTL)', child: Text('Arabic (RTL)')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _language = val;
                        _isRtl = val.contains('RTL');
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _currency,
                        decoration: const InputDecoration(labelText: 'Base Currency'),
                        items: const [
                          DropdownMenuItem(value: 'USD (\$)', child: Text('USD (\$)')),
                          DropdownMenuItem(value: 'EUR (€)', child: Text('EUR (€)')),
                          DropdownMenuItem(value: 'INR (₹)', child: Text('INR (₹)')),
                        ],
                        onChanged: (val) => setState(() => _currency = val!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _timezone,
                        decoration: const InputDecoration(labelText: 'Primary Timezone'),
                        items: const [
                          DropdownMenuItem(value: 'UTC (GMT+0)', child: Text('UTC (GMT+0)')),
                          DropdownMenuItem(value: 'EST (GMT-5)', child: Text('EST (GMT-5)')),
                          DropdownMenuItem(value: 'IST (GMT+5:30)', child: Text('IST (GMT+5:30)')),
                        ],
                        onChanged: (val) => setState(() => _timezone = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: _brandColor),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: const Text('Dynamic branding config applied successfully!'), backgroundColor: _brandColor),
                    );
                  },
                  child: const Text('Apply Changes'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // TAB 2: Security & Device session audit
  Widget _buildSecurityTab(BuildContext context, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: SwitchListTile(
            title: const Text('Two-Factor Authentication (2FA)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: const Text('Require OTP security code on top of standard credentials.', style: TextStyle(fontSize: 11)),
            value: _twoFactorEnabled,
            onChanged: (val) => setState(() => _twoFactorEnabled = val),
          ),
        ),
        const SizedBox(height: 24),

        const Text('Active Device Login Sessions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),

        ...List.generate(_sessions.length, (idx) {
          final s = _sessions[idx];
          final isCurrent = s['status'] == 'Current Session';
          return Card(
            child: ListTile(
              leading: Icon(s['device']!.contains('Chrome') ? Icons.computer : Icons.phone_iphone, color: isCurrent ? AppColors.success : Colors.grey),
              title: Text(s['device']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text('IP Address: ${s['ip']} • Location: ${s['loc']}'),
              trailing: isCurrent
                  ? Text(s['status']!, style: const TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold))
                  : OutlinedButton(onPressed: () => _revokeSession(idx), child: const Text('Revoke', style: TextStyle(fontSize: 10))),
            ),
          );
        }),
      ],
    );
  }

  // TAB 3: Offline operation & sync queue
  Widget _buildOfflineTab(BuildContext context, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: _isOnline ? AppColors.success.withOpacity(0.08) : AppColors.error.withOpacity(0.08),
          child: ListTile(
            leading: Icon(_isOnline ? Icons.cloud_done : Icons.cloud_off, color: _isOnline ? AppColors.success : AppColors.error),
            title: Text(_isOnline ? 'System Status: Connected (Online)' : 'System Status: Offline', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: const Text('Offline check-ins and tasks queue automatically for replication syncing.'),
            trailing: Switch(
              value: _isOnline,
              onChanged: (val) => setState(() => _isOnline = val),
            ),
          ),
        ),
        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Pending Sync Database Queue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            if (_offlineQueue.isNotEmpty)
              ElevatedButton.icon(
                onPressed: _forceSync,
                icon: const Icon(Icons.sync, size: 16),
                label: const Text('Sync Queue Now', style: TextStyle(fontSize: 11)),
              )
          ],
        ),
        const SizedBox(height: 12),

        if (_offlineQueue.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: Text('All local cache entries synced. Queue empty.', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
            ),
          )
        else
          ..._offlineQueue.map((item) {
            return Card(
              child: ListTile(
                leading: const Icon(Icons.history_toggle_off),
                title: Text(item['action']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text('Queued: ${item['time']} • Payload: ${item['payload']}'),
              ),
            );
          }),
      ],
    );
  }

  // TAB 4: BI Telemetry
  Widget _buildTelemetryTab(BuildContext context, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Business Intelligence Telemetry (Visuals)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildMetricCard('Daily Active Users (DAU)', '14,210', Icons.people_outline, AppColors.indigoAccent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard('Monthly Active Users (MAU)', '102,400', Icons.analytics_outlined, Colors.teal),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard('API Latency', '84 ms', Icons.speed_outlined, AppColors.success),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard('Crash Rate', '0.04%', Icons.bug_report_outlined, AppColors.error),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey))),
                Icon(icon, color: color, size: 16),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
