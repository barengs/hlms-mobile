import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hlms_mobile/features/instructor/data/instructor_repository.dart';

class InstructorSubmissionsScreen extends StatefulWidget {
  const InstructorSubmissionsScreen({super.key});

  @override
  State<InstructorSubmissionsScreen> createState() => _InstructorSubmissionsScreenState();
}

class _InstructorSubmissionsScreenState extends State<InstructorSubmissionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<dynamic>> _pendingSubmissionsFuture;
  late Future<List<dynamic>> _gradedSubmissionsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSubmissions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadSubmissions() {
    setState(() {
      _pendingSubmissionsFuture = context.read<InstructorRepository>().getSubmissions(status: 'pending');
      _gradedSubmissionsFuture = context.read<InstructorRepository>().getSubmissions(status: 'graded');
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
          'Pengumpulan Tugas',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF0D47A1),
          unselectedLabelColor: Colors.black54,
          indicatorColor: const Color(0xFF0D47A1),
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Belum Dinilai'),
            Tab(text: 'Sudah Dinilai'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSubmissionList(_pendingSubmissionsFuture, true),
          _buildSubmissionList(_gradedSubmissionsFuture, false),
        ],
      ),
    );
  }

  Widget _buildSubmissionList(Future<List<dynamic>> future, bool isPendingTab) {
    return RefreshIndicator(
      onRefresh: () async {
        _loadSubmissions();
      },
      child: FutureBuilder<List<dynamic>>(
        future: future,
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
                      onPressed: _loadSubmissions,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1)),
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
                  Icon(Icons.assignment_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    isPendingTab ? 'Semua tugas sudah dinilai!' : 'Belum ada tugas yang dinilai',
                    style: const TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }

          final submissions = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: submissions.length,
            itemBuilder: (context, index) {
              final sub = submissions[index];
              return _buildSubmissionCard(sub, isPendingTab);
            },
          );
        },
      ),
    );
  }

  Widget _buildSubmissionCard(Map<String, dynamic> sub, bool isPendingTab) {
    final assignmentTitle = sub['assignment']?['title'] ?? 'Tugas';
    final studentName = sub['student']?['name'] ?? sub['user']?['name'] ?? 'Siswa';
    final studentAvatar = sub['student']?['avatar'] ?? sub['user']?['profile']?['avatar'] ?? '';
    final submittedAtStr = sub['submitted_at'] ?? sub['created_at'] ?? '';
    final status = sub['status'] ?? 'submitted';

    String submittedAt = '';
    if (submittedAtStr.isNotEmpty) {
      try {
        final date = DateTime.parse(submittedAtStr);
        submittedAt = '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } catch (e) {
        submittedAt = submittedAtStr;
      }
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey.shade100,
          backgroundImage: studentAvatar.isNotEmpty ? NetworkImage(studentAvatar) : null,
          child: studentAvatar.isEmpty ? const Icon(Icons.person, color: Colors.grey) : null,
        ),
        title: Text(
          assignmentTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Oleh: $studentName', style: const TextStyle(fontSize: 13, color: Colors.black54)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(submittedAt, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isPendingTab)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Text(
                  'Nilai: ${sub['points_awarded'] ?? 0}',
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
            const SizedBox(height: 4),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
        onTap: () => _showGradingBottomSheet(sub, isPendingTab),
      ),
    );
  }

  void _showGradingBottomSheet(Map<String, dynamic> sub, bool isPendingTab) {
    final submissionId = sub['id'] is String ? int.parse(sub['id']) : sub['id'] as int;
    final assignmentTitle = sub['assignment']?['title'] ?? 'Tugas';
    final studentName = sub['student']?['name'] ?? sub['user']?['name'] ?? 'Siswa';
    final content = sub['content'] ?? '';
    
    String filePath = sub['file_path'] ?? '';
    if (sub['files'] != null && sub['files'] is List && (sub['files'] as List).isNotEmpty) {
      filePath = sub['files'][0]['url'] ?? sub['files'][0]['path'] ?? sub['files'][0] ?? '';
    }
    
    final maxPoints = (sub['assignment']?['max_points'] as num?)?.toDouble() ?? 100.0;

    final pointsController = TextEditingController(text: sub['points_awarded']?.toString() ?? '');
    final feedbackController = TextEditingController(text: sub['instructor_feedback'] ?? '');
    String aiFeedbackText = sub['ai_feedback'] ?? '';
    bool isAiLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                assignmentTitle,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text('Siswa: $studentName', style: const TextStyle(color: Colors.black54, fontSize: 14)),
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
                    const Text('Jawaban Siswa:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        content.isNotEmpty ? content : 'Tidak ada konten teks.',
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                    if (filePath.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text('File Terlampir:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade100),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.insert_drive_file, color: Color(0xFF0D47A1)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                filePath.split('/').last,
                                style: const TextStyle(color: Color(0xFF0D47A1), fontSize: 13, fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.download, color: Color(0xFF0D47A1)),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Mengunduh file terlampir...')),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: pointsController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Nilai (Maks: $maxPoints)',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: isAiLoading
                              ? null
                              : () async {
                                  setModalState(() {
                                    isAiLoading = true;
                                  });
                                  try {
                                    final aiResult = await context
                                        .read<InstructorRepository>()
                                        .aiGradeSubmission(submissionId);
                                    
                                    setModalState(() {
                                      isAiLoading = false;
                                      if (aiResult['points_awarded'] != null) {
                                        pointsController.text = aiResult['points_awarded'].toString();
                                      }
                                      if (aiResult['ai_feedback'] != null) {
                                        aiFeedbackText = aiResult['ai_feedback'].toString();
                                      }
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Penilaian AI berhasil diproses!')),
                                    );
                                  } catch (e) {
                                    setModalState(() {
                                      isAiLoading = false;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Gagal: ${e.toString().replaceAll('Exception: ', '')}')),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1), // Indigo color for AI
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          icon: isAiLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Icon(Icons.auto_awesome, size: 18),
                          label: const Text('Nilai via AI', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    if (aiFeedbackText.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFC7D2FE)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.auto_awesome, color: Color(0xFF4F46E5), size: 16),
                                const SizedBox(width: 8),
                                const Text(
                                  'Feedback AI',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF312E81), fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              aiFeedbackText,
                              style: const TextStyle(color: Color(0xFF3730A3), fontSize: 13, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextField(
                      controller: feedbackController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Masukkan Feedback Instruktur',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          final ptsStr = pointsController.text.trim();
                          if (ptsStr.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Mohon masukkan nilai terlebih dahulu.')),
                            );
                            return;
                          }
                          final pts = double.tryParse(ptsStr);
                          if (pts == null || pts < 0 || pts > maxPoints) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Nilai harus berupa angka antara 0 s.d $maxPoints.')),
                            );
                            return;
                          }

                          try {
                            await context.read<InstructorRepository>().gradeSubmission(
                                  submissionId: submissionId,
                                  pointsAwarded: pts,
                                  feedback: feedbackController.text.trim(),
                                );
                            Navigator.pop(context);
                            _loadSubmissions();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Tugas berhasil dinilai!')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Gagal mengirim nilai: ${e.toString().replaceAll('Exception: ', '')}')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D47A1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('SIMPAN PENILAIAN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
