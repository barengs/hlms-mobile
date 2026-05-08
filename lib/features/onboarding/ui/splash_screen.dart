import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hlms_mobile/features/auth/logic/auth_bloc/auth_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated) {
          final user = authState.user;
          final profile = user['profile'] as Map<String, dynamic>?;
          final roles = user['roles'] as List<dynamic>?;
          
          final isStudent = roles?.any((role) => role['name'] == 'student') ?? true;
          final onboardingCompleted = profile?['onboarding_completed'] == true || 
                                     profile?['onboarding_completed'] == 1 ||
                                     user['onboarding_completed'] == true ||
                                     (profile?['interests'] != null && (profile?['interests'] as List).isNotEmpty);
          
          // Only students who haven't completed onboarding should see the onboarding screen.
          // Existing users, instructors, and admins should go straight to home.
          if (!isStudent || onboardingCompleted) {
            context.go('/home');
          } else {
            context.go('/onboarding');
          }
        } else {
          context.go('/login');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Education Logo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_stories, // Book/Education icon
                size: 120,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'MOLANG',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
                color: Color(0xFF0D47A1),
              ),
            ),
            const Text(
              'Modern Learning & Guidance',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 64),
            // Loading Animation
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D47A1)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
