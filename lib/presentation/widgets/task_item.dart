import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todolity/presentation/widgets/edit_task_dialog.dart';
import 'package:todolity/presentation/widgets/share_task_dialog.dart';
import 'package:todolity/presentation/widgets/shared_user_list_dialog.dart';
import '../../data/models/task_model.dart';
import '../blocs/tasks/task_bloc.dart';
import '../blocs/tasks/task_event.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final List<String>? participants;
  
  const TaskItem({
    Key? key,
    required this.task,
    this.participants,
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
      child: Container(
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
                            color: Colors.grey[600],
                            fontSize: 14,
                            decoration: task.isCompleted 
                                ? TextDecoration.lineThrough 
                                : TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (participants != null && participants!.isNotEmpty)
                    _buildParticipantsStack(),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  _buildTag('Today', Colors.black),
                  SizedBox(width: 8),
                 
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
                      onPressed: () => _toggleCompletion(context),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParticipantsStack() {
    return SizedBox(
      width: 80,
      height: 40,
      child: Stack(
        children: [
          ...List.generate(
            participants!.length > 3 ? 3 : participants!.length,
            (index) => Positioned(
              right: index * 20.0,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[300],
                child: Text(participants![index][0]),
              ),
            ),
          ),
          if (participants!.length > 3)
            Positioned(
              right: 60,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.orange,
                child: Text(
                  '+${participants!.length - 3}',
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