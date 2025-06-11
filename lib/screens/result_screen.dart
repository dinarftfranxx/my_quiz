// lib/screens/result_screen.dart

import 'package:flutter/material.dart';
import 'package:my_quiz/screens/leaderboard_screen.dart'; // Import halaman leaderboard

class ResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final VoidCallback onRetakeQuiz; // KEMBALI: Menerima onRetakeQuiz

  const ResultScreen({
    Key? key,
    required this.score,
    required this.totalQuestions,
    required this.onRetakeQuiz, // KEMBALI: Menerima onRetakeQuiz
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final userProvider = Provider.of<UserProvider>(context); // Hapus akses Provider jika tidak menggunakan Provider
    // final themeProvider = Provider.of<ThemeProvider>(context); // Hapus akses Provider jika tidak menggunakan Provider

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Kuis'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        centerTitle: true,
        automaticallyImplyLeading: false, // Sembunyikan tombol back bawaan
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.emoji_events, // Ikon piala
                size: 100,
                color: Colors.amber,
              ),
              const SizedBox(height: 20),
              // PERBAIKAN: Tampilkan pesan default (tanpa username dari Provider)
              const Text(
                'Kuis Selesai!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Skor Anda:',
                style: TextStyle(fontSize: 20, color: Colors.grey[700]),
              ),
              Text(
                '$score / $totalQuestions',
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.green),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop(); // Tutup halaman hasil
                  onRetakeQuiz(); // KEMBALI: Panggil callback untuk mulai kuis baru
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Ulangi Kuis', style: TextStyle(fontSize: 18)),
                style: Theme.of(context).elevatedButtonTheme.style,
              ),
              const SizedBox(height: 15),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push( // Gunakan push agar bisa kembali ke ResultScreen
                    context,
                    MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
                  );
                },
                icon: const Icon(Icons.leaderboard),
                label: const Text('Lihat Leaderboard', style: TextStyle(fontSize: 18)),
                style: Theme.of(context).outlinedButtonTheme.style, // Gunakan tema dari OutlinedButtonTheme
              ),
            ],
          ),
        ),
      ),
    );
  }
}