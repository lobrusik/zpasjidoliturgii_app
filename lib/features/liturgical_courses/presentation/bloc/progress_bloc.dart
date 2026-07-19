import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/progress_repository.dart';

abstract class ProgressEvent extends Equatable {
  const ProgressEvent();
  @override
  List<Object?> get props => [];
}

class LoadProgress extends ProgressEvent {
  final String courseId;
  const LoadProgress(this.courseId);
  @override
  List<Object?> get props => [courseId];
}

class ProgressUpdated extends ProgressEvent {
  final List<String> completedPlanIds;
  const ProgressUpdated(this.completedPlanIds);
  @override
  List<Object?> get props => [completedPlanIds];
}

class ToggleLessonProgress extends ProgressEvent {
  final String courseId;
  final String planId;
  final bool isCompleted;

  const ToggleLessonProgress({
    required this.courseId,
    required this.planId,
    required this.isCompleted,
  });
  @override
  List<Object?> get props => [courseId, planId, isCompleted];
}

class ProgressErrorOccurred extends ProgressEvent {
  final String message;
  const ProgressErrorOccurred(this.message);
  @override
  List<Object?> get props => [message];
}

abstract class ProgressState extends Equatable {
  const ProgressState();
  @override
  List<Object?> get props => [];
}

class ProgressLoading extends ProgressState {}

class ProgressLoaded extends ProgressState {
  final List<String> completedPlanIds;
  const ProgressLoaded(this.completedPlanIds);
  @override
  List<Object?> get props => [completedPlanIds];
}

class ProgressError extends ProgressState {
  final String message;
  const ProgressError(this.message);
  @override
  List<Object?> get props => [message];
}

class ProgressBloc extends Bloc<ProgressEvent, ProgressState> {
  final ProgressRepository _progressRepository;
  StreamSubscription? _progressSubscription;

  ProgressBloc({required ProgressRepository progressRepository})
      : _progressRepository = progressRepository,
        super(ProgressLoading()) {
    on<LoadProgress>(_onLoadProgress);
    on<ProgressUpdated>(_onProgressUpdated);
    on<ToggleLessonProgress>(_onToggleProgress);
    on<ProgressErrorOccurred>(_onProgressErrorOccurred);
  }

  void _onLoadProgress(LoadProgress event, Emitter<ProgressState> emit) {
    emit(ProgressLoading());
    _progressSubscription?.cancel();
    
    _progressSubscription = _progressRepository
        .getCompletedPlansForCourse(event.courseId)
        .listen(
      (completedIds) {
        add(ProgressUpdated(completedIds));
      },
      onError: (error) {
        add(ProgressErrorOccurred('Nie udało się pobrać postępów.'));
      },
    );
  }

  void _onProgressUpdated(ProgressUpdated event, Emitter<ProgressState> emit) {
    emit(ProgressLoaded(event.completedPlanIds));
  }

  void _onToggleProgress(ToggleLessonProgress event, Emitter<ProgressState> emit) async {
    try {
      await _progressRepository.toggleLessonCompletion(
        event.courseId, 
        event.planId, 
        event.isCompleted,
      );
    } catch (e) {
      add(ProgressErrorOccurred('Błąd podczas zapisywania postępu: $e'));
    }
  }

  void _onProgressErrorOccurred(ProgressErrorOccurred event, Emitter<ProgressState> emit) {
    emit(ProgressError(event.message));
  }

  @override
  Future<void> close() {
    _progressSubscription?.cancel();
    return super.close();
  }
}