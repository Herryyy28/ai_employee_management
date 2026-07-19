import 'package:flutter/material.dart';
import '../../../../core/themes/app_colors.dart';

class WellnessRecognitionScreen extends StatefulWidget {
  const WellnessRecognitionScreen({super.key});

  @override
  State<WellnessRecognitionScreen> createState() => _WellnessRecognitionScreenState();
}

class _WellnessRecognitionScreenState extends State<WellnessRecognitionScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  String _selectedMood = '';
  int _waterIntakeMl = 500;
  bool _waterReminder = true;
  bool _breakReminder = true;

  // Peer Appreciation messages
  final List<Map<String, String>> _appreciationFeeds = [
    {
      'from': 'Jane Cooper',
      'to': 'Cody Fisher',
      'text': 'A huge shoutout for resolving the Supabase RLS policy latency issues! Saved the sprint timeline!',
      'badge': 'Tech Guru'
    },
    {
      'from': 'David Chen',
      'to': 'Emma Watson',
      'text': 'Stunning Figma layout adjustments for the White Label brand builder config screens.',
      'badge': 'Design Champ'
    }
  ];

  final _appreciateFormKey = GlobalKey<FormState>();
  final _appreciateToController = TextEditingController();
  final _appreciateMsgController = TextEditingController();
  String _selectedAppreciateBadge = 'Super Colleague';

  // Badges catalog
  final List<Map<String, dynamic>> _badges = [
    {'name': 'Security Guardian', 'icon': Icons.security, 'desc': 'Activated 2FA & secure device controls.'},
    {'name': 'Fast Responder', 'icon': Icons.flash_on, 'desc': 'Resolved IT support ticket within SLA.'},
    {'name': 'Team Catalyst', 'icon': Icons.bolt, 'desc': 'Posted 5+ peer appreciation spotlights.'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _appreciateToController.dispose();
    _appreciateMsgController.dispose();
    super.dispose();
  }

  void _postAppreciation() {
    if (_appreciateFormKey.currentState?.validate() ?? false) {
      setState(() {
        _appreciationFeeds.insert(0, {
          'from': 'You',
          'to': _appreciateToController.text.trim(),
          'text': _appreciateMsgController.text.trim(),
          'badge': _selectedAppreciateBadge
        });
        _appreciateToController.clear();
        _appreciateMsgController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appreciation card pinned to the Wall!'), backgroundColor: AppColors.success),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wellness & Recognition Board'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Daily Wellness'),
            Tab(text: 'Appreciation Wall'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWellnessTab(context, isDark),
          _buildAppreciationTab(context, isDark),
        ],
      ),
    );
  }

  // TAB 1: Daily Wellness trackers
  Widget _buildWellnessTab(BuildContext context, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Daily Mood selector
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Daily Mood Check', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMoodButton('😀', 'Happy'),
                    _buildMoodButton('😐', 'Neutral'),
                    _buildMoodButton('😔', 'Stressed'),
                  ],
                ),
                if (_selectedMood.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Center(
                    child: Text('Logged today: $_selectedMood. Take regular deep breaths!',
                        style: const TextStyle(color: AppColors.indigoAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                  )
                ]
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Water tracker
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.local_drink, color: Colors.blue, size: 36),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Hydration Counter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text('Current Intake: $_waterIntakeMl ml / 2000 ml target', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _waterIntakeMl += 250;
                    });
                  },
                  child: const Text('+250ml'),
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Break triggers
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Water Intake Reminder', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: const Text('Reminds you to sip water every 60 minutes.', style: TextStyle(fontSize: 11)),
                value: _waterReminder,
                onChanged: (val) => setState(() => _waterReminder = val),
              ),
              SwitchListTile(
                title: const Text('Meditation & Stretch Break Alert', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: const Text('Notify to stretch eyes/body after 2 hours screen time.', style: TextStyle(fontSize: 11)),
                value: _breakReminder,
                onChanged: (val) => setState(() => _breakReminder = val),
              ),
              ListTile(
                title: const Text('Trigger Demo Break Timer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.indigoAccent)),
                trailing: const Icon(Icons.alarm, color: AppColors.indigoAccent),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Take a 5-min breathing break! Step away from your desktop screen.'), backgroundColor: AppColors.indigoAccent),
                  );
                },
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMoodButton(String emoji, String label) {
    final isSelected = _selectedMood == label;
    return InkWell(
      onTap: () => setState(() => _selectedMood = label),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.indigoAccent.withOpacity(0.12) : Colors.transparent,
          border: Border.all(color: isSelected ? AppColors.indigoAccent : Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }

  // TAB 2: Recognition / appreciation board
  Widget _buildAppreciationTab(BuildContext context, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Employee Spotlight
        Card(
          color: AppColors.indigoAccent.withOpacity(0.08),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: AppColors.indigoAccent, width: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.indigoAccent,
                  child: Text('🏆', style: TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('EMPLOYEE OF THE MONTH', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.indigoAccent)),
                      SizedBox(height: 4),
                      Text('Cody Fisher', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Lead DevOps • 450 Appreciation Points', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Post Appreciation Form
        Form(
          key: _appreciateFormKey,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Send Kudos Card to Colleague', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _appreciateToController,
                    decoration: const InputDecoration(labelText: 'Colleague Name (e.g. @Cody)'),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Enter name' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _appreciateMsgController,
                    decoration: const InputDecoration(labelText: 'Appreciation Message'),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Enter message text' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedAppreciateBadge,
                    decoration: const InputDecoration(labelText: 'Award Badge'),
                    items: const [
                      DropdownMenuItem(value: 'Super Colleague', child: Text('Super Colleague')),
                      DropdownMenuItem(value: 'Tech Guru', child: Text('Tech Guru')),
                      DropdownMenuItem(value: 'Design Champ', child: Text('Design Champ')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedAppreciateBadge = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _postAppreciation,
                    child: const Text('Post Appreciation Card'),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Feeds
        const Text('Appreciation Wall Feed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),

        ..._appreciationFeeds.map((feed) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: Text('Kudos from ${feed['from']} to ${feed['to']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text(feed['text']!),
              trailing: Chip(
                label: Text(feed['badge']!, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                backgroundColor: AppColors.indigoAccent.withOpacity(0.08),
              ),
            ),
          );
        }),
        const SizedBox(height: 24),

        // Badges grid
        const Text('Your Badges Cabinet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _badges.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            final badge = _badges[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(badge['icon'], color: AppColors.indigoAccent, size: 30),
                    const SizedBox(height: 8),
                    Text(badge['name'], textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
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
