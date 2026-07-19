import 'package:flutter/material.dart';
import '../../../../core/themes/app_colors.dart';

class ProjectManagementScreen extends StatefulWidget {
  const ProjectManagementScreen({super.key});

  @override
  State<ProjectManagementScreen> createState() => _ProjectManagementScreenState();
}

class _ProjectManagementScreenState extends State<ProjectManagementScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  final List<Map<String, dynamic>> _kanbanTasks = [
    {
      'title': 'Setup Supabase Row-Level Security',
      'col': 'todo',
      'priority': 'critical',
      'assignee': 'Cody F.',
      'sprint': 'Sprint 3'
    },
    {
      'title': 'Build White Label Theme Customizer',
      'col': 'in_progress',
      'priority': 'high',
      'assignee': 'Alice V.',
      'sprint': 'Sprint 3'
    },
    {
      'title': 'Digital Signature Canvas Integration',
      'col': 'review',
      'priority': 'medium',
      'assignee': 'David C.',
      'sprint': 'Sprint 2'
    },
    {
      'title': 'Database Schema Design Mapping',
      'col': 'completed',
      'priority': 'low',
      'assignee': 'Jane C.',
      'sprint': 'Sprint 1'
    },
  ];

  final List<Map<String, dynamic>> _ganttTimeline = [
    {'phase': 'Requirement Analysis', 'start': '07-01', 'end': '07-05', 'progress': 1.0, 'color': Colors.blue},
    {'phase': 'UI Wireframes Design', 'start': '07-06', 'end': '07-12', 'progress': 0.85, 'color': Colors.purple},
    {'phase': 'Database & Auth Setup', 'start': '07-13', 'end': '07-20', 'progress': 0.9, 'color': Colors.teal},
    {'phase': 'Core Modules Coding', 'start': '07-21', 'end': '08-15', 'progress': 0.25, 'color': AppColors.indigoAccent},
  ];

  final List<Map<String, dynamic>> _riskRegister = [
    {
      'risk': 'Supabase API rate limits exceeded',
      'mitigation': 'Implement Hive local query cache checks & queue batching.',
      'status': 'Managed',
      'severity': 'High'
    },
    {
      'risk': 'Delays in client signoffs on Figma assets',
      'mitigation': 'Deploy client portal early with interactive reviews.',
      'status': 'Monitored',
      'severity': 'Medium'
    }
  ];

  final List<Map<String, dynamic>> _resourceAllocations = [
    {'name': 'Jane Cooper', 'project': 'Acme HR Portal', 'allocation': '80% (Client)'},
    {'name': 'Cody Fisher', 'project': 'Internal DevOps CI/CD', 'allocation': '100% (Internal)'},
    {'name': 'David Chen', 'project': 'Acme HR Portal', 'allocation': '50% (Client)'},
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

  void _moveKanbanTask(int index, String newCol) {
    setState(() {
      _kanbanTasks[index]['col'] = newCol;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project & Sprint Manager'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Kanban Board'),
            Tab(text: 'Gantt Timeline'),
            Tab(text: 'Risk & Budgets'),
            Tab(text: 'Health & Resources'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildKanbanTab(context, isDark),
          _buildGanttTab(context, isDark),
          _buildRiskBudgetTab(context, isDark),
          _buildHealthResourceTab(context, isDark),
        ],
      ),
    );
  }

  // TAB 1: Kanban Board columns
  Widget _buildKanbanTab(BuildContext context, bool isDark) {
    final columns = ['todo', 'in_progress', 'review', 'completed'];
    final width = MediaQuery.of(context).size.width;
    final isTablet = width > 768;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: isTablet
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: columns.map((col) => Expanded(child: _buildKanbanColumn(context, col, isDark))).toList(),
            )
          : ListView(
              children: columns.map((col) => _buildKanbanColumn(context, col, isDark)).toList(),
            ),
    );
  }

  Widget _buildKanbanColumn(BuildContext context, String col, bool isDark) {
    final columnTasks = _kanbanTasks.where((t) => t['col'] == col).toList();
    String title = col.toUpperCase();
    if (col == 'in_progress') title = 'IN PROGRESS';

    return Container(
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.obsidianSurface : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                CircleAvatar(
                  radius: 10,
                  backgroundColor: Theme.of(context).dividerColor,
                  child: Text('${columnTasks.length}', style: const TextStyle(fontSize: 10)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: columnTasks.length,
            itemBuilder: (context, index) {
              final task = columnTasks[index];
              final globalIndex = _kanbanTasks.indexOf(task);
              Color priorityColor = Colors.grey;
              if (task['priority'] == 'critical') priorityColor = AppColors.error;
              if (task['priority'] == 'high') priorityColor = AppColors.warning;
              if (task['priority'] == 'medium') priorityColor = AppColors.indigoAccent;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: priorityColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(task['priority'].toUpperCase(), style: TextStyle(color: priorityColor, fontSize: 8, fontWeight: FontWeight.bold)),
                          ),
                          Text(task['sprint'], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(task['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const CircleAvatar(radius: 8, child: Icon(Icons.person, size: 10)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    task['assignee'],
                                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Dropdown to quick switch kanban status
                          DropdownButton<String>(
                            value: col,
                            underline: const SizedBox(),
                            icon: const Icon(Icons.swap_horiz, size: 14, color: Colors.grey),
                            items: const [
                              DropdownMenuItem(value: 'todo', child: Text('Todo', style: TextStyle(fontSize: 11))),
                              DropdownMenuItem(value: 'in_progress', child: Text('In Progress', style: TextStyle(fontSize: 11))),
                              DropdownMenuItem(value: 'review', child: Text('Review', style: TextStyle(fontSize: 11))),
                              DropdownMenuItem(value: 'completed', child: Text('Done', style: TextStyle(fontSize: 11))),
                            ],
                            onChanged: (val) {
                              if (val != null) _moveKanbanTask(globalIndex, val);
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // TAB 2: Gantt Chart View
  Widget _buildGanttTab(BuildContext context, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Sprint Roadmap & Gantt Timelines', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 16),
        ..._ganttTimeline.map((item) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item['phase'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('${item['start']} to ${item['end']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: item['progress'],
                    color: item['color'],
                    backgroundColor: item['color'].withOpacity(0.12),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Completion: ${(item['progress'] * 100).toInt()}%', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      const Icon(Icons.arrow_right_alt, size: 16, color: Colors.grey),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // TAB 3: Risk & Budgets
  Widget _buildRiskBudgetTab(BuildContext context, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Budget trackers cards
        const Text('Financial Budget Tracking', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Supabase Client Project Budget', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text('\$45,000 Total', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.success)),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Budget Utilization: \$31,500 Expended', style: TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: 0.7,
                  color: AppColors.indigoAccent,
                  backgroundColor: AppColors.indigoAccent.withOpacity(0.12),
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Risk Register
        const Text('Active Project Risk Register', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 12),
        ..._riskRegister.map((risk) {
          Color severityColor = Colors.orange;
          if (risk['severity'] == 'High') severityColor = AppColors.error;

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(risk['risk'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: severityColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(risk['severity'].toUpperCase(), style: TextStyle(color: severityColor, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Mitigation: ${risk['mitigation']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Status: ${risk['status']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      const Icon(Icons.shield_outlined, size: 14, color: Colors.grey),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // TAB 4: Health & Resources Allocations
  Widget _buildHealthResourceTab(BuildContext context, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Health score metric
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 70,
                      width: 70,
                      child: CircularProgressIndicator(
                        value: 0.94,
                        strokeWidth: 8,
                        color: AppColors.success,
                        backgroundColor: AppColors.success.withOpacity(0.12),
                      ),
                    ),
                    const Text('94', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  ],
                ),
                const SizedBox(width: 24),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Project Health Index', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 4),
                      Text('All deliverables matching roadmap SLA benchmarks. Risk levels stabilized.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        const Text('Resource Allocations (Client vs Internal)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 12),

        ..._resourceAllocations.map((res) {
          return Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_outline)),
              title: Text(res['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text(res['project']!),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.indigoAccent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(res['allocation']!, style: const TextStyle(fontSize: 10, color: AppColors.indigoAccent, fontWeight: FontWeight.bold)),
              ),
            ),
          );
        }),
      ],
    );
  }
}
