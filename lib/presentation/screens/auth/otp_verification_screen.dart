import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../widgets/common/custom_button.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String userId;
  final String email;

  const OTPVerificationScreen({
    Key? key,
    required this.userId,
    required this.email,
  }) : super(key: key);

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final AuthService _authService = AuthService();
  final List<TextEditingController> _controllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    4,
    (index) => FocusNode(),
  );

  bool _isLoading = false;
  bool _isResending = false;
  int _resendCountdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    _resendCountdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String _getOTP() {
    return _controllers.map((c) => c.text).join();
  }

  // Handle back button to sign out
  Future<void> _handleBackButton() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _verifyOTP() async {
    final otp = _getOTP();

    if (otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter 4-digit code'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _authService.verifyOTP(widget.userId, otp);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email verified successfully!'),
            backgroundColor: AppColors.success,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 500));
        // AuthWrapper will automatically navigate to MainScreen
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        String errorMsg = e.toString().replaceAll('Exception: ', '');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );

        // Clear OTP fields
        for (var controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
      }
    }
  }

  Future<void> _resendOTP() async {
    if (_resendCountdown > 0) return;

    setState(() {
      _isResending = true;
    });

    try {
      await _authService.resendOTP(widget.userId, widget.email);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New code sent to your email'),
            backgroundColor: AppColors.success,
          ),
        );

        _startResendTimer();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _handleBackButton();
        return false; // Prevent default back
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.secondary),
            onPressed: _handleBackButton,
          ),
          title: const Text(
            'Verification Code',
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Logo
                Center(
                  child: Image.asset(
                    'assets/images/logo_text.png',
                    height: 80,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 80,
                        width: 80,
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
                ),

                const SizedBox(height: 32),

                // Title
                const Text(
                  'Check your email',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle with email
                Text(
                  'We\'ve sent the code to\n${widget.email}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.thirdary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // OTP Input Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) {
                    return Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _controllers[index].text.isEmpty
                              ? AppColors.thirdary
                              : AppColors.primary,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.thirdary,
                          ),
                          decoration: const InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) {
                            setState(() {}); // Update border color
                            
                            if (value.isNotEmpty && index < 3) {
                              _focusNodes[index + 1].requestFocus();
                            } else if (value.isEmpty && index > 0) {
                              _focusNodes[index - 1].requestFocus();
                            }

                            // Auto-verify when all 4 digits entered
                            if (index == 3 && value.isNotEmpty) {
                              _verifyOTP();
                            }
                          },
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 24),

                // Resend Code
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Not received a code? ",
                      style: TextStyle(
                        color: AppColors.thirdary,
                        fontSize: 14,
                      ),
                    ),
                    if (_resendCountdown > 0)
                      Text(
                        '($_resendCountdown)',
                        style: const TextStyle(
                          color: AppColors.thirdary,
                          fontSize: 14,
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: _isResending ? null : _resendOTP,
                        child: Text(
                          _isResending ? 'Sending...' : 'Resend',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Continue Button
                CustomButton(
                  text: 'Continue',
                  onPressed: _verifyOTP,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}