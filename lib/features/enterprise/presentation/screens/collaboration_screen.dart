import 'package:flutter/material.dart';
import '../../../../core/themes/app_colors.dart';

class CollaborationScreen extends StatefulWidget {
  const CollaborationScreen({super.key});

  @override
  State<CollaborationScreen> createState() => _CollaborationScreenState();
}

class _CollaborationScreenState extends State<CollaborationScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final TextEditingController _msgController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String _selectedChannel = '#general';

  // Mock channels and messages
  final List<String> _channels = ['#general', '#announcements', '#dev-sprint-planning'];
  final List<Map<String, dynamic>> _messages = [
    {
      'channel': '#general',
      'user': 'Jane Cooper',
      'text': 'Hi @Cody Fisher, did you check the RLS policies configuration in Supabase?',
      'reactions': {'👍': 4, '🔥': 2},
      'replies': 3,
    },
    {
      'channel': '#general',
      'user': 'Cody Fisher',
      'text': 'Yes! Added the filters to local Hive sync queue too. Testing tomorrow.',
      'reactions': {'👍': 2, '🚀': 3},
      'replies': 0,
    },
    {
      'channel': '#announcements',
      'user': 'Admin',
      'text': '⚠️ Emergency Alert: Power scheduled maintenance this Sunday 02:00 AM UTC.',
      'reactions': {'😮': 5},
      'replies': 1,
    }
  ];

  // Mock Polls data
  final List<Map<String, dynamic>> _polls = [
    {
      'question': 'Where should we host the Q3 team retreat?',
      'options': [
        {'text': 'Beach Resort', 'votes': 8},
        {'text': 'Mountain Cabin', 'votes': 12},
        {'text': 'Virtual Escape Room', 'votes': 3},
      ],
      'totalVotes': 23,
      'votedIndex': -1,
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _noteController.text = '### Shared Note:\n- Configure test coverage metrics for new PR releases.\n- Restrict white-label config to company_admin roles.';
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _msgController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'channel': _selectedChannel,
        'user': 'You',
        'text': text,
        'reactions': {},
        'replies': 0,
      });
      _msgController.clear();
    });
  }

  void _addReaction(int msgIndex, String emoji) {
    setState(() {
      final reactions = Map<String, int>.from(_messages[msgIndex]['reactions']);
      reactions[emoji] = (reactions[emoji] ?? 0) + 1;
      _messages[msgIndex]['reactions'] = reactions;
    });
  }

  void _votePoll(int pollIndex, int optIndex) {
    setState(() {
      final poll = _polls[pollIndex];
      if (poll['votedIndex'] == -1) {
        poll['options'][optIndex]['votes'] += 1;
        poll['totalVotes'] += 1;
        poll['votedIndex'] = optIndex;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Collaboration Hub'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Team Chat'),
            Tab(text: 'Shared Notes'),
            Tab(text: 'Polls'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatTab(context, isDark),
          _buildNotesTab(context, isDark),
          _buildPollsTab(context, isDark),
        ],
      ),
    );
  }

  // TAB 1: Slack style Chat UI
  Widget _buildChatTab(BuildContext context, bool isDark) {
    final channelMessages = _messages.where((m) => m['channel'] == _selectedChannel).toList();

    return Row(
      children: [
        // Sidebar for channels list
        Container(
          width: 80,
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: Theme.of(context).dividerColor)),
            color: isDark ? AppColors.obsidianBackground : Colors.grey[50],
          ),
          child: ListView.builder(
            itemCount: _channels.length,
            itemBuilder: (context, index) {
              final chan = _channels[index];
              final isSelected = _selectedChannel == chan;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedChannel = chan;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  color: isSelected ? AppColors.indigoAccent.withOpacity(0.08) : Colors.transparent,
                  alignment: Alignment.center,
                  child: Text(
                    chan.substring(1, 3).toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.indigoAccent : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Main Chat Screen
        Expanded(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor))),
                child: Row(
                  children: [
                    Text(_selectedChannel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const Spacer(),
                    const Icon(Icons.people_outline, size: 18, color: Colors.grey),
                    const SizedBox(width: 4),
                    const Text('8 Members', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),

              // Message lists
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: channelMessages.length,
                  itemBuilder: (context, index) {
                    final msg = channelMessages[index];
                    final globalIdx = _messages.indexOf(msg);

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CircleAvatar(radius: 16, child: Icon(Icons.person, size: 16)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(msg['user'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    const SizedBox(width: 8),
                                    const Text('10:45 AM', style: TextStyle(color: Colors.grey, fontSize: 10)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(msg['text'], style: const TextStyle(fontSize: 13, height: 1.4)),
                                const SizedBox(height: 6),

                                // Reactions & Reply controls
                                Row(
                                  children: [
                                    ...msg['reactions'].entries.map<Widget>((e) {
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 6.0),
                                        child: InkWell(
                                          onTap: () => _addReaction(globalIdx, e.key),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.indigoAccent.withOpacity(0.08),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text('${e.key} ${e.value}', style: const TextStyle(fontSize: 10)),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    IconButton(
                                      icon: const Icon(Icons.add_reaction_outlined, size: 14),
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () => _addReaction(globalIdx, '👍'),
                                    ),
                                    if (msg['replies'] > 0)
                                      TextButton(
                                        onPressed: () {},
                                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                                        child: Text('${msg['replies']} replies', style: const TextStyle(fontSize: 11, color: AppColors.indigoAccent)),
                                      ),
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Chat controls bar
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(border: Border(top: BorderSide(color: Theme.of(context).dividerColor))),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _msgController,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: 'Message $_selectedChannel...',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          border: InputBorder.none,
                          fillColor: isDark ? AppColors.obsidianBackground : Colors.grey[50],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: AppColors.indigoAccent),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  // TAB 2: Shared Notepad
  Widget _buildNotesTab(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Shared Team Pad', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Team notes saved locally!'), backgroundColor: AppColors.success),
                  );
                },
                icon: const Icon(Icons.save_outlined, size: 16),
                label: const Text('Save Pad'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.obsidianSurface : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: TextFormField(
                controller: _noteController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),
          )
        ],
      ),
    );
  }

  // TAB 3: Interactive Polls
  Widget _buildPollsTab(BuildContext context, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _polls.length,
      itemBuilder: (context, index) {
        final poll = _polls[index];
        final voted = poll['votedIndex'] != -1;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.poll_outlined, color: AppColors.indigoAccent, size: 18),
                    SizedBox(width: 8),
                    Text('Active Team Poll', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(poll['question'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 16),

                ...List.generate(poll['options'].length, (optIdx) {
                  final opt = poll['options'][optIdx];
                  final percentage = poll['totalVotes'] == 0 ? 0.0 : (opt['votes'] / poll['totalVotes']);
                  final isMyVote = poll['votedIndex'] == optIdx;

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: InkWell(
                      onTap: voted ? null : () => _votePoll(index, optIdx),
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          // Custom percentage progress bar background
                          FractionallySizedBox(
                            widthFactor: percentage,
                            child: Container(
                              height: 42,
                              decoration: BoxDecoration(
                                color: isMyVote 
                                    ? AppColors.indigoAccent.withOpacity(0.18) 
                                    : (isDark ? Colors.grey[800] : Colors.grey[200]),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          Container(
                            height: 42,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isMyVote ? AppColors.indigoAccent : Theme.of(context).dividerColor,
                                width: isMyVote ? 1.5 : 1.0,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(opt['text'], style: TextStyle(fontWeight: isMyVote ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
                                Text('${(percentage * 100).toInt()}% (${opt['votes']})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                Text('Total Votes: ${poll['totalVotes']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
        );
      },
    );
  }
}
