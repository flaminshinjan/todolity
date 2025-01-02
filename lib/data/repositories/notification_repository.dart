import 'package:cloud_functions/cloud_functions.dart';
import '../models/task_model.dart';

class NotificationRepository {
  final FirebaseFunctions _functions;

  NotificationRepository({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  Future<void> sendTaskCompletionNotification(Task task, String completedBy) async {
    try {
      await _functions.httpsCallable('sendTaskNotification').call({
        'taskId': task.id,
        'taskTitle': task.title,
        'completedBy': completedBy,
        'sharedWith': task.sharedWith,
        'type': 'completion',
      });
    } catch (e) {
      print('Error sending notification: $e');
      throw Exception('Failed to send notification: ${e.toString()}');
    }
  }
}