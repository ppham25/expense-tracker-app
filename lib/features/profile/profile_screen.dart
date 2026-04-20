import 'package:adv_basic/features/auth/login_screen.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 150),
            SizedBox(height: 16),
            Text('Người dùng chưa đăng nhập', style: TextStyle(fontSize: 25)),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text("Login", style: TextStyle(fontSize: 20)),
            ),
            TextButton(
              onPressed: () {},
              child: Text("Sign Up", style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
