import 'package:flutter/material.dart';

class alertsPage extends StatelessWidget {
  const alertsPage({Key? key}) : super(key: key);

  // Mock alert data
  final List<Map<String, dynamic>> alerts = const [
    {
      "time": "Today • 8:45 PM",
      "camera": "Front Door",
      "type": "Person detected",
      "thumbnail": Icons.person,
      "severity": "High"
    },
    {
      "time": "Today • 7:10 PM",
      "camera": "Garage",
      "type": "Motion detected",
      "thumbnail": Icons.directions_car,
      "severity": "Medium"
    },
    {
      "time": "Yesterday • 11:15 PM",
      "camera": "Backyard",
      "type": "Unknown object",
      "thumbnail": Icons.help_outline,
      "severity": "Low"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F9FF),
      appBar: AppBar(
        title: const Text("Alerts"),
        backgroundColor: const Color(0xFFE8F9FF),
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          final alert = alerts[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.indigo.shade100,
                child: Icon(alert["thumbnail"], color: Colors.indigo),
              ),
              title: Text(alert["type"], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${alert["camera"]} • ${alert["time"]}"),
              trailing: Chip(
                label: Text(alert["severity"]),
                backgroundColor: _severityColor(alert["severity"]),
              ),
              onTap: () {
                // Navigate to alert details or show modal
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Viewing ${alert["type"]}")),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // Helper for severity chip color
  Color _severityColor(String severity) {
    switch (severity) {
      case "High":
        return Colors.redAccent.withOpacity(0.2);
      case "Medium":
        return Colors.orange.withOpacity(0.2);
      case "Low":
      default:
        return Colors.green.withOpacity(0.2);
    }
  }
}
