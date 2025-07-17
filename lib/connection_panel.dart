import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConnectionPanel extends StatefulWidget {
  @override
  _ConnectionPanelState createState() => _ConnectionPanelState();
}

class _ConnectionPanelState extends State<ConnectionPanel> {
  String connectionStatus = "Unknown";
  late Connectivity _connectivity;
  late Stream<List<ConnectivityResult>> _connectivityStream;

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    _connectivityStream = _connectivity.onConnectivityChanged;
    _connectivityStream.listen(_updateConnectionStatus);

    checkCycleValidity();
    getConnectionStatus();
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    setState(() {
      if (result.first == ConnectivityResult.mobile) {
        connectionStatus = "Mobile Data Connected";
      } else if (result.first == ConnectivityResult.wifi) {
        connectionStatus = "WiFi Connected";
      } else {
        connectionStatus = "No Internet Connection";
      }
    });
  }

  Future<void> getConnectionStatus() async {
    List<ConnectivityResult> result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
  }

  Future<void> checkCycleValidity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cycle = prefs.getString("activationCycle");
    String? activationDateStr = prefs.getString("activationDate");

    if (cycle == null || activationDateStr == null) {
      Navigator.pushReplacementNamed(context, '/activation');
      return;
    }

    DateTime activationDate = DateTime.parse(activationDateStr);
    DateTime now = DateTime.now();
    Duration difference = now.difference(activationDate);

    bool isValid = false;
    if (cycle == "Monthly" && difference.inDays < 30) {
      isValid = true;
    } else if (cycle == "Weekly" && difference.inDays < 7) {
      isValid = true;
    } else if (cycle == "Biweekly" && difference.inDays < 14) {
      isValid = true;
    }

    if (!isValid) {
      // Reset Activation
      await prefs.setBool("isActivated", false);
      await prefs.remove("activationCode");
      await prefs.remove("activationDate");
      await prefs.remove("activationCycle");

      Navigator.pushReplacementNamed(context, '/activation');
    }
  }

  void openNetworkSettings() {
    _connectivity.checkConnectivity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Internet Connection Panel")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              connectionStatus.contains("Connected") ? Icons.wifi : Icons.wifi_off,
              size: 100,
              color: connectionStatus.contains("Connected") ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 20),
            Text(
              connectionStatus,
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: openNetworkSettings,
              icon: Icon(Icons.settings),
              label: Text("Open Network Settings"),
            ),
          ],
        ),
      ),
    );
  }
}
