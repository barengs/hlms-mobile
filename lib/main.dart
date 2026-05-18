import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hlms_mobile/core/config/app_router.dart';
import 'package:hlms_mobile/core/config/app_theme.dart';
import 'package:hlms_mobile/core/network/api_client.dart';
import 'package:hlms_mobile/features/auth/data/auth_repository.dart';
import 'package:hlms_mobile/features/auth/logic/auth_bloc/auth_bloc.dart';
import 'package:hlms_mobile/features/course/data/course_repository.dart';
import 'package:hlms_mobile/features/home/logic/home_bloc/home_bloc.dart';
import 'package:hlms_mobile/features/profile/data/profile_repository.dart';
import 'package:hlms_mobile/features/classroom/data/classroom_repository.dart';
import 'package:hlms_mobile/features/onboarding/data/onboarding_repository.dart';
import 'package:hlms_mobile/features/instructor/data/instructor_repository.dart';
import 'package:hlms_mobile/features/instructor/logic/instructor_dashboard_bloc/instructor_dashboard_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MolangApp());
}

class MolangApp extends StatelessWidget {
  const MolangApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => ApiClient()),
        RepositoryProvider(
          create: (context) => AuthRepository(context.read<ApiClient>()),
        ),
        RepositoryProvider(
          create: (context) => CourseRepository(context.read<ApiClient>()),
        ),
        RepositoryProvider(
          create: (context) => ProfileRepository(context.read<ApiClient>()),
        ),
        RepositoryProvider(
          create: (context) => ClassroomRepository(context.read<ApiClient>()),
        ),
        RepositoryProvider(
          create: (context) => OnboardingRepository(context.read<ApiClient>()),
        ),
        RepositoryProvider(
          create: (context) => InstructorRepository(context.read<ApiClient>()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(context.read<AuthRepository>())
              ..add(AuthCheckRequested()),
          ),
          BlocProvider(
            create: (context) => HomeBloc(context.read<CourseRepository>())
              ..add(HomeDataRequested()),
          ),
          BlocProvider(
            create: (context) => InstructorDashboardBloc(context.read<InstructorRepository>()),
          ),
        ],
        child: MaterialApp.router(
          title: 'MOLANG',
          theme: AppTheme.lightTheme,
          routerConfig: AppRouter.router,
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthUnauthenticated) {
                  AppRouter.router.go('/login');
                } else if (state is AuthAuthenticated) {
                  final roles = state.user['roles'] as List<dynamic>? ?? [];
                  final isInstructor = roles.any((role) => role['name'] == 'instructor');
                  if (!isInstructor) {
                    context.read<HomeBloc>().add(HomeDataRequested());
                  }
                }
              },
              child: child!,
            );
          },
        ),
      ),
    );
  }
}
