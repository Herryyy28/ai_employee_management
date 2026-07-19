import 'package:flutter/material.dart';
import '../../../../core/themes/app_colors.dart';

class LearningHelpdeskScreen extends StatefulWidget {
  const LearningHelpdeskScreen({super.key});

  @override
  State<LearningHelpdeskScreen> createState() => _LearningHelpdeskScreenState();
}

class _LearningHelpdeskScreenState extends State<LearningHelpdeskScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  // Quiz state variables
  int _currentQuestionIdx = 0;
  int _selectedQuizAnswer = -1;
  bool _answered = false;
  int _score = 0;
  bool _quizCompleted = false;

  final List<Map<String, dynamic>> _quizQuestions = [
    {
      'q': 'What does RLS stand for in database architecture?',
      'opts': ['Remote Lock Service', 'Row-Level Security', 'Replication Log Sync', 'Resource Load Shifting'],
      'ans': 1
    },
    {
      'q': 'Which encryption type is typical for securing offline Hive database boxes?',
      'opts': ['AES-128', 'SHA-256', 'AES-256', 'MD5'],
      'ans': 2
    }
  ];

  // Helpdesk Ticket fields
  final _ticketFormKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  String _selectedPriority = 'high';
  String _selectedCategory = 'IT Support';

  // Mock Helpdesk Tickets
  final List<Map<String, dynamic>> _tickets = [
    {
      'id': 'TCK-940',
      'cat': 'IT Support',
      'priority': 'critical',
      'desc': 'VPN connection timeout failure.',
      'status': 'In Progress',
      'sla': '1h 24m remaining'
    },
    {
      'id': 'TCK-201',
      'cat': 'HR Support',
      'priority': 'medium',
      'desc': 'Clarify PF tax deduction brackets.',
      'status': 'Resolved',
      'sla': 'Met SLA'
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
    _descController.dispose();
    super.dispose();
  }

  void _submitTicket() {
    if (_ticketFormKey.currentState?.validate() ?? false) {
      String slaTarget = '4h 00m remaining';
      if (_selectedPriority == 'critical') slaTarget = '1h 00m remaining';
      if (_selectedPriority == 'medium') slaTarget = '24h 00m remaining';
      if (_selectedPriority == 'low') slaTarget = '48h 00m remaining';

      setState(() {
        _tickets.insert(0, {
          'id': 'TCK-${100 + _tickets.length * 15}',
          'cat': _selectedCategory,
          'priority': _selectedPriority,
          'desc': _descController.text.trim(),
          'status': 'Open',
          'sla': slaTarget
        });
        _descController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Support ticket logged! IT dispatcher notified.'), backgroundColor: AppColors.success),
      );
    }
  }

  void _answerQuiz(int optIdx) {
    if (_answered) return;
    setState(() {
      _selectedQuizAnswer = optIdx;
      _answered = true;
      if (optIdx == _quizQuestions[_currentQuestionIdx]['ans']) {
        _score++;
      }
    });
  }

  void _nextQuizQuestion() {
    setState(() {
      if (_currentQuestionIdx + 1 < _quizQuestions.length) {
        _currentQuestionIdx++;
        _selectedQuizAnswer = -1;
        _answered = false;
      } else {
        _quizCompleted = true;
      }
    });
  }

  void _resetQuiz() {
    setState(() {
      _currentQuestionIdx = 0;
      _selectedQuizAnswer = -1;
      _answered = false;
      _score = 0;
      _quizCompleted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning & Helpdesk Suite'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'LMS Courses'),
            Tab(text: 'Quiz Platform'),
            Tab(text: 'IT & HR Tickets'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLmsTab(context, isDark),
          _buildQuizTab(context, isDark),
          _buildTicketsTab(context, isDark),
        ],
      ),
    );
  }

  // TAB 1: LMS Learning Center
  Widget _buildLmsTab(BuildContext context, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Enterprise Training Academy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 12),
        // Mock Video player
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 180,
                color: Colors.black87,
                child: Center(
                  child: IconButton(
                    icon: const Icon(Icons.play_circle_fill, size: 64, color: AppColors.indigoAccent),
                    onPressed: () {},
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('SaaS Multi-Tenancy Architecture', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('Duration: 45 mins • Instructor: Sarah Jenkins', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(value: 0.65),
                    const SizedBox(height: 8),
                    const Text('Overall progress: 65% Completed', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  // TAB 2: Quiz Deck
  Widget _buildQuizTab(BuildContext context, bool isDark) {
    if (_quizCompleted) {
      final passed = _score == _quizQuestions.length;
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(passed ? Icons.emoji_events : Icons.refresh, size: 64, color: passed ? Colors.amber : AppColors.error),
              const SizedBox(height: 16),
              Text(
                passed ? 'CONGRATULATIONS!' : 'Quiz Attempt Finished',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text('Your Score: $_score / ${_quizQuestions.length} correct responses', style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 16),
              if (passed) ...[
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'CERTIFICATE SECURED\nVerified multi-tenancy compliant practitioner',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.success),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              ElevatedButton(
                onPressed: _resetQuiz,
                child: Text(passed ? 'Retake Quiz' : 'Try Again'),
              )
            ],
          ),
        ),
      );
    }

    final currentQ = _quizQuestions[_currentQuestionIdx];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Question ${_currentQuestionIdx + 1}/${_quizQuestions.length}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
              Text('Score: $_score', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(currentQ['q'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 20),

          ...List.generate(currentQ['opts'].length, (idx) {
            final opt = currentQ['opts'][idx];
            Color btnColor = isDark ? AppColors.obsidianSurface : Colors.white;
            Color textColor = isDark ? Colors.white : Colors.black87;

            if (_answered) {
              if (idx == currentQ['ans']) {
                btnColor = AppColors.success.withOpacity(0.2);
                textColor = Colors.green;
              } else if (_selectedQuizAnswer == idx) {
                btnColor = AppColors.error.withOpacity(0.2);
                textColor = Colors.red;
              }
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: btnColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: _answered && idx == currentQ['ans'] ? Colors.green : Theme.of(context).dividerColor),
                ),
                onPressed: () => _answerQuiz(idx),
                child: Text(opt, style: TextStyle(color: textColor, fontSize: 13)),
              ),
            );
          }),
          const Spacer(),
          if (_answered)
            ElevatedButton(
              onPressed: _nextQuizQuestion,
              child: Text(_currentQuestionIdx + 1 == _quizQuestions.length ? 'Finish Quiz' : 'Next Question'),
            ),
        ],
      ),
    );
  }

  // TAB 3: Helpdesk Ticketing
  Widget _buildTicketsTab(BuildContext context, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Form(
          key: _ticketFormKey,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Submit Ticket Desk Request', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(labelText: 'Ticket Category'),
                    items: const [
                      DropdownMenuItem(value: 'IT Support', child: Text('IT Support / Hardware')),
                      DropdownMenuItem(value: 'HR Support', child: Text('HR Policy / Payroll')),
                      DropdownMenuItem(value: 'Admin', child: Text('Admin Operations')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedPriority,
                    decoration: const InputDecoration(labelText: 'Priority Level'),
                    items: const [
                      DropdownMenuItem(value: 'low', child: Text('Low Priority')),
                      DropdownMenuItem(value: 'medium', child: Text('Medium Priority')),
                      DropdownMenuItem(value: 'high', child: Text('High Priority')),
                      DropdownMenuItem(value: 'critical', child: Text('Critical Severity')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedPriority = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Explain Support Request Details'),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Provide details' : null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitTicket,
                    child: const Text('File Ticket'),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text('Your Active SLA Tickets', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),

        ..._tickets.map((t) {
          Color priColor = Colors.grey;
          if (t['priority'] == 'critical') priColor = AppColors.error;
          if (t['priority'] == 'high') priColor = AppColors.warning;
          if (t['priority'] == 'medium') priColor = AppColors.indigoAccent;

          return Card(
            child: ListTile(
              leading: const Icon(Icons.support_agent_outlined),
              title: Text('${t['cat']} (${t['id']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text('${t['desc']}\nSLA Status: ${t['sla']}'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: priColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  t['status'].toUpperCase(),
                  style: TextStyle(color: priColor, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
