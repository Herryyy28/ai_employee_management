import 'package:flutter/material.dart';
import '../../../../core/themes/app_colors.dart';

class VisitorManagementScreen extends StatefulWidget {
  const VisitorManagementScreen({super.key});

  @override
  State<VisitorManagementScreen> createState() => _VisitorManagementScreenState();
}

class _VisitorManagementScreenState extends State<VisitorManagementScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _orgController = TextEditingController();
  final _hostController = TextEditingController();
  
  String _activeVisitorPassQr = ''; // Stores QR pass data when generated
  String _activeVisitorName = '';

  // Mock visitor database
  final List<Map<String, dynamic>> _visitorLogs = [
    {
      'name': 'Sarah Jenkins',
      'org': 'Acme Partners',
      'host': 'Jane Cooper',
      'checkIn': '10:00 AM',
      'checkOut': null,
      'status': 'checked_in'
    },
    {
      'name': 'James Miller',
      'org': 'Intel Tech',
      'host': 'Cody Fisher',
      'checkIn': '09:15 AM',
      'checkOut': '11:30 AM',
      'status': 'checked_out'
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _orgController.dispose();
    _hostController.dispose();
    super.dispose();
  }

  void _generatePass() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _activeVisitorName = _nameController.text.trim();
        _activeVisitorPassQr = 'AI-EMS-VISITOR-${_nameController.text.replaceAll(' ', '').toUpperCase()}';
        
        // Add to mock visitor logs
        _visitorLogs.insert(0, {
          'name': _nameController.text.trim(),
          'org': _orgController.text.trim(),
          'host': _hostController.text.trim(),
          'checkIn': 'Now',
          'checkOut': null,
          'status': 'checked_in'
        });

        _nameController.clear();
        _emailController.clear();
        _orgController.clear();
        _hostController.clear();
      });

      _tabController?.animateTo(1); // Auto jump to Active Pass tab
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Visitor Pass QR Code generated! Notification sent to Host.'), backgroundColor: AppColors.success),
      );
    }
  }

  void _checkoutVisitor(int index) {
    setState(() {
      _visitorLogs[index]['status'] = 'checked_out';
      _visitorLogs[index]['checkOut'] = 'Now';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitor Check-in & Passes'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Register Visitor'),
            Tab(text: 'Active QR Pass'),
            Tab(text: 'Visitor Logs'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRegisterTab(context, isDark),
          _buildPassTab(context, isDark),
          _buildLogsTab(context, isDark),
        ],
      ),
    );
  }

  // TAB 1: Register Form
  Widget _buildRegisterTab(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Pre-Register Corporate Guest', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Visitor Full Name', prefixIcon: Icon(Icons.person_outline)),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Enter visitor name' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Visitor Email Address', prefixIcon: Icon(Icons.mail_outline)),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Enter visitor email' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _orgController,
                  decoration: const InputDecoration(labelText: 'Organization / Company', prefixIcon: Icon(Icons.business_outlined)),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Enter organization name' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _hostController,
                  decoration: const InputDecoration(labelText: 'Host Employee (Sponsor)', prefixIcon: Icon(Icons.admin_panel_settings_outlined)),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Enter sponsor colleague name' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _generatePass,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Generate Visitor QR Pass'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // TAB 2: Active Pass QR Code Card
  Widget _buildPassTab(BuildContext context, bool isDark) {
    if (_activeVisitorPassQr.isEmpty) {
      return const Center(
        child: Text('No active visitor QR pass generated. Register a guest first.', style: TextStyle(color: Colors.grey, fontSize: 13)),
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          width: 320,
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('VISITOR PASS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.0, color: AppColors.indigoAccent)),
                      Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.primary, size: 20),
                    ],
                  ),
                  const Divider(height: 24),
                  // Mock QR code design
                  Container(
                    height: 180,
                    width: 180,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code_2, size: 120, color: isDark ? Colors.black87 : Colors.black87),
                          const SizedBox(height: 6),
                          FittedBox(
                            child: Text(
                              _activeVisitorPassQr,
                              style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: Colors.grey, fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(_activeVisitorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 4),
                  const Text('Approved for corporate portal access', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.share_outlined, size: 16),
                    label: const Text('Share QR Pass'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // TAB 3: Checked in list logs
  Widget _buildLogsTab(BuildContext context, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _visitorLogs.length,
      itemBuilder: (context, index) {
        final log = _visitorLogs[index];
        final isCheckedIn = log['status'] == 'checked_in';

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isCheckedIn ? AppColors.success.withOpacity(0.12) : Colors.grey.withOpacity(0.12),
              child: Icon(
                isCheckedIn ? Icons.login_outlined : Icons.logout_outlined,
                color: isCheckedIn ? AppColors.success : Colors.grey,
                size: 20,
              ),
            ),
            title: Text(log['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: Text('Sponsor: ${log['host']} • Org: ${log['org']}\nChecked-in: ${log['checkIn']}' + (log['checkOut'] != null ? ' | Out: ${log['checkOut']}' : '')),
            trailing: isCheckedIn
                ? OutlinedButton(
                    onPressed: () => _checkoutVisitor(index),
                    child: const Text('Check-out', style: TextStyle(fontSize: 11)),
                  )
                : const Text('Completed', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }
}
