import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hlms_mobile/features/instructor/data/instructor_repository.dart';
import 'instructor_dashboard_event.dart';
import 'instructor_dashboard_state.dart';

class InstructorDashboardBloc extends Bloc<InstructorDashboardEvent, InstructorDashboardState> {
  final InstructorRepository _instructorRepository;

  InstructorDashboardBloc(this._instructorRepository) : super(InstructorDashboardInitial()) {
    on<InstructorDashboardRequested>(_onDashboardRequested);
  }

  Future<void> _onDashboardRequested(
    InstructorDashboardRequested event,
    Emitter<InstructorDashboardState> emit,
  ) async {
    emit(InstructorDashboardLoading());
    try {
      final data = await _instructorRepository.getDashboardData();
      emit(InstructorDashboardLoaded(data));
    } catch (e) {
      emit(InstructorDashboardError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
