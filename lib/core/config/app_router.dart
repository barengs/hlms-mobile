import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:hlms_mobile/features/onboarding/ui/onboarding_screen.dart';
import 'package:hlms_mobile/features/auth/ui/login_screen.dart';
import 'package:hlms_mobile/features/home/ui/main_navigation_screen.dart';
import 'package:hlms_mobile/features/course/ui/course_detail_screen.dart';
import 'package:hlms_mobile/features/learning/ui/video_player_screen.dart';
import 'package:hlms_mobile/features/classroom/ui/assignment_list_screen.dart';
import 'package:hlms_mobile/features/classroom/ui/assignment_upload_screen.dart';
import 'package:hlms_mobile/features/classroom/ui/quiz_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainNavigationScreen(),
      ),
      GoRoute(
        path: '/course/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return CourseDetailScreen(courseId: id);
        },
      ),
      GoRoute(
        path: '/video-player',
        builder: (context, state) => const VideoPlayerScreen(),
      ),
      GoRoute(
        path: '/assignments',
        builder: (context, state) => const AssignmentListScreen(),
      ),
      GoRoute(
        path: '/assignment/upload',
        builder: (context, state) => const AssignmentUploadScreen(),
      ),
      GoRoute(
        path: '/quiz',
        builder: (context, state) => const QuizScreen(),
      ),
    ],
  );
}

