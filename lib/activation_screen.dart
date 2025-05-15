// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'database_helper.dart';

// class ActivationScreen extends StatefulWidget {
//   @override
//   _ActivationScreenState createState() => _ActivationScreenState();
// }

// class _ActivationScreenState extends State<ActivationScreen> {
//   final TextEditingController _codeController = TextEditingController();
//   String _selectedCycle = 'Monthly';
//   String _message = "";

//   List<String> cycles = ['Monthly', 'Weekly', 'Biweekly'];

//   Future<void> activateDevice() async {
//     String code = _codeController.text.trim();
//     if (code.isEmpty) {
//       setState(() {
//         _message = "Please enter a valid code.";
//       });
//       return;
//     }

//     bool isValid = await DatabaseHelper().checkCodeExists(code);
//     if (isValid) {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setBool("isActivated", true);
//       await prefs.setString("activationCode", code);
//       await prefs.setString("activationCycle", _selectedCycle);
//       await prefs.setString("activationDate", DateTime.now().toIso8601String());

//       setState(() {
//         _message = "Device activated successfully!";
//       });

//       Navigator.pushReplacementNamed(context, '/');
//     } else {
//       setState(() {
//         _message = "Invalid activation code.";
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Activate Device")),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text("Enter Activation Code", style: TextStyle(fontSize: 18)),
//             SizedBox(height: 15),
//             TextField(
//               controller: _codeController,
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(),
//                 hintText: "Activation Code",
//               ),
//             ),
//             SizedBox(height: 20),
//             DropdownButtonFormField<String>(
//               value: _selectedCycle,
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(),
//                 labelText: "Select Cycle",
//               ),
//               onChanged: (value) {
//                 setState(() {
//                   _selectedCycle = value!;
//                 });
//               },
//               items: cycles.map((cycle) {
//                 return DropdownMenuItem(
//                   value: cycle,
//                   child: Text(cycle),
//                 );
//               }).toList(),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: activateDevice,
//               child: Text("Activate"),
//             ),
//             SizedBox(height: 20),
//             Text(_message, style: TextStyle(color: Colors.red)),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admin_login_screen.dart';
import 'database_helper.dart';
import 'connection_panel.dart'; // for internet panel if needed

class ActivationScreen extends StatefulWidget {
  @override
  _ActivationScreenState createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  static const platform = MethodChannel("device_admin");
  final TextEditingController _codeController = TextEditingController();
  String _message = "";
  bool isActivated = false;
  int _tapCounter = 0;
  DateTime _firstTapTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    enableKioskMode();
    checkActivationStatus();
  }

  Future<void> enableKioskMode() async {
    try {
      await platform.invokeMethod("enableKioskMode");
    } catch (e) {
      print("Error enabling Kiosk Mode: $e");
    }
  }

  Future<void> checkActivationStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isActivated = prefs.getBool("isActivated") ?? false;
    });
  }

  Future<void> checkActivationCode() async {
    bool exists = await DatabaseHelper().checkCodeExists(_codeController.text);
    if (exists) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool("isActivated", true);

      setState(() {
        _message = "Activation Successful! Exiting Kiosk Mode...";
        isActivated = true;
      });

      await platform.invokeMethod("disableKioskMode");
    } else {
      setState(() {
        _message = "Invalid Code. Try Again!";
      });
    }
  }

  void _handleSecretTap() {
    DateTime now = DateTime.now();
    if (now.difference(_firstTapTime).inSeconds > 3) {
      // Reset counter if taps are slow
      _tapCounter = 0;
    }

    _firstTapTime = now;
    _tapCounter++;

    if (_tapCounter >= 5) {
      // Success after 5 quick taps
      _tapCounter = 0;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AdminLoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _handleSecretTap,
          child: Text("Affrikia App"),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: isActivated
            ? Center(child: Text("Device is activated."))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Enter Activation Code:", style: TextStyle(fontSize: 18)),
                  SizedBox(height: 20),
                  TextField(
                    controller: _codeController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter Code",
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: checkActivationCode,
                    child: Text("Submit"),
                  ),
                  SizedBox(height: 20),
                  Text(_message, style: TextStyle(color: Colors.red)),
                ],
              ),
      ),
    );
  }
}
