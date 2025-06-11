import 'package:flutter/material.dart';
import 'package:my_quiz/models/users.dart';
import 'package:provider/provider.dart';
import 'package:my_quiz/providers/user_provider.dart';

class UserCrudScreen extends StatefulWidget {
  const UserCrudScreen({super.key});

  @override
  State<UserCrudScreen> createState() => _UserCrudScreenState();
}

class _UserCrudScreenState extends State<UserCrudScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _updateUserIdController = TextEditingController();
  final _updateUsernameController = TextEditingController();
  final _updateEmailController = TextEditingController();

  User? _selectedUserForUpdate;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _updateUserIdController.dispose();
    _updateUsernameController.dispose();
    _updateEmailController.dispose();
    super.dispose();
  }

  Future<void> _createUser() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final success = await userProvider.register(
      _usernameController.text,
      _emailController.text,
      _passwordController.text,
    );
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User ${userProvider.loggedInUser?.username ?? ''} created successfully!')),
      );
      _usernameController.clear();
      _emailController.clear();
      _passwordController.clear();
      setState(() {}); // Refresh UI
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create user. (Username/Email mungkin sudah terdaftar)')),
      );
    }
  }

  Future<void> _updateUser() async {
    if (_selectedUserForUpdate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a user to update.')),
      );
      return;
    }
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final success = await userProvider.updateProfile(
      _selectedUserForUpdate!.id,
      username: _updateUsernameController.text.isNotEmpty
          ? _updateUsernameController.text
          : null,
      email: _updateEmailController.text.isNotEmpty
          ? _updateEmailController.text
          : null,
    );
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User ${_selectedUserForUpdate!.username} updated successfully!')),
      );
      _updateUsernameController.clear();
      _updateEmailController.clear();
      setState(() {
        _selectedUserForUpdate = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update user.')),
      );
    }
  }

  Future<void> _deleteUser(int id, String username) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Anda yakin ingin menghapus user "$username"?'),
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
          SnackBar(content: Text('User "$username" berhasil dihapus!')),
        );
        setState(() {}); // Refresh UI
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus user "$username".')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD User (MySQL)'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Buat User Baru',
                          style: Theme.of(context).textTheme.titleLarge),
                      TextField(
                          controller: _usernameController,
                          decoration: const InputDecoration(labelText: 'Username')),
                      TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email')),
                      TextField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                            labelText: 'Password',
                            suffixIcon: Icon(Icons.visibility_off)),
                        obscureText: true,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                          onPressed: _createUser, child: const Text('Tambah User')),
                    ],
                  ),
                ),
              ),
              Text('Daftar User', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              FutureBuilder<List<User>>(
                future: userProvider.getUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Belum ada user.'));
                  } else {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final user = snapshot.data![index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            title: Text(user.username),
                            subtitle: Text(user.email),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    setState(() {
                                      _selectedUserForUpdate = user;
                                      _updateUserIdController.text = user.id.toString();
                                      _updateUsernameController.text = user.username;
                                      _updateEmailController.text = user.email;
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteUser(user.id, user.username),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              if (_selectedUserForUpdate != null)
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Update User: ${_selectedUserForUpdate!.username}',
                            style: Theme.of(context).textTheme.titleLarge),
                        TextField(
                          controller: _updateUserIdController,
                          decoration: const InputDecoration(labelText: 'User ID'),
                          readOnly: true,
                        ),
                        TextField(
                            controller: _updateUsernameController,
                            decoration:
                                const InputDecoration(labelText: 'New Username')),
                        TextField(
                            controller: _updateEmailController,
                            decoration: const InputDecoration(labelText: 'New Email')),
                        const SizedBox(height: 10),
                        ElevatedButton(
                            onPressed: _updateUser, child: const Text('Update User')),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedUserForUpdate = null;
                              _updateUsernameController.clear();
                              _updateEmailController.clear();
                            });
                          },
                          child: const Text('Batal Update'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() {}),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}