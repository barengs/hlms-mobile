import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int? _selectedAnswerIndex;

  final List<Map<String, Object>> _questions = [
    {
      'question': 'Manakah dari berikut ini yang merupakan kelebihan Flutter?',
      'options': [
        'Hanya bisa untuk Android',
        'Single codebase untuk berbagai platform',
        'Menggunakan bahasa pemrograman Java',
        'Tidak memiliki hot reload',
      ],
      'answer': 1,
    },
    {
      'question': 'State management mana yang disarankan oleh blueprint ini?',
      'options': [
        'Provider',
        'GetX',
        'Bloc / Cubit',
        'Riverpod',
      ],
      'answer': 2,
    },
  ];

  void _nextQuestion() {
    if (_selectedAnswerIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih jawaban terlebih dahulu!')),
      );
      return;
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = null;
      });
    } else {
      // Finish Quiz
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Kuis Selesai!'),
          content: const Text('Skor akan dikalkulasi dan disimpan.'),
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

  @override
  Widget build(BuildContext context) {
    final currentQ = _questions[_currentQuestionIndex];
    final options = currentQ['options'] as List<String>;

    return Scaffold(
      appBar: AppBar(
        title: Text('Kuis Sesi ${_currentQuestionIndex + 1} / ${_questions.length}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
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
            ),
            const SizedBox(height: 32),
            Text(
              currentQ['question'] as String,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ...List.generate(options.length, (index) {
              final isSelected = _selectedAnswerIndex == index;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedAnswerIndex = index;
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
                        Expanded(child: Text(options[index])),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const Spacer(),
            ElevatedButton(
              onPressed: _nextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D47A1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(_currentQuestionIndex < _questions.length - 1 ? 'Pertanyaan Selanjutnya' : 'Selesai Kuis'),
            ),
          ],
        ),
      ),
    );
  }
}
