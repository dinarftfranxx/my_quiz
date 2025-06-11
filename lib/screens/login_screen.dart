// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:my_quiz/screens/quiz_screen.dart';
import 'package:my_quiz/screens/signup_screen.dart';
import 'package:my_quiz/services/users_service.dart'; // PERBAIKAN: Import UserService


class LoginScreen extends StatefulWidget {
  final Function(ThemeMode) setThemeMode; // KEMBALI: Menerima setThemeMode
  const LoginScreen({Key? key, required this.setThemeMode}) : super(key: key); // KEMBALI: Menerima setThemeMode

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final UserService _userService = UserService(); // KEMBALI: UserService digunakan langsung
  bool _isLoading = false; // KEMBALI: State lokal untuk loading

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final user = await _userService.loginUser( // KEMBALI: Memanggil UserService langsung
      _identifierController.text,
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selamat datang, ${user.username}!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => QuizScreen(setThemeMode: widget.setThemeMode)), // KEMBALI: Meneruskan setThemeMode
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login gagal. Periksa username/email dan password Anda.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column( // KEMBALI: Tidak lagi Consumer, tapi langsung Column
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.lock_open, size: 80, color: Colors.deepPurple),
              const SizedBox(height: 30),
              Text(
                'Masuk ke Akun Anda',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _identifierController,
                decoration: InputDecoration(
                  labelText: 'Username atau Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.person),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: const Icon(Icons.visibility_off),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 30),
              _isLoading // KEMBALI: Menggunakan _isLoading lokal
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _login,
                      style: Theme.of(context).elevatedButtonTheme.style,
                      child: const Text('Login', style: TextStyle(fontSize: 18)),
                    ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpScreen(setThemeMode: widget.setThemeMode)), // KEMBALI: Meneruskan setThemeMode
                  );
                },
                child: Text('Belum punya akun? Daftar sekarang', style: TextStyle(color: Theme.of(context).primaryColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}