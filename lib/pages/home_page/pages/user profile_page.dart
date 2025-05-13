import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user;
  String phoneNumber = 'Loading...'; // Default value


  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    await currentUser?.reload(); // Force refresh
    setState(() {
      user = FirebaseAuth.instance.currentUser; // Reloaded user
    });

    if (user != null) {
      // Fetch phone number from Firestore
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      setState(() {
        phoneNumber = snapshot['phone'] ?? 'No Phone Number Set';
      });
    }
  }


  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Password'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Current Password'),
              ),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'New Password'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text('Update'),
            onPressed: () async {
              Navigator.pop(context);
              try {
                final cred = EmailAuthProvider.credential(
                  email: user!.email!,
                  password: currentPasswordController.text,
                );
                await user!.reauthenticateWithCredential(cred);
                await user!.updatePassword(newPasswordController.text);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Password updated successfully')),
                );
              } catch (e) {
                print(e);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to update password')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8F9FF),
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Color(0xFFE8F9FF),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
      ),
      body: user == null
          ? Center(child: CircularProgressIndicator()) // While loading user
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Hero(
                tag: 'profileAvatar',
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade300,
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Card(
            margin: EdgeInsets.symmetric(horizontal: 20),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Phone Number: $phoneNumber", // Display phone number
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Email: ${user!.email ?? 'N/A'}",
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => _showChangePasswordDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              textStyle: TextStyle(fontSize: 18),
            ),
            child: Text('Change Password', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}