import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hlms_mobile/features/course/data/course_repository.dart';

class QuizScreen extends StatefulWidget {
  final int? assignmentId;
  final int? quizId;
  const QuizScreen({super.key, this.assignmentId, this.quizId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  String? _selectedAnswer;
  Map<String, dynamic>? _quizData;
  List<dynamic> _questions = [];
  Map<String, String> _userAnswers = {};
  Map<String, dynamic>? _lastResults;
  bool _isLoading = true;
  bool _showQuestions = false;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    try {
      Map<String, dynamic> data;
      if (widget.quizId != null) {
        data = await context.read<CourseRepository>().getQuizDetail(widget.quizId!);
      } else {
        data = await context.read<CourseRepository>().getAssignmentDetail(widget.assignmentId!);
      }

      setState(() {
        _quizData = data;
        var content = data['content'];
        
        // Handle if content is a JSON string
        if (content is String && content.isNotEmpty) {
          try {
            content = jsonDecode(content);
          } catch (e) {
            debugPrint('Error decoding quiz content: $e');
          }
        }
        
        // Load questions based on architecture
        if (data.containsKey('questions') && data['questions'] != null) {
          _questions = data['questions'];
        } else if (content is Map && content.containsKey('questions')) {
          _questions = content['questions'];
        } else if (content is List) {
          _questions = content;
        } else {
          _questions = [];
        }
        
        _lastResults = data['results'];
        _showQuestions = _lastResults == null;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        context.pop();
      }
    }
  }

  void _nextQuestion() async {
    if (_selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih jawaban terlebih dahulu!')),
      );
      return;
    }

    // Save answer
    final currentQ = _questions[_currentQuestionIndex];
    _userAnswers[currentQ['id'].toString()] = _selectedAnswer!;

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
      });
    } else {
      // Submit Quiz
      setState(() => _isLoading = true);
      try {
        if (widget.quizId != null) {
          final result = await context.read<CourseRepository>().submitQuiz(
            quizId: widget.quizId!,
            answers: _userAnswers,
          );
          if (mounted) {
            final data = result['data'];
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(data['passed'] ? 'Lulus!' : 'Belum Lulus'),
                content: Text('Skor Anda: ${data['score']}\n${data['message']}'),
                actions: [
                  TextButton(
                    onPressed: () {
                      context.pop(); // close dialog
                      context.pop(); // close quiz screen
                    },
                    child: const Text('Tutup'),
                  ),
                ],
              ),
            );
          }
        } else {
          await context.read<CourseRepository>().submitAssignment(
            assignmentId: widget.assignmentId!,
            answers: _userAnswers,
          );
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Kuis Selesai!'),
                content: const Text('Jawaban Anda telah dikirim dan dinilai secara otomatis.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      context.pop(); // close dialog
                      context.pop(); // close quiz screen
                    },
                    child: const Text('Tutup'),
                  ),
                ],
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kuis')),
        body: const Center(child: Text('Tidak ada pertanyaan dalam kuis ini.')),
      );
    }

    if (_lastResults != null && !_showQuestions) {
      return _buildResultsScreen();
    }

    final currentQ = _questions[_currentQuestionIndex];
    final optionsRaw = currentQ['options'];
    
    // Handle both Map and List formats for options
    List<MapEntry<String, String>> optionsList = [];
    if (optionsRaw is Map) {
      optionsList = optionsRaw.entries.map((e) => MapEntry(e.key.toString(), e.value.toString())).toList();
    } else if (optionsRaw is List) {
      optionsList = optionsRaw.map((opt) {
        if (opt is Map) {
          final id = (opt['id'] ?? opt['value'] ?? '').toString();
          final text = (opt['text'] ?? opt['label'] ?? '').toString();
          return MapEntry(id, text);
        }
        return MapEntry(opt.toString(), opt.toString());
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Kuis Sesi ${_currentQuestionIndex + 1} / ${_questions.length}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _questions.length,
              backgroundColor: Colors.grey.shade200,
              color: const Color(0xFF0D47A1),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            const SizedBox(height: 32),
            Text(
              currentQ['text'] ?? currentQ['question'] ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView(
                children: optionsList.map((entry) {
                  final isSelected = _selectedAnswer == entry.key;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedAnswer = entry.key;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? const Color(0xFF0D47A1) : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected ? Colors.blue.shade50 : Colors.white,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                              color: isSelected ? const Color(0xFF0D47A1) : Colors.grey,
                            ),
                            const SizedBox(width: 16),
                            Expanded(child: Text(entry.value)),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _nextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D47A1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(_currentQuestionIndex < _questions.length - 1 ? 'Pertanyaan Selanjutnya' : 'Kirim Jawaban'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsScreen() {
    final results = _lastResults!;
    final bool passed = results['passed'] ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Kuis'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: passed ? Colors.green.shade50 : Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                passed ? Icons.emoji_events : Icons.sentiment_very_dissatisfied,
                size: 80,
                color: passed ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              passed ? 'Selamat! Anda Lulus' : 'Maaf, Anda Belum Lulus',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: passed ? Colors.green.shade800 : Colors.red.shade800,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  const Text('Skor Akhir Anda', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text(
                    '${results['score']}',
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Benar', '${results['correct_count']}'),
                      _buildStatItem('Total', '${results['total_questions']}'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showQuestions = true;
                    _currentQuestionIndex = 0;
                    _userAnswers = {};
                    _selectedAnswer = null;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0D47A1),
                  side: const BorderSide(color: Color(0xFF0D47A1)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Ulangi Kuis'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => context.pop(),
                child: const Text('Kembali ke Materi'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
