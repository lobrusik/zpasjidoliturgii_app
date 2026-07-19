import '../../data/models/course_model.dart';
import '../../data/models/study_plan_model.dart';

abstract class CourseRepository {
  Stream<List<CourseModel>> getCourses();
  Stream<List<StudyPlanModel>> getStudyPlansForCourse(String courseId);
}