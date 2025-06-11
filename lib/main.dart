import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_quiz/firebase_options.dart';
import 'package:my_quiz/screens/quiz_screen.dart';
import 'package:my_quiz/screens/login_screen.dart';
import 'package:my_quiz/providers/theme_provider.dart';
import 'package:my_quiz/providers/user_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Aplikasi Kuis',
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
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
              cardTheme: CardThemeData(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 5,
              ),
            ),
            darkTheme: ThemeData(
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
              cardTheme: CardThemeData(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 5,
                color: Colors.grey[850],
              ),
            ),
            home: Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                if (userProvider.isLoadingAuth) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(color: Colors.deepPurple),
                    ),
                  );
                }
                return userProvider.isLoggedIn
                    ?  QuizScreen(setThemeMode: (ThemeMode ) {  },)
                    :  LoginScreen(setThemeMode: (ThemeMode ) {  },);
              },
            ),
          );
        },
      ),
    );
  }
}