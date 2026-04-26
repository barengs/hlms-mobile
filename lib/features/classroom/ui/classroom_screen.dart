import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3, // Dummy
      itemBuilder: (context, index) {
        return ExpansionTile(
          title: Text('Topik ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
          children: [
            ListTile(
              leading: const Icon(Icons.assignment, color: Colors.blue),
              title: const Text('Tugas Implementasi UI'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.description, color: Colors.green),
              title: const Text('Materi PDF: Dasar Flutter'),
              onTap: () {},
            ),
          ],
        );
      },
    );
  }

  Widget _buildPeopleTab() {
    return const Center(child: Text('Daftar Anggota Kelas'));
  }
}
