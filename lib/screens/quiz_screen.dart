// lib/screens/quiz_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_quiz/models/question.dart';
import 'package:my_quiz/screens/login_screen.dart';
import 'package:my_quiz/screens/profile_screen.dart';
import 'package:my_quiz/screens/result_screen.dart';
import 'package:my_quiz/screens/settings_screen.dart';
import 'package:my_quiz/services/users_service.dart'; // Import UserService


class QuizScreen extends StatefulWidget {
  final Function(ThemeMode) setThemeMode;
  const QuizScreen({super.key, required this.setThemeMode});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> _questions = [];
  bool _isLoading = true;
  int _currentQuestionIndex = 0;
  String? _selectedAnswer;
  bool _isAnswerChecked = false;
  int _score = 0;

  final UserService _userService = UserService();
  String? _loggedInUsername;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
    _loadLoggedInUser();
  }

  Future<void> _loadLoggedInUser() async {
    final username = await _userService.getLoggedInUsername();
    setState(() {
      _loggedInUsername = username;
    });
  }

  Future<void> _fetchQuestions() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('questions')
          .get();

      setState(() {
        List<Question> allQuestions = querySnapshot.docs.map((doc) {
          return Question.fromFirestore(doc);
        }).toList();

        allQuestions.shuffle();
        _questions = allQuestions.take(5).toList();

        _isLoading = false;
        _currentQuestionIndex = 0;
        _selectedAnswer = null;
        _isAnswerChecked = false;
        _score = 0;
      });
    } catch (e) {
      print("Error fetching questions: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat pertanyaan: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _checkAnswer(String selectedOption) {
    if (_isAnswerChecked) return;

    setState(() {
      _selectedAnswer = selectedOption;
      _isAnswerChecked = true;
    });

    final currentQuestion = _questions[_currentQuestionIndex];
    if (selectedOption == currentQuestion.correctAnswer) {
      print('Jawaban Benar!');
      _score++;
    } else {
      print('Jawaban Salah. Yang benar adalah: ${currentQuestion.correctAnswer}');
    }
  }

  Future<void> _saveScoreToFirestore() async {
    try {
      CollectionReference scoresCollection = FirebaseFirestore.instance.collection('scores');
      final loggedInUserId = await _userService.getLoggedInUserId();
      String currentUserId = loggedInUserId?.toString() ?? 'guest_user_123';
      String currentUsername = _loggedInUsername ?? 'Guest';

      QuerySnapshot existingScores = await scoresCollection
          .where('userId', isEqualTo: currentUserId)
          .orderBy('score', descending: true)
          .limit(1)
          .get();

      if (existingScores.docs.isNotEmpty) {
        DocumentSnapshot topScoreDoc = existingScores.docs.first;
        int oldTopScore = (topScoreDoc.data() as Map<String, dynamic>)['score'] ?? 0;

        if (_score > oldTopScore) {
          await topScoreDoc.reference.update({
            'score': _score,
            'totalQuestions': _questions.length,
            'timestamp': FieldValue.serverTimestamp(),
            'username': currentUsername,
          });
          print('Skor $currentUsername (ID: $currentUserId) berhasil diperbarui ke: $_score');
          if (!mounted) return; // Tambahkan mounted check
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Skor tertinggi Anda diperbarui!')),
          );
        } else {
          print('Skor $currentUsername (ID: $currentUserId) tidak diperbarui, skor saat ini lebih rendah/sama.');
          if (!mounted) return; // Tambahkan mounted check
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Skor tidak melampaui skor tertinggi sebelumnya.')),
          );
        }
      } else {
        await scoresCollection.add({
          'userId': currentUserId,
          'username': currentUsername,
          'score': _score,
          'totalQuestions': _questions.length,
          'timestamp': FieldValue.serverTimestamp(),
        });
        print('Skor baru untuk $currentUsername (ID: $currentUserId) berhasil disimpan.');
        if (!mounted) return; // Tambahkan mounted check
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Skor Anda berhasil disimpan!')),
        );
      }
    } catch (e) {
      print('Error menyimpan/memperbarui skor ke Firestore: $e');
      if (!mounted) return; // Tambahkan mounted check
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan/memperbarui skor: $e')),
      );
    }
  }

  void _nextQuestion() {
    setState(() {
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _isAnswerChecked = false;
      } else {
        _saveScoreToFirestore();

        // PERBAIKAN UTAMA: Ubah Navigator.pushReplacement menjadi Navigator.push
        Navigator.push( // INI YANG DIUBAH!
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              score: _score,
              totalQuestions: _questions.length,
              onRetakeQuiz: _fetchQuestions, // Teruskan callback _fetchQuestions
            ),
          ),
        );
      }
    });
  }

  Color _getOptionColor(String option) {
    if (!_isAnswerChecked) return Colors.blueAccent;

    final currentQuestion = _questions[_currentQuestionIndex];
    if (option == currentQuestion.correctAnswer) {
      return Colors.green;
    } else if (option == _selectedAnswer) {
      return Colors.red;
    }
    return Colors.blueAccent;
  }

  Future<void> _logout() async {
    await _userService.logoutUser();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen(setThemeMode: widget.setThemeMode)),
      (Route<dynamic> route) => false,
    );
  }

  @override
    Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_loggedInUsername != null ? 'Kuis (${_loggedInUsername!})' : 'Aplikasi Kuis'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        centerTitle: false, // Judul akan rata kiri
        actions: [
          // Tombol untuk melihat/mengelola user CRUD (Admin-like) - DIHAPUS
          // IconButton(
          //   icon: const Icon(Icons.people),
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => const UserCrudScreen()),
          //     );
          //   },
          // ),
          IconButton( // Tombol Profil (User yang login)
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen(setThemeMode: widget.setThemeMode)),
              );
            },
          ),
          IconButton( // Tombol Settings (untuk tema)
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(setThemeMode: widget.setThemeMode),
                ),
              );
            },
          ),
          IconButton( // Tombol Logout
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          : _questions.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      'Tidak ada pertanyaan kuis yang tersedia. Pastikan Anda sudah mengimpor soal ke Firebase Firestore!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Indikator Pertanyaan
                      Text(
                        'Pertanyaan ${_currentQuestionIndex + 1} dari ${_questions.length}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.deepPurple),
                      ),
                      const SizedBox(height: 10),

                      // Box Pertanyaan
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            _questions[_currentQuestionIndex].questionText,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Opsi Jawaban
                      ..._questions[_currentQuestionIndex].options.map((option) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ElevatedButton(
                            onPressed: _isAnswerChecked ? null : () => _checkAnswer(option),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              backgroundColor: _getOptionColor(option),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: _isAnswerChecked ? 0 : 3,
                            ),
                            child:
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    option,
                                    style: const TextStyle(fontSize: 18),
                                    textAlign: TextAlign.center,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 20),

                      // Tombol Lanjut
                      if (_isAnswerChecked)
                        ElevatedButton(
                          onPressed: _nextQuestion,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            _currentQuestionIndex < _questions.length - 1
                                ? 'Pertanyaan Selanjutnya'
                                : 'Selesai Kuis',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}