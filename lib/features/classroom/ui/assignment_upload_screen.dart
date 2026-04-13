import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';

class AssignmentUploadScreen extends StatefulWidget {
  const AssignmentUploadScreen({super.key});

  @override
  State<AssignmentUploadScreen> createState() => _AssignmentUploadScreenState();
}

class _AssignmentUploadScreenState extends State<AssignmentUploadScreen> {
  String? _selectedFileName;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'zip', 'rar'],
    );

    if (result != null) {
      setState(() {
        _selectedFileName = result.files.single.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kumpulkan Tugas'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Tugas Sesi 2: State Management',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Buatlah aplikasi counter sederhana menggunakan Flutter Bloc dan kumpulkan source codenya dalam bentuk zip.',
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey.shade50,
              ),
              child: Column(
                children: [
                  const Icon(Icons.cloud_upload_outlined, size: 64, color: Color(0xFF0D47A1)),
                  const SizedBox(height: 16),
                  Text(_selectedFileName ?? 'Pilih file tugas (.zip / .pdf)'),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Pilih File'),
                  ),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                if (_selectedFileName != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tugas berhasil dikumpulkan.')),
                  );
                  context.pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pilih file terlebih dahulu.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D47A1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Kirim Tugas'),
            ),
          ],
        ),
      ),
    );
  }
}
