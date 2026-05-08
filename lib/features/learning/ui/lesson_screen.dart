import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
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
  YoutubePlayerController? _youtubeController;
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
    final youtubeId = YoutubePlayer.convertUrlToId(videoUrl);
    
    if (youtubeId != null) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: youtubeId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
        ),
      );
      setState(() => _isLoading = false);
    } else {
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
  }

  @override
  void dispose() {
    if (_chewieController != null) {
      _videoPlayerController.dispose();
      _chewieController?.dispose();
    }
    _youtubeController?.dispose();
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
            if (_youtubeController != null)
              YoutubePlayer(
                controller: _youtubeController!,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.blueAccent,
              )
            else if (_chewieController != null)
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
                  
                  // Next / Assignment Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        final assignmentId = _lessonData?['assignment_id'];
                        final assignmentType = _lessonData?['assignment_type'];
                        
                        // If it's an assignment (and not a quiz which is handled in teaser)
                        if (assignmentId != null && assignmentType != 'quiz') {
                          context.push('/assignment/upload/$assignmentId');
                          return;
                        }

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
                            (_lessonData?['assignment_id'] != null && _lessonData?['assignment_type'] != 'quiz')
                                ? 'KERJAKAN TUGAS'
                                : (_lessonData?['next_lesson_id'] != null ? 'SELANJUTNYA' : 'SELESAI'),
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

    // If it's already a Map/List (decoded by backend)
    if (content is Map<String, dynamic> && content.containsKey('questions')) {
      return _buildQuizTeaser(content);
    }
    
    if (content is List) {
      // Could be a list of questions without wrapper
      return _buildQuizTeaser({'questions': content});
    }

    // Try to parse as JSON if it's a string
    if (content is String) {
      final contentStr = content.trim();
      if (contentStr.startsWith('{') || contentStr.startsWith('[')) {
        try {
          final decoded = jsonDecode(contentStr);
          if (decoded is Map<String, dynamic> && decoded.containsKey('questions')) {
            return _buildQuizTeaser(decoded);
          } else if (decoded is List) {
            return _buildQuizTeaser({'questions': decoded});
          }
        } catch (_) {}
      }
      
      return Text(
        contentStr,
        style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
      );
    }

    return Text(
      content.toString(),
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
          if (quiz.containsKey('last_result') && quiz['last_result'] != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: (quiz['last_result']['passed'] ?? false) ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: (quiz['last_result']['passed'] ?? false) ? Colors.green.shade200 : Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    (quiz['last_result']['passed'] ?? false) ? Icons.check_circle : Icons.error,
                    size: 16,
                    color: (quiz['last_result']['passed'] ?? false) ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Skor Terakhir: ${quiz['last_result']['score']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: (quiz['last_result']['passed'] ?? false) ? Colors.green.shade800 : Colors.red.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // For relational quizzes, the ID is in the content (quiz variable here)
              final quizId = quiz['id'];
              final assignmentId = _lessonData?['assignment_id'];
              final type = _lessonData?['assignment_type'] ?? _lessonData?['type'] ?? 'quiz';
              
              if (type == 'quiz_v2' || (quiz != null && quiz.containsKey('questions'))) {
                context.push('/quiz-v2/$quizId');
              } else if (assignmentId != null) {
                context.push('/quiz/$assignmentId');
              } else if (quizId != null) {
                context.push('/quiz-v2/$quizId');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ID Kuis tidak ditemukan.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              (quiz.containsKey('last_result') && quiz['last_result'] != null)
                  ? 'LIHAT HASIL'
                  : 'KERJAKAN KUIS',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
