import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CourseDetailScreen extends StatelessWidget {
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCourseHeader(),
                  const SizedBox(height: 24),
                  _buildInstructorInfo(),
                  const SizedBox(height: 24),
                  _buildTabs(context),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220.0,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF0D47A1),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?q=80&w=600&auto=format&fit=crop',
              fit: BoxFit.cover,
            ),
            Container(
              color: Colors.black.withOpacity(0.4),
            ),
            Center(
              child: IconButton(
                icon: const Icon(Icons.play_circle_fill, size: 64, color: Colors.white),
                onPressed: () {
                  context.push('/video-player');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('Bestseller', style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            const Text('Programming', style: TextStyle(color: Color(0xFF0D47A1), fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Fullstack Flutter & Laravel 11 untuk Pemula',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.2),
        ),
        const SizedBox(height: 8),
        const Text(
          'Belajar membuat aplikasi mobile dan backend web secara komprehensif. Mulai dari nol hingga deploy ke VPS.',
          style: TextStyle(color: Colors.grey, height: 1.5),
        ),
        const SizedBox(height: 16),
        Row(
          children: const [
            Icon(Icons.star, color: Colors.orange, size: 20),
            SizedBox(width: 4),
            Text('4.8', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(' (1,234 Ulasan)', style: TextStyle(color: Colors.grey)),
            Spacer(),
            Icon(Icons.people_alt_outlined, color: Colors.grey, size: 16),
            SizedBox(width: 4),
            Text('10k+ Siswa', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildInstructorInfo() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage('https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=200&auto=format&fit=crop'),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Budi Santoso', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('Senior Software Engineer', style: TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabs(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TabBar(
            labelColor: Color(0xFF0D47A1),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF0D47A1),
            tabs: [
              Tab(text: 'Kurikulum'),
              Tab(text: 'Tentang'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 400, // Fixed height for demo
            child: TabBarView(
              children: [
                _buildCurriculum(),
                _buildAboutSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurriculum() {
    final modules = [
      {'title': 'Sesi 1: Pengenalan Flutter', 'lessons': 4, 'time': '1 jam'},
      {'title': 'Sesi 2: Dasar Dart', 'lessons': 6, 'time': '2 jam'},
      {'title': 'Sesi 3: UI/UX di Flutter', 'lessons': 5, 'time': '1.5 jam'},
    ];

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final mod = modules[index];
        return ExpansionTile(
          title: Text(mod['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${mod['lessons']} pelajaran • ${mod['time']}'),
          children: [
            ListTile(
              leading: const Icon(Icons.play_circle_outline, color: Color(0xFF0D47A1)),
              title: const Text('Instalasi SDK'),
              trailing: const Text('10:00'),
              onTap: () {
                context.push('/video-player');
              },
            ),
            const ListTile(
              leading: Icon(Icons.text_snippet_outlined, color: Colors.orange),
              title: Text('Setup Editor (VSCode)'),
              trailing: Text('Bacaan'),
            ),
            ListTile(
              leading: const Icon(Icons.help_outline, color: Colors.purple),
              title: const Text('Kuis Sesi 1'),
              trailing: const Text('Kuis'),
              onTap: () {
                context.push('/quiz');
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildAboutSection() {
    return const Text(
      'Kursus ini dirancang khusus untuk pemula yang ingin terjun ke dunia software engineering menggunakan teknologi modern yaitu Flutter dan Laravel. Anda akan dibimbing tahap demi tahap dengan project nyata (Real-world project).',
      style: TextStyle(height: 1.5, color: Colors.black87),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Harga Kelas', style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text('Rp 450.000', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF0D47A1))),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Checkout logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Beli Kursus', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
