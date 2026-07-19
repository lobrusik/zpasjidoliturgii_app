import 'package:equatable/equatable.dart';

abstract class CoursesEvent extends Equatable {
  const CoursesEvent();

  @override
  List<Object?> get props => [];
}

// Event triggered at startup – starts listening for the database
class LoadCourses extends CoursesEvent {}

// Internal event – triggered automatically when Firestore sends new data
class CoursesUpdated extends CoursesEvent {
  final List<dynamic> courses;

  const CoursesUpdated(this.courses);

  @override
  List<Object?> get props => [courses];
}