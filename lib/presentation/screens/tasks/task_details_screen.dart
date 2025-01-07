import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todolity/presentation/screens/dashboard/dashboard_screen.dart';
import '../../../data/models/task_model.dart';
import '../../blocs/tasks/task_bloc.dart';
import '../../blocs/tasks/task_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NoTransitionRoute extends MaterialPageRoute {
  NoTransitionRoute({required WidgetBuilder builder})
      : super(builder: builder);

  @override
  Duration get transitionDuration => Duration.zero;
  
  @override
  Duration get reverseTransitionDuration => Duration.zero;
}

class TaskDetailsScreen extends StatefulWidget {
  final Task task;

  const TaskDetailsScreen({Key? key, required this.task}) : super(key: key);

  @override
  _TaskDetailsScreenState createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final updatedTask = widget.task.copyWith(
      title: _titleController.text,
      description: _descriptionController.text,
    );
    context.read<TaskBloc>().add(UpdateTask(updatedTask));
    setState(() {
      isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
    icon: Icon(Icons.arrow_back, color: Colors.black),
    onPressed: () {
      Navigator.of(context).pushReplacement(
        NoTransitionRoute(
          builder: (context) => DashboardScreen(),
        ),
      );
    },
  ),
        actions: [
          if (isEditing)
            IconButton(
              icon: Icon(Icons.check, color: Colors.green),
              onPressed: _saveChanges,
            )
          else
            IconButton(
              icon: Icon(Icons.edit, color: Colors.black),
              onPressed: () => setState(() => isEditing = true),
            ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusCard(),
              SizedBox(height: 24),

              if (isEditing)
                TextField(
                  controller: _titleController,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Task Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.purple, width: 2),
                    ),
                  ),
                )
              else
                GestureDetector(
                  onTap: () => setState(() => isEditing = true),
                  child: Text(
                    widget.task.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              SizedBox(height: 16),

              Text(
                'Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8),
              if (isEditing)
                TextField(
                  controller: _descriptionController,
                  maxLines: null,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Add description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.purple, width: 2),
                    ),
                  ),
                )
              else
                GestureDetector(
                  onTap: () => setState(() => isEditing = true),
                  child: Text(
                    widget.task.description.isEmpty 
                        ? 'Add description'
                        : widget.task.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                ),
              SizedBox(height: 24),

              _buildInfoRow(
                'Created',
                DateFormat('MMM dd, yyyy - HH:mm').format(widget.task.createdAt),
                Icons.calendar_today,
              ),
              SizedBox(height: 16),

              _buildInfoRow(
                'Created by',
                widget.task.createdBy,
                Icons.person,
              ),
              SizedBox(height: 24),

              if (widget.task.sharedWith.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Shared with',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.person_add),
                      onPressed: () {
                        // TODO: Implement share with new user
                      },
                    ),
                  ],
                ),
                SizedBox(height: 12),
                _buildSharedWithList(),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: widget.task.isCompleted ? Colors.green[50] : Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.task.isCompleted ? Icons.check_circle : Icons.pending,
            color: widget.task.isCompleted ? Colors.green : Colors.blue,
          ),
          SizedBox(width: 8),
          Text(
            widget.task.isCompleted ? 'Completed' : 'In Progress',
            style: TextStyle(
              color: widget.task.isCompleted ? Colors.green : Colors.blue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSharedWithList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: widget.task.sharedWith.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey[200],
            child: Icon(Icons.person, color: Colors.grey[600]),
          ),
          title: Text(widget.task.sharedWith[index]),
          contentPadding: EdgeInsets.zero,
          trailing: IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              // TODO: Implement remove shared user
            },
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () => _toggleTaskStatus(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.task.isCompleted ? Colors.grey : Colors.purple,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            widget.task.isCompleted ? 'Mark as Incomplete' : 'Mark as Complete',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _toggleTaskStatus(BuildContext context) {
    final updatedTask = widget.task.copyWith(isCompleted: !widget.task.isCompleted);
    context.read<TaskBloc>().add(UpdateTask(updatedTask));
    Navigator.pop(context);
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Task'),
          content: Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<TaskBloc>().add(DeleteTask(widget.task.id));
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close details screen
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}