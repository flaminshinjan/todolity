import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todolity/data/models/shared_tasks_model.dart';
import '../models/task_model.dart';
import 'package:logger/logger.dart';

class SharedTaskRepository {
  final FirebaseFirestore _firestore;
  final Logger _logger = Logger();

  SharedTaskRepository({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<SharedTask>> getSharedWithMeTasks(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('shared_with_me')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SharedTask.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      _logger.e('Error fetching shared with me tasks: $e');
      throw Exception('Failed to load shared tasks: $e');
    }
  }

 Future<List<SharedTask>> getSharedByMeTasks(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('shared_by_me')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SharedTask.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      _logger.e('Error fetching shared by me tasks: $e');
      throw Exception('Failed to load shared tasks: $e');
    }
  }

  // Share a task with another user
  Future<void> shareTask(Task originalTask, String sharedWithUserId) async {
    try {
      final sharedTask = SharedTask.fromTask(originalTask, sharedWithUserId);
      final batch = _firestore.batch();
      
      // Add to current user's shared_by_me collection
      final sharedByRef = _firestore
          .collection('users')
          .doc(originalTask.createdBy)
          .collection('shared_by_me')
          .doc();

      // Add to recipient's shared_with_me collection
      final sharedWithRef = _firestore
          .collection('users')
          .doc(sharedWithUserId)
          .collection('shared_with_me')
          .doc(sharedByRef.id);

      final sharedTaskData = sharedTask.toJson();

      batch.set(sharedByRef, sharedTaskData);
      batch.set(sharedWithRef, sharedTaskData);

      await batch.commit();
      _logger.i('Task shared successfully');
    } catch (e) {
      _logger.e('Error sharing task: $e');
      throw Exception('Failed to share task: $e');
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
  Future<void> updateTaskCompletion(String taskId, String userId, bool isCompleted) async {
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
    Stream<QuerySnapshot> getSharedWithMeTasksStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('shared_with_me')
        .snapshots();
  }

  Stream<QuerySnapshot> getSharedByMeTasksStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('shared_by_me')
        .snapshots();
  }
}