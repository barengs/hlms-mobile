import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hlms_mobile/features/instructor/logic/instructor_dashboard_bloc/instructor_dashboard_bloc.dart';
import 'package:hlms_mobile/features/instructor/logic/instructor_dashboard_bloc/instructor_dashboard_event.dart';
import 'package:hlms_mobile/features/instructor/ui/instructor_home_screen.dart';
import 'package:hlms_mobile/features/instructor/ui/instructor_course_screen.dart';
import 'package:hlms_mobile/features/instructor/ui/instructor_redeem_screen.dart';
import 'package:hlms_mobile/features/instructor/ui/instructor_profile_screen.dart';

class InstructorMainScreen extends StatefulWidget {
  const InstructorMainScreen({super.key});

  @override
  State<InstructorMainScreen> createState() => _InstructorMainScreenState();
}

class _InstructorMainScreenState extends State<InstructorMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const InstructorHomeScreen(),
    const InstructorCourseScreen(),
    const InstructorRedeemScreen(),
    const InstructorProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Fetch initial dashboard data
    context.read<InstructorDashboardBloc>().add(InstructorDashboardRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF0D47A1),
          unselectedItemColor: Colors.grey.shade400,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard, size: 26),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school, size: 26),
              label: 'Courses',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet, size: 26),
              label: 'Redeem',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 26),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
