// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:my_quiz/providers/user_provider.dart';
import 'package:my_quiz/screens/quiz_screen.dart';
import 'package:my_quiz/screens/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  final Function(ThemeMode) setThemeMode;
  const LoginScreen({
    Key? key,
    required this.setThemeMode,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final success = await userProvider.login(
      _identifierController.text,
      _passwordController.text,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selamat datang, ${userProvider.loggedInUser!.username}!')),
      );
      await Future.delayed(const Duration(milliseconds: 750));
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => QuizScreen(setThemeMode: (ThemeMode ) {  },)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login gagal. Periksa username/email dan password Anda.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
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
          child: Column(
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
              userProvider.isLoadingAuth
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
                    MaterialPageRoute(builder: (context) =>  SignUpScreen(setThemeMode: (ThemeMode ) {  },)),
                  );
                },
                child: Text('Belum punya akun? Daftar sekarang',
                    style: TextStyle(color: Theme.of(context).primaryColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}