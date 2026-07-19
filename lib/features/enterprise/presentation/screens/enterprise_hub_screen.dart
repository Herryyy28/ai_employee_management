import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/themes/app_colors.dart';

class EnterpriseHubScreen extends StatefulWidget {
  const EnterpriseHubScreen({super.key});

  @override
  State<EnterpriseHubScreen> createState() => _EnterpriseHubScreenState();
}

class _EnterpriseHubScreenState extends State<EnterpriseHubScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _searchQuery = '';

  // Mock global dataset for Smart Search
  final List<Map<String, String>> _mockSearchDatabase = [
    {'type': 'Employee', 'title': 'Jane Cooper', 'subtitle': 'HR Manager - Active', 'category': 'HR'},
    {'type': 'Employee', 'title': 'Cody Fisher', 'subtitle': 'Lead DevOps Engineer', 'category': 'Security'},
    {'type': 'Project', 'title': 'Supabase RLS Rollout', 'subtitle': 'Sprint 3 - In Progress', 'category': 'Projects'},
    {'type': 'Project', 'title': 'Biometric Authentication', 'subtitle': 'Planning Phase', 'category': 'Security'},
    {'type': 'Task', 'title': 'Configure two-factor UI', 'subtitle': 'Assigned to Cody - Critical', 'category': 'Security'},
    {'type': 'Task', 'title': 'Draft salary templates', 'subtitle': 'Assigned to Jane - Medium', 'category': 'Finance'},
    {'type': 'Document', 'title': 'Company Handbook 2026', 'subtitle': 'Version 2.1 - SOP approved', 'category': 'HR'},
    {'type': 'Document', 'title': 'Expense Policy PDF', 'subtitle': 'Expiration Dec 2026', 'category': 'Finance'},
    {'type': 'Asset', 'title': 'Dell UltraSharp 34" Monitor', 'subtitle': 'Allocated to Cody - Warranty Active', 'category': 'Assets'},
    {'type': 'Asset', 'title': 'MacBook Pro M3 Max', 'subtitle': 'Allocated to Jane - Active', 'category': 'Assets'},
    {'type': 'Meeting', 'title': 'Weekly Sync: Project Health', 'subtitle': 'Every Monday 10:00 AM', 'category': 'Projects'},
    {'type': 'Leave', 'title': 'Casual Leave Request - Jane', 'subtitle': 'Approved by Admin', 'category': 'HR'},
  ];

  final List<String> _filters = ['All', 'AI', 'Projects', 'Finance', 'HR', 'Security', 'Assets'];

  final List<Map<String, dynamic>> _modules = [
    {
      'title': 'AI Assistant & Copilot',
      'desc': 'Recruitment parsing, policy Q&A, scheduler & workforce insights.',
      'icon': Icons.auto_awesome_outlined,
      'color': AppColors.electricViolet,
      'route': '/enterprise/ai-assistant',
      'badge': 'AI Powered'
    },
    {
      'title': 'Project Management',
      'desc': 'Scrum boards, sprint calendars, Gantt charts, risk logs & health scores.',
      'icon': Icons.workspaces_outline,
      'color': AppColors.indigoAccent,
      'route': '/enterprise/projects',
      'badge': 'Active'
    },
    {
      'title': 'Collaboration Chat',
      'desc': 'Team chats, thread replies, channels, file sharing & shared note pads.',
      'icon': Icons.forum_outlined,
      'color': Colors.teal,
      'route': '/enterprise/collaboration',
    },
    {
      'title': 'Secure Document Hub',
      'desc': 'Upload archives, digital signature pad, workflow approvals & OCR parser.',
      'icon': Icons.description_outlined,
      'color': Colors.deepOrange,
      'route': '/enterprise/documents',
    },
    {
      'title': 'Visitor Registration',
      'desc': 'Digital visitor logs, QR access passes & analytics dashboards.',
      'icon': Icons.badge_outlined,
      'color': Colors.amber,
      'route': '/enterprise/visitors',
    },
    {
      'title': 'Asset Allocation',
      'desc': 'Hardware tracking catalog, QR labels generator & returns scheduler.',
      'icon': Icons.devices_outlined,
      'color': Colors.purple,
      'route': '/enterprise/assets',
    },
    {
      'title': 'Finance & Payroll',
      'desc': 'Salary templates, tax PF calculators, payslips & expense claims tracking.',
      'icon': Icons.payments_outlined,
      'color': AppColors.success,
      'route': '/enterprise/finance',
    },
    {
      'title': 'Learning & Ticketing',
      'desc': 'LMS video courses, interactive quizzes & SLA Help Desk tickets.',
      'icon': Icons.school_outlined,
      'color': Colors.pink,
      'route': '/enterprise/learning-wellness',
    },
    {
      'title': 'Wellness & Rewards',
      'desc': 'Mood checkins, water break alerts, peer badges & employee spotlight.',
      'icon': Icons.favorite_border_outlined,
      'color': Colors.redAccent,
      'route': '/enterprise/wellness',
    },
    {
      'title': 'Portal Customization',
      'desc': 'White labeling, brand colors, theme options & 2FA security audit logs.',
      'icon': Icons.tune_outlined,
      'color': Colors.blueGrey,
      'route': '/enterprise/settings',
      'badge': 'Admin Only'
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> _getFilteredSearchResults() {
    if (_searchQuery.trim().isEmpty) return [];
    return _mockSearchDatabase.where((item) {
      final matchesSearch = item['title']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item['subtitle']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item['type']!.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesFilter = _selectedFilter == 'All' || item['category'] == _selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = _getFilteredSearchResults();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.business, color: AppColors.indigoAccent),
            SizedBox(width: 8),
            Text('Enterprise Portal Suite'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Smart Search Header Section
              _buildSearchHeader(context, isDark),
              const SizedBox(height: 24),

              // Filter Chips
              _buildFilterChips(context),
              const SizedBox(height: 24),

              // Search Results display or Full Grid View
              _searchQuery.trim().isNotEmpty
                  ? _buildSearchResultsSection(context, searchResults, isDark)
                  : _buildModulesGrid(context, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.obsidianSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Smart Global Directory',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Instantly lookup colleagues, active sprints, documents, assets, and payroll schedules.',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 16),
          // Search Input Bar
          TextField(
            controller: _searchController,
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search across portal directories...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              filled: true,
              fillColor: isDark ? AppColors.obsidianBackground : Colors.grey[50],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(
                filter,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (val) {
                if (val) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchResultsSection(
      BuildContext context, List<Map<String, String>> results, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Search Results (${results.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                });
              },
              child: const Text('Clear Search', style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (results.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Column(
                children: [
                  Icon(Icons.search_off_outlined, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  const Text('No records match your query or category filters.',
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final item = results[index];
              IconData itemIcon = Icons.info_outline;
              Color iconColor = AppColors.indigoAccent;

              switch (item['type']) {
                case 'Employee':
                  itemIcon = Icons.person_outline;
                  iconColor = Colors.teal;
                  break;
                case 'Project':
                  itemIcon = Icons.workspaces_outline;
                  iconColor = AppColors.electricViolet;
                  break;
                case 'Task':
                  itemIcon = Icons.task_alt;
                  iconColor = AppColors.warning;
                  break;
                case 'Document':
                  itemIcon = Icons.description_outlined;
                  iconColor = Colors.deepOrange;
                  break;
                case 'Asset':
                  itemIcon = Icons.devices_outlined;
                  iconColor = Colors.purple;
                  break;
                case 'Meeting':
                  itemIcon = Icons.videocam_outlined;
                  iconColor = Colors.blue;
                  break;
                case 'Leave':
                  itemIcon = Icons.time_to_leave_outlined;
                  iconColor = Colors.redAccent;
                  break;
              }

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: iconColor.withOpacity(0.1),
                    child: Icon(itemIcon, color: iconColor, size: 20),
                  ),
                  title: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text(item['subtitle']!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item['type']!.toUpperCase(),
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildModulesGrid(BuildContext context, bool isDark) {
    final width = MediaQuery.of(context).size.width;
    final gridCount = width > 1024 ? 3 : (width > 600 ? 2 : 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Advanced Services Directory',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _modules.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: width > 600 ? 1.6 : 2.1,
          ),
          itemBuilder: (context, index) {
            final mod = _modules[index];
            final Color accentColor = mod['color'];

            return InkWell(
              onTap: () {
                context.go(mod['route']);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.obsidianSurface : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.01),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(mod['icon'], color: accentColor, size: 24),
                        ),
                        if (mod['badge'] != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              mod['badge'],
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mod['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mod['desc'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
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
