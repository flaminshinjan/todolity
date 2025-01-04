import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/task_model.dart';
import '../../data/models/app_user_model.dart';
import 'package:logger/logger.dart';

class SharedUsersListDialog extends StatelessWidget {
  final Task task;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  SharedUsersListDialog({Key? key, required this.task}) : super(key: key);

  Future<List<AppUser>> _getSharedUsers() async {
    try {
      _logger.i('Fetching shared users for task: ${task.id}');
      
      // First, get the task document to get up-to-date sharedWith list
      final taskDoc = await _firestore.collection('tasks').doc(task.id).get();
      
      if (!taskDoc.exists || taskDoc.data() == null) {
        _logger.w('Task document not found');
        return [];
      }

      final sharedWithIds = List<String>.from(taskDoc.data()!['sharedWith'] ?? []);
      
      if (sharedWithIds.isEmpty) {
        _logger.i('No shared users found');
        return [];
      }

      // Get users from the users collection using sharedWith IDs
      final userSnapshots = await Future.wait(
        sharedWithIds.map((userId) => 
          _firestore.collection('users').doc(userId).get()
        )
      );

      // Convert snapshots to AppUser objects
      return userSnapshots
          .where((doc) => doc.exists && doc.data() != null)
          .map((doc) => AppUser(
                id: doc.id,
                email: doc.data()!['email'] ?? '',
                name: doc.data()!['name'] ?? '',
              ))
          .toList();

    } catch (e) {
      _logger.e('Error fetching shared users: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Shared Users',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 24),
            Container(
              constraints: BoxConstraints(maxHeight: 300),
              child: FutureBuilder<List<AppUser>>(
                future: _getSharedUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF036ac9),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading users',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  final users = snapshot.data ?? [];
                  if (users.isEmpty) {
                    return Center(
                      child: Text(
                        'No users shared with this task',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Color(0xFF036ac9),
                            child: Text(
                              user.email[0].toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            user.email,
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: user.name != null && user.name!.isNotEmpty
                            ? Text(
                                user.name!,
                                style: TextStyle(color: Colors.grey[600]),
                              ) 
                            : null,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}