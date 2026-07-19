import 'package:flutter/material.dart';
import '../../../../core/themes/app_colors.dart';

class AssetManagementScreen extends StatefulWidget {
  const AssetManagementScreen({super.key});

  @override
  State<AssetManagementScreen> createState() => _AssetManagementScreenState();
}

class _AssetManagementScreenState extends State<AssetManagementScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final _reqFormKey = GlobalKey<FormState>();
  String _selectedAssetType = 'Laptop';
  final _reasonController = TextEditingController();

  // Mock Asset Inventory
  final List<Map<String, dynamic>> _assets = [
    {'id': 'LPT-MBP-085', 'name': 'MacBook Pro M3 Max', 'type': 'Laptop', 'status': 'allocated', 'assignee': 'Jane Cooper'},
    {'id': 'LPT-TNK-102', 'name': 'Lenovo ThinkPad T14', 'type': 'Laptop', 'status': 'available', 'assignee': null},
    {'id': 'MON-LG-034', 'name': 'LG UltraWide 34"', 'type': 'Monitor', 'status': 'allocated', 'assignee': 'Cody Fisher'},
    {'id': 'MOB-IPH-021', 'name': 'iPhone 15 Pro Max', 'type': 'Mobile', 'status': 'maintenance', 'assignee': null},
  ];

  // Mock Request log
  final List<Map<String, String>> _requests = [
    {'type': 'Monitor', 'reason': 'Dual setup for DevOps testing', 'status': 'Pending Approval'},
    {'type': 'Accessories', 'reason': 'Replacement mechanical keyboard', 'status': 'Approved'}
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _submitRequest() {
    if (_reqFormKey.currentState?.validate() ?? false) {
      setState(() {
        _requests.insert(0, {
          'type': _selectedAssetType,
          'reason': _reasonController.text.trim(),
          'status': 'Pending Approval'
        });
        _reasonController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Asset request submitted to Admin!'), backgroundColor: AppColors.success),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Corporate Asset Allocation'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Asset Catalog'),
            Tab(text: 'Request Asset'),
            Tab(text: 'Maintenance Logs'),
            Tab(text: 'Print QR Tags'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCatalogTab(context, isDark),
          _buildRequestTab(context, isDark),
          _buildMaintenanceTab(context, isDark),
          _buildQrTagsTab(context, isDark),
        ],
      ),
    );
  }

  // TAB 1: Asset Catalog
  Widget _buildCatalogTab(BuildContext context, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _assets.length,
      itemBuilder: (context, index) {
        final asset = _assets[index];
        Color statusColor = Colors.green;
        String statusLabel = 'Available';

        if (asset['status'] == 'allocated') {
          statusColor = AppColors.indigoAccent;
          statusLabel = 'Allocated: ${asset['assignee']}';
        } else if (asset['status'] == 'maintenance') {
          statusColor = AppColors.warning;
          statusLabel = 'In Service';
        }

        IconData typeIcon = Icons.laptop;
        if (asset['type'] == 'Monitor') typeIcon = Icons.desktop_windows;
        if (asset['type'] == 'Mobile') typeIcon = Icons.phone_android;

        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: statusColor.withOpacity(0.12),
              child: Icon(typeIcon, color: statusColor, size: 20),
            ),
            title: Text(asset['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: Text('Asset ID: ${asset['id']} • Type: ${asset['type']}'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }

  // TAB 2: Request & Return Assets Form
  Widget _buildRequestTab(BuildContext context, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Form(
          key: _reqFormKey,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Request Hardware Allocation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedAssetType,
                    decoration: const InputDecoration(labelText: 'Hardware Category'),
                    items: const [
                      DropdownMenuItem(value: 'Laptop', child: Text('Laptop')),
                      DropdownMenuItem(value: 'Monitor', child: Text('Monitor / Screen')),
                      DropdownMenuItem(value: 'Mobile', child: Text('Smartphone')),
                      DropdownMenuItem(value: 'Accessories', child: Text('Accessories (Mouse, Keyboard)')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedAssetType = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _reasonController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Reason for requesting asset allocation'),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Enter justification reason' : null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitRequest,
                    child: const Text('Submit Request Form'),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text('Your Asset Requests History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),
        ..._requests.map((req) {
          final isPending = req['status'] == 'Pending Approval';
          return Card(
            child: ListTile(
              leading: const Icon(Icons.history_outlined),
              title: Text('Allocation: ${req['type']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text('Justification: "${req['reason']}"'),
              trailing: Text(
                req['status']!,
                style: TextStyle(
                  color: isPending ? AppColors.warning : AppColors.success,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // TAB 3: Maintenance log
  Widget _buildMaintenanceTab(BuildContext context, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Asset Service & Warranty Checks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: const [
              ListTile(
                leading: Icon(Icons.build_outlined, color: AppColors.warning),
                title: Text('iPhone 15 Pro Max (MOB-IPH-021)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text('Reason: Battery swelling replacement • Status: In Progress'),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.verified_outlined, color: AppColors.success),
                title: Text('MacBook Pro M3 Max (LPT-MBP-085)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text('Reason: Annual dust cleaning & paste check • Status: Completed (Jul 12)'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // TAB 4: Barcode Printable tags
  Widget _buildQrTagsTab(BuildContext context, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Generate Asset QR Labels', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.print_outlined, size: 16),
              label: const Text('Print All labels', style: TextStyle(fontSize: 12)),
            )
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _assets.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemBuilder: (context, index) {
            final asset = _assets[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(asset['id'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, fontFamily: 'monospace')),
                    const Icon(Icons.qr_code, size: 54, color: Colors.black87),
                    Text(asset['name'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
