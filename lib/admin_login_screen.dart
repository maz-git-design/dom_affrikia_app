import 'package:flutter/material.dart';
import 'admin_panel.dart'; // After successful login, navigate here.

class AdminLoginScreen extends StatefulWidget {
  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _adminCodeController = TextEditingController();
  final String realAdminCode = "123456"; // You can change this secret code

  void _checkAdminCode() {
    if (_adminCodeController.text == realAdminCode) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminPanel()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Incorrect Admin Code!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Login')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Enter Admin Code to Continue", style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            TextField(
              controller: _adminCodeController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Admin Code",
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkAdminCode,
              child: Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
