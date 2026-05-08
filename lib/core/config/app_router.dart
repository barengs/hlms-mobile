import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:hlms_mobile/features/onboarding/ui/splash_screen.dart';
import 'package:hlms_mobile/features/auth/ui/login_screen.dart';
import 'package:hlms_mobile/features/auth/ui/register_screen.dart';
import 'package:hlms_mobile/features/home/ui/main_navigation_screen.dart';
import 'package:hlms_mobile/features/course/ui/course_detail_screen.dart';
import 'package:hlms_mobile/features/learning/ui/lesson_screen.dart';
import 'package:hlms_mobile/features/classroom/ui/assignment_list_screen.dart';
import 'package:hlms_mobile/features/classroom/ui/assignment_upload_screen.dart';
import 'package:hlms_mobile/features/classroom/ui/quiz_screen.dart';
import 'package:hlms_mobile/features/course/ui/enrollment_screen.dart';
import 'package:hlms_mobile/features/classroom/ui/classroom_screen.dart';
import 'package:hlms_mobile/features/auth/ui/forgot_password_screen.dart';
import 'package:hlms_mobile/features/onboarding/ui/onboarding_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainNavigationScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/course/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final isEnrolled = state.uri.queryParameters['enrolled'] == 'true';
          return CourseDetailScreen(courseId: id, isEnrolled: isEnrolled);
        },
      ),
      GoRoute(
        path: '/course/enroll/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EnrollmentScreen(courseId: id);
        },
      ),
      GoRoute(
        path: '/lesson/:slug/:lessonId',
        builder: (context, state) {
          final slug = state.pathParameters['slug']!;
          final lessonId = int.parse(state.pathParameters['lessonId']!);
          return LessonScreen(slug: slug, lessonId: lessonId);
        },
      ),
      GoRoute(
        path: '/assignments',
        builder: (context, state) => const AssignmentListScreen(),
      ),
      GoRoute(
        path: '/assignment/upload/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return AssignmentUploadScreen(assignmentId: id);
        },
      ),
      GoRoute(
        path: '/quiz/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return QuizScreen(assignmentId: id);
        },
      ),
      GoRoute(
        path: '/quiz-v2/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return QuizScreen(quizId: id);
        },
      ),
      GoRoute(
        path: '/classroom/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ClassroomScreen(classId: id);
        },
      ),
    ],
  );
}

