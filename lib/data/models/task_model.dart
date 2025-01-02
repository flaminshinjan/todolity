import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final String createdBy;
  final List<String> sharedWith;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.createdBy,
    required this.sharedWith,
    required this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> json, String id) {
    // Handle the timestamp conversion safely
    DateTime createdAt;
    final timestamp = json['createdAt'];
    if (timestamp is Timestamp) {
      createdAt = timestamp.toDate();
    } else {
      createdAt = DateTime.now();
    }

    // Handle sharedWith list safely
    List<String> sharedWith = [];
    if (json['sharedWith'] != null) {
      if (json['sharedWith'] is List) {
        sharedWith = (json['sharedWith'] as List)
            .map((item) => item.toString())
            .toList();
      }
    }

    return Task(
      id: id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      createdBy: json['createdBy'] ?? '',
      sharedWith: sharedWith,
      createdAt: createdAt,
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
    };
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    String? createdBy,
    List<String>? sharedWith,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdBy: createdBy ?? this.createdBy,
      sharedWith: sharedWith ?? List<String>.from(this.sharedWith),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}