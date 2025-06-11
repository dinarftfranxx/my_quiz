// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_quiz/firebase_options.dart';
import 'package:my_quiz/screens/quiz_screen.dart';
import 'package:my_quiz/screens/login_screen.dart'; // Import halaman login
import 'package:my_quiz/services/users_service.dart'; // Import UserService
import 'package:shared_preferences/shared_preferences.dart'; // Import Shared Preferences


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

// MyApp sekarang menjadi StatefulWidget untuk mengelola state tema dan status login
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system; // Default tema: mengikuti sistem
  bool _isLoggedIn = false; // Status login
  bool _isLoadingAuth = true; // Loading untuk proses cek autentikasi awal

  @override
  void initState() {
    super.initState();
    _loadThemeMode(); // Muat preferensi tema saat aplikasi dimulai
    _checkLoginStatus(); // Cek status login saat aplikasi dimulai
  }

  // Fungsi untuk memuat preferensi tema dari Shared Preferences
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString('themeMode') ?? 'system';

      setState(() {
        if (savedTheme == 'light') {
          _themeMode = ThemeMode.light;
        } else if (savedTheme == 'dark') {
          _themeMode = ThemeMode.dark;
        } else {
          _themeMode = ThemeMode.system;
        }
      });
    } catch (e) {
      print("Error loading theme mode: $e");
      setState(() {
        _themeMode = ThemeMode.system;
      });
    }
  }

  // Fungsi untuk mengatur dan menyimpan preferensi tema
  void setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    String themeString;
    if (mode == ThemeMode.light) {
      themeString = 'light';
    } else if (mode == ThemeMode.dark) {
      themeString = 'dark';
    } else {
      themeString = 'system';
    }

    setState(() {
      _themeMode = mode;
    });
    await prefs.setString('themeMode', themeString);
    print('Tema diatur ke: $themeString');
  }

  // Fungsi untuk mengecek status login dari Shared Preferences
  Future<void> _checkLoginStatus() async {
    final userService = UserService();
    _isLoggedIn = await userService.checkLoginStatus();
    setState(() {
      _isLoadingAuth = false; // Proses cek selesai
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan loading screen jika sedang memeriksa status login
    if (_isLoadingAuth) {
      return MaterialApp(
        home: const Scaffold( // Tambahkan const karena tidak ada state dinamis di loading
          body: Center(
            child: CircularProgressIndicator(color: Colors.deepPurple),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Aplikasi Kuis', // Judul aplikasi
      themeMode: _themeMode, // Terapkan tema yang dipilih
      theme: ThemeData( // Tema Terang (Light Mode)
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 3,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.deepPurple,
            side: const BorderSide(color: Colors.deepPurple, width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        cardTheme: CardThemeData( // TIPE yang benar
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 5,
        ),
      ),
      darkTheme: ThemeData( // Tema Gelap (Dark Mode)
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.grey[900],
        cardColor: Colors.grey[850],
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          displayLarge: TextStyle(color: Colors.white),
          displayMedium: TextStyle(color: Colors.white),
          displaySmall: TextStyle(color: Colors.white),
          headlineLarge: TextStyle(color: Colors.white),
          headlineMedium: TextStyle(color: Colors.white),
          headlineSmall: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Colors.white),
          labelLarge: TextStyle(color: Colors.white),
          labelMedium: TextStyle(color: Colors.white70),
          labelSmall: TextStyle(color: Colors.white54),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[850],
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple[700],
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 3,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.deepPurple[300],
            side: BorderSide(color: Colors.deepPurple[300]!, width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        cardTheme: CardThemeData( // Tanpa 'const' karena properti 'color' bukan const compile-time
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 5,
          color: Colors.grey[850],
        ),
      ),
      // Tentukan halaman awal berdasarkan status login
      home: _isLoggedIn
          ? QuizScreen(setThemeMode: setThemeMode) // Jika sudah login, ke QuizScreen
          : LoginScreen(setThemeMode: setThemeMode), // Jika belum, ke LoginScreen
    );
  }
}