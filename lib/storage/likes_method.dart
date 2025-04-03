import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LikeService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Toggles a like for a specialist
  /// Returns:
  /// - 'liked' if the like was added
  /// - 'unliked' if the like was removed
  /// - Error message if something went wrong
  Future<String> toggleLike(String specialistId) async {
    final user = _auth.currentUser;
    if (user == null) {
      return 'Authentication required';
    }

    // Prevent users from liking themselves
    if (specialistId == user.uid) {
      return 'Error: You cannot like yourself';
    }

    try {
      final likeRef = _firestore.collection('users').doc(specialistId).collection('likes').doc(user.uid);

      final likeDoc = await likeRef.get();

      if (likeDoc.exists) {
        // Unlike if already liked
        await likeRef.delete();
        return 'un_liked';
      } else {
        // Add like if not already liked
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        String userName = userDoc.exists ? (userDoc.data()?['firstName'] ?? 'Anonymous') : 'Anonymous';
        String userLastName = userDoc.exists ? (userDoc.data()?['lastName'] ?? 'Anonymous') : 'Anonymous';

        await likeRef.set({
          'userId': user.uid,
          'userName': userName,
          'userLastName': userLastName,
          'timestamp': FieldValue.serverTimestamp(),
        });
        return 'liked';
      }
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  /// Checks if the current user has liked the specialist
  Future<bool> hasLiked(String specialistId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final likeDoc = await _firestore.collection('users').doc(specialistId).collection('likes').doc(user.uid).get();

    return likeDoc.exists;
  }

  /// Gets all users who liked the specialist
  Stream<QuerySnapshot> getLikes(String specialistId) {
    return _firestore.collection('users').doc(specialistId).collection('likes').orderBy('timestamp', descending: true).snapshots();
  }
}
