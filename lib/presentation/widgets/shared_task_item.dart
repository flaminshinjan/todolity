import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todolity/data/models/shared_tasks_model.dart';
import '../../data/models/app_user_model.dart';
import 'package:logger/logger.dart';

class SharedTaskItem extends StatelessWidget {
  final SharedTask task;
  final bool isSharedByMe;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  SharedTaskItem({
    Key? key,
    required this.task,
    required this.isSharedByMe,
  }) : super(key: key);

  Future<List<AppUser>> _getSharedUsers() async {
    try {
      _logger.i('Fetching users for task: ${task.id}');
      
      final userDocs = await Future.wait(
        task.sharedWith.map((userId) => 
          _firestore.collection('users').doc(userId).get()
        )
      );

      return userDocs
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
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xfff9be03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      SizedBox(height: 4),
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          decoration: task.isCompleted 
                              ? TextDecoration.lineThrough 
                              : TextDecoration.none,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        task.description,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          decoration: task.isCompleted 
                              ? TextDecoration.lineThrough 
                              : TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
                FutureBuilder<List<AppUser>>(
                  future: _getSharedUsers(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return SizedBox();
                    final users = snapshot.data!;
                    return _buildParticipantsStack(users);
                  },
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                _buildTag('Today', Colors.black),
                SizedBox(width: 8),
                if (isSharedByMe)
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: _buildTag('Shared by me', Colors.black54),
                  ),
                Spacer(),
                Container(
                  width: 40,
                  height: 40,
                  margin: EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: task.isCompleted ? Colors.green : Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      task.isCompleted ? Icons.check : Icons.check_outlined,
                      color: Color(0xfff9be03),
                      size: 20,
                    ),
                    onPressed: () {
                      // Handle completion toggle
                    },
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: PopupMenuButton<String>(
                    icon: Icon(
                      Icons.arrow_forward,
                      color: Color(0xfff9be03),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Color(0xfff9be03),
                    elevation: 4,
                    onSelected: (value) {
                      // Handle menu actions
                    },
                    itemBuilder: (BuildContext context) => [
                      if (isSharedByMe) ...[
                        PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit),
                            title: Text('Edit'),
                            dense: true,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        PopupMenuItem(
                          value: 'share',
                          child: ListTile(
                            leading: Icon(Icons.share),
                            title: Text('Share with more'),
                            dense: true,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                      PopupMenuItem(
                        value: 'viewShared',
                        child: ListTile(
                          leading: Icon(Icons.people),
                          title: Text(isSharedByMe ? 'View Shared Users' : 'Shared By'),
                          dense: true,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantsStack(List<AppUser> users) {
    return SizedBox(
      width: 80,
      height: 40,
      child: Stack(
        children: [
          ...List.generate(
            users.length > 3 ? 3 : users.length,
            (index) => Positioned(
              right: index * 20.0,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[300],
                child: Text(users[index].name?[0] ?? users[index].email[0]),
              ),
            ),
          ),
          if (users.length > 3)
            Positioned(
              right: 60,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.orange,
                child: Text(
                  '+${users.length - 3}',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Color(0xfff9be03),
          fontSize: 12,
        ),
      ),
    );
  }
}