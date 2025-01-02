class User {
  final String id;
  final String email;
  final String name;
  final List<String> taskIds;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.taskIds = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      taskIds: List<String>.from(json['taskIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'taskIds': taskIds,
    };
  }
}