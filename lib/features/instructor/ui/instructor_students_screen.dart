import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hlms_mobile/features/instructor/data/instructor_repository.dart';

class InstructorStudentsScreen extends StatefulWidget {
  const InstructorStudentsScreen({super.key});

  @override
  State<InstructorStudentsScreen> createState() => _InstructorStudentsScreenState();
}

class _InstructorStudentsScreenState extends State<InstructorStudentsScreen> {
  late Future<List<dynamic>> _studentsFuture;
  List<dynamic> _allStudents = [];
  List<dynamic> _filteredStudents = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadStudents() {
    setState(() {
      _studentsFuture = context.read<InstructorRepository>().getStudents().then((value) {
        _allStudents = value;
        _filteredStudents = value;
        return value;
      });
    });
  }

  void _filterStudents(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredStudents = _allStudents;
      } else {
        _filteredStudents = _allStudents.where((student) {
          final name = (student['name'] ?? '').toString().toLowerCase();
          final email = (student['email'] ?? '').toString().toLowerCase();
          return name.contains(query.toLowerCase()) || email.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Daftar Siswa',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterStudents,
              decoration: InputDecoration(
                hintText: 'Cari siswa berdasarkan nama atau email...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _filterStudents('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _loadStudents();
              },
              child: FutureBuilder<List<dynamic>>(
                future: _studentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF0D47A1)));
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 60, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              snapshot.error.toString().replaceAll('Exception: ', ''),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16, color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadStudents,
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1)),
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (_allStudents.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 80, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          const Text(
                            'Belum ada siswa terdaftar',
                            style: TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    );
                  } else if (_filteredStudents.isEmpty) {
                    return const Center(
                      child: Text(
                        'Tidak ditemukan siswa yang cocok',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = _filteredStudents[index];
                      return _buildStudentCard(student);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    final avatar = student['avatar'] ?? '';
    final name = student['name'] ?? 'Siswa';
    final email = student['email'] ?? '';
    final totalProgress = student['totalProgress'] ?? 0;
    final totalCourses = student['totalCoursesEnrolled'] ?? 0;
    final enrolledCourses = student['enrolledCourses'] as List<dynamic>? ?? [];

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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
            child: avatar.isEmpty ? const Icon(Icons.person, color: Colors.grey) : null,
          ),
          title: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(email, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.book_outlined, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('$totalCourses Kursus', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  const SizedBox(width: 12),
                  const Icon(Icons.trending_up, size: 14, color: Colors.green),
                  const SizedBox(width: 4),
                  Text('$totalProgress% Progres', style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(height: 1),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kursus yang Diikuti:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  if (enrolledCourses.isEmpty)
                    const Text('Belum mengikuti kursus apa pun.', style: TextStyle(fontSize: 12, color: Colors.grey))
                  else
                    ...enrolledCourses.map((course) {
                      final title = course['courseTitle'] ?? 'Unknown Course';
                      final progress = course['progress'] ?? 0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '$progress%',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: progress / 100,
                              backgroundColor: Colors.grey.shade100,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                progress == 100 ? Colors.green : const Color(0xFF0D47A1),
                              ),
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
