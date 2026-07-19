import '../../data/models/task_model.dart';

abstract class TasksRepository {
  Future<void> createTask(TaskModel task);
  
  Future<List<TaskModel>> getTasks(String companyId);

  Future<void> updateTaskStatus({
    required String id,
    required String status,
  });
}
