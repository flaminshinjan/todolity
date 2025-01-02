import 'package:todolity/data/models/task_model.dart';

abstract class TaskEvent {}

class LoadTasks extends TaskEvent {
  final String userId;
  LoadTasks(this.userId);
}

class AddTask extends TaskEvent {
  final Task task;
  AddTask(this.task);
}

class UpdateTask extends TaskEvent {
  final Task task;
  UpdateTask(this.task);
}

class DeleteTask extends TaskEvent {
  final String taskId;
  DeleteTask(this.taskId);
}

class ShareTask extends TaskEvent {
  final String taskId;
  final String userId;
  ShareTask(this.taskId, this.userId);
}