// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:my_quiz/models/users.dart'; // PERBAIKAN: Import 'user.dart' (TANPA 'S')
import 'package:my_quiz/services/users_service.dart'; // PERBAIKAN: Import 'user_service.dart' (TANPA 'S')
import 'package:my_quiz/screens/login_screen.dart'; // Untuk navigasi setelah logout/delete

class ProfileScreen extends StatefulWidget {
  final Function(ThemeMode) setThemeMode; // KEMBALI: Menerima setThemeMode
  const ProfileScreen({super.key, required this.setThemeMode}); // KEMBALI: Menerima setThemeMode

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService(); // KEMBALI: UserService digunakan langsung
  User? _currentUser; // KEMBALI: State lokal untuk user
  bool _isLoading = true; // KEMBALI: State lokal untuk loading
  bool _isUpdating = false; // KEMBALI: State lokal untuk update

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController(); // Untuk verifikasi saat ganti password
  final TextEditingController _newPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile(); // KEMBALI: Memuat user profile secara manual
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final userId = await _userService.getLoggedInUserId();
      if (userId != null) {
        final user = await _userService.getUserById(userId);
        setState(() {
          _currentUser = user;
          if (_currentUser != null) {
            _usernameController.text = _currentUser!.username;
            _emailController.text = _currentUser!.email;
          }
        });
      }
    } catch (e) {
      print("Error loading user profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat profil: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isUpdating = true;
    });

    final newUsername = _usernameController.text.trim();
    final newEmail = _emailController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    // Hanya update jika ada perubahan pada username atau email
    bool shouldUpdate = false;
    if (_currentUser != null) {
      if (newUsername != _currentUser!.username || newEmail != _currentUser!.email) {
        shouldUpdate = true;
      }
    }

    if (shouldUpdate || newPassword.isNotEmpty) {
      final success = await _userService.updateUser(
        _currentUser!.id,
        username: newUsername,
        email: newEmail,
        password: newPassword.isNotEmpty ? newPassword : null,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui!')),
        );
        _newPasswordController.clear(); // Bersihkan field password baru
        await _loadUserProfile(); // Muat ulang profil untuk update UI
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memperbarui profil.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada perubahan untuk disimpan.')),
      );
    }

    setState(() {
      _isUpdating = false;
    });
  }

  Future<void> _deleteAccount() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Akun?'),
        content: const Text('Apakah Anda yakin ingin menghapus akun Anda secara permanen? Aksi ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true && _currentUser != null) {
      final success = await _userService.deleteUser(_currentUser!.id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Akun berhasil dihapus.')),
        );
        await _userService.logoutUser(); // Logout setelah akun dihapus
        Navigator.pushAndRemoveUntil( // Kembali ke LoginScreen
          context,
          MaterialPageRoute(builder: (context) => LoginScreen(setThemeMode: widget.setThemeMode)), // KEMBALI: Meneruskan setThemeMode
          (Route<dynamic> route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus akun.')),
        );
      }
    }
  }

  Future<void> _logout() async {
    await _userService.logoutUser();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen(setThemeMode: widget.setThemeMode)), // KEMBALI: Meneruskan setThemeMode
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentUser == null
              ? const Center(child: Text('Gagal memuat data profil. Silakan coba lagi.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.account_circle, size: 100, color: Colors.deepPurple),
                      const SizedBox(height: 20),
                      Text(
                        _currentUser!.username,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        _currentUser!.email,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Bergabung sejak: ${Theme.of(context).brightness == Brightness.light ? _currentUser!.createdAt.toLocal().toIso8601String().substring(0, 10) : _currentUser!.createdAt.toLocal().toString().substring(0, 10)}',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),

                      // Bagian Edit Profil
                      Text('Edit Informasi Profil', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          prefixIcon: const Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 15),
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

                      // Bagian Ganti Password (opsional)
                      Text('Ganti Password (Opsional)', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _newPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Password Baru',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: const Icon(Icons.visibility_off),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 20),

                      _isUpdating
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _updateProfile,
                              style: Theme.of(context).elevatedButtonTheme.style,
                              child: const Text('Simpan Perubahan', style: TextStyle(fontSize: 18)),
                            ),
                      const SizedBox(height: 30),

                      // Tombol Hapus Akun
                      OutlinedButton.icon(
                        onPressed: _deleteAccount,
                        icon: const Icon(Icons.delete_forever, color: Colors.red),
                        label: const Text('Hapus Akun Saya', style: TextStyle(fontSize: 18, color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red, width: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}