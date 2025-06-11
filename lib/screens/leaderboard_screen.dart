// lib/screens/leaderboard_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Untuk memformat tanggal

// PERBAIKAN: Import Provider
// PERBAIKAN: Import ThemeProvider


class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  Future<void> _deleteScore(BuildContext context, String docId) async {
    try {
      bool? confirmDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Hapus Skor?'),
            content: const Text('Apakah Anda yakin ingin menghapus skor ini?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      );

      if (confirmDelete == true) {
        await FirebaseFirestore.instance.collection('scores').doc(docId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Skor berhasil dihapus!')),
        );
        print('Dokumen skor $docId berhasil dihapus.');
      }
    } catch (e) {
      print('Error menghapus skor: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus skor: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Akses ThemeProvider untuk konsistensi tema
    // final themeProvider = Provider.of<ThemeProvider>(context); // Tidak perlu listen jika hanya baca theme data sekali

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard Skor'),
        // PERBAIKAN: Ambil warna dari Theme.of(context)
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('scores')
            .orderBy('score', descending: true)
            .orderBy('timestamp', descending: true)
            .limit(20)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              // PERBAIKAN: Gunakan warna tema dari Theme.of(context)
              child: CircularProgressIndicator(color: Theme.of(context).primaryColor),
            );
          }
          if (snapshot.hasError) {
            print("Error loading scores: ${snapshot.error}");
            return Center(
              // PERBAIKAN: Gunakan warna tema dari Theme.of(context)
              child: Text('Error: ${snapshot.error}', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Belum ada skor yang tercatat.',
                style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.bodyMedium?.color), // PERBAIKAN: Gunakan warna tema
              ),
            );
          }

          final scores = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: scores.length,
            itemBuilder: (context, index) {
              final scoreDoc = scores[index];
              final scoreData = scoreDoc.data() as Map<String, dynamic>;
              final scoreId = scoreDoc.id;
              final score = scoreData['score'] ?? 0;
              final totalQuestions = scoreData['totalQuestions'] ?? 0;
              final userId = scoreData['userId'] ?? 'Anonim';
              final username = scoreData['username'] ?? 'Guest'; // Ambil username dari Firestore
              final timestamp = scoreData['timestamp'] as Timestamp?;

              String formattedTime = 'N/A';
              if (timestamp != null) {
                DateTime dateTime = timestamp.toDate();
                formattedTime = DateFormat('dd MMMEEEE, HH:mm').format(dateTime);
              }

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: CircleAvatar(
                    // PERBAIKAN: Gunakan warna tema dari Theme.of(context)
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    'Skor: $score / $totalQuestions',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Pemain: $username (ID: $userId)\nTanggal: $formattedTime',
                    style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color), // PERBAIKAN: Gunakan warna tema
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteScore(context, scoreId),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}