import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import 'otp_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
  );
  final OTPService _otpService = OTPService();

  User? get currentUser => _auth.currentUser;
  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

// Sign In with Email & Password
  Future<UserModel?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _convertToUserModel(result.user);
      } catch (e) {
      rethrow;
    }
  }

  // Register with Email & Password
  Future<UserModel?> register(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await result.user?.updateDisplayName(name);

      // Generate and send OTP
      if (result.user != null) {
        final otp = _otpService.generateOTP();
        
        await _otpService.saveOTP(
          userId: result.user!.uid,
          otp: otp,
          email: email,
        );
        
        await _otpService.sendOTPEmail(email: email, otp: otp);
      }

      return _convertToUserModel(result.user);
    } catch (e) {
      rethrow;
    }
  }

  // Verify OTP
  Future<bool> verifyOTP(String userId, String otp) async {
    return await _otpService.verifyOTP(userId: userId, enteredOTP: otp);
  }

  // Resend OTP
  Future<void> resendOTP(String userId, String email) async {
    await _otpService.resendOTP(userId: userId, email: email);
  }

  // Check if user is verified
  Future<bool> isUserVerified(String userId) async {
    return await _otpService.isUserVerified(userId);
  }

  // Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  // Change Password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      if (currentPassword == newPassword) {
        throw Exception('New password must be different from current password');
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw Exception('Current password is incorrect');
      } else if (e.code == 'weak-password') {
        throw Exception('New password is too weak. Please use at least 6 characters');
      } else {
        throw Exception(e.message ?? 'Failed to change password');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Sign In with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      return _convertToUserModel(result.user);
    } catch (e) {
      rethrow;
    }
  }

  // Sign Up with Google
  Future<UserModel?> signUpWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      
      final isNewUser = result.additionalUserInfo?.isNewUser ?? false;
      
      if (!isNewUser) {
        await _auth.signOut();
        await _googleSignIn.signOut();
        
        throw FirebaseAuthException(
          code: 'account-exists',
          message: 'This email is already registered. Please use Login instead.',
        );
      }
      
      return _convertToUserModel(result.user);
    } catch (e) {
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      // Ignore errors, force sign out
    }
  }

  // Resend Email Verification
  Future<void> resendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      rethrow;
    }
  }

  // Check Email Verified
  Future<bool> checkEmailVerified() async {
    try {
      await _auth.currentUser?.reload();
      return _auth.currentUser?.emailVerified ?? false;
    } catch (e) {
      return false;
    }
  }

  // Convert Firebase User to UserModel
  UserModel? _convertToUserModel(User? user) {
    if (user == null) return null;
    return UserModel(
      id: user.uid,
      email: user.email!,
      displayName: user.displayName,
      photoURL: user.photoURL,
    );
  }
}