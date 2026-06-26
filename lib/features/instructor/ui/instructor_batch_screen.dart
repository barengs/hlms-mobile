import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hlms_mobile/features/instructor/data/instructor_repository.dart';

class InstructorBatchScreen extends StatefulWidget {
  const InstructorBatchScreen({super.key});

  @override
  State<InstructorBatchScreen> createState() => _InstructorBatchScreenState();
}

class _InstructorBatchScreenState extends State<InstructorBatchScreen> {
  late Future<List<dynamic>> _batchesFuture;

  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  void _loadBatches() {
    setState(() {
      _batchesFuture = context.read<InstructorRepository>().getBatches();
    });
  }

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
              child: Image.asset('assets/app_icon.png', height: 32, width: 32),
            ),
            const SizedBox(width: 10),
            const Text(
              'Kelas Saya',
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
            icon: const Icon(Icons.add, color: Color(0xFF0D47A1), size: 28),
            onPressed: () {
              // Add Batch placeholder
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadBatches();
        },
        child: FutureBuilder<List<dynamic>>(
          future: _batchesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF0D47A1)),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        snapshot.error.toString().replaceAll('Exception: ', ''),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadBatches,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D47A1),
                        ),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.class_, size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    const Text(
                      'Belum ada kelas yang dibuat',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D47A1),
                      ),
                      child: const Text('Buat Kelas Pertama'),
                    ),
                  ],
                ),
              );
            }

            final batches = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: batches.length,
              itemBuilder: (context, index) {
                final batch = batches[index];
                return _buildBatchCard(batch);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildBatchCard(Map<String, dynamic> batch) {
    final status = batch['status'] ?? 'draft';
    final studentsCount = batch['students_count'] ?? 0;

    // We can show the first course's thumbnail if batch has no thumbnail (or if batch thumbnail is not available)
    final courses = batch['courses'] as List<dynamic>? ?? [];
    String? thumbnail;
    if (batch['thumbnail'] != null) {
      thumbnail = batch['thumbnail'];
    } else if (courses.isNotEmpty && courses.first['thumbnail'] != null) {
      thumbnail = courses.first['thumbnail'];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: thumbnail != null
                      ? Image.network(
                          thumbnail,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.class_,
                                size: 60,
                                color: Colors.grey,
                              ),
                        )
                      : const Icon(Icons.class_, size: 60, color: Colors.grey),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: _buildStatusBadge(status),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    batch['name'] ?? 'Tanpa Nama',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.people, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '$studentsCount Siswa',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.book, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${courses.length} Kursus',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          final batchId = batch['id']?.toString() ?? '';
                          if (batchId.isNotEmpty) {
                            context.push('/classroom/$batchId');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D47A1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.settings, size: 16, color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              'Lihat',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'open':
      case 'in_progress':
      case 'active':
        color = Colors.green;
        label = status.toUpperCase();
        break;
      case 'completed':
        color = Colors.blue;
        label = 'COMPLETED';
        break;
      case 'draft':
      default:
        color = Colors.grey.shade600;
        label = 'DRAFT';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
