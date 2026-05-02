import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hlms_mobile/features/course/data/course_repository.dart';

class AssignmentUploadScreen extends StatefulWidget {
  final int assignmentId;
  const AssignmentUploadScreen({super.key, required this.assignmentId});

  @override
  State<AssignmentUploadScreen> createState() => _AssignmentUploadScreenState();
}

class _AssignmentUploadScreenState extends State<AssignmentUploadScreen> {
  String? _selectedFileName;
  String? _selectedFilePath;
  final _contentController = TextEditingController();
  Map<String, dynamic>? _assignmentData;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadAssignment();
  }

  Future<void> _loadAssignment() async {
    try {
      final data = await context.read<CourseRepository>().getAssignmentDetail(widget.assignmentId);
      setState(() {
        _assignmentData = data;
        _isLoading = false;
        // If already submitted, pre-fill text
        if (data['my_submission'] != null) {
          _contentController.text = data['my_submission']['content'] ?? '';
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        context.pop();
      }
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'zip', 'rar', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        _selectedFileName = result.files.single.name;
        _selectedFilePath = result.files.single.path;
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

    setState(() => _isSubmitting = true);
    try {
      await context.read<CourseRepository>().submitAssignment(
        assignmentId: widget.assignmentId,
        content: _contentController.text,
        filePath: _selectedFilePath,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tugas berhasil dikumpulkan!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final submission = _assignmentData?['my_submission'];
    final status = submission?['status'] ?? 'pending';
    final isGraded = status == 'graded' || status == 'reviewed';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kumpulkan Tugas'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _assignmentData?['title'] ?? 'Tugas',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              _assignmentData?['description'] ?? '',
              style: const TextStyle(color: Colors.black54, height: 1.5),
            ),
            if (isGraded) ...[
              const SizedBox(height: 24),
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
                        'Tugas Selesai & Dinilai: ${submission['points_awarded']} / ${_assignmentData?['max_points']}',
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            const Text('Teks Jawaban (Opsional)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              maxLines: 5,
              enabled: !isGraded,
              decoration: InputDecoration(
                hintText: 'Tuliskan jawaban Anda di sini...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),
            const Text('Lampiran File', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey.shade50,
              ),
              child: Column(
                children: [
                  Icon(Icons.cloud_upload_outlined, size: 64, color: isGraded ? Colors.grey : const Color(0xFF0D47A1)),
                  const SizedBox(height: 16),
                  Text(_selectedFileName ?? (submission?['files'] != null ? 'File sudah terunggah' : 'Pilih file tugas')),
                  if (!isGraded) ...[
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Pilih File'),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 48),
            if (!isGraded)
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isSubmitting 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Kirim Tugas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}
