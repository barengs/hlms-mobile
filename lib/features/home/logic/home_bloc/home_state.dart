part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<Course> latestCourses;
  final List<Enrollment> continuingCourses;
  final List<Map<String, dynamic>> categories;

  const HomeLoaded({
    required this.latestCourses,
    required this.continuingCourses,
    required this.categories,
  });

  @override
  List<Object?> get props => [latestCourses, continuingCourses, categories];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
