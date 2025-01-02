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
      
      if (task.sharedWith.isEmpty) {
        return [];
      }

      // Get users from the users collection using sharedWith IDs
      final userSnapshots = await Future.wait(
        task.sharedWith.map((userId) => 
          _firestore.collection('users').doc(userId).get()
        )
      );

      // Convert snapshots to AppUser objects
      return userSnapshots
          .where((doc) => doc.exists && doc.data() != null)
          .map((doc) => AppUser(
                id: doc.id,
                email: doc.data()!['email'] ?? '',
                name: doc.data()!['name'],
              ))
          .toList();

    } catch (e) {
      _logger.e('Error fetching shared users: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: BoxConstraints(maxHeight: 400),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Shared Users',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<AppUser>>(
                future: _getSharedUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error loading users'),
                    );
                  }

                  final users = snapshot.data ?? [];
                  if (users.isEmpty) {
                    return Center(
                      child: Text('No users shared with this task'),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            user.email[0].toUpperCase(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(user.email),
                        subtitle: user.name != null ? Text(user.name!) : null,
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}