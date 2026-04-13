import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AssignmentListScreen extends StatelessWidget {
  const AssignmentListScreen({super.key});

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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAssignmentCard(
            context,
            title: 'Tugas Sesi 2: State Management',
            course: 'Fullstack Flutter & Laravel 11',
            deadline: 'Besok, 23:59',
            status: 'Belum Selesai',
            statusColor: Colors.orange,
            isCompleted: false,
          ),
          const SizedBox(height: 16),
          _buildAssignmentCard(
            context,
            title: 'Tugas Sesi 1: UI Slicing',
            course: 'Fullstack Flutter & Laravel 11',
            deadline: '10 Mei 2026',
            status: 'Selesai (Dinilai: 95)',
            statusColor: Colors.green,
            isCompleted: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard(BuildContext context, {
    required String title,
    required String course,
    required String deadline,
    required String status,
    required Color statusColor,
    required bool isCompleted,
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
                  context.push('/assignment/upload');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCompleted ? Colors.grey.shade200 : const Color(0xFF0D47A1),
                  foregroundColor: isCompleted ? Colors.black54 : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(isCompleted ? 'Lihat Detail' : 'Kumpulkan'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
