import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/course_repository.dart';
import '../models/course_model.dart';
import '../models/study_plan_model.dart';

class CourseRepositoryImpl implements CourseRepository {
  final FirebaseFirestore _firestore;

  CourseRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<CourseModel>> getCourses() {
    return _firestore
        .collection('courses')
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return CourseModel.fromFirestore(doc.data(), doc.id);
          }).toList();
        });
  }

  @override
  Stream<List<StudyPlanModel>> getStudyPlansForCourse(String courseId) {
    return _firestore
        .collection('study_plans')
        .where('courseId', isEqualTo: courseId)
        .orderBy('dayStage')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return StudyPlanModel.fromFirestore(doc.data(), doc.id);
          }).toList();
        });
  }
}