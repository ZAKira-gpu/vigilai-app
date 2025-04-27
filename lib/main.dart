import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:new_vigilai/pages/home_page/home_page.dart';
import 'package:new_vigilai/pages/home_page/pages/about_page.dart';
import 'package:new_vigilai/pages/signin_page.dart';
import 'package:new_vigilai/pages/signup_page.dart';
import 'package:new_vigilai/pages/splash_screen.dart';
import 'package:new_vigilai/pages/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp()); // <--- no need to check login here
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Always start from splash
      routes: {
        '/': (context) => SplashScreen(), // Splash first
        '/loging': (context) => LoginPage(),
        '/signin': (context) => SignInPage(),
        '/signup': (context) => SignUpPage(),
        '/home': (context) => home(),
        '/about': (context) => about(),
      },
    );
  }
}
