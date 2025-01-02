abstract class SharedTaskEvent {}

class LoadSharedTasks extends SharedTaskEvent {
  final String userId;
  LoadSharedTasks(this.userId);
}

class CompleteSharedTask extends SharedTaskEvent {
  final String taskId;
  final String userId;
  final bool isCompleted;
  CompleteSharedTask(this.taskId, this.userId, this.isCompleted);
}

class RemoveSharedTask extends SharedTaskEvent {
  final String taskId;
  final String userId;
  final bool isSharedByMe;
  RemoveSharedTask(this.taskId, this.userId, this.isSharedByMe);
}