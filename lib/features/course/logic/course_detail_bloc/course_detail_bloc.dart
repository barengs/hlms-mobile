import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hlms_mobile/core/models/course.dart';
import 'package:hlms_mobile/features/course/data/course_repository.dart';

part 'course_detail_event.dart';
part 'course_detail_state.dart';

class CourseDetailBloc extends Bloc<CourseDetailEvent, CourseDetailState> {
  final CourseRepository _courseRepository;

  CourseDetailBloc(this._courseRepository) : super(CourseDetailInitial()) {
    on<CourseDetailRequested>(_onCourseDetailRequested);
  }

  Future<void> _onCourseDetailRequested(
    CourseDetailRequested event,
    Emitter<CourseDetailState> emit,
  ) async {
    emit(CourseDetailLoading());
    try {
      final course = await _courseRepository.getCourseDetail(event.slug);
      emit(CourseDetailLoaded(course));
    } catch (e) {
      emit(CourseDetailError(e.toString()));
    }
  }
}
