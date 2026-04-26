part of 'course_detail_bloc.dart';

abstract class CourseDetailEvent extends Equatable {
  const CourseDetailEvent();

  @override
  List<Object?> get props => [];
}

class CourseDetailRequested extends CourseDetailEvent {
  final String slug;
  const CourseDetailRequested(this.slug);

  @override
  List<Object?> get props => [slug];
}
