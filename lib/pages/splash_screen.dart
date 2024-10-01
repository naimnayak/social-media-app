import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ganpatibapa/authentication/signup_page.dart';
import 'package:ganpatibapa/pages/home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Wait for the splash screen animation to finish (2.5 seconds)
    await Future.delayed(const Duration(seconds: 2, milliseconds: 500));

    // Check login status from SharedPreferences and FirebaseAuth
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    User? user = FirebaseAuth.instance.currentUser;

    if (user == null || !isLoggedIn) {
      // Navigate to signup screen if not logged in
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const SignUpScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(seconds: 3),
        ),
      );
    } else {
      // Navigate to home screen if logged in
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff060720),
      body: Center(
        child: Hero(
          tag: "bappa",
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Image.asset('assets/Bappa-removebg-preview.png'),
          ),
        ),
      ),
    );
  }
}
