import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todolity/presentation/screens/tasks/task_details_screen.dart';
import 'package:todolity/presentation/widgets/edit_task_dialog.dart';
import 'package:todolity/presentation/widgets/share_task_dialog.dart';
import 'package:todolity/presentation/widgets/shared_user_list_dialog.dart';
import 'dart:math';
import '../../data/models/task_model.dart';
import '../blocs/tasks/task_bloc.dart';
import '../blocs/tasks/task_event.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  
  // List of pastel colors
  static const List<Color> pastelColors = [
    Color(0xFFF5E6FF), // Light Purple
    Color(0xFFE6F0FF), // Light Blue
    Color(0xFFFFE6E6), // Light Pink
    Color(0xFFE6FFE6), // Light Green
    Color(0xFFFFF5E6), // Light Orange
    Color(0xFFE6FFFF), // Light Cyan
  ];

  // Generate a random color from the list based on task ID
  Color _getRandomColor() {
    final random = Random(task.id.hashCode);
    return pastelColors[random.nextInt(pastelColors.length)];
  }
  
  const TaskItem({
    Key? key,
    required this.task,
  }) : super(key: key);

  void _toggleCompletion(BuildContext context) async {
    try {
      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
      context.read<TaskBloc>().add(UpdateTask(updatedTask));
      
      if (updatedTask.isCompleted) {
        print('Sending notification for task: ${task.id}');
        await context.read<TaskBloc>().taskRepository.updateTaskCompletion(
          task,
          true,
        );
      }
    } catch (e) {
      print('Error updating task: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating task: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getRandomColor();
    
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Delete Task'),
              content: Text('Are you sure you want to delete this task?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Delete'),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        context.read<TaskBloc>().add(DeleteTask(task.id));
      },
      background: Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        child: Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: GestureDetector(
        onTap: () {
    Navigator.of(context).pushReplacement(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => TaskDetailsScreen(task: task),
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    ),
  );
  },
        child: Container(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor, // Using random pastel color
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                        decoration: task.isCompleted 
                            ? TextDecoration.lineThrough 
                            : TextDecoration.none,
                      ),
                    ),
                    if (task.description.isNotEmpty) ...[
                      SizedBox(height: 4),
                      Text(
                        task.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          decoration: task.isCompleted 
                              ? TextDecoration.lineThrough 
                              : TextDecoration.none,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _toggleCompletion(context),
                child: Container(
                  width: 40,
                  height: 40,
                  margin: EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: task.isCompleted ? Colors.white : Colors.white!,
                      width: 1,
                    ),
                    color: task.isCompleted ? Colors.white : Colors.white,
                  ),
                  child: task.isCompleted
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.black,
                        )
                      : null,
                ),
              ),
              Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: PopupMenuButton<String>(
                      icon: Icon(
                        Icons.arrow_forward,
                        color: Colors.black,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                     color: Color.fromARGB(255, 0, 0, 0),
                      elevation: 4,
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => SingleChildScrollView(
      child: EditTaskDialog(task: task),
    ),
  );
                            break;
                          case 'share':
                            showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => SingleChildScrollView(
      child: ShareTaskDialog(task: task),
    ),
  );
                            break;
                          case 'viewShared':
                            showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => SingleChildScrollView(
      child: SharedUsersListDialog(task: task),
    ),
  );
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) => [
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
                            title: Text('Share'),
                            dense: true,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        PopupMenuItem(
                          value: 'viewShared',
                          child: ListTile(
                            leading: Icon(Icons.people),
                            title: Text('View Shared Users'),
                            dense: true,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}