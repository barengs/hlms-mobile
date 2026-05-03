import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hlms_mobile/core/models/course.dart';
import 'package:hlms_mobile/core/models/enrollment.dart';
import 'package:hlms_mobile/features/course/data/course_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final CourseRepository _courseRepository;

  HomeBloc(this._courseRepository) : super(HomeInitial()) {
    on<HomeDataRequested>(_onHomeDataRequested);
  }

  Future<void> _onHomeDataRequested(
    HomeDataRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      final results = await Future.wait([
        _courseRepository.getLatestCourses(),
        _courseRepository.getMyLearning(),
        _courseRepository.getCategories(),
        _courseRepository.getRecommendations(),
      ]);

      final allLearning = results[1] as List<Enrollment>;
      final myCourses = allLearning.where((e) => e.type == 'course').toList();
      final myClasses = allLearning.where((e) => e.type != 'course').toList();

      emit(HomeLoaded(
        latestCourses: results[0] as List<Course>,
        continuingCourses: myCourses,
        myClasses: myClasses,
        recommendations: results[3] as List<Course>,
        categories: results[2] as List<Map<String, dynamic>>,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
