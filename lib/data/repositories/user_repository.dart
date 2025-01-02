import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todolity/data/models/app_user_model.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

 Future<List<AppUser>> searchUsers(String searchTerm) async {
    try {
      final String searchLower = searchTerm.toLowerCase();
      
      final querySnapshot = await _firestore
          .collection('users')
          .where('searchKey', isGreaterThanOrEqualTo: searchLower)
          .where('searchKey', isLessThan: searchLower + 'z')
          .limit(10) // Limit results for better performance
          .get();

      print('Found ${querySnapshot.docs.length} users'); // Debug log

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        print('User data: $data'); // Debug log
        return AppUser.fromJson({
          ...data,
          'id': doc.id,
        });
      }).toList();
    } catch (e) {
      print('Error searching users: $e');
      throw Exception('Failed to search users: ${e.toString()}');
    }
  }
Future<void> updateFcmToken(String userId, String token) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
      });
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }

  Future<List<String>> getUserFcmTokens(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      final data = doc.data();
      if (data != null && data['fcmTokens'] != null) {
        return List<String>.from(data['fcmTokens']);
      }
      return [];
    } catch (e) {
      print('Error getting FCM tokens: $e');
      return [];
    }
  }
  Future<List<AppUser>> getUsersByIds(List<String> userIds) async {
    try {
      if (userIds.isEmpty) return [];
      
      final snapshots = await Future.wait(
        userIds.map((id) => 
          _firestore.collection('users').doc(id).get()
        )
      );

      return snapshots
          .where((doc) => doc.exists)
          .map((doc) => AppUser.fromMap(doc.data()!, doc.id))
          .toList();
    } catch (e) {
      print('Error fetching users: $e');
      throw Exception('Failed to load users');
    }
  }

  Future<void> createUserProfile(String userId, String email, {String? name}) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'email': email,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating user profile: $e');
      throw Exception('Failed to create user profile');
    }
  }

  Stream<AppUser?> getUserStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return AppUser.fromJson({...doc.data()!, 'id': doc.id});
        });
  }
}