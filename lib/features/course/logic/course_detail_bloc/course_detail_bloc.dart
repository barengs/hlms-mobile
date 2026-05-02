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
      
      // If enrolled, we can also fetch learning detail for better UX (progress, etc)
      if (course.isEnrolled) {
        try {
          final learningData = await _courseRepository.getLearningDetail(event.slug);
          // Merge sections if available in learning data
          final mergedCourse = Course(
            id: course.id,
            title: course.title,
            slug: course.slug,
            subtitle: course.subtitle,
            thumbnail: course.thumbnail,
            instructorName: course.instructorName,
            price: course.price,
            discountPrice: course.discountPrice,
            level: course.level,
            rating: course.rating,
            totalEnrollments: course.totalEnrollments,
            sections: learningData['sections'] ?? course.sections,
            description: course.description,
            requirements: course.requirements,
            outcomes: course.outcomes,
            isEnrolled: true,
          );
          emit(CourseDetailLoaded(mergedCourse));
          return;
        } catch (_) {
          // Fallback to basic detail if learning detail fails
        }
      }
      
      emit(CourseDetailLoaded(course));
    } catch (e) {
      emit(CourseDetailError(e.toString()));
    }
  }
}
