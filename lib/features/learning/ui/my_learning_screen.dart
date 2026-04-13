import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyLearningScreen extends StatelessWidget {
  const MyLearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        body: const TabBarView(
          children: [
            _SelfPacedTab(),
            _CohortClassTab(),
          ],
        ),
      ),
    );
  }
}

class _SelfPacedTab extends StatelessWidget {
  const _SelfPacedTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSelfPacedCard(
          context,
          title: 'Dasar Pemrograman React',
          instructor: 'Budi Santoso',
          progress: 0.6,
          imageUrl: 'https://images.unsplash.com/photo-1555949963-aa79dcee981c?q=80&w=200&auto=format&fit=crop',
        ),
        const SizedBox(height: 16),
        _buildSelfPacedCard(
          context,
          title: 'Mastering Figma UI/UX',
          instructor: 'Siti Aminah',
          progress: 0.2,
          imageUrl: 'https://images.unsplash.com/photo-1561070791-2526d30994b5?q=80&w=200&auto=format&fit=crop',
        ),
      ],
    );
  }

  Widget _buildSelfPacedCard(BuildContext context, {required String title, required String instructor, required double progress, required String imageUrl}) {
    return InkWell(
      onTap: () {
        context.push('/course/1');
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
              child: Image.network(imageUrl, width: 80, height: 80, fit: BoxFit.cover),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(instructor, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey.shade200,
                          color: const Color(0xFF0D47A1),
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
  const _CohortClassTab();

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
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildClassCard(
                context,
                className: 'Batch 5: Fullstack Laravel Bootcamp',
                period: '12 Apr 2026 - 12 Jul 2026',
                status: 'Aktif',
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showJoinClassDialog(BuildContext context) {
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
            onPressed: () {
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil bergabung dengan kelas!')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white),
            child: const Text('Gabung'),
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, {required String className, required String period, required String status}) {
    return InkWell(
      onTap: () {
        // Navigasi ke tugas kelas struktural / Classroom Hub
        context.push('/assignments');
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0D47A1),
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: const NetworkImage('https://images.unsplash.com/photo-1524178232363-1fb2b075b655?q=80&w=600&auto=format&fit=crop'),
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
                  child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const Icon(Icons.class_outlined, color: Colors.white70),
              ],
            ),
            const SizedBox(height: 32),
            Text(className, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(period, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
