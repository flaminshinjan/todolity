class AppUser {
  final String id;
  final String email;
  final String? name;
   final List<String> tasksSharedWithMe;
  final List<String> tasksSharedByMe;
   final String? photoUrl;
  final int? backgroundColor;

  AppUser({
    required this.id,
    required this.email,
    this.name,
    this.tasksSharedWithMe = const [],
    this.tasksSharedByMe = const [],
    this.photoUrl,
    this.backgroundColor,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
       tasksSharedWithMe: List<String>.from(json['tasksSharedWithMe'] ?? []),
      tasksSharedByMe: List<String>.from(json['tasksSharedByMe'] ?? []),
      photoUrl: json['photoUrl'],
      backgroundColor: json['backgroundColor'], 
    );
  }

  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    return AppUser(
      id: id,
      email: map['email'] as String,
      name: map['name'] as String?,
      tasksSharedByMe: map['tasksSharedByMe'] as List<String>,
      tasksSharedWithMe: map['tasksSharedWithMe'] as List<String>,
      
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'tasksSharedWithMe': tasksSharedWithMe,
      'tasksSharedByMe': tasksSharedByMe,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'tasksSharedWithMe': tasksSharedWithMe,
      'tasksSharedByMe': tasksSharedByMe,
    };
  }
}