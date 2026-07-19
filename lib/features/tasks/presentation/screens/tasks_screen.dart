import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/tasks_controller.dart';
import '../../data/models/task_model.dart';
import '../../../../core/themes/app_colors.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final List<String> _columns = ['todo', 'in_progress', 'review', 'completed'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _columns.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  String _getColumnTitle(String col) {
    switch (col) {
      case 'todo':
        return 'To Do';
      case 'in_progress':
        return 'In Progress';
      case 'review':
        return 'Review';
      case 'completed':
        return 'Done';
      default:
        return col;
    }
  }

  void _showAddTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTaskBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tasksControllerProvider);
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 768;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.assignment_outlined),
            SizedBox(width: 8),
            Text('Project Board'),
          ],
        ),
        bottom: !isTablet
            ? TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: _columns.map((col) => Tab(text: _getColumnTitle(col))).toList(),
              )
            : null,
      ),
      body: state.isLoading && state.tasks.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : (isTablet
              ? _buildTabletLayout(context, state.tasks)
              : _buildMobileLayout(context, state.tasks)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Tablet layout: columns side-by-side
  Widget _buildTabletLayout(BuildContext context, List<TaskModel> allTasks) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _columns.map((col) {
          final columnTasks = allTasks.where((t) => t.status == col).toList();
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6.0),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.obsidianSurface
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getColumnTitle(col),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).dividerColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${columnTasks.length}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: columnTasks.length,
                      itemBuilder: (context, index) {
                        final task = columnTasks[index];
                        return _buildTaskCard(context, task);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Mobile layout: tab bar view containing columns
  Widget _buildMobileLayout(BuildContext context, List<TaskModel> allTasks) {
    return TabBarView(
      controller: _tabController,
      children: _columns.map((col) {
        final columnTasks = allTasks.where((t) => t.status == col).toList();
        if (columnTasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 48, color: Colors.grey[600]),
                const SizedBox(height: 12),
                Text('No tasks in ${_getColumnTitle(col)}', style: const TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: columnTasks.length,
          itemBuilder: (context, index) {
            final task = columnTasks[index];
            return _buildTaskCard(context, task);
          },
        );
      }).toList(),
    );
  }

  Widget _buildTaskCard(BuildContext context, TaskModel task) {
    Color priorityColor = Colors.grey;
    if (task.priority == 'critical') priorityColor = AppColors.error;
    if (task.priority == 'high') priorityColor = AppColors.warning;
    if (task.priority == 'medium') priorityColor = AppColors.indigoAccent;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    task.priority.toUpperCase(),
                    style: TextStyle(color: priorityColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                if (task.aiGenerated)
                  const Tooltip(
                    message: 'AI Generated Task',
                    child: Icon(Icons.auto_awesome, size: 16, color: AppColors.indigoAccent),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              task.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              task.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (task.dueDate != null)
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        task.dueDate!.toIso8601String().substring(0, 10),
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  )
                else
                  const SizedBox(),
                // Dropdown to quick move column status
                DropdownButton<String>(
                  value: task.status,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  items: _columns.map((col) {
                    return DropdownMenuItem(
                      value: col,
                      child: Text(_getColumnTitle(col)),
                    );
                  }).toList(),
                  onChanged: (newStatus) {
                    if (newStatus != null && newStatus != task.status && task.id != null) {
                      ref.read(tasksControllerProvider.notifier).updateTaskStatus(task.id!, newStatus);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddTaskBottomSheet extends ConsumerStatefulWidget {
  const AddTaskBottomSheet({super.key});

  @override
  ConsumerState<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends ConsumerState<AddTaskBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedPriority = 'medium';
  DateTime? _dueDate;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      // Mocking project association
      ref.read(tasksControllerProvider.notifier).addTask(
            projectId: 'default_project_uuid',
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            priority: _selectedPriority,
            dueDate: _dueDate,
          );
      Navigator.of(context).pop();
    }
  }

  // Simulate AI task details autofill
  void _triggerAiAutofill() {
    setState(() {
      _titleController.text = 'Implement Row-Level Security Rules';
      _descriptionController.text = 'Configure Supabase schema level policies on attendance, employees and departments tables to guarantee multi-tenant SaaS compliance.';
      _selectedPriority = 'critical';
      _dueDate = DateTime.now().add(const Duration(days: 3));
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('AI Breakdown generated task details!'),
        backgroundColor: AppColors.indigoAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Create Task', style: Theme.of(context).textTheme.titleLarge),
                IconButton(
                  onPressed: _triggerAiAutofill,
                  icon: const Icon(Icons.auto_awesome_outlined, color: AppColors.indigoAccent),
                  tooltip: 'Generate via AI',
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Task Title'),
              validator: (val) => val == null || val.trim().isEmpty ? 'Enter a title' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
              validator: (val) => val == null || val.trim().isEmpty ? 'Enter a description' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              decoration: const InputDecoration(labelText: 'Priority'),
              items: const [
                DropdownMenuItem(value: 'low', child: Text('Low')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'high', child: Text('High')),
                DropdownMenuItem(value: 'critical', child: Text('Critical')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedPriority = val);
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Due Date'),
              subtitle: Text(_dueDate == null ? 'No date set' : _dueDate!.toIso8601String().substring(0, 10)),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) setState(() => _dueDate = date);
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Submit Task'),
            ),
          ],
        ),
      ),
    );
  }
}
