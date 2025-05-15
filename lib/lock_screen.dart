import 'package:flutter/material.dart';

class LockScreen extends StatelessWidget {
  final VoidCallback onUnlock;

  const LockScreen({required this.onUnlock, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 100, color: Colors.white),
              SizedBox(height: 30),
              Text(
                'Your activation has expired!',
                style: TextStyle(color: Colors.white, fontSize: 24),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: onUnlock,
                child: Text('Enter New Activation Code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
