import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'main_dashboard.dart';
import 'package:adoption_ui_app/theme/color.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  Duration get loadingTime => const Duration(milliseconds: 500);
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const timeoutDuration = Duration(seconds: 30);

  bool _validateEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _validatePassword(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    if (!password.contains(RegExp(r'[!@#\\$%^&*(),.?":{}|<>]'))) return false;
    return true;
  }

  Future<String?> _authUser(LoginData data) async {
    if (!_validateEmail(data.name)) {
      return 'Please enter a valid email address';
    }
    if (!_validatePassword(data.password)) {
      return 'Password must contain at least 8 characters, including uppercase, lowercase, number, and special character';
    }

    try {
      await _auth
          .signInWithEmailAndPassword(email: data.name, password: data.password)
          .timeout(timeoutDuration);

      return null; // Login successful
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found for that email';
        case 'wrong-password':
          return 'Incorrect password';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        default:
          return 'Login failed: ${e.message}';
      }
    } on TimeoutException {
      return 'Login timed out. Please check your internet connection and try again.';
    } catch (e) {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  Future<String?> _signUpUser(SignupData data) async {
    if (!_validateEmail(data.name!)) {
      return 'Please enter a valid email address';
    }
    if (!_validatePassword(data.password!)) {
      return 'Password must contain at least 8 characters, including uppercase, lowercase, number, and special character';
    }

    try {
      await _auth
          .createUserWithEmailAndPassword(
            email: data.name!,
            password: data.password!,
          )
          .timeout(timeoutDuration);

      return null; // Signup successful
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'An account already exists with this email';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        default:
          return 'Signup failed: ${e.message}';
      }
    } on TimeoutException {
      return 'Signup timed out. Please check your internet connection and try again.';
    } catch (e) {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  Future<String?> _recoverPassword(String email) async {
    if (!_validateEmail(email)) {
      return 'Please enter a valid email address';
    }

    try {
      await _auth.sendPasswordResetEmail(email: email).timeout(timeoutDuration);

      return null; // Password reset email sent
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No account found with this email';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        default:
          return 'Error: ${e.message}';
      }
    } on TimeoutException {
      return 'Password recovery timed out. Please check your internet connection and try again.';
    } catch (e) {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterLogin(
        onLogin: _authUser,
        onSignup: _signUpUser,
        onRecoverPassword: _recoverPassword,
        title: 'PawGuard',
        theme: LoginTheme(
          primaryColor:
              AppColor
                  .secondary, // Changed from primary to secondary to match Page1
          accentColor: AppColor.secondary, // Kept as secondary
          errorColor: Colors.redAccent,
          pageColorLight: AppColor.appBgColor,
          pageColorDark: AppColor.darker,
          titleStyle: const TextStyle(
            color:
                AppColor
                    .mainColor, // Changed from textColor to mainColor to match Page1
            fontSize: 26, // Increased to match Page1's text size
            fontWeight: FontWeight.w800, // Changed to match Page1's font weight
          ),
          cardTheme: const CardTheme(color: AppColor.cardColor, elevation: 8),
          bodyStyle: const TextStyle(
            fontSize: 16,
            color:
                AppColor
                    .labelColor, // Changed from textColor to labelColor to match Page1
          ),
          textFieldStyle: const TextStyle(
            color: AppColor.mainColor, // Changed from textColor to mainColor
          ),
          buttonStyle: const TextStyle(
            color:
                AppColor
                    .cardColor, // Changed from primary to cardColor to match Page1's button text
          ),
          buttonTheme: LoginButtonTheme(
            backgroundColor: AppColor.secondary,
            highlightColor: AppColor.secondary.withOpacity(
              0.15,
            ), // Changed to match Page1's style
            elevation: 0, // Changed to match Page1's button elevation
          ),
        ),
        
        onSubmitAnimationCompleted: () {
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder:
                    (context, animation, secondaryAnimation) => MainDashboard(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 500),
              ),
            );
          }
        },
      ),
    );
  }
}
