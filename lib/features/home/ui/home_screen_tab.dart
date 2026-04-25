import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreenTab extends StatelessWidget {
  const HomeScreenTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildSearchBar(),
          const SizedBox(height: 20),
          _buildCategoryChips(),
          const SizedBox(height: 32),
          _buildSectionHeader('Lanjutkan Belajar', onSeeAll: () {}),
          const SizedBox(height: 20),
          _buildContinueLearningList(),
          const SizedBox(height: 32),
          _buildSectionHeader('Kursus Populer', onSeeAll: () {}),
          const SizedBox(height: 20),
          _buildPopularCourses(context),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.blue.shade50,
          backgroundImage: const NetworkImage('https://cdn-icons-png.flaticon.com/512/3135/3135715.png'),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 22, color: Colors.black),
                  children: [
                    TextSpan(text: 'Selamat Datang, '),
                    TextSpan(
                      text: 'Fawais',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                'Siap belajar apa hari ini?',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        Icon(Icons.settings_outlined, color: Colors.grey.shade300, size: 30),
        const SizedBox(width: 12),
        Icon(Icons.notifications_outlined, color: Colors.grey.shade300, size: 30),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Cari materi...',
          hintStyle: TextStyle(color: Colors.grey, fontSize: 18),
          prefixIcon: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Icon(Icons.search, color: Colors.grey, size: 30),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categories = ['UI/UX', 'Graphics Design', 'Figma', 'Web Dev'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isFirst = cat == categories.first;
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: Chip(
              label: Text(
                cat,
                style: TextStyle(
                  color: isFirst ? Colors.black : Colors.black87,
                  fontSize: 16,
                ),
              ),
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
                side: BorderSide(color: Colors.grey.shade200),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {required VoidCallback onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: Text(
            'Lihat Semua',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueLearningList() {
    final courses = [
      {
        'title': 'Graphic Design',
        'instructor': 'Syed Hasnain',
        'progress': 0.45,
        'image': 'https://images.unsplash.com/photo-1558655146-d09347e92766?q=80&w=400&auto=format&fit=crop',
      },
      {
        'title': 'Wireframing',
        'instructor': 'Shoaib Hassan',
        'progress': 0.45,
        'image': 'https://images.unsplash.com/photo-1545235617-9465d2a55698?q=80&w=400&auto=format&fit=crop',
      },
      {
        'title': 'Website Design',
        'instructor': 'Dawar Hanif',
        'progress': 0.45,
        'image': 'https://images.unsplash.com/photo-1547658719-da2b51169166?q=80&w=400&auto=format&fit=crop',
      },
      {
        'title': 'Video Editing',
        'instructor': 'Ammar Ijaz',
        'progress': 0.45,
        'image': 'https://images.unsplash.com/photo-1574717024653-61fd2cf4d44d?q=80&w=400&auto=format&fit=crop',
      },
    ];

    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return GestureDetector(
            onTap: () => context.push('/course/1'),
            child: Container(
              width: 220,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        image: DecorationImage(
                          image: NetworkImage(course['image'] as String),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            course['title'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Oleh ${course['instructor']}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
                                ),
                              ),
                              const Row(
                                children: [
                                  Icon(Icons.star, color: Color(0xFF0D47A1), size: 10),
                                  Icon(Icons.star, color: Color(0xFF0D47A1), size: 10),
                                  Icon(Icons.star, color: Color(0xFF0D47A1), size: 10),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: course['progress'] as double,
                                  backgroundColor: Colors.grey.shade100,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0D47A1)),
                                  minHeight: 5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '${((course['progress'] as double) * 100).toInt()}% Selesai',
                                  style: TextStyle(color: Colors.grey.shade400, fontSize: 9),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPopularCourses(BuildContext context) {
    final popular = [
      {
        'title': 'Mastering Flutter UI',
        'instructor': 'Alex Smith',
        'price': 'Rp 250.000',
        'rating': '4.9',
        'students': '2.5k',
        'image': 'https://images.unsplash.com/photo-1551033406-611cf9a28f67?q=80&w=400&auto=format&fit=crop',
      },
      {
        'title': 'Laravel for Beginners',
        'instructor': 'Jane Doe',
        'price': 'Rp 150.000',
        'rating': '4.7',
        'students': '1.8k',
        'image': 'https://images.unsplash.com/photo-1599507591144-667d4f3ff3a2?q=80&w=400&auto=format&fit=crop',
      },
    ];

    return Column(
      children: popular.map((course) {
        return GestureDetector(
          onTap: () => context.push('/course/1'),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(course['image'] as String),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course['title'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Oleh ${course['instructor']}',
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            course['price'] as String,
                            style: const TextStyle(
                              color: Color(0xFF0D47A1),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.orange, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '${course['rating']} (${course['students']})',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
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
      }).toList(),
    );
  }
}
