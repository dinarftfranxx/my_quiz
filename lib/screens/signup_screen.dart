import 'package:flutter/material.dart';
import 'package:my_quiz/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:my_quiz/providers/user_provider.dart';

class SignUpScreen extends StatefulWidget {
  final Function(ThemeMode) setThemeMode;
  const SignUpScreen({super.key, required this.setThemeMode});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final success = await userProvider.register(
      _usernameController.text,
      _emailController.text,
      _passwordController.text,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Registrasi berhasil! Selamat datang, ${userProvider.loggedInUser!.username}!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  LoginScreen(setThemeMode: (ThemeMode p1) {  },)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Registrasi gagal. Coba username/email lain atau periksa koneksi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Akun'),
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
              const Icon(Icons.person_add, size: 80, color: Colors.deepPurple),
              const SizedBox(height: 30),
              Text(
                'Buat Akun Baru',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.email),
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
                      onPressed: _signUp,
                      style: Theme.of(context).elevatedButtonTheme.style,
                      child: const Text('Daftar', style: TextStyle(fontSize: 18)),
                    ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Sudah punya akun? Login di sini',
                    style: TextStyle(color: Theme.of(context).primaryColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}