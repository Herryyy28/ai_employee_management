class TaskModel {
  final String? id;
  final String projectId;
  final String companyId;
  final String title;
  final String description;
  final String? assignedTo;
  final String status; // todo, in_progress, review, completed
  final String priority; // low, medium, high, critical
  final DateTime? dueDate;
  final bool aiGenerated;

  TaskModel({
    this.id,
    required this.projectId,
    required this.companyId,
    required this.title,
    required this.description,
    this.assignedTo,
    required this.status,
    required this.priority,
    this.dueDate,
    this.aiGenerated = false,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String?,
      projectId: json['project_id'] as String,
      companyId: json['company_id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      assignedTo: json['assigned_to'] as String?,
      status: json['status'] as String? ?? 'todo',
      priority: json['priority'] as String? ?? 'medium',
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date'] as String) : null,
      aiGenerated: json['ai_generated'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'project_id': projectId,
      'company_id': companyId,
      'title': title,
      'description': description,
      if (assignedTo != null) 'assigned_to': assignedTo,
      'status': status,
      'priority': priority,
      if (dueDate != null) 'due_date': dueDate!.toIso8601String().substring(0, 10),
      'ai_generated': aiGenerated,
    };
  }

  TaskModel copyWith({
    String? id,
    String? projectId,
    String? companyId,
    String? title,
    String? description,
    String? assignedTo,
    String? status,
    String? priority,
    DateTime? dueDate,
    bool? aiGenerated,
  }) {
    return TaskModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      companyId: companyId ?? this.companyId,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedTo: assignedTo ?? this.assignedTo,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      aiGenerated: aiGenerated ?? this.aiGenerated,
    );
  }
}
