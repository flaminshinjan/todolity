import 'package:todolity/data/models/shared_tasks_model.dart';


abstract class SharedTaskState {}

class SharedTaskInitial extends SharedTaskState {}

class SharedTaskLoading extends SharedTaskState {}

class SharedTaskLoaded extends SharedTaskState {
  final List<SharedTask> sharedWithMeTasks;
  final List<SharedTask> sharedByMeTasks;

  SharedTaskLoaded({
    required this.sharedWithMeTasks,
    required this.sharedByMeTasks,
  });
}

class SharedTaskError extends SharedTaskState {
  final String message;
  SharedTaskError(this.message);
}