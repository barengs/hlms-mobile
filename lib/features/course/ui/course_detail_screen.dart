import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Video/Header Section
            _buildVideoHeader(context),
            
            // Tab Bar
            _buildTabBar(),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildLessonsTab(),
                  _buildReviewsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomEnrollButton(),
    );
  }

  Widget _buildVideoHeader(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 250,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage('https://images.unsplash.com/photo-1558655146-d09347e92766?q=80&w=600&auto=format&fit=crop'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow, size: 40, color: Color(0xFF003399)),
            ),
          ),
        ),
        // Back Button
        Positioned(
          top: 16,
          left: 16,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
        ),
        // Bookmark Button
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bookmark_border, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.black87,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: const BoxDecoration(
          color: Color(0xFF003399),
        ),
        tabs: const [
          Tab(text: 'Ringkasan'),
          Tab(text: 'Materi'),
          Tab(text: 'Ulasan'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Graphic Design',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Oleh Syed Hasnain',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.star, color: Color(0xFF003399), size: 18),
                        Icon(Icons.star, color: Color(0xFF003399), size: 18),
                        Icon(Icons.star, color: Color(0xFF003399), size: 18),
                        Icon(Icons.star, color: Color(0xFF003399), size: 18),
                        Icon(Icons.star, color: Color(0xFF003399), size: 18),
                      ],
                    ),
                  ],
                ),
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '72\$',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  Text(
                    'Lorem Ipsum Text',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14, height: 1.5),
              children: const [
                TextSpan(text: 'Lorem ipsum dolor sit amet consectetur. Nec eget accumsan molestie proin. Integer rhoncus vitae nisi natoque ac mus tellus scelerisque gravida. Consectetur aliquet sit at diam. Augue eu mauris suspendisse adipiscing nibh. Nibh lorem id eu suspendisse nulla leo hendrerit. Erat tortor commodo quam fames et molestie. '),
                TextSpan(
                  text: 'Baca Selengkapnya',
                  style: TextStyle(color: Color(0xFF003399), fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Info Grid
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 3,
              children: [
                _buildInfoItem(Icons.book, '80+ Materi'),
                _buildInfoItem(Icons.workspace_premium, 'Sertifikat'),
                _buildInfoItem(Icons.access_time_filled, '8 Minggu'),
                _buildInfoItem(Icons.local_offer, 'Diskon 10%'),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text('Keahlian', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildSkillTag('Adobe'),
              _buildSkillTag('Adobe Photo Shop'),
              _buildSkillTag('Logo'),
              _buildSkillTag('Designing'),
              _buildSkillTag('Poster Design'),
              _buildSkillTag('Figma'),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF003399), size: 24),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      ],
    );
  }

  Widget _buildSkillTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(label, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildLessonsTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildChapterHeader('Bab 1 : Apa itu Graphics Designing?'),
        _buildLessonItem(Icons.play_circle_filled, 'Lorem ipsum dolor sit amet consectetur.'),
        _buildLessonItem(Icons.list_alt, 'Lorem ipsum dolor sit amet consectetur.'),
        _buildLessonItem(Icons.play_circle_filled, 'Lorem ipsum dolor sit amet consectetur.'),
        _buildLessonItem(Icons.list_alt, 'Lorem ipsum dolor sit amet consectetur.'),
        const SizedBox(height: 16),
        _buildChapterHeader('Bab 2 : Apa itu Logo Designing?', isExpanded: false),
        _buildChapterHeader('Bab 3 : Apa itu Poster Designing?', isExpanded: false),
        _buildChapterHeader('Bab 4 : Apa itu Picture Editing?', isExpanded: false),
      ],
    );
  }

  Widget _buildChapterHeader(String title, {bool isExpanded = true}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
          if (!isExpanded) const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildLessonItem(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF003399), size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey.shade200,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Muhammad Arsalan', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Siswa', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Row(
                    children: [
                      Icon(Icons.star, color: Color(0xFF003399), size: 14),
                      Icon(Icons.star, color: Color(0xFF003399), size: 14),
                      Icon(Icons.star, color: Color(0xFF003399), size: 14),
                      Icon(Icons.star, color: Color(0xFF003399), size: 14),
                      Icon(Icons.star, color: Color(0xFF003399), size: 14),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Lorem ipsum dolor sit amet consectetur. Euismod turpis tortor sollicitudin et. Quam tempor tincidunt a nunc feugiat semper tristique id.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomEnrollButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => context.push('/course/enroll/${widget.courseId}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF003399),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              'DAFTAR SEKARANG',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
