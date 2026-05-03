import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:hlms_mobile/features/course/data/course_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LessonScreen extends StatefulWidget {
  final String slug;
  final int lessonId;
  const LessonScreen({super.key, required this.slug, required this.lessonId});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  Map<String, dynamic>? _lessonData;
  bool _isLoading = true;

  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadLesson();
  }

  Future<void> _loadLesson() async {
    try {
      setState(() => _errorMessage = null);
      final data = await context.read<CourseRepository>().getLessonDetail(widget.slug, widget.lessonId);
      setState(() {
        _lessonData = data;
      });
      
      if (data['video_url'] != null && data['video_url'].toString().isNotEmpty) {
        await _initializePlayer(data['video_url']);
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _initializePlayer(String videoUrl) async {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    await _videoPlayerController.initialize();
    
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
      allowPlaybackSpeedChanging: true,
      aspectRatio: _videoPlayerController.value.aspectRatio,
    );

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Memuat...')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Menyiapkan materi...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    if (_lessonData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  _errorMessage ?? 'Gagal memuat materi pelajaran',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pastikan koneksi internet Anda stabil atau coba lagi nanti.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() => _isLoading = true);
                    _loadLesson();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('COBA LAGI'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_lessonData?['title'] ?? 'Belajar'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_chewieController != null)
              AspectRatio(
                aspectRatio: _videoPlayerController.value.aspectRatio,
                child: Chewie(controller: _chewieController!),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _lessonData?['title'] ?? '',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildContentBody(_lessonData?['content']),
                  const SizedBox(height: 40),
                  
                  // Next Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await context.read<CourseRepository>().markLessonComplete(widget.slug, widget.lessonId);
                          
                          if (mounted) {
                            final nextId = _lessonData?['next_lesson_id'];
                            if (nextId != null) {
                              // Navigate to next lesson
                              context.pushReplacement('/lesson/${widget.slug}/$nextId');
                            } else {
                              // No more lessons
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Selamat! Anda telah menyelesaikan materi terakhir.')),
                              );
                              context.pop();
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D47A1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _lessonData?['next_lesson_id'] != null ? 'SELANJUTNYA' : 'SELESAI',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentBody(dynamic content) {
    if (content == null || content.toString().isEmpty) {
      return const Text('Tidak ada deskripsi teks.', style: TextStyle(fontSize: 16));
    }

    // Try to parse as JSON if it looks like JSON
    final contentStr = content.toString();
    if (contentStr.trim().startsWith('{') || contentStr.trim().startsWith('[')) {
      try {
        final decoded = jsonDecode(contentStr);
        if (decoded is Map<String, dynamic> && decoded.containsKey('questions')) {
          return _buildQuizTeaser(decoded);
        }
      } catch (_) {
        // Not valid JSON or not a quiz, fall back to text
      }
    }

    return Text(
      contentStr,
      style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
    );
  }

  Widget _buildQuizTeaser(Map<String, dynamic> quiz) {
    final questions = quiz['questions'] as List? ?? [];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.quiz, color: Colors.orange),
              const SizedBox(width: 12),
              const Text(
                'Kuis Tersedia',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.orange),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            quiz['description'] ?? 'Uji pemahaman Anda mengenai materi ini.',
            style: const TextStyle(color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            '${questions.length} Pertanyaan • Batas Waktu: ${quiz['timeLimit'] ?? "-"} Menit',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // We need the assignment ID. If it's not in the JSON, we might have a problem.
              // But usually in this system, the lesson ID is used or there's a reference.
              // For now, let's try to find an ID in the JSON.
              final id = quiz['id'];
              if (id != null) {
                 // Navigation to quiz screen
                 // However, we need a numeric ID for the route.
                 // If the ID in JSON is a string like "quiz-3-2", we might need to handle it.
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Silakan buka kuis ini melalui daftar materi.')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('KERJAKAN KUIS'),
          ),
        ],
      ),
    );
  }
}
