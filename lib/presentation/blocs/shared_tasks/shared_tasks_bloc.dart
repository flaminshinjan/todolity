import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todolity/data/repositories/shared_tasks_repository.dart';
import 'package:todolity/presentation/blocs/shared_tasks/shared_tasks_event.dart';
import 'shared_task_state.dart';
import 'package:logger/logger.dart';

class SharedTaskBloc extends Bloc<SharedTaskEvent, SharedTaskState> {
  final SharedTaskRepository repository;  // Updated type
  final Logger _logger = Logger();

  SharedTaskBloc({required this.repository}) : super(SharedTaskInitial()) {
    on<LoadSharedTasks>(_onLoadSharedTasks);
    on<CompleteSharedTask>(_onCompleteSharedTask);
    on<RemoveSharedTask>(_onRemoveSharedTask);
  }

  Future<void> _onLoadSharedTasks(
    LoadSharedTasks event,
    Emitter<SharedTaskState> emit,
  ) async {
    try {
      emit(SharedTaskLoading());
      
      final sharedWithMeTasks = await repository.getSharedWithMeTasks(event.userId);
      final sharedByMeTasks = await repository.getSharedByMeTasks(event.userId);
      
      emit(SharedTaskLoaded(
        sharedWithMeTasks: sharedWithMeTasks,
        sharedByMeTasks: sharedByMeTasks,
      ));
    } catch (e) {
      _logger.e('Error loading shared tasks: $e');
      emit(SharedTaskError(e.toString()));
    }
  }

  Future<void> _onCompleteSharedTask(
    CompleteSharedTask event,
    Emitter<SharedTaskState> emit,
  ) async {
    try {
      await repository.updateTaskCompletion(
        event.taskId,
        event.userId,
        event.isCompleted,
      );
      add(LoadSharedTasks(event.userId));
    } catch (e) {
      _logger.e('Error completing shared task: $e');
      emit(SharedTaskError(e.toString()));
    }
  }

  Future<void> _onRemoveSharedTask(
    RemoveSharedTask event,
    Emitter<SharedTaskState> emit,
  ) async {
    try {
      await repository.removeSharedTask(
        event.taskId,
        event.userId,
        event.isSharedByMe,
      );
      add(LoadSharedTasks(event.userId));
    } catch (e) {
      _logger.e('Error removing shared task: $e');
      emit(SharedTaskError(e.toString()));
    }
  }
}