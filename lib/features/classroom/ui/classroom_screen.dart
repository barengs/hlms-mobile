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
  List<dynamic> _streamData = [];
  Map<String, dynamic>? _peopleData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final repo = context.read<ClassroomRepository>();
      final results = await Future.wait([
        repo.getClassDetail(widget.classId),
        repo.getClassStream(widget.classId).catchError((_) => <dynamic>[]),
        repo.getClassPeople(widget.classId).catchError((_) => <String, dynamic>{}),
      ]);

      if (mounted) {
        setState(() {
          _classData = results[0] as Map<String, dynamic>?;
          _streamData = (results[1] as List<dynamic>?) ?? [];
          _peopleData = results[2] as Map<String, dynamic>?;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading classroom data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Ensure we don't leave _classData in an inconsistent state if it fails
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_classData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Gagal memuat data kelas'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() => _isLoading = true);
                  _loadData();
                },
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              stretch: true,
              backgroundColor: const Color(0xFF0D47A1),
              foregroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                title: innerBoxIsScrolled 
                  ? Text(_classData?['name'] ?? 'Kelas', style: const TextStyle(color: Colors.white, fontSize: 16))
                  : null,
                background: _buildHeaderBackground(),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFF0D47A1),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: const Color(0xFF0D47A1),
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: 'Forum'),
                      Tab(text: 'Tugas Kelas'),
                      Tab(text: 'Anggota'),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildStreamTab(),
            _buildClassworkTab(),
            _buildPeopleTab(),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () => _showCreateDiscussionBottomSheet(),
              backgroundColor: const Color(0xFF0D47A1),
              child: const Icon(Icons.add_comment, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildHeaderBackground() {
    final instructor = _classData?['instructor'];
    final description = _classData?['description'] ?? 'Belum ada deskripsi kelas.';
    
    return Stack(
      fit: StackFit.expand,
      children: [
        // Gradient Background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
            ),
          ),
        ),
        // Decorative Circles
        Positioned(
          top: -50,
          right: -50,
          child: CircleAvatar(
            radius: 100,
            backgroundColor: Colors.white.withValues(alpha: 0.05),
          ),
        ),
        // Content
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _classData?['name'] ?? 'Kelas',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.white24,
                      backgroundImage: instructor?['avatar'] != null ? NetworkImage(instructor['avatar']) : null,
                      child: instructor?['avatar'] == null ? const Icon(Icons.person, size: 14, color: Colors.white) : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      instructor?['name'] ?? 'Instruktur',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildHeaderStat(Icons.people_outline, '${_classData?['students_count'] ?? 0} Siswa'),
                    const SizedBox(width: 16),
                    _buildHeaderStat(Icons.topic_outlined, '${_classData?['topicsCount'] ?? 0} Topik'),
                    const SizedBox(width: 16),
                    _buildHeaderStat(Icons.play_lesson_outlined, '${_classData?['materialsCount'] ?? 0} Materi'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white60, size: 16),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ],
    );
  }

  Widget _buildStreamTab() {
    if (_streamData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Belum ada pengumuman.',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _streamData.length,
      itemBuilder: (context, index) {
        final item = _streamData[index];
        final author = item['user'];
        final date = item['created_at'];

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: InkWell(
            onTap: () => _showDiscussionBottomSheet(item),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFF0D47A1).withValues(alpha: 0.1),
                        backgroundImage: author?['avatar'] != null ? NetworkImage(author['avatar']) : null,
                        child: author?['avatar'] == null ? const Icon(Icons.person, size: 20, color: Color(0xFF0D47A1)) : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              author?['name'] ?? 'Instruktur',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              date != null ? date.toString().split('T')[0] : 'Baru saja',
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    item['content'] ?? '',
                    style: const TextStyle(height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildClassworkTab() {
    final List<dynamic> timeline = (_classData?['timeline'] as List<dynamic>?) ?? [];
    final List<dynamic> topics = (_classData?['classwork_topics'] as List<dynamic>?) ?? [];
    
    if (timeline.isEmpty && topics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_stories_outlined, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Belum ada alur belajar.',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      children: [
        // Section Header
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFF0D47A1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Alur Belajar',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Roadmap Content
        if (timeline.isNotEmpty)
          _buildTimelineView(timeline)
        else
          _buildTopicsTimelineView(topics),
      ],
    );
  }

  Widget _buildTimelineView(List<dynamic> timeline) {
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
                  child: _buildItemCard(item, item['type'], isActive, isCompleted),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopicsTimelineView(List<dynamic> topics) {
    return Column(
      children: topics.asMap().entries.map((entry) {
        final topic = entry.value as Map<String, dynamic>;
        final sessions = (topic['sessions'] as List<dynamic>?) ?? [];
        final assignments = (topic['assignments'] as List<dynamic>?) ?? [];
        final materials = [...sessions, ...assignments];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Materials List with Connectors
            ...materials.asMap().entries.map((mEntry) {
              final mIndex = mEntry.key;
              final item = mEntry.value;
              final isLast = mIndex == materials.length - 1;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Roadmap Connector Line
                    Padding(
                      padding: const EdgeInsets.only(left: 14),
                      child: Column(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(color: const Color(0xFF0D47A1), width: 2),
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: const Color(0xFF0D47A1).withValues(alpha: 0.2),
                              ),
                            )
                          else
                            const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Item Card
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: _buildItemCard(
                          item,
                          item['type'] ?? 'session',
                          true,
                          item['is_completed'] == true,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item, String type, bool isActive, bool isCompleted) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted 
              ? Colors.green.withValues(alpha: 0.2) 
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
                  color: _getColorForType(type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  type.toUpperCase(),
                  style: TextStyle(
                    color: _getColorForType(type),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (item['is_required'] == true || item['is_required'] == "1") ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
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
              const Spacer(),
              if (item['duration'] != null)
                Text(
                  '${item['duration']} min',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item['title'] ?? '',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isCompleted ? Colors.green.shade800 : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isActive)
                TextButton(
                  onPressed: () => _toggleComplete(item['id']),
                  style: TextButton.styleFrom(
                    foregroundColor: isCompleted ? Colors.green : const Color(0xFF0D47A1),
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
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
                )
              else
                const SizedBox.shrink(),
              ElevatedButton(
                onPressed: isActive ? () => _handleOpenItem(item, type) : null,
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
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'course': return Icons.book_outlined;
      case 'session': return Icons.video_call_outlined;
      case 'assignment': return Icons.assignment_outlined;
      case 'quiz':
      case 'quiz_v2': return Icons.quiz_outlined;
      default: return Icons.rocket_launch_outlined;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'course': return Colors.blue;
      case 'session': return Colors.red;
      case 'assignment': return Colors.purple;
      case 'quiz':
      case 'quiz_v2': return Colors.orange;
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

  Widget _buildPeopleTab() {
    final instructor = _classData?['instructor'];
    final students = (_peopleData?['students'] as List<dynamic>?) ?? (_classData?['students'] as List<dynamic>?) ?? [];

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Instruktur',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
        ),
        const SizedBox(height: 16),
        _buildPersonTile(instructor?['name'] ?? 'Instruktur', instructor?['avatar']),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Teman Sekelas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
            ),
            Text(
              '${students.length} Siswa',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (students.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text('Belum ada siswa yang bergabung.', style: TextStyle(color: Colors.grey.shade400)),
            ),
          )
        else
          ...students.map((s) => _buildPersonTile(s['name'] ?? 'Siswa', s['avatar'])),
      ],
    );
  }

  Widget _buildPersonTile(String name, String? avatar) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF0D47A1).withValues(alpha: 0.1),
            backgroundImage: avatar != null ? NetworkImage(avatar) : null,
            child: avatar == null ? const Icon(Icons.person, color: Color(0xFF0D47A1)) : null,
          ),
          const SizedBox(width: 16),
          Text(
            name,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _handleOpenItem(Map<String, dynamic> item, String type) {
    final refId = item['reference_id'] ?? item['id'];
    final slug = item['slug'];

    if (type == 'course' && slug != null) {
      context.push('/course/$slug');
    } else if (type == 'assignment') {
      context.push('/assignment/upload/$refId');
    } else if (type == 'quiz' || type == 'quiz_v2') {
      context.push('/quiz/$refId');
    } else if (type == 'session' || type == 'material') {
      _showSessionDetails(item);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aktivitas ini dapat dibuka di web.')),
      );
    }
  }

  void _showSessionDetails(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconForType(item['type'] ?? 'material'),
                    color: const Color(0xFF0D47A1),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (item['type'] ?? 'Materi').toString().toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        item['title'] ?? 'Detail Materi',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Deskripsi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Text(
              item['description'] ?? 'Tidak ada deskripsi untuk materi ini.',
              style: TextStyle(color: Colors.grey[700], height: 1.5),
            ),
            const SizedBox(height: 32),
            if (item['meetingUrl'] != null || item['recordingUrl'] != null || item['content_url'] != null)
              ElevatedButton(
                onPressed: () {
                  // In real app, use url_launcher
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Membuka tautan...')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Buka Tautan Materi'),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: const Text(
                  'Belum ada tautan atau file yang dilampirkan untuk materi ini.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showCreateDiscussionBottomSheet() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          top: 24,
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Buat Diskusi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 24),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'Judul Diskusi',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: contentController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: 'Isi diskusi...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  final title = titleController.text.trim();
                  final content = contentController.text.trim();
                  if (title.isEmpty || content.isEmpty) return;

                  try {
                    await context.read<ClassroomRepository>().createDiscussion(
                          widget.classId,
                          title,
                          content,
                          'discussion',
                        );
                    if (mounted) {
                      Navigator.pop(context);
                      _loadData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Diskusi berhasil dibuat!')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal: ${e.toString().replaceAll('Exception: ', '')}')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Kirim', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDiscussionBottomSheet(Map<String, dynamic> disc) {
    final parentId = disc['id'] as int;
    final title = disc['title'] ?? 'Diskusi';
    final content = disc['content'] ?? '';
    final studentName = disc['user']?['name'] ?? 'Siswa';
    final replies = List<dynamic>.from(disc['replies'] ?? []);
    final replyController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
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
                              title,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text('Dari: $studentName', style: const TextStyle(color: Colors.black54, fontSize: 14)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      content,
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Balasan:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: replies.isEmpty
                        ? const Center(
                            child: Text('Belum ada balasan.',
                                style: TextStyle(color: Colors.grey, fontSize: 13)),
                          )
                        : ListView.builder(
                            itemCount: replies.length,
                            itemBuilder: (context, index) {
                              final reply = replies[index];
                              final rUser = reply['user']?['name'] ?? 'Pengguna';
                              final rContent = reply['content'] ?? '';
                              final rAvatar = reply['user']?['avatar'] ?? '';
                              final rCreatedAtStr = reply['created_at'] ?? '';

                              String rDate = '';
                              if (rCreatedAtStr.isNotEmpty) {
                                try {
                                  final date = DateTime.parse(rCreatedAtStr);
                                  rDate = '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                                } catch (e) {
                                  rDate = rCreatedAtStr;
                                }
                              }

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.grey.shade200,
                                      backgroundImage: rAvatar.isNotEmpty ? NetworkImage(rAvatar) : null,
                                      child: rAvatar.isEmpty ? const Icon(Icons.person, size: 14, color: Colors.grey) : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                rUser,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                              ),
                                              Text(
                                                rDate,
                                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            rContent,
                                            style: const TextStyle(fontSize: 13, color: Colors.black87),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: replyController,
                          decoration: InputDecoration(
                            hintText: 'Tulis balasan Anda...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send, color: Color(0xFF0D47A1)),
                        onPressed: () async {
                          final text = replyController.text.trim();
                          if (text.isEmpty) return;

                          try {
                            await context.read<ClassroomRepository>().replyToDiscussion(
                                  parentId,
                                  text,
                                );

                            setModalState(() {
                              replies.add({
                                'content': text,
                                'created_at': DateTime.now().toIso8601String(),
                                'user': {
                                  'name': 'Anda',
                                  'avatar': '',
                                }
                              });
                              replyController.clear();
                            });
                            _loadData();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Balasan berhasil dikirim!')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Gagal: ${e.toString().replaceAll('Exception: ', '')}')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
