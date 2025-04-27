import 'package:flutter/material.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';
import 'package:new_vigilai/pages/home_page/home_page.dart';
import 'package:new_vigilai/pages/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:new_vigilai/pages/signin_page.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startSplash();
  }

  void _startSplash() async {
    await Future.delayed(Duration(seconds: 4)); // Reduced time for faster startup
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => isLoggedIn ? home() : LoginPage()), // Adjusted logic to go to SignInPage instead of LoginPage
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F6F9), // Softer background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo with subtle fade-in effect
            FadeInAnimation(
              duration: Duration(seconds: 2),
              child: Lottie.asset(
                'assets/Logo.json',
                width: 250,
                height: 250,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),

            // App Title with improved typography and spacing
            Text(
              "VigilAI",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w800,
                color: Color(0xFF3A3A3A),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 15),

            // Optional progress indicator or loading animation
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6EA1FF)),
            ),
          ],
        ),
      ),
    );
  }
}

// FadeInAnimation Widget (For logo animation)
class FadeInAnimation extends StatelessWidget {
  final Widget child;
  final Duration duration;

  FadeInAnimation({required this.child, required this.duration});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: duration,
      child: child,
    );
  }
}
