import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/auth_service.dart';
import 'login_screen.dart';
import 'otp_verification_screen.dart';
import '../main/main_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();

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

        // No user → Login Screen
        if (user == null) {
          return const LoginScreen();
        }

        // User is logged in → Check verification
        final isEmailUser = user.providerData.any(
          (provider) => provider.providerId == 'password'
        );

        // Email users → Check verification
        if (isEmailUser) {
          return FutureBuilder<bool>(
            future: _authService.isUserVerified(user.uid),
            builder: (context, verifySnapshot) {
              if (verifySnapshot.connectionState == ConnectionState.waiting) {
                return const _LoadingScreen();
              }

              final isVerified = verifySnapshot.data ?? false;

              if (!isVerified) {
                // Not verified → OTP Screen
                return OTPVerificationScreen(
                  userId: user.uid,
                  email: user.email ?? '',
                );
              }

              // Verified → Main Screen
              return const MainScreen();
            },
          );
        }

        // Google users → Main Screen
        return const MainScreen();
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo_text.png',
              height: 80,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    size: 40,
                    color: Colors.white,
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}