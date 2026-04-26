import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hlms_mobile/core/models/enrollment.dart';
import 'package:hlms_mobile/features/course/data/course_repository.dart';
import 'package:hlms_mobile/features/classroom/data/classroom_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyLearningScreen extends StatefulWidget {
  const MyLearningScreen({super.key});

  @override
  State<MyLearningScreen> createState() => _MyLearningScreenState();
}

class _MyLearningScreenState extends State<MyLearningScreen> {
  List<Enrollment> _allLearning = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await context.read<CourseRepository>().getMyLearning();
      if (mounted) {
        setState(() {
          _allLearning = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final courses = _allLearning.where((e) => e.type == 'course').toList();
    final classes = _allLearning.where((e) => e.type != 'course').toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Belajar Saya', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          bottom: const TabBar(
            labelColor: Color(0xFF0D47A1),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF0D47A1),
            tabs: [
              Tab(text: 'Mandiri (Udemy)'),
              Tab(text: 'Kelas (Classroom)'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _SelfPacedTab(enrollments: courses),
            _CohortClassTab(enrollments: classes, onRefresh: _loadData),
          ],
        ),
      ),
    );
  }
}

class _SelfPacedTab extends StatelessWidget {
  final List<Enrollment> enrollments;
  const _SelfPacedTab({required this.enrollments});

  @override
  Widget build(BuildContext context) {
    if (enrollments.isEmpty) {
      return const Center(child: Text('Belum ada kursus mandiri.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: enrollments.length,
      itemBuilder: (context, index) {
        final enrollment = enrollments[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildSelfPacedCard(
            context,
            enrollment: enrollment,
          ),
        );
      },
    );
  }

  Widget _buildSelfPacedCard(BuildContext context, {required Enrollment enrollment}) {
    return InkWell(
      onTap: () {
        context.push('/course/${enrollment.slug}');
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(enrollment.thumbnail, width: 80, height: 80, fit: BoxFit.cover),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(enrollment.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(enrollment.instructor ?? "Instructor", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: enrollment.progress / 100,
                          backgroundColor: Colors.grey.shade200,
                          color: const Color(0xFF0D47A1),
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${enrollment.progress}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CohortClassTab extends StatelessWidget {
  final List<Enrollment> enrollments;
  final VoidCallback onRefresh;
  const _CohortClassTab({required this.enrollments, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () {
              _showJoinClassDialog(context);
            },
            icon: const Icon(Icons.add),
            label: const Text('Gabung dengan Kode Kelas'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.blue.shade50,
              foregroundColor: const Color(0xFF0D47A1),
              elevation: 0,
            ),
          ),
        ),
        if (enrollments.isEmpty)
          const Expanded(child: Center(child: Text('Belum ada kelas yang diikuti.'))),
        if (enrollments.isNotEmpty)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: enrollments.length,
              itemBuilder: (context, index) {
                final enrollment = enrollments[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildClassCard(
                    context,
                    enrollment: enrollment,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  void _showJoinClassDialog(BuildContext context) {
    final codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gabung Kelas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Masukkan kode kelas dari instruktur Anda.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                hintText: 'Contoh: X7Y9ZQ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              try {
                await context.read<ClassroomRepository>().joinClass(codeController.text);
                if (context.mounted) {
                  context.pop();
                  onRefresh();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil bergabung dengan kelas!')));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white),
            child: const Text('Gabung'),
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, {required Enrollment enrollment}) {
    return InkWell(
      onTap: () {
        context.push('/classroom/${enrollment.id}');
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0D47A1),
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(enrollment.thumbnail),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.darken),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                  child: const Text('Aktif', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const Icon(Icons.class_outlined, color: Colors.white70),
              ],
            ),
            const SizedBox(height: 32),
            Text(enrollment.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(enrollment.instructor ?? "Instructor", style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
