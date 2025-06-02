import 'package:flutter/material.dart';
import '../globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../globals.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String vanityName = "";
  List<String> files = [];
  int usedSpaceMB = 0;
  int totalSpaceMB = 1000;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    //_loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final response = await http.get(
      Uri.parse("$serverAddress/accounts/dashboard"),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': globals.sessionCookie,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        vanityName = data['vanity_name'];
        files = List<String>.from(data['files']);
        usedSpaceMB = data['used_space_mb'];
        totalSpaceMB = data['total_space_mb'];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, $vanityName",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildStorageRing(),
                const SizedBox(width: 24),
                Expanded(child: _buildFileList()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Your Files:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        ...files.map((file) => ListTile(title: Text(file))),
      ],
    );
  }

  Widget _buildStorageRing() {
    double percent = usedSpaceMB / totalSpaceMB;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: CircularProgressIndicator(
                value: percent,
                strokeWidth: 10,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                    percent > 0.8 ? Colors.red : Colors.blue),
              ),
            ),
            Text("${usedSpaceMB}MB\nof ${totalSpaceMB}MB", textAlign: TextAlign.center),
          ],
        ),
        const SizedBox(height: 8),
        Text("${(percent * 100).toStringAsFixed(1)}% used"),
      ],
    );
  }
}
