import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/tasks_repository.dart';
import '../../data/models/task_model.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/controllers/auth_state.dart';
import '../../../../core/config/service_locator.dart';

class TasksState {
  final List<TaskModel> tasks;
  final bool isLoading;
  final String? errorMessage;

  TasksState({
    this.tasks = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  TasksState copyWith({
    List<TaskModel>? tasks,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TasksState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class TasksController extends StateNotifier<TasksState> {
  final TasksRepository _tasksRepository;
  final String? _companyId;

  TasksController(this._tasksRepository, this._companyId) : super(TasksState()) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    if (_companyId == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final list = await _tasksRepository.getTasks(_companyId!);
      state = state.copyWith(tasks: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  Future<void> addTask({
    required String projectId,
    required String title,
    required String description,
    String? assignedTo,
    required String priority,
    DateTime? dueDate,
    bool aiGenerated = false,
  }) async {
    if (_companyId == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final task = TaskModel(
        projectId: projectId,
        companyId: _companyId!,
        title: title,
        description: description,
        assignedTo: assignedTo,
        status: 'todo',
        priority: priority,
        dueDate: dueDate,
        aiGenerated: aiGenerated,
      );
      await _tasksRepository.createTask(task);
      await loadTasks();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  Future<void> updateTaskStatus(String id, String status) async {
    // Optimistic local update
    final updatedList = state.tasks.map((t) {
      if (t.id == id) {
        return t.copyWith(status: status);
      }
      return t;
    }).toList();
    state = state.copyWith(tasks: updatedList);

    try {
      await _tasksRepository.updateTaskStatus(id: id, status: status);
    } catch (e) {
      // Revert if error occurs by reload
      await loadTasks();
    }
  }
}

// Tasks controller provider mapped with auth state credentials
final tasksControllerProvider = StateNotifierProvider<TasksController, TasksState>((ref) {
  final authState = ref.watch(authControllerProvider);
  String? companyId;

  if (authState is AuthAuthenticated) {
    companyId = authState.user.companyId;
  }

  return TasksController(
    sl<TasksRepository>(),
    companyId,
  );
});
