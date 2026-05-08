import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hlms_mobile/core/models/course.dart';
import 'package:hlms_mobile/features/course/data/course_repository.dart';
import 'package:hlms_mobile/features/course/logic/course_detail_bloc/course_detail_bloc.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;
  final bool isEnrolled;

  const CourseDetailScreen({super.key, required this.courseId, this.isEnrolled = false});

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
    return BlocProvider(
      create: (context) => CourseDetailBloc(context.read<CourseRepository>())
        ..add(CourseDetailRequested(widget.courseId)),
      child: BlocBuilder<CourseDetailBloc, CourseDetailState>(
        builder: (context, state) {
          if (state is CourseDetailLoading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          if (state is CourseDetailError) {
            return Scaffold(body: Center(child: Text(state.message)));
          }

          if (state is CourseDetailLoaded) {
            final course = state.course;
            final isEnrolled = course.isEnrolled || widget.isEnrolled;
            return Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                child: Column(
                  children: [
                    // Top Video/Header Section
                    _buildVideoHeader(context, course),
                    
                    // Tab Bar
                    _buildTabBar(),
                    
                    // Tab Content
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildOverviewTab(course, isEnrolled),
                          _buildLessonsTab(course),
                          _buildReviewsTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: _buildBottomEnrollButton(course, isEnrolled),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildVideoHeader(BuildContext context, Course course) {
    return Stack(
      children: [
        SizedBox(
          height: 250,
          width: double.infinity,
          child: Stack(
            children: [
              Image.network(
                course.thumbnail,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade100,
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow, size: 40, color: Color(0xFF003399)),
                ),
              ),
            ],
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

  Widget _buildOverviewTab(Course course, bool isEnrolled) {
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
                    Text(
                      course.title,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Oleh ${course.instructorName ?? "Instructor"}',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          Icons.star,
                          color: index < (course.rating ?? 0).floor() ? const Color(0xFF003399) : Colors.grey.shade300,
                          size: 18,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              if (!isEnrolled)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      course.price != null ? 'Rp ${course.price?.toInt()}' : 'Free',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 24),
          RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.5),
              children: [
                TextSpan(text: course.description ?? 'Belum ada deskripsi untuk kursus ini.'),
                if (course.description != null && course.description!.length > 200)
                  const TextSpan(
                    text: '... Baca Selengkapnya',
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

  Widget _buildLessonsTab(Course course) {
    // Note: Course model needs to have sections/lessons if they are in the response
    // For now, I'll assume they are in course.sections
    final sections = (course as dynamic).sections as List? ?? [];
    
    if (sections.isEmpty) {
      return const Center(child: Text('Belum ada materi tersedia.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final section = sections[index];
        final lessons = section['lessons'] as List? ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChapterHeader(section['title'] ?? 'Section ${index + 1}'),
            ...lessons.map((lesson) {
              final isCompleted = lesson['is_completed'] == true;
              final lessonAssignments = lesson['assignments'] as List? ?? [];
              return Column(
                children: [
                  _buildLessonItem(
                    lesson['type'] == 'quiz_v2' 
                        ? Icons.quiz 
                        : (isCompleted ? Icons.check_circle : Icons.play_circle_filled), 
                    lesson['title'] ?? 'Lesson',
                    color: lesson['type'] == 'quiz_v2' 
                        ? Colors.orange 
                        : (isCompleted ? Colors.green : const Color(0xFF003399)),
                    onTap: () {
                      if (lesson['type'] == 'quiz_v2') {
                        context.push('/quiz-v2/${lesson['id']}');
                      } else {
                        context.push('/lesson/${course.slug}/${lesson['id']}');
                      }
                    },
                  ),
                  ...lessonAssignments.map((assignment) {
                    final isQuiz = assignment['type'] == 'quiz';
                    return _buildLessonItem(
                      isQuiz ? Icons.quiz : Icons.assignment,
                      isQuiz ? 'Kuis: ${assignment['title']}' : 'Tugas: ${assignment['title']}',
                      color: isQuiz ? Colors.orange : Colors.green,
                      onTap: () {
                        context.push(isQuiz ? '/quiz/${assignment['id']}' : '/assignment/upload/${assignment['id']}');
                      },
                    );
                  }),
                ],
              );
            }),
            const SizedBox(height: 16),
          ],
        );
      },
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

  Widget _buildLessonItem(IconData icon, String title, {VoidCallback? onTap, Color? color}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color ?? const Color(0xFF003399), size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          ],
        ),
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

  Widget _buildBottomEnrollButton(Course course, bool isEnrolled) {
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
            onPressed: () {
              if (isEnrolled) {
                // Find first uncompleted lesson to continue
                final sections = (course as dynamic).sections as List? ?? [];
                Map<String, dynamic>? targetLesson;
                
                for (var section in sections) {
                  final lessons = section['lessons'] as List? ?? [];
                  for (var lesson in lessons) {
                    if (lesson['is_completed'] == false) {
                      targetLesson = lesson;
                      break;
                    }
                    
                    final assignments = lesson['assignments'] as List? ?? [];
                    for (var assignment in assignments) {
                      if (assignment['is_completed'] == false) {
                        targetLesson = assignment;
                        break;
                      }
                    }
                    if (targetLesson != null) break;
                  }
                  if (targetLesson != null) break;
                }
                
                // Fallback to first lesson if none found
                if (targetLesson == null && sections.isNotEmpty) {
                  final lessons = sections[0]['lessons'] as List? ?? [];
                  if (lessons.isNotEmpty) targetLesson = lessons[0];
                }

                if (targetLesson != null) {
                  final isQuiz = targetLesson['type'] == 'quiz';
                  final isAssignment = targetLesson['type'] == 'assignment';
                  
                  if (isQuiz) {
                    if (targetLesson['type'] == 'quiz_v2') {
                      context.push('/quiz-v2/${targetLesson['id']}');
                    } else {
                      context.push('/quiz/${targetLesson['id']}');
                    }
                  } else if (isAssignment) {
                    context.push('/assignment/upload/${targetLesson['id']}');
                  } else {
                    context.push('/lesson/${course.slug}/${targetLesson['id']}');
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Belum ada materi tersedia untuk kursus ini.'))
                  );
                }
              } else {
                context.push('/course/enroll/${course.slug}');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF003399),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(
              isEnrolled ? 'LANJUTKAN BELAJAR' : 'AMBIL KURSUS',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
