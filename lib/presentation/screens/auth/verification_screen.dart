import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import 'login_screen.dart';

class VerificationScreen extends StatefulWidget {
  final String email;

  const VerificationScreen({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Timer? _checkTimer;
  bool _isVerifying = false;
  bool _emailSent = false;

  @override
  void initState() {
    super.initState();
    _sendVerificationEmail();
    _startCheckingVerification();
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }

  // Send verification email
  Future<void> _sendVerificationEmail() async {
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        setState(() {
          _emailSent = true;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Verification email sent! Please check your inbox.'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Check email verification status periodically
  void _startCheckingVerification() {
    _checkTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      User? user = _auth.currentUser;
      await user?.reload();
      user = _auth.currentUser;

      if (user != null && user.emailVerified) {
        timer.cancel();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Email verified successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    });
  }

  // Resend verification email
  Future<void> _resendEmail() async {
    setState(() {
      _isVerifying = true;
    });

    await _sendVerificationEmail();

    setState(() {
      _isVerifying = false;
    });
  }

  // Skip verification (for testing only)
  void _skipVerification() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip Verification?'),
        content: const Text(
          'Your email is not verified. You can verify it later in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () async {
            // Logout and go back to login
            await _auth.signOut();
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              // Logo
              Center(
                child: Container(
                  height: 100,
                  width: 200,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'RECIPE\nDAILY',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Icon
              const Center(
                child: Icon(
                  Icons.email_outlined,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Title
              const Text(
                'Verify your email',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Subtitle
              Text(
                'We sent a verification link to\n${widget.email}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Instructions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, 
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'How to verify:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInstruction('1. Check your email inbox'),
                    _buildInstruction('2. Click the verification link'),
                    _buildInstruction('3. Return to this app'),
                    const SizedBox(height: 8),
                    Text(
                      "Don't see the email? Check spam folder",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Checking status
              if (_emailSent)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, 
                          color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Checking verification status...',
                          style: TextStyle(
                            color: Colors.green[800],
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.green),
                        ),
                      ),
                    ],
                  ),
                ),
              
              const Spacer(),
              
              // Resend Button
              CustomButton(
                text: 'Resend Email',
                onPressed: _resendEmail,
                isLoading: _isVerifying,
                isOutlined: true,
              ),
              
              const SizedBox(height: 12),
              
              // Skip Button (for testing)
              TextButton(
                onPressed: _skipVerification,
                child: Text(
                  'Skip for now',
                  style: TextStyle(
                    color: Colors.grey[600],
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstruction(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 28),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}