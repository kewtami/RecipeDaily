import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import '../config/email_config.dart';

class OTPService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String generateOTP() {
    final random = Random();
    return (1000 + random.nextInt(9000)).toString();
  }

  Future<void> saveOTP({
    required String userId,
    required String otp,
    required String email,
  }) async {
    try {
      await _firestore.collection('otps').doc(userId).set({
        'otp': otp,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': DateTime.now().add(const Duration(minutes: 5)).millisecondsSinceEpoch,
        'verified': false,
      });
    } catch (e) {
      throw Exception('Failed to save verification code');
    }
  }

  Future<void> sendOTPEmail({
    required String email,
    required String otp,
  }) async {
    try {
      // Configure SMTP
      final smtpServer = gmail(
        EmailConfig.senderEmail,
        EmailConfig.senderPassword,
      );

      // Create email message
      final message = Message()
        ..from = Address(EmailConfig.senderEmail, EmailConfig.senderName)
        ..recipients.add(email)
        ..subject = 'Recipe Daily - Email Verification Code'
        ..html = EmailConfig.getOTPEmailBody(otp);

      // Send email
      await send(message, smtpServer);
    } catch (e) {
      throw Exception('Failed to send verification email. Please try again.');
    }
  }

  Future<bool> verifyOTP({
    required String userId,
    required String enteredOTP,
  }) async {
    try {
      final doc = await _firestore.collection('otps').doc(userId).get();
      
      if (!doc.exists) {
        throw Exception('Verification code not found');
      }

      final data = doc.data()!;
      final savedOTP = data['otp'] as String;
      final expiresAt = data['expiresAt'] as int;
      final verified = data['verified'] as bool;

      if (verified) {
        throw Exception('Verification code already used');
      }

      if (DateTime.now().millisecondsSinceEpoch > expiresAt) {
        throw Exception('Verification code expired. Please request a new one');
      }

      if (savedOTP != enteredOTP) {
        throw Exception('Invalid verification code');
      }

      // Mark as verified
      await _firestore.collection('otps').doc(userId).update({
        'verified': true,
        'verifiedAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('users').doc(userId).set({
        'email': data['email'],
        'emailVerified': true,
        'verifiedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resendOTP({
    required String userId,
    required String email,
  }) async {
    final newOTP = generateOTP();
    await saveOTP(userId: userId, otp: newOTP, email: email);
    await sendOTPEmail(email: email, otp: newOTP);
  }

  Future<bool> isUserVerified(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return false;
      return doc.data()?['emailVerified'] == true;
    } catch (e) {
      return false;
    }
  }
}