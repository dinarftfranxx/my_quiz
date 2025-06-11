import 'package:flutter/material.dart';
import 'package:my_quiz/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:my_quiz/providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  final Function(ThemeMode) setThemeMode;
  const ProfileScreen({super.key, required this.setThemeMode});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.loggedInUser != null) {
      _usernameController.text = userProvider.loggedInUser!.username;
      _emailController.text = userProvider.loggedInUser!.email;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.loggedInUser == null) return;

    final newUsername = _usernameController.text.trim();
    final newEmail = _emailController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    bool shouldUpdate = newUsername != userProvider.loggedInUser!.username ||
        newEmail != userProvider.loggedInUser!.email ||
        newPassword.isNotEmpty;

    if (shouldUpdate) {
      final success = await userProvider.updateProfile(
        userProvider.loggedInUser!.id,
        username: newUsername,
        email: newEmail,
        password: newPassword.isNotEmpty ? newPassword : null,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui!')),
        );
        _newPasswordController.clear();
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
  }

  Future<void> _deleteAccount() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Akun?'),
        content: const Text(
            'Apakah Anda yakin ingin menghapus akun Anda secara permanen? Aksi ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final success = await userProvider.deleteAccount();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Akun berhasil dihapus.')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen(setThemeMode: (ThemeMode p1) {  },)),
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
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) =>  LoginScreen(setThemeMode: (ThemeMode p1) {  },)),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
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
      body: userProvider.isLoadingAuth
          ? const Center(child: CircularProgressIndicator())
          : userProvider.loggedInUser == null
              ? const Center(
                  child: Text('Gagal memuat data profil. Silakan coba lagi.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.account_circle,
                          size: 100, color: Colors.deepPurple),
                      const SizedBox(height: 20),
                      Text(
                        userProvider.loggedInUser!.username,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        userProvider.loggedInUser!.email,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Bergabung sejak: ${userProvider.loggedInUser!.createdAt.toLocal().toIso8601String().substring(0, 10)}',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      Text('Edit Informasi Profil',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          prefixIcon: const Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          prefixIcon: const Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      Text('Ganti Password (Opsional)',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _newPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Password Baru',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: const Icon(Icons.visibility_off),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 20),
                      userProvider.isLoadingAuth
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _updateProfile,
                              style: Theme.of(context).elevatedButtonTheme.style,
                              child: const Text('Simpan Perubahan',
                                  style: TextStyle(fontSize: 18)),
                            ),
                      const SizedBox(height: 30),
                      OutlinedButton.icon(
                        onPressed: _deleteAccount,
                        icon: const Icon(Icons.delete_forever, color: Colors.red),
                        label: const Text('Hapus Akun Saya',
                            style: TextStyle(fontSize: 18, color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red, width: 2),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}