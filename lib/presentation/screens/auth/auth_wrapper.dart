import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import 'login_screen.dart';
import 'verification_screen.dart';
import '../main/main_screen.dart'; 

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        // Get current user
        final user = snapshot.data;

        // No user logged in
        if (user == null) {
          print('Auth: No user logged in → LoginScreen');
          return const LoginScreen();
        }

        // User logged in but email not verified 
        if (!user.emailVerified) {
          print('Auth: User ${user.email} not verified → VerificationScreen');
          return VerificationScreen(email: user.email ?? '');
        }

        // User logged in and verified
        print('Auth: User ${user.email} verified → MainScreen');
        return const MainScreen();
      },
    );
  }
}

/// Loading screen shown while checking auth state
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo or Icon
            Icon(
              Icons.restaurant,
              size: 80,
              color: AppColors.primary,
            ),
            SizedBox(height: 24),
            Text(
              'Recipe Daily',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}