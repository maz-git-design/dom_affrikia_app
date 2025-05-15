import 'package:flutter/material.dart';

class AdminAuthScreen extends StatelessWidget {
  const AdminAuthScreen({super.key});
  static const routeName = '/admin-auth-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Admin Authentication Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
