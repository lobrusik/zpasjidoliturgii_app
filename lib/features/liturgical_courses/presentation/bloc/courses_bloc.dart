import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/course_repository.dart';
import 'courses_event.dart';
import 'courses_state.dart';

class CoursesBloc extends Bloc<CoursesEvent, CoursesState> {
  final CourseRepository _courseRepository;
  StreamSubscription? _coursesSubscription;

  CoursesBloc({required CourseRepository courseRepository})
      : _courseRepository = courseRepository,
        super(CoursesLoading()) {
    
    on<LoadCourses>(_onLoadCourses);
    on<CoursesUpdated>(_onCoursesUpdated);
  }

  void _onLoadCourses(LoadCourses event, Emitter<CoursesState> emit) {
    emit(CoursesLoading());
    _coursesSubscription?.cancel();
    
    _coursesSubscription = _courseRepository.getCourses().listen(
      (coursesList) {
        add(CoursesUpdated(coursesList));
      },
      onError: (error) {
        add(CoursesUpdated(const []));
      },
    );
  }

  void _onCoursesUpdated(CoursesUpdated event, Emitter<CoursesState> emit) {
    if (event.courses.isEmpty) {
      emit(const CoursesLoaded([]));
    } else {
      emit(CoursesLoaded(List<dynamic>.from(event.courses).cast()));
    }
  }

  @override
  Future<void> close() {
    _coursesSubscription?.cancel();
    return super.close();
  }
}