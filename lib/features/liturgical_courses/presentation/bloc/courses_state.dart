import 'package:equatable/equatable.dart';
import '../../data/models/course_model.dart';

abstract class CoursesState extends Equatable {
  const CoursesState();
  
  @override
  List<Object?> get props => [];
}

// 1. Loading Status (CircularProgressIndicator)
class CoursesLoading extends CoursesState {}

// 2.  Success Status (List View)
class CoursesLoaded extends CoursesState {
  final List<CourseModel> courses;

  const CoursesLoaded(this.courses);

  @override
  List<Object?> get props => [courses];
}

// 3. Error Status (Network Error Message)
class CoursesError extends CoursesState {
  final String message;

  const CoursesError(this.message);

  @override
  List<Object?> get props => [message];
}