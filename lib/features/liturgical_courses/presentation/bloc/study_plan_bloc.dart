import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/study_plan_model.dart';
import '../../domain/repositories/course_repository.dart';

// Events
abstract class StudyPlanEvent extends Equatable {
  const StudyPlanEvent();
  @override
  List<Object?> get props => [];
}

class LoadStudyPlans extends StudyPlanEvent {
  final String courseId;
  const LoadStudyPlans(this.courseId);
  @override
  List<Object?> get props => [courseId];
}

class StudyPlansUpdated extends StudyPlanEvent {
  final List<StudyPlanModel> plans;
  const StudyPlansUpdated(this.plans);
  @override
  List<Object?> get props => [plans];
}

class StudyPlanErrorOccurred extends StudyPlanEvent {
  final String message;
  const StudyPlanErrorOccurred(this.message);
  @override
  List<Object?> get props => [message];
}

// States
abstract class StudyPlanState extends Equatable {
  const StudyPlanState();
  @override
  List<Object?> get props => [];
}

class StudyPlanLoading extends StudyPlanState {}
class StudyPlanLoaded extends StudyPlanState {
  final List<StudyPlanModel> plans;
  const StudyPlanLoaded(this.plans);
  @override
  List<Object?> get props => [plans];
}
class StudyPlanError extends StudyPlanState {
  final String message;
  const StudyPlanError(this.message);
  @override
  List<Object?> get props => [message];
}

// Business logic
class StudyPlanBloc extends Bloc<StudyPlanEvent, StudyPlanState> {
  final CourseRepository _courseRepository;
  StreamSubscription? _plansSubscription;

  StudyPlanBloc({required CourseRepository courseRepository})
      : _courseRepository = courseRepository,
        super(StudyPlanLoading()) {
    on<LoadStudyPlans>(_onLoadStudyPlans);
    on<StudyPlansUpdated>(_onStudyPlansUpdated);
    on<StudyPlanErrorOccurred>(_onStudyPlanErrorOccurred);
  }

  void _onLoadStudyPlans(LoadStudyPlans event, Emitter<StudyPlanState> emit) {
    emit(StudyPlanLoading());
    _plansSubscription?.cancel();
    
    _plansSubscription = _courseRepository.getStudyPlansForCourse(event.courseId).listen(
      (plansList) => add(StudyPlansUpdated(plansList)),
      onError: (error) => add(const StudyPlanErrorOccurred('Nie udało się pobrać etapów kursu.')),
    );
  }

  void _onStudyPlansUpdated(StudyPlansUpdated event, Emitter<StudyPlanState> emit) {
    emit(StudyPlanLoaded(event.plans));
  }
  void _onStudyPlanErrorOccurred(StudyPlanErrorOccurred event, Emitter<StudyPlanState> emit) {
    emit(StudyPlanError(event.message));
  }

  @override
  Future<void> close() {
    _plansSubscription?.cancel();
    return super.close();
  }
}