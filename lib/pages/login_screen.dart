
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:new_vigilai/pages/signin_page.dart';
import 'package:new_vigilai/pages/signup_page.dart';


class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top Half - Lottie Animation
          Center(
            child: Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                child: Lottie.asset(
                  'assets/login.json',
                  // Make sure the file is in assets folder and declared in pubspec.yaml
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Bottom Half - Buttons
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildButton(
                      context, "Sign In", Color(0xFF515070), Colors.white),
                  const SizedBox(height: 16),
                  _buildButton(
                      context, "Sign Up", Colors.white, Color(0xFF6EA1FF),
                      outlined: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context,
      String text,
      Color bgColor,
      Color textColor, {
        bool outlined = false,
      }) {
     final VoidCallback onPressed = () {
       if (text == "Sign In") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SignInPage()),
        );
      } else if (text == "Sign Up") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SignUpPage()),
        );
      }
    };

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: outlined
          ? OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: textColor, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: onPressed,
        child: Text(text, style: TextStyle(color: textColor, fontSize: 16)),
      )
          : ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: onPressed,
        child: Text(text, style: TextStyle(color: textColor, fontSize: 16)),
      ),
    );
  }
}