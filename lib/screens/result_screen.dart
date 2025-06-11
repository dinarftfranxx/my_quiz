import 'package:flutter/material.dart';
import 'package:my_quiz/screens/leaderboard_screen.dart';
import 'package:provider/provider.dart';
import 'package:my_quiz/providers/user_provider.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final VoidCallback onRetakeQuiz;

  const ResultScreen({
    Key? key,
    required this.score,
    required this.totalQuestions,
    required this.onRetakeQuiz,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Kuis'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.emoji_events,
                size: 100,
                color: Colors.amber,
              ),
              const SizedBox(height: 20),
              Text(
                userProvider.loggedInUser != null
                    ? 'Selamat, ${userProvider.loggedInUser!.username}!'
                    : 'Kuis Selesai!',
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Skor Anda:',
                style: TextStyle(fontSize: 20, color: Colors.grey[700]),
              ),
              Text(
                '$score / $totalQuestions',
                style: const TextStyle(
                    fontSize: 48, fontWeight: FontWeight.bold, color: Colors.green),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetakeQuiz();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Ulangi Kuis', style: TextStyle(fontSize: 18)),
                style: Theme.of(context).elevatedButtonTheme.style,
              ),
              const SizedBox(height: 15),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
                  );
                },
                icon: const Icon(Icons.leaderboard),
                label: const Text('Lihat Leaderboard', style: TextStyle(fontSize: 18)),
                style: Theme.of(context).outlinedButtonTheme.style,
              ),
            ],
          ),
        ),
      ),
    );
  }
}