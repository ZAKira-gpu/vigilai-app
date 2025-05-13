import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_vigilai/pages/home_page/home_page.dart';
import 'package:new_vigilai/pages/signin_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<bool> signin(BuildContext context, String email, String password) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (!FirebaseAuth.instance.currentUser!.emailVerified) {
      await FirebaseAuth.instance.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please verify your email before signing in.")),
      );
      return false;
    }
    // Save login state
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);


    // Navigate to Home Page on success
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => home()),
    );

    return true; // ✅ Return true on success
  } catch (e) {
    // Handle error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login failed: ${e.toString()}')),
    );
    return false; // ❌ Return false on error

  }
}
Future<bool> signup(BuildContext context, String email, String password, String phone) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);


    // Send email verification
    await userCredential.user?.sendEmailVerification();

    // Do not set isLoggedIn to true yet, since email is not verified
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false); // wait until user verifies email

    return true;
  } on FirebaseAuthException catch (e) {
    print("Signup error: ${e.message}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message ?? 'Signup failed')),
    );
    return false;
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Signup failed: ${e.toString()}')),
    );
    return false;
  }
}
