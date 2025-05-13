import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({Key? key}) : super(key: key);

  @override
  _DevicesPageState createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Map<String, Map<String, dynamic>> _statusCache = {};

  Future<void> _saveCamera() async {
    if (_formKey.currentState!.validate()) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('cameras')
          .add({
        'name': _nameController.text.trim(),
        'url': _urlController.text.trim(),
        'username': _usernameController.text.trim(),
        'password': _passwordController.text.trim(),
        'addedAt': FieldValue.serverTimestamp(),
      });

      _nameController.clear();
      _urlController.clear();
      _usernameController.clear();
      _passwordController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Camera added successfully")),
      );
    }
  }

  Future<bool> _isCameraOnline(String url) async {
    final cacheKey = url;
    final now = DateTime.now();

    if (_statusCache.containsKey(cacheKey)) {
      final cached = _statusCache[cacheKey]!;
      if (now.difference(cached['timestamp']) < Duration(minutes: 1)) {
        return cached['online'];
      }
    }

    bool online = false;
    try {
      final uri = Uri.parse(url);
      final socket = await Socket.connect(uri.host, uri.port == 0 ? 554 : uri.port,
          timeout: Duration(seconds: 2));
      socket.destroy();
      online = true;
    } catch (_) {
      online = false;
    }

    _statusCache[cacheKey] = {
      'online': online,
      'timestamp': now,
    };

    return online;
  }

  Widget _buildCameraCard(String docId, Map<String, dynamic> camera, bool online) {
    return Dismissible(
      key: Key(docId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        color: Colors.red,
        child: Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("Delete Camera"),
            content: Text("Are you sure you want to delete this camera?"),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text("Cancel")),
              TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text("Delete")),
            ],
          ),
        );
      },
      onDismissed: (direction) async {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('cameras')
              .doc(docId)
              .delete();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Camera deleted")),
          );
        }
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: EdgeInsets.all(12),
          leading: CircleAvatar(
            backgroundColor: online ? Colors.green : Colors.red,
            child: Icon(online ? Icons.videocam : Icons.videocam_off, color: Colors.white),
          ),
          title: Text(camera['name'] ?? 'Unnamed', style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(camera['url']),
        ),
      ),
    );
  }


  void _showAddCameraSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 16,
          right: 16,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Add Camera",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Divider(thickness: 1.2),

                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Camera Name'),
                  validator: (value) => value!.isEmpty ? 'Enter a name' : null,
                ),
                TextFormField(
                  controller: _urlController,
                  decoration: InputDecoration(labelText: 'Stream URL'),
                  validator: (value) => value!.isEmpty ? 'Enter a URL' : null,
                ),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: 'Username (optional)'),
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password (optional)'),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await _saveCamera();
                    Navigator.pop(context);
                  },
                  child: Text('Save Camera'),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Color(0xFFE8F9FF),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0xFFE8F9FF),
        title: Text(
          "Devices",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 2,
                color: Colors.black12,
              )
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: uid == null
            ? Center(child: Text("Not logged in"))
            : StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('cameras')
              .orderBy('addedAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator());

            final cameras = snapshot.data!.docs;

            if (cameras.isEmpty) {
              return Center(child: Text("No cameras added yet."));
            }

            return ListView.builder(
              itemCount: cameras.length,
              itemBuilder: (context, index) {
                final camera =
                cameras[index].data() as Map<String, dynamic>;
                return FutureBuilder<bool>(
                  future: _isCameraOnline(camera['url']),
                  builder: (context, statusSnapshot) {
                    final online = statusSnapshot.data ?? false;
                    return _buildCameraCard(
                      cameras[index].id,
                      camera,
                      online,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCameraSheet,
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}

class CameraStreamPage extends StatelessWidget {
  final String url;
  final String name;

  const CameraStreamPage({required this.url, required this.name});

  @override
  Widget build(BuildContext context) {
    // Assuming you're showing an RTSP stream in a widget here.
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Center(
        child: Text("Stream URL: $url"), // Replace with RTSP player widget
      ),
    );
  }
}
