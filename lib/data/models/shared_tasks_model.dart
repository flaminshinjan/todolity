import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todolity/data/models/task_model.dart';

class SharedTask {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final String createdBy;
  final List<String> sharedWith;
  final DateTime createdAt;
  final String originalTaskId;
  String? creatorName;  // Optional creator name
  String? creatorEmail; // Optional creator email

  SharedTask({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.createdBy,
    required this.sharedWith,
    required this.createdAt,
    required this.originalTaskId,
    this.creatorName,
    this.creatorEmail,
  });

  factory SharedTask.fromJson(Map<String, dynamic> json, String id) {
    return SharedTask(
      id: id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      createdBy: json['createdBy'] ?? '',
      sharedWith: List<String>.from(json['sharedWith'] ?? []),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      originalTaskId: json['originalTaskId'] ?? '',
    );
  }

  factory SharedTask.fromTask(Task task, String sharedWithUserId) {
    return SharedTask(
      id: '',  // Will be set by Firestore
      title: task.title,
      description: task.description,
      isCompleted: task.isCompleted,
      createdBy: task.createdBy,
      sharedWith: [sharedWithUserId],
      createdAt: task.createdAt,
      originalTaskId: task.id,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdBy': createdBy,
      'sharedWith': sharedWith,
      'createdAt': Timestamp.fromDate(createdAt),
      'originalTaskId': originalTaskId,
    };
  }

  SharedTask copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    String? createdBy,
    List<String>? sharedWith,
    DateTime? createdAt,
    String? originalTaskId,
  }) {
    return SharedTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdBy: createdBy ?? this.createdBy,
      sharedWith: sharedWith ?? List<String>.from(this.sharedWith),
      createdAt: createdAt ?? this.createdAt,
      originalTaskId: originalTaskId ?? this.originalTaskId,
    );
  }
}