import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todolity/data/repositories/notification_repository.dart';
import '../models/task_model.dart';
import 'package:logger/logger.dart';

class TaskRepository {
  final FirebaseFirestore _firestore;
  final Logger _logger = Logger();

  final NotificationRepository _notificationRepository;

  TaskRepository({
    FirebaseFirestore? firestore,
    NotificationRepository? notificationRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _notificationRepository = notificationRepository ?? NotificationRepository();


Stream<List<Task>> getTasks(String userId) {
    return _firestore
        .collection('tasks')
        .where('createdBy', isEqualTo: userId) // Changed to fetch by createdBy
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            try {
              // Add error logging
              _logger.d('Processing document: ${doc.id}');
              _logger.d('Document data: ${doc.data()}');
              
              return Task.fromJson(doc.data(), doc.id);
            } catch (e) {
              _logger.e('Error parsing task ${doc.id}: $e');
              rethrow;
            }
          }).toList();
        });
  }

  Future<String> createTask(Task task) async {
    try {
      final docRef = await _firestore.collection('tasks').add({
        'title': task.title,
        'description': task.description,
        'isCompleted': task.isCompleted,
        'createdBy': task.createdBy,
        'sharedWith': task.sharedWith,
        'createdAt': FieldValue.serverTimestamp(), // Use server timestamp
      });
      print('Task created with ID: ${docRef.id}'); // Debug log
      return docRef.id;
    } catch (e) {
      print('Error creating task: $e'); // Debug log
      throw Exception('Failed to create task: ${e.toString()}');
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await _firestore.collection('tasks').doc(task.id).update({
        'title': task.title,
        'description': task.description,
        'isCompleted': task.isCompleted,
        'sharedWith': task.sharedWith,
        // Don't update createdAt when updating task
      });
      print('Task updated: ${task.id}'); // Debug log
    } catch (e) {
      print('Error updating task: $e'); // Debug log
      throw Exception('Failed to update task: ${e.toString()}');
    }
  }
 

  Future<void> unshareTask(String taskId, String userId) async {
    try {
      final taskRef = _firestore.collection('tasks').doc(taskId);
      
      await taskRef.update({
        'sharedWith': FieldValue.arrayRemove([userId])
      });
    } catch (e) {
      throw Exception('Failed to unshare task: $e');
    }
  }
  Future<void> deleteTask(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
      print('Task deleted: $taskId'); // Debug log
    } catch (e) {
      print('Error deleting task: $e'); // Debug log
      throw Exception('Failed to delete task: ${e.toString()}');
    }
  }
      Future<void> updateTaskCompletion(Task task, bool isCompleted) async {
    try {
      await _firestore.collection('tasks').doc(task.id).update({
        'isCompleted': isCompleted,
      });

      if (isCompleted) {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          await _notificationRepository.sendTaskCompletionNotification(
            task,
            currentUser.uid,
          );
        }
      }
    } catch (e) {
      print('Error updating task completion: $e');
      throw Exception('Failed to update task: ${e.toString()}');
    }
  }

  Future<void> shareTask(Task task, String sharedWithUserId) async {
    try {
      final batch = _firestore.batch();
      
      // Add to current user's shared_by_me collection
      final sharedByRef = _firestore
          .collection('users')
          .doc(task.createdBy)
          .collection('shared_by_me')
          .doc();

      // Add to recipient's shared_with_me collection
      final sharedWithRef = _firestore
          .collection('users')
          .doc(sharedWithUserId)
          .collection('shared_with_me')
          .doc(sharedByRef.id);

      final sharedTaskData = {
        ...task.toJson(),
        'sharedWith': FieldValue.arrayUnion([sharedWithUserId]),
      };

      batch.set(sharedByRef, sharedTaskData);
      batch.set(sharedWithRef, sharedTaskData);

      await batch.commit();
      _logger.i('Task shared successfully');
    } catch (e) {
      _logger.e('Error sharing task: $e');
      throw Exception('Failed to share task: $e');
    }
  }

  // Get tasks shared with the current user
  Future<List<Task>> getSharedWithMeTasks(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('shared_with_me')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Task.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      _logger.e('Error fetching shared with me tasks: $e');
      throw Exception('Failed to load shared tasks: $e');
    }
  }

  // Get tasks shared by the current user
  Future<List<Task>> getSharedByMeTasks(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('shared_by_me')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Task.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      _logger.e('Error fetching shared by me tasks: $e');
      throw Exception('Failed to load shared tasks: $e');
    }
  }

  // Remove shared task
  Future<void> removeSharedTask(String taskId, String userId, bool isSharedByMe) async {
    try {
      final collection = isSharedByMe ? 'shared_by_me' : 'shared_with_me';
      await _firestore
          .collection('users')
          .doc(userId)
          .collection(collection)
          .doc(taskId)
          .delete();

      _logger.i('Shared task removed successfully');
    } catch (e) {
      _logger.e('Error removing shared task: $e');
      throw Exception('Failed to remove shared task: $e');
    }
  }

  // Update shared task completion status
  Future<void> updateSharedTaskCompletion(
    String taskId, 
    String userId, 
    bool isCompleted
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('shared_with_me')
          .doc(taskId)
          .update({'isCompleted': isCompleted});

      _logger.i('Task completion status updated');
    } catch (e) {
      _logger.e('Error updating task completion: $e');
      throw Exception('Failed to update task completion: $e');
    }
  }
  Stream<QuerySnapshot> getMyTasksStream(String userId) {
    return _firestore
        .collection('tasks')
        .where('createdBy', isEqualTo: userId)
        .snapshots();
  }
}
