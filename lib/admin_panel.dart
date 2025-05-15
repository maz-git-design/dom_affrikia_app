import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminPanel extends StatefulWidget {
  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final TextEditingController _adminCodeController = TextEditingController();
  bool isUnlocked = false;
  String currentCycle = "Unknown";
  final String realAdminCode = "123456"; // Change this to your secret Admin Code

  @override
  void initState() {
    super.initState();
    fetchCurrentCycle();
  }

  Future<void> fetchCurrentCycle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentCycle = prefs.getString("activationCycle") ?? "Unknown";
    });
  }

  Future<void> unlockAdminPanel() async {
    if (_adminCodeController.text == realAdminCode) {
      setState(() {
        isUnlocked = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid Admin Code!")),
      );
    }
  }

  Future<void> changeCycle(String newCycle) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("activationCycle", newCycle);
    await prefs.setString("activationDate", DateTime.now().toIso8601String());
    setState(() {
      currentCycle = newCycle;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Cycle changed to $newCycle")),
    );
  }

  Future<void> unlockDevice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isActivated", true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Device manually unlocked!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Panel")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: isUnlocked
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Current Cycle: $currentCycle", style: TextStyle(fontSize: 20)),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => changeCycle("Monthly"),
                    child: Text("Change to Monthly"),
                  ),
                  ElevatedButton(
                    onPressed: () => changeCycle("Weekly"),
                    child: Text("Change to Weekly"),
                  ),
                  ElevatedButton(
                    onPressed: () => changeCycle("Biweekly"),
                    child: Text("Change to Biweekly"),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: unlockDevice,
                    child: Text("Manually Unlock Device"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Enter Admin Code:", style: TextStyle(fontSize: 18)),
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
                    onPressed: unlockAdminPanel,
                    child: Text("Unlock Admin Panel"),
                  ),
                ],
              ),
      ),
    );
  }
}
