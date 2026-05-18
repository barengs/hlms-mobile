import 'package:equatable/equatable.dart';

abstract class InstructorDashboardEvent extends Equatable {
  const InstructorDashboardEvent();

  @override
  List<Object> get props => [];
}

class InstructorDashboardRequested extends InstructorDashboardEvent {}
