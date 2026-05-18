import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hlms_mobile/features/auth/logic/auth_bloc/auth_bloc.dart';
import 'package:hlms_mobile/features/instructor/logic/instructor_dashboard_bloc/instructor_dashboard_bloc.dart';
import 'package:hlms_mobile/features/instructor/logic/instructor_dashboard_bloc/instructor_dashboard_state.dart';

class InstructorProfileScreen extends StatelessWidget {
  const InstructorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = authState.user;
        final name = user['name'] ?? 'Instruktur';
        final email = user['email'] ?? '';
        final profile = user['profile'] as Map<String, dynamic>? ?? {};
        final avatar = profile['avatar'];
        final bio = profile['bio'] ?? 'Belum ada bio singkat.';

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Header section with gradient
                _buildHeader(context, name, email, avatar),
                const SizedBox(height: 24),

                // Stats Section (Optional, loaded from InstructorDashboardBloc if active)
                _buildStatsSummary(),
                const SizedBox(height: 24),

                // Information Cards
                _buildInfoSection(bio),
                const SizedBox(height: 24),

                // Logout Button
                _buildLogoutButton(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, String name, String email, String? avatar) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.only(top: 60, bottom: 32, left: 24, right: 24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            backgroundImage: avatar != null ? NetworkImage(avatar) : null,
            child: avatar == null
                ? const Icon(Icons.person, size: 60, color: Color(0xFF0D47A1))
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'INSTRUCTOR ROLE',
              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary() {
    return BlocBuilder<InstructorDashboardBloc, InstructorDashboardState>(
      builder: (context, state) {
        int totalCourses = 0;
        int totalStudents = 0;

        if (state is InstructorDashboardLoaded) {
          final stats = state.dashboardData['stats'] ?? {};
          totalCourses = stats['total_courses'] ?? 0;
          totalStudents = stats['total_students'] ?? 0;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: _buildMiniStatCard('TOTAL KURSUS', '$totalCourses', Icons.menu_book, Colors.blue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMiniStatCard('TOTAL SISWA', '$totalStudents', Icons.people, Colors.orange),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.black45, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String bio) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Biografi Singkat',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              bio,
              style: const TextStyle(color: Colors.black54, height: 1.5),
            ),
            const Divider(height: 32),
            _buildInfoRow(Icons.security, 'Keamanan Akun', 'Ubah Kata Sandi'),
            _buildInfoRow(Icons.help_outline, 'Pusat Bantuan', 'Panduan & FAQ'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                Text(subtitle, style: const TextStyle(color: Colors.black45, fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton.icon(
          onPressed: () {
            context.read<AuthBloc>().add(AuthLogoutRequested());
          },
          icon: const Icon(Icons.logout, color: Colors.red),
          label: const Text(
            'KELUAR AKUN',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}
