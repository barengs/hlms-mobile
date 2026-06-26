import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hlms_mobile/features/auth/logic/auth_bloc/auth_bloc.dart';
import 'package:hlms_mobile/features/instructor/logic/instructor_dashboard_bloc/instructor_dashboard_bloc.dart';
import 'package:hlms_mobile/features/instructor/logic/instructor_dashboard_bloc/instructor_dashboard_state.dart';

class InstructorHomeScreen extends StatelessWidget {
  final Function(int)? onTabChange;
  const InstructorHomeScreen({super.key, this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(
                'assets/app_icon.png',
                height: 32,
                width: 32,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Molang',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<InstructorDashboardBloc, InstructorDashboardState>(
        builder: (context, state) {
          if (state is InstructorDashboardLoading || state is InstructorDashboardInitial) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF0D47A1)));
          } else if (state is InstructorDashboardError) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<InstructorDashboardBloc>().add(InstructorDashboardRequested());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else if (state is InstructorDashboardLoaded) {
            final data = state.dashboardData;
            final stats = data['stats'] ?? {};
            final actions = data['actions'] ?? {};
            final topCourses = data['top_courses'] as List<dynamic>? ?? [];
            final activities = data['activities'] as List<dynamic>? ?? [];

            final authState = context.read<AuthBloc>().state;
            String instructorName = 'Instruktur';
            if (authState is AuthAuthenticated) {
              instructorName = authState.user['name'] ?? 'Instruktur';
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<InstructorDashboardBloc>().add(InstructorDashboardRequested());
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeSection(instructorName),
                    const SizedBox(height: 24),
                    _buildStatsGrid(context, stats),
                    const SizedBox(height: 24),
                    _buildActionItems(context, actions),
                    const SizedBox(height: 24),
                    _buildTopCourses(context, topCourses),
                    const SizedBox(height: 24),
                    _buildRecentActivities(context, activities),
                  ],
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildWelcomeSection(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selamat Datang, $name!',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
        ),
        const SizedBox(height: 4),
        const Text(
          'Berikut adalah ringkasan performa Anda.',
          style: TextStyle(color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, Map<String, dynamic> stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          title: 'Total Siswa',
          value: '${stats['total_students'] ?? 0}',
          icon: Icons.people,
          color: Colors.blue,
          onTap: () => context.push('/instructor/students'),
        ),
        _buildStatCard(
          title: 'Total Kursus',
          value: '${stats['total_courses'] ?? 0}',
          icon: Icons.school,
          color: Colors.orange,
          onTap: () => onTabChange?.call(1),
        ),
        _buildStatCard(
          title: 'Total Kelas',
          value: '${stats['total_batches'] ?? 0}',
          icon: Icons.class_,
          color: Colors.purple,
          onTap: () => onTabChange?.call(2),
        ),
        _buildStatCard(
          title: 'Pendapatan Bulan Ini',
          value: 'Rp ${_formatCurrency(stats['monthly_revenue'] ?? 0)}',
          icon: Icons.monetization_on,
          color: Colors.green,
          onTap: () => onTabChange?.call(3),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItems(BuildContext context, Map<String, dynamic> actions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tindakan Diperlukan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          icon: Icons.assignment_turned_in,
          title: '${actions['pending_grading'] ?? 0} Tugas Menunggu Penilaian',
          color: Colors.redAccent,
          onTap: () => context.push('/instructor/submissions'),
        ),
        const SizedBox(height: 8),
        _buildActionTile(
          icon: Icons.question_answer,
          title: '${actions['unanswered_questions'] ?? 0} Pertanyaan Belum Terjawab',
          color: Colors.orangeAccent,
          onTap: () => context.push('/instructor/discussions'),
        ),
      ],
    );
  }

  Widget _buildActionTile({required IconData icon, required String title, required Color color, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: color.withOpacity(0.8), fontWeight: FontWeight.w600),
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCourses(BuildContext context, List<dynamic> courses) {
    if (courses.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kursus Terpopuler',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                    image: course['thumbnail'] != null
                        ? DecorationImage(
                            image: NetworkImage(course['thumbnail']),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: course['thumbnail'] == null
                      ? const Icon(Icons.school, color: Colors.grey)
                      : null,
                ),
                title: Text(
                  course['title'] ?? 'Unknown Course',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text('${course['total_students'] ?? 0} Siswa'),
                trailing: Text(
                  course['trend'] ?? '',
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  final courseIdOrSlug = course['slug'] ?? course['id']?.toString() ?? '';
                  if (courseIdOrSlug.isNotEmpty) {
                    context.push('/course/$courseIdOrSlug?enrolled=true');
                  }
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentActivities(BuildContext context, List<dynamic> activities) {
    if (activities.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aktivitas Terbaru',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final act = activities[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE3F2FD),
                child: Icon(Icons.notifications, color: Color(0xFF0D47A1), size: 20),
              ),
              title: Text(
                act['message'] ?? 'Aktivitas baru',
                style: const TextStyle(fontSize: 14),
              ),
              subtitle: Text(
                _formatDate(act['created_at']),
                style: const TextStyle(fontSize: 12),
              ),
              onTap: () {
                final message = (act['message'] ?? '').toString().toLowerCase();
                if (message.contains('tugas') || message.contains('submission') || message.contains('nilai')) {
                  context.push('/instructor/submissions');
                } else if (message.contains('pertanyaan') || message.contains('diskusi') || message.contains('tanya') || message.contains('discussion')) {
                  context.push('/instructor/discussions');
                } else {
                  onTabChange?.call(1);
                }
              },
            );
          },
        ),
      ],
    );
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '0';
    return amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}

