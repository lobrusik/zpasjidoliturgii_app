import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProgressRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Securely Retrieve Your Current User ID
  String get _currentUserId {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Użytkownik nie jest zalogowany.");
    return user.uid;
  }

  // Downloading the stream of completed stages
  Stream<List<String>> getCompletedPlansForCourse(String courseId) {
    return _firestore
        .collection('users')
        .doc(_currentUserId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return [];
      
      final data = snapshot.data()!;
      final progressMap = data['progress'] as Map<String, dynamic>? ?? {};
      final courseProgress = progressMap[courseId] as List<dynamic>? ?? [];
      
      return courseProgress.map((e) => e.toString()).toList();
    });
  }

  // Marking a lesson as completed
  Future<void> toggleLessonCompletion(String courseId, String planId, bool isCompleted) async {
    final docRef = _firestore.collection('users').doc(_currentUserId);

    await docRef.set({
      'progress': {
        courseId: isCompleted 
            ? FieldValue.arrayUnion([planId]) 
            : FieldValue.arrayRemove([planId])
      }
    }, SetOptions(merge: true));
  }
}