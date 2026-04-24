import 'package:adv_basic/features/auth/login_screen.dart';
import 'package:adv_basic/features/auth/models/user.dart';
import 'package:adv_basic/features/auth/regis_screen.dart';
import 'package:adv_basic/features/auth/services/auth_service.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = await _authService.getToken();

      if (token == null) {
        if (!mounted) return;
        setState(() {
          _user = null;
        });
        return;
      }

      final user = await _authService.getMe(token);

      if (!mounted) return;
      setState(() {
        _user = user;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _user = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load profile: ${error.toString()}")),
      );
    } finally {
      // ignore: control_flow_in_finally
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await _authService.clearToken();

    if (!mounted) return;
    setState(() {
      _user = null;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã đăng xuất')));
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_isLoading) {
      content = const CircularProgressIndicator();
    } else if (_user == null) {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.person, size: 150),
          const SizedBox(height: 16),
          const Text(
            'Người dùng chưa đăng nhập',
            style: TextStyle(fontSize: 25),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              ).then((_) => _loadProfile());
            },
            child: const Text("Login", style: TextStyle(fontSize: 20)),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterScreen()),
              );
            },
            child: const Text("Sign Up", style: TextStyle(fontSize: 20)),
          ),
        ],
      );
    } else {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.person, size: 150),
          const SizedBox(height: 16),
          Text(
            _user!.name,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(_user!.email, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _logout, child: const Text('Logout')),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(child: content),
    );
  }
}
