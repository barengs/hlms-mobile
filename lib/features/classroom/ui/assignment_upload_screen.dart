import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hlms_mobile/features/course/data/course_repository.dart';
import 'package:hlms_mobile/features/auth/logic/auth_bloc/auth_bloc.dart';

class AssignmentUploadScreen extends StatefulWidget {
  final int assignmentId;
  const AssignmentUploadScreen({super.key, required this.assignmentId});

  @override
  State<AssignmentUploadScreen> createState() => _AssignmentUploadScreenState();
}

class _AssignmentUploadScreenState extends State<AssignmentUploadScreen>
    with TickerProviderStateMixin {
  String? _selectedFileName;
  String? _selectedFilePath;
  List<int>? _selectedFileBytes;
  final _contentController = TextEditingController();
  Map<String, dynamic>? _assignmentData;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _submitMessage;
  Map<String, dynamic>? _submitMeta;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation =
        Tween<double>(begin: 0.7, end: 1.0).animate(_pulseController);
    _loadAssignment();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadAssignment() async {
    try {
      final data = await context
          .read<CourseRepository>()
          .getAssignmentDetail(widget.assignmentId);
      setState(() {
        _assignmentData = data;
        _isLoading = false;
        if (data['my_submission'] != null) {
          _contentController.text =
              data['my_submission']['content'] ?? '';
          // Restore submission metadata if already submitted
          _submitMeta = {
            'submission_status': data['my_submission']['status'],
            'ai_status': data['my_submission']['ai_status'] ?? 'not_applicable',
          };
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
        context.pop();
      }
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        // Documents
        'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt',
        // Images
        'jpg', 'jpeg', 'png', 'webp', 'gif',
        // Code
        'dart', 'js', 'ts', 'py', 'java', 'cpp', 'c', 'html', 'css', 'json', 'php',
        // Archives
        'zip', 'rar'
      ],
      withData: true, // Crucial for Web
    );

    if (result != null) {
      setState(() {
        _selectedFileName = result.files.single.name;
        _selectedFilePath = result.files.single.path;
        _selectedFileBytes = result.files.single.bytes;
      });
    }
  }

  Future<void> _submit() async {
    if (_selectedFilePath == null && _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih file atau masukkan teks jawaban.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitMessage = null;
      _submitMeta = null;
    });

    try {
      final result = await context.read<CourseRepository>().submitAssignment(
            assignmentId: widget.assignmentId,
            content: _contentController.text,
            filePath: _selectedFilePath,
            fileBytes: _selectedFileBytes,
            fileName: _selectedFileName,
          );

      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _submitMessage = result['message']?.toString();
          _submitMeta = result['meta'] != null ? Map<String, dynamic>.from(result['meta'] as Map) : null;
          // Update assignment data with new submission from result
          if (result['data'] != null) {
            _assignmentData = {
              ..._assignmentData ?? {},
              'my_submission': result['data'] != null ? Map<String, dynamic>.from(result['data'] as Map) : null,
            };
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  /// Returns icon and color for the AI grading status.
  (IconData, Color, String) _aiStatusInfo(String? aiStatus) {
    return switch (aiStatus) {
      'completed' => (
          Icons.auto_awesome,
          const Color(0xFF00897B),
          'Evaluasi AI Selesai'
        ),
      'processing' => (
          Icons.hourglass_top_rounded,
          const Color(0xFF1E88E5),
          'AI sedang mengevaluasi...'
        ),
      'failed' => (
          Icons.error_outline,
          const Color(0xFFE53935),
          'Evaluasi AI gagal'
        ),
      _ => (Icons.pending_outlined, const Color(0xFF757575), 'Menunggu penilaian'),
    };
  }

  Color _submissionStatusColor(String? status) {
    return switch (status) {
      'graded' || 'reviewed' => const Color(0xFF00897B),
      'submitted' || 'late' => const Color(0xFF1E88E5),
      _ => const Color(0xFF757575),
    };
  }

  String _submissionStatusLabel(String? status) {
    return switch (status) {
      'graded' => 'Dinilai',
      'reviewed' => 'Ditinjau',
      'submitted' => 'Terkumpul',
      'late' => 'Terlambat',
      _ => 'Belum dikumpulkan',
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final submission = _assignmentData?['my_submission'];
    final submissionStatus = (_submitMeta?['submission_status'] ?? submission?['status']) as String?;
    final aiStatus = (_submitMeta?['ai_status'] ?? submission?['ai_status']) as String?;
    final isGraded = submissionStatus == 'graded' || submissionStatus == 'reviewed';
    final hasSubmitted = submission != null || _submitMeta != null;

    final authState = context.read<AuthBloc>().state;
    bool isInstructor = false;
    if (authState is AuthAuthenticated) {
      final roles = authState.user['roles'] as List<dynamic>?;
      isInstructor = roles?.any((role) => role['name'] == 'instructor') ?? false;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kumpulkan Tugas'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (hasSubmitted)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Chip(
                label: Text(
                  _submissionStatusLabel(submissionStatus),
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
                backgroundColor: _submissionStatusColor(submissionStatus),
                padding: EdgeInsets.zero,
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Assignment Title & Description
            Text(
              _assignmentData?['title'] ?? 'Tugas',
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              _assignmentData?['description'] ?? '',
              style: const TextStyle(color: Colors.black54, height: 1.5),
            ),

            // --- SUBMISSION STATUS BANNER ---
            if (_submitMessage != null || hasSubmitted) ...[
              const SizedBox(height: 24),
              _SubmissionStatusBanner(
                message: _submitMessage,
                aiStatus: aiStatus,
                submissionStatus: submissionStatus,
                aiStatusInfo: _aiStatusInfo(aiStatus),
                pulseAnimation: _pulseAnimation,
                aiScore: submission?['ai_score'],
                aiFeedback: submission?['ai_feedback'],
                maxPoints: _assignmentData?['max_points'],
              ),
            ],

            // --- GRADED RESULT ---
            if (isGraded && submission?['points_awarded'] != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Nilai: ${submission['points_awarded']} / ${_assignmentData?['max_points']}',
                        style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            if (!isInstructor) ...[
              // --- TEXT ANSWER ---
              const Text('Teks Jawaban (Opsional)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              maxLines: 5,
              enabled: !isGraded && !_isSubmitting,
              decoration: InputDecoration(
                hintText: 'Tuliskan jawaban Anda di sini...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 32),

            // --- FILE ATTACHMENT ---
            const Text('Lampiran File',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.grey.shade300,
                    style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey.shade50,
              ),
              child: Column(
                children: [
                  Icon(Icons.cloud_upload_outlined,
                      size: 64,
                      color: isGraded
                          ? Colors.grey
                          : const Color(0xFF0D47A1)),
                  const SizedBox(height: 16),
                  Text(_selectedFileName ??
                      (submission?['files'] != null &&
                              (submission!['files'] as List).isNotEmpty
                          ? 'File sudah terunggah ✓'
                          : 'Pilih file tugas')),
                  if (!isGraded) ...[
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _isSubmitting ? null : _pickFile,
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Pilih File'),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 48),

            // --- SUBMIT BUTTON ---
            if (!isGraded)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isSubmitting
                    ? _SubmittingIndicator()
                    : InkWell(
                        onTap: _submit,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          key: const ValueKey('submit_button'),
                          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0D47A1).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                hasSubmitted ? Icons.update : Icons.send_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                hasSubmitted
                                    ? 'Perbarui Pengumpulan'
                                    : 'Kirim Tugas Sekarang',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Submission Status Banner Widget
// ---------------------------------------------------------------------------
class _SubmissionStatusBanner extends StatelessWidget {
  final String? message;
  final String? aiStatus;
  final String? submissionStatus;
  final (IconData, Color, String) aiStatusInfo;
  final Animation<double> pulseAnimation;
  final dynamic aiScore;
  final dynamic aiFeedback;
  final dynamic maxPoints;

  const _SubmissionStatusBanner({
    required this.message,
    required this.aiStatus,
    required this.submissionStatus,
    required this.aiStatusInfo,
    required this.pulseAnimation,
    this.aiScore,
    this.aiFeedback,
    this.maxPoints,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, color, statusLabel) = aiStatusInfo;
    final isProcessing = aiStatus == 'processing';
    final isCompleted = aiStatus == 'completed';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Header
          Row(
            children: [
              // Pulse animation for processing state
              if (isProcessing)
                AnimatedBuilder(
                  animation: pulseAnimation,
                  builder: (_, child) => Opacity(
                    opacity: pulseAnimation.value,
                    child: child,
                  ),
                  child: Icon(icon, color: color, size: 22),
                )
              else
                Icon(icon, color: color, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message != null)
                      Text(
                        message!,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    if (aiStatus != null &&
                        aiStatus != 'not_applicable') ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            statusLabel,
                            style: TextStyle(
                                color: color,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // AI Score & Feedback
          if (isCompleted && aiScore != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.stars_rounded,
                    color: Color(0xFF00897B), size: 18),
                const SizedBox(width: 6),
                Text(
                  'Skor AI: $aiScore / $maxPoints',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00897B),
                  ),
                ),
              ],
            ),
            if (aiFeedback != null) ...[
              const SizedBox(height: 8),
              Text(
                aiFeedback.toString(),
                style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.5),
              ),
            ],
          ],

          // Processing explanation
          if (isProcessing) ...[
            const SizedBox(height: 10),
            const LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              color: Color(0xFF1E88E5),
              minHeight: 2,
            ),
            const SizedBox(height: 8),
            const Text(
              'Tunggu sebentar ya, AI sedang membaca dan menilai tugasmu secara otomatis.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Submitting Indicator Widget
// ---------------------------------------------------------------------------
class _SubmittingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('submitting_indicator'),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0D47A1).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0D47A1).withOpacity(0.3)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              color: Color(0xFF0D47A1),
              strokeWidth: 2.5,
            ),
          ),
          SizedBox(width: 14),
          Text(
            'Sedang mengupload & mengirim tugas...',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0D47A1),
            ),
          ),
        ],
      ),
    );
  }
}
