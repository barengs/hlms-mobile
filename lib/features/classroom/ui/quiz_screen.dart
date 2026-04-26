import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hlms_mobile/features/course/data/course_repository.dart';

class QuizScreen extends StatefulWidget {
  final int assignmentId;
  const QuizScreen({super.key, required this.assignmentId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  String? _selectedAnswer;
  Map<String, dynamic>? _quizData;
  List<dynamic> _questions = [];
  Map<String, String> _userAnswers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    try {
      final data = await context.read<CourseRepository>().getAssignmentDetail(widget.assignmentId);
      setState(() {
        _quizData = data;
        _questions = data['content']['questions'] ?? [];
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
        await context.read<CourseRepository>().submitAssignment(
          assignmentId: widget.assignmentId,
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

    final currentQ = _questions[_currentQuestionIndex];
    final options = currentQ['options'] as Map<String, dynamic>;

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
                children: options.entries.map((entry) {
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
                            Expanded(child: Text(entry.value.toString())),
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
}
