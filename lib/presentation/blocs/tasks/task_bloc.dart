import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/task_repository.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository taskRepository;  // Make it accessible

  TaskBloc({required this.taskRepository})  // Update constructor
      : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
  }

  void _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      await emit.forEach(
        taskRepository.getTasks(event.userId),
        onData: (tasks) => TaskLoaded(tasks),
        onError: (error, stackTrace) {
          print('Error loading tasks: $error');
          return TaskError(error.toString());
        },
      );
    } catch (e) {
      print('Error in _onLoadTasks: $e');
      emit(TaskError(e.toString()));
    }
  }

  void _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    try {
      await taskRepository.createTask(event.task);
      // The stream will automatically update the UI
    } catch (e) {
      print('Error in _onAddTask: $e');
      emit(TaskError(e.toString()));
    }
  }

  void _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    try {
      await taskRepository.updateTask(event.task);
      // The stream will automatically update the UI
    } catch (e) {
      print('Error in _onUpdateTask: $e');
      emit(TaskError(e.toString()));
    }
  }

  void _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    try {
      await taskRepository.deleteTask(event.taskId);
      // The stream will automatically update the UI
    } catch (e) {
      print('Error in _onDeleteTask: $e');
      emit(TaskError(e.toString()));
    }
  }
}