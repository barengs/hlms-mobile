import 'package:equatable/equatable.dart';

abstract class InstructorDashboardState extends Equatable {
  const InstructorDashboardState();

  @override
  List<Object?> get props => [];
}

class InstructorDashboardInitial extends InstructorDashboardState {}

class InstructorDashboardLoading extends InstructorDashboardState {}

class InstructorDashboardLoaded extends InstructorDashboardState {
  final Map<String, dynamic> dashboardData;

  const InstructorDashboardLoaded(this.dashboardData);

  @override
  List<Object?> get props => [dashboardData];
}

class InstructorDashboardError extends InstructorDashboardState {
  final String message;

  const InstructorDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
