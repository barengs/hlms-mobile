import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hlms_mobile/features/course/data/course_repository.dart';
import 'package:intl/intl.dart';

class AssignmentListScreen extends StatefulWidget {
  const AssignmentListScreen({super.key});

  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> {
  List<Map<String, dynamic>> _assignments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    try {
      final data = await context.read<CourseRepository>().getAssignments();
      setState(() {
        _assignments = data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Tugas Saya', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _assignments.isEmpty
              ? const Center(child: Text('Tidak ada tugas saat ini.'))
              : RefreshIndicator(
                  onRefresh: _loadAssignments,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _assignments.length,
                    itemBuilder: (context, index) {
                      final assignment = _assignments[index];
                      final submission = assignment['my_submission'];
                      final status = submission != null ? submission['status'] : 'pending';
                      final isCompleted = status == 'graded' || status == 'reviewed' || status == 'submitted';
                      
                      Color statusColor = Colors.orange;
                      String statusText = 'Belum Selesai';
                      
                      if (status == 'graded' || status == 'reviewed') {
                        statusColor = Colors.green;
                        statusText = 'Selesai (Nilai: ${submission['points_awarded']})';
                      } else if (status == 'submitted') {
                        statusColor = Colors.blue;
                        statusText = 'Sudah Dikumpulkan';
                      }

                      DateTime? dueDate;
                      if (assignment['due_date'] != null) {
                        dueDate = DateTime.parse(assignment['due_date']);
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildAssignmentCard(
                          context,
                          id: assignment['id'],
                          title: assignment['title'],
                          course: assignment['batch']?['courses'] != null && (assignment['batch']['courses'] as List).isNotEmpty 
                              ? assignment['batch']['courses'][0]['title'] 
                              : 'General',
                          deadline: dueDate != null ? DateFormat('dd MMM yyyy, HH:mm').format(dueDate) : 'No Deadline',
                          status: statusText,
                          statusColor: statusColor,
                          isCompleted: isCompleted,
                          type: assignment['type'] ?? 'assignment',
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildAssignmentCard(BuildContext context, {
    required int id,
    required String title,
    required String course,
    required String deadline,
    required String status,
    required Color statusColor,
    required bool isCompleted,
    required String type,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            course,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                'Tenggat: $deadline',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  if (type == 'quiz') {
                    context.push('/quiz/$id');
                  } else {
                    context.push('/assignment/upload/$id');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCompleted ? Colors.grey.shade200 : const Color(0xFF0D47A1),
                  foregroundColor: isCompleted ? Colors.black54 : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(isCompleted ? 'Lihat Detail' : 'Kerjakan'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
