import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hlms_mobile/features/classroom/data/classroom_repository.dart';

class ClassroomScreen extends StatefulWidget {
  final int classId;
  const ClassroomScreen({super.key, required this.classId});

  @override
  State<ClassroomScreen> createState() => _ClassroomScreenState();
}

class _ClassroomScreenState extends State<ClassroomScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _classData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await context.read<ClassroomRepository>().getClassDetail(widget.classId);
      setState(() {
        _classData = data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_classData?['name'] ?? 'Kelas'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Forum'),
            Tab(text: 'Tugas Kelas'),
            Tab(text: 'Anggota'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStreamTab(),
          _buildClassworkTab(),
          _buildPeopleTab(),
        ],
      ),
    );
  }

  Widget _buildStreamTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5, // Dummy items for now, connect to getClassStream
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.announcement)),
            title: const Text('Pengumuman Baru'),
            subtitle: Text('Silakan cek materi terbaru untuk bab $index'),
          ),
        );
      },
    );
  }

  Widget _buildClassworkTab() {
    final List<dynamic> timeline = _classData?['timeline'] ?? [];
    
    if (timeline.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Belum ada alur belajar.',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: timeline.length,
      itemBuilder: (context, index) {
        final item = timeline[index];
        final isCompleted = item['is_completed'] == true || item['is_completed'] == 1;
        final isActive = index == 0 || (timeline[index - 1]['is_completed'] == true || timeline[index - 1]['is_completed'] == 1);
        
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline line and circle
              Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCompleted 
                          ? Colors.green 
                          : isActive 
                            ? const Color(0xFF0D47A1) 
                            : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted 
                            ? Colors.green 
                            : isActive 
                              ? const Color(0xFF0D47A1) 
                              : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      isCompleted 
                          ? Icons.check 
                          : _getIconForType(item['type']),
                      size: 16,
                      color: (isCompleted || isActive) ? Colors.white : Colors.grey.shade400,
                    ),
                  ),
                  if (index != timeline.length - 1)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: isCompleted ? Colors.green : Colors.grey.shade200,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 20),
              // Content Card
              Expanded(
                child: Opacity(
                  opacity: isActive ? 1.0 : 0.5,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.green.withOpacity(0.05) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isCompleted 
                            ? Colors.green.withOpacity(0.2) 
                            : Colors.grey.shade100,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getColorForType(item['type']).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item['type'].toString().toUpperCase(),
                                style: TextStyle(
                                  color: _getColorForType(item['type']),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (item['is_required'] == true) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'WAJIB',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item['title'] ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isCompleted ? Colors.green.shade800 : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: isActive ? () => _toggleComplete(item['id']) : null,
                              style: TextButton.styleFrom(
                                foregroundColor: isCompleted ? Colors.green : const Color(0xFF0D47A1),
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Row(
                                children: [
                                  Icon(isCompleted ? Icons.check_circle : Icons.circle_outlined, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    isCompleted ? 'Selesai' : 'Tandai Selesai',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: isActive ? () => _handleOpenItem(item) : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0D47A1),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                minimumSize: const Size(0, 0),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Buka', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'course': return Icons.book_outlined;
      case 'session': return Icons.video_call_outlined;
      case 'assignment': return Icons.assignment_outlined;
      default: return Icons.rocket_launch_outlined;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'course': return Colors.blue;
      case 'session': return Colors.red;
      case 'assignment': return Colors.purple;
      default: return Colors.grey;
    }
  }

  Future<void> _toggleComplete(int id) async {
    try {
      await context.read<ClassroomRepository>().toggleActivityComplete(id);
      _loadData(); // Refresh data
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  void _handleOpenItem(Map<String, dynamic> item) {
    final type = item['type'];
    final refId = item['reference_id'];
    final slug = item['slug'];

    if (type == 'course' && slug != null) {
      context.push('/course/$slug');
    } else if (type == 'assignment') {
      context.push('/classroom/assignments/$refId');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aktivitas ini dapat dibuka di web.')),
      );
    }
  }

  Widget _buildPeopleTab() {
    return const Center(child: Text('Daftar Anggota Kelas'));
  }
}
