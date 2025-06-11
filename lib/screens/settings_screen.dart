import 'package:flutter/material.dart';
import 'package:my_quiz/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:my_quiz/providers/theme_provider.dart';
import 'package:my_quiz/providers/user_provider.dart';

class SettingsScreen extends StatelessWidget {
  final Function(ThemeMode) setThemeMode;
  const SettingsScreen({super.key, required this.setThemeMode});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
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
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            ListTile(
              title: const Text('Tema'),
              trailing: DropdownButton<ThemeMode>(
                value: themeProvider.themeMode,
                items: const [
                  DropdownMenuItem(value: ThemeMode.system, child: Text('Sistem')),
                  DropdownMenuItem(value: ThemeMode.light, child: Text('Terang')),
                  DropdownMenuItem(value: ThemeMode.dark, child: Text('Gelap')),
                ],
                onChanged: (mode) {
                  if (mode != null) {
                    Provider.of<ThemeProvider>(context, listen: false)
                        .setThemeMode(mode);
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Akun',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () async {
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                await userProvider.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) =>  LoginScreen(setThemeMode: (ThemeMode p1) {  },)),
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