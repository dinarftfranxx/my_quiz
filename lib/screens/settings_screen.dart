// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
// Hapus import yang tidak diperlukan
// import 'package:provider/provider.dart';
// import 'package:my_quiz/providers/theme_provider.dart';
// import 'package:my_quiz/providers/user_provider.dart';
import 'package:my_quiz/screens/login_screen.dart'; // Untuk navigasi setelah logout
import 'package:my_quiz/services/users_service.dart'; // PERBAIKAN: Import UserService

class SettingsScreen extends StatelessWidget {
  final Function(ThemeMode) setThemeMode; // KEMBALI: Menerima setThemeMode
  const SettingsScreen({super.key, required this.setThemeMode});

  @override
  Widget build(BuildContext context) {
    // KEMBALI: Mendapatkan ThemeMode aktif dari context
    ThemeMode currentActiveThemeMode;
    if (Theme.of(context).brightness == Brightness.light) {
      currentActiveThemeMode = ThemeMode.light;
    } else {
      currentActiveThemeMode = ThemeMode.dark;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'), // Ubah judul lebih umum
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tampilan',
              style: Theme.of(context).textTheme.headline6, // KEMBALI: Akses textTheme.headline6
            ),
            ListTile(
              title: const Text('Tema'),
              trailing: DropdownButton<ThemeMode>(
                value: currentActiveThemeMode, // KEMBALI: Gunakan currentActiveThemeMode
                items: const [
                  DropdownMenuItem(value: ThemeMode.system, child: Text('Sistem')),
                  DropdownMenuItem(value: ThemeMode.light, child: Text('Terang')),
                  DropdownMenuItem(value: ThemeMode.dark, child: Text('Gelap')),
                ],
                onChanged: (mode) {
                  if (mode != null) {
                    setThemeMode(mode); // KEMBALI: Panggil setThemeMode yang diteruskan
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Akun',
              style: Theme.of(context).textTheme.headline6, // KEMBALI: Akses textTheme.headline6
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () async {
                // KEMBALI: Panggil logout dari UserService langsung
                final userService = UserService(); // Buat instance UserService
                await userService.logoutUser();
                // Navigasi ke LoginScreen setelah logout (hapus semua route sebelumnya)
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen(setThemeMode: setThemeMode)), // KEMBALI: Teruskan setThemeMode
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// PERBAIKAN: Tambahkan extension ini jika Anda menggunakannya (untuk headline6)
extension on TextTheme {
  TextStyle? get headline6 => headlineSmall; // headline6 diganti jadi headlineSmall di Flutter 3.x
}