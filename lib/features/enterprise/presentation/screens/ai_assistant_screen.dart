import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/themes/app_colors.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final TextEditingController _qaController = TextEditingController();
  final List<Map<String, dynamic>> _chatHistory = [];
  bool _isChatLoading = false;
  String _selectedSop = 'Holiday Guidelines';
  String _sopSummary = '';
  bool _isSopLoading = false;

  // Mock Resume Parsed data
  final List<Map<String, dynamic>> _candidates = [
    {
      'name': 'Sarah Jenkins',
      'role': 'Senior Flutter Dev',
      'score': 95,
      'skills': ['Flutter', 'Riverpod', 'Hive', 'CI/CD'],
      'questions': [
        'How do you manage complex states offline using Hive and Riverpod?',
        'Describe your strategy for ensuring 90%+ test coverage in Flutter.'
      ]
    },
    {
      'name': 'David Chen',
      'role': 'Fullstack Engineer',
      'score': 88,
      'skills': ['Dart', 'PostgreSQL', 'Supabase', 'NodeJS'],
      'questions': [
        'How do you structure Row-Level Security policies in Supabase for multi-tenant apps?',
        'Explain your experience with PostgreSQL triggers and channel replication.'
      ]
    },
    {
      'name': 'Emma Watson',
      'role': 'UI/UX Mobile Designer',
      'score': 82,
      'skills': ['Figma', 'Material Design 3', 'Micro-interactions'],
      'questions': [
        'How do you hand off design tokens to Flutter engineers?',
        'Detail your approach to responsive layouts across desktop and mobile screens.'
      ]
    }
  ];

  // Mock Leave Conflicts
  final List<Map<String, String>> _conflicts = [
    {
      'date': '2026-08-05',
      'team': 'DevOps Team',
      'conflict': 'Cody Fisher & David Chen both requested leave. Min staffing threshold violated.',
      'type': 'Staffing Shortage'
    },
    {
      'date': '2026-08-12',
      'team': 'Design Team',
      'conflict': 'Emma Watson & Alice Vance on annual leave. Project timeline alert triggered.',
      'type': 'Timeline Overlap'
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _chatHistory.add({
      'role': 'assistant',
      'text': 'Hello! I am your Enterprise AI HR Copilot. Ask me about policies, leave rules, and salary FAQs.'
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _qaController.dispose();
    super.dispose();
  }

  void _handleSendQa() {
    final text = _qaController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _chatHistory.add({'role': 'user', 'text': text});
      _isChatLoading = true;
      _qaController.clear();
    });

    // Simulate AI response logic
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      String answer = 'I processed your policy query. Let me search the SOP documents database.';
      final query = text.toLowerCase();
      if (query.contains('leave') || query.contains('holiday')) {
        answer = 'Casual Leave allowance is 15 days per calendar year. Sick leaves total 8 days. Submit requests via the Leaves module. Conflicts are checked automatically by the Smart Scheduler.';
      } else if (query.contains('salary') || query.contains('payslip')) {
        answer = 'Salaries are credited on the 28th of every month. Deductions for PF (12%) and ESI (0.75%) are calculated automatically based on your salary template.';
      } else if (query.contains('overtime') || query.contains('shift')) {
        answer = 'Overtime is approved by managers. Shift rosters can be customized in Shift Management under Morning, Evening, and Night shift brackets.';
      }

      setState(() {
        _chatHistory.add({'role': 'assistant', 'text': answer});
        _isChatLoading = false;
      });
    });
  }

  void _handleSummarizeSop() {
    setState(() {
      _isSopLoading = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _sopSummary = '• **Overview**: Guidelines detailing code coverage requirements and QA workflow policies.\n'
            '• **Key Rules**: All commits require 90%+ unit test coverage. Automated checks must pass on GitHub Actions CI.\n'
            '• **Compliance**: Security audits are conducted quarterly. Device security constraints must be toggled on local profiles.';
        _isSopLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI HR & Recruitment Hub'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'HR Q&A & Wiki'),
            Tab(text: 'AI Recruitment'),
            Tab(text: 'Workforce Analytics'),
            Tab(text: 'Smart Scheduler'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWikiTab(context, isDark),
          _buildRecruitmentTab(context, isDark),
          _buildAnalyticsTab(context, isDark),
          _buildSchedulerTab(context, isDark),
        ],
      ),
    );
  }

  // TAB 1: HR Q&A / Knowledge Base Summarization
  Widget _buildWikiTab(BuildContext context, bool isDark) {
    return Column(
      children: [
        // Conversational Chat Q&A
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.obsidianSurface : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _chatHistory.length,
                    itemBuilder: (context, index) {
                      final chat = _chatHistory[index];
                      final isUser = chat['role'] == 'user';
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                          decoration: BoxDecoration(
                            color: isUser
                                ? Theme.of(context).colorScheme.primary
                                : (isDark ? AppColors.obsidianBackground : Colors.grey[200]),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            chat['text']!,
                            style: TextStyle(
                              color: isUser ? Colors.white : (isDark ? Colors.white : Colors.black87),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_isChatLoading)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SizedBox(height: 12, width: 12, child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _qaController,
                          onSubmitted: (_) => _handleSendQa(),
                          decoration: const InputDecoration(
                            hintText: 'Ask AI HR Assistant policy FAQs...',
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _handleSendQa,
                        icon: const Icon(Icons.send, color: AppColors.indigoAccent),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // SOP Wiki Summarizer
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.obsidianSurface : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_stories_outlined, color: AppColors.indigoAccent, size: 20),
                    SizedBox(width: 8),
                    Text('SOP AI Document Summarizer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedSop,
                        decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                        items: const [
                          DropdownMenuItem(value: 'Holiday Guidelines', child: Text('Holiday Guidelines')),
                          DropdownMenuItem(value: 'QA & Coverage Rules', child: Text('QA & Coverage Rules')),
                          DropdownMenuItem(value: 'Device Allocation Rules', child: Text('Device Allocation Rules')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedSop = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isSopLoading ? null : _handleSummarizeSop,
                      child: _isSopLoading
                          ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Summarize'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: _sopSummary.isEmpty
                        ? const Center(child: Text('Select an SOP document above to summarize with AI.', style: TextStyle(color: Colors.grey, fontSize: 12)))
                        : Text(_sopSummary, style: const TextStyle(fontSize: 12, height: 1.5)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // TAB 2: AI Recruitment resume parsing & candidate scores
  Widget _buildRecruitmentTab(BuildContext context, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Resume upload drop zone mockup
        Container(
          padding: const EdgeInsets.symmetric(vertical: 32),
          decoration: BoxDecoration(
            color: isDark ? AppColors.obsidianSurface : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.indigoAccent.withOpacity(0.5), style: BorderStyle.solid),
          ),
          child: Column(
            children: [
              const Icon(Icons.cloud_upload_outlined, size: 40, color: AppColors.indigoAccent),
              const SizedBox(height: 12),
              const Text('Drag & Drop Resumes (PDF, Word)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text('AI will parse key skills, calculate candidate score & generate interview Qs.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 24),

        const Text('AI Candidate Rankings & Skill Match', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 12),

        // Candidate List
        ..._candidates.map((cand) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.indigoAccent.withOpacity(0.1),
                child: Text('${cand['score']}%', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.indigoAccent, fontSize: 12)),
              ),
              title: Text(cand['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${cand['role']} • Skill Match: ${cand['skills'].join(', ')}'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('AI Generated Custom Interview Questions:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.indigoAccent)),
                      const SizedBox(height: 8),
                      ...cand['questions'].map<Widget>((q) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.quiz_outlined, size: 14, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(child: Text(q, style: const TextStyle(fontSize: 12, height: 1.4))),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // TAB 3: Workforce Analytics
  Widget _buildAnalyticsTab(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Workforce Engagement & Health Analytics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildMetricCard(context, 'Average Productivity', '87%', Icons.trending_up, AppColors.success),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(context, 'Burnout Risk Factor', 'Low (14%)', Icons.healing_outlined, AppColors.warning),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Line chart representing performance trends
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Engagement Index Trend (Past 6 Months)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              const FlSpot(0, 72),
                              const FlSpot(1, 75),
                              const FlSpot(2, 79),
                              const FlSpot(3, 81),
                              const FlSpot(4, 85),
                              const FlSpot(5, 87),
                            ],
                            isCurved: true,
                            color: AppColors.electricViolet,
                            barWidth: 4,
                            belowBarData: BarAreaData(show: true, color: AppColors.electricViolet.withOpacity(0.1)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Icon(icon, color: color, size: 18),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  // TAB 4: Smart Scheduler
  Widget _buildSchedulerTab(BuildContext context, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: AppColors.warning.withOpacity(0.08),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: AppColors.warning, width: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Auto Leave Conflict Detection Active', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.warning)),
                      SizedBox(height: 4),
                      Text('The AI engine continuously checks leaves against team coverage rules.', style: TextStyle(fontSize: 11, color: Colors.black87)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        const Text('Auto-Detected Schedule Conflicts:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),

        ..._conflicts.map((conf) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.event_busy, color: Colors.redAccent),
              title: Text('${conf['team']} (${conf['date']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text(conf['conflict']!, style: const TextStyle(fontSize: 11)),
              trailing: ActionChip(
                label: const Text('Reschedule Meet', style: TextStyle(fontSize: 10)),
                onPressed: () {},
              ),
            ),
          );
        }),
        const SizedBox(height: 20),

        // Calendar Sync controls
        Card(
          child: SwitchListTile(
            title: const Text('Google / Outlook Calendar Sync', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: const Text('Automatically sync meetings and rosters to corporate calendars.', style: TextStyle(fontSize: 11)),
            value: true,
            onChanged: (val) {},
          ),
        ),
      ],
    );
  }
}
