import 'package:flutter/material.dart';
import '../../../../core/themes/app_colors.dart';

class DocumentManagementScreen extends StatefulWidget {
  const DocumentManagementScreen({super.key});

  @override
  State<DocumentManagementScreen> createState() => _DocumentManagementScreenState();
}

class _DocumentManagementScreenState extends State<DocumentManagementScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final List<Offset?> _points = [];

  // Mock Folder & Document dataset
  final List<Map<String, dynamic>> _folders = [
    {
      'name': 'HR Policies',
      'files': [
        {'name': 'Leave_Policy_2026.pdf', 'size': '1.2 MB', 'exp': '2028-12-31'},
        {'name': 'Standard_Conduct_Guide.pdf', 'size': '850 KB', 'exp': 'N/A'}
      ]
    },
    {
      'name': 'Finance & Receipts',
      'files': [
        {'name': 'Q2_Budget_Report.xlsx', 'size': '4.5 MB', 'exp': '2026-09-30'},
        {'name': 'Travel_Policy_Rules.pdf', 'size': '2.1 MB', 'exp': '2027-06-30'}
      ]
    }
  ];

  String _currentFolder = '';
  String _ocrTextResult = '';
  bool _isOcrLoading = false;
  DateTime _expirationDate = DateTime.now().add(const Duration(days: 365));

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

  void _triggerOcrExtraction() {
    setState(() {
      _isOcrLoading = true;
      _ocrTextResult = '';
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _ocrTextResult = '### OCR PARSING RESULT:\n'
            '• Merchant Name: Hertz Car Rental\n'
            '• Transaction Date: 2026-07-18\n'
            '• Total Amount: \$245.80 USD\n'
            '• Currency Status: Verified';
        _isOcrLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Document Center'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Folder Explorer'),
            Tab(text: 'Digital Signature'),
            Tab(text: 'OCR Extract'),
            Tab(text: 'Secure Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExplorerTab(context, isDark),
          _buildSignatureTab(context, isDark),
          _buildOcrTab(context, isDark),
          _buildSettingsTab(context, isDark),
        ],
      ),
    );
  }

  // TAB 1: Folder Explorer
  Widget _buildExplorerTab(BuildContext context, bool isDark) {
    if (_currentFolder.isNotEmpty) {
      final selectedFolder = _folders.firstWhere((f) => f['name'] == _currentFolder);
      final files = selectedFolder['files'] as List;

      return WillPopScope(
        onWillPop: () async {
          setState(() => _currentFolder = '');
          return false;
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _currentFolder = '')),
                const SizedBox(width: 8),
                Text(_currentFolder, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            ...files.map((file) {
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.insert_drive_file, color: Colors.deepOrange),
                  title: Text(file['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text('File Size: ${file['size']} • Expiration: ${file['exp']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.download_outlined, size: 20), onPressed: () {}),
                      IconButton(icon: const Icon(Icons.security, size: 20, color: AppColors.success), onPressed: () {}),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Storage Folders', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.create_new_folder_outlined, size: 16),
              label: const Text('New Folder', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._folders.map((folder) {
          final fileCount = (folder['files'] as List).length;
          return Card(
            child: ListTile(
              leading: const Icon(Icons.folder, color: Colors.amber, size: 36),
              title: Text(folder['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('$fileCount documents archived'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {
                setState(() {
                  _currentFolder = folder['name'];
                });
              },
            ),
          );
        }),
      ],
    );
  }

  // TAB 2: Canvas Drawing Digital Signature Pad
  Widget _buildSignatureTab(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Digital Signature Authorization Pad', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 4),
          const Text('Draw your signature below to approve internal document agreements.', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 16),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.obsidianSurface : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: GestureDetector(
                onPanUpdate: (DragUpdateDetails details) {
                  setState(() {
                    RenderBox renderBox = context.findRenderObject() as RenderBox;
                    _points.add(renderBox.globalToLocal(details.globalPosition));
                  });
                },
                onPanEnd: (DragEndDetails details) {
                  _points.add(null);
                },
                child: CustomPaint(
                  painter: SignaturePainter(points: _points, color: isDark ? Colors.white : Colors.black87),
                  size: Size.infinite,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () => setState(() => _points.clear()),
                icon: const Icon(Icons.clear, color: Colors.red),
                label: const Text('Clear', style: TextStyle(color: Colors.red)),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Signature saved. Document workflow approved!'), backgroundColor: AppColors.success),
                  );
                },
                icon: const Icon(Icons.check),
                label: const Text('Approve Signature'),
              ),
            ],
          )
        ],
      ),
    );
  }

  // TAB 3: OCR text parser
  Widget _buildOcrTab(BuildContext context, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('OCR Text Extractor Engine', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Icon(Icons.center_focus_weak, size: 40, color: AppColors.indigoAccent),
                const SizedBox(height: 12),
                const Text('Select Receipt or Document Image to parse text', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isOcrLoading ? null : _triggerOcrExtraction,
                  child: _isOcrLoading
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Trigger OCR Parse'),
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (_ocrTextResult.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.obsidianSurface : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Text(
              _ocrTextResult,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12, height: 1.4),
            ),
          ),
      ],
    );
  }

  // TAB 4: Secure Document Settings
  Widget _buildSettingsTab(BuildContext context, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Security & Access Controls', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              const SwitchListTile(
                title: Text('Secure File Encryption', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text('AES-256 local DB block encryption for downloaded offline caches.', style: TextStyle(fontSize: 11)),
                value: true,
                onChanged: null,
              ),
              const SwitchListTile(
                title: Text('Role-Based Folder Restrict', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text('Restrict folder visibility matching superAdmin configuration guidelines.', style: TextStyle(fontSize: 11)),
                value: true,
                onChanged: null,
              ),
              ListTile(
                title: const Text('Default Expiration Date Limit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text(_expirationDate.toIso8601String().substring(0, 10)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _expirationDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  );
                  if (date != null) {
                    setState(() => _expirationDate = date);
                  }
                },
              )
            ],
          ),
        ),
      ],
    );
  }
}

// Drawing custom painter for signatures
class SignaturePainter extends CustomPainter {
  final List<Offset?> points;
  final Color color;

  SignaturePainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SignaturePainter oldDelegate) => oldDelegate.points != points;
}
