// lib/services/user_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_quiz/models/users.dart'; // PERBAIKAN: Import 'user.dart' (TANPA 'S')
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  // --- BASE URL UNTUK PHP NATIVE ---
  // SESUAIKAN INI DENGAN LOKASI FILE users.php ANDA DI XAMPP
  static const String _baseUrl = 'http://192.168.62.211/quiz_api/users.php'; // Ganti dengan IP PC Anda!
  // ----------------------------------

  // Fungsi untuk menyimpan status login user ke Shared Preferences
  Future<void> _saveUserLoginStatus(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setInt('userId', user.id);
    await prefs.setString('username', user.username);
    await prefs.setString('email', user.email);
    print('User login status saved: ${user.username}');
  }

  // Fungsi untuk menghapus status login user (logout) dari Shared Preferences
  Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus semua data yang tersimpan di SP
    print('User logged out.');
  }

  // Fungsi untuk mengecek status login user dari Shared Preferences
  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  // Fungsi untuk mendapatkan user ID yang sedang login dari Shared Preferences
  Future<int?> getLoggedInUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }
  
  // Fungsi untuk mendapatkan username yang sedang login dari Shared Preferences
  Future<String?> getLoggedInUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  // --- C (Create User) - Registrasi ---
  Future<User?> registerUser(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse(_baseUrl), // Endpoint POST untuk membuat user
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      final newUser = User(
        id: int.parse(responseData['id'].toString()), // PERBAIKAN: Konversi string ID dari PHP ke int
        username: responseData['username'] as String,
        email: responseData['email'] as String,
        createdAt: DateTime.now(), // Fallback karena API create mungkin tidak mengembalikan timestamp
        updatedAt: DateTime.now(), // Fallback
      );
      print('User ${newUser.username} berhasil terdaftar.');
      return newUser;
    } else {
      print('Gagal mendaftar user: ${response.body}');
      return null;
    }
  }

  // --- LOGIN USER ---
  Future<User?> loginUser(String identifier, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl?action=login'), // Endpoint POST untuk login (dengan parameter GET)
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'identifier': identifier,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final userData = responseData['user'] as Map<String, dynamic>;
      final loggedInUser = User(
        id: int.parse(userData['id'].toString()), // ID dari login seharusnya int
        username: userData['username'] as String,
        email: userData['email'] as String,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _saveUserLoginStatus(loggedInUser); // Simpan status login ke SP
      print('User ${loggedInUser.username} berhasil login.');
      return loggedInUser;
    } else {
      print('Gagal login: ${response.body}');
      return null;
    }
  }

  // --- R (Read All Users) ---
  Future<List<User>> getUsers() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((user) => User.fromJson(user as Map<String, dynamic>)).toList();
    } else {
      print('Gagal memuat user: ${response.body}');
      return [];
    }
  }

  // --- R (Read Single User by ID) ---
  Future<User?> getUserById(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl?id=$id'));

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else if (response.statusCode == 404) {
      print('User dengan ID $id tidak ditemukan.');
      return null;
    } else {
      print('Gagal memuat user: ${response.body}');
      return null;
    }
  }

  // --- U (Update User) ---
  Future<bool> updateUser(int id, {String? username, String? email, String? password}) async {
    final Map<String, String> body = {};
    if (username != null) body['username'] = username;
    if (email != null) body['email'] = email;
    if (password != null) body['password'] = password;

    final response = await http.put(
      Uri.parse('$_baseUrl?id=$id'), // ID user sebagai parameter GET
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      print('User dengan ID $id berhasil diupdate.');
      return true;
    } else {
      print('Gagal mengupdate user: ${response.body}');
      return false;
    }
  }

  // --- D (Delete User) ---
  Future<bool> deleteUser(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl?id=$id'));

    if (response.statusCode == 200) {
      print('User dengan ID $id berhasil dihapus.');
      return true;
    } else if (response.statusCode == 404) {
      print('User dengan ID $id tidak ditemukan.');
      return false;
    } else {
      print('Gagal menghapus user: ${response.body}');
      return false;
    }
  }
}