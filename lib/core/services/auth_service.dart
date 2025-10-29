import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
  );

  User? get currentUser => _auth.currentUser;

  // Stream for auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email
  Future<UserModel?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _convertToUserModel(result.user);
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    }
  }

  // Register
  Future<UserModel?> register(String email, String password, String name) async {
    try {
      print('Creating user account...');
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('User account created');
      
      // Update display name
      await result.user?.updateDisplayName(name);
      print('Display name updated');

      // Send email verification
      if (result.user != null) {
        await result.user!.sendEmailVerification();
        print('Verification email sent to ${result.user!.email}');
      }

      return _convertToUserModel(result.user);
    } catch (e) {
      print('❌ Register error: $e');
      rethrow;
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Send password reset error: $e');
      rethrow;
    }
  }

  // Change password with validation
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      // Check if new password is same as current
      if (currentPassword == newPassword) {
        throw Exception('New password must be different from current password');
      }

      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update to new password
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
      print('Change password error: $e');
      rethrow;
    }
  }

  // Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      print('Starting Google Sign In...');

      // Sign out from Google first 
      await _googleSignIn.signOut();
      print('Signed out from previous Google account');

      // Sign in
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('Google sign in cancelled by user');
        return null;
      }

      print('Google user selected: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print('Got Google authentication tokens');

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('Created Firebase credential');

      // Sign in to Firebase with the Google credential
      UserCredential result = await _auth.signInWithCredential(credential);

      print('Signed in to Firebase: ${result.user?.email}');

      return _convertToUserModel(result.user);
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      print('Google sign in error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Sign out from both Firebase and Google
  Future<void> signOut() async {
    try {
      // Sign out concurrently for faster performance
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      print('Signed out successfully from Firebase and Google');
    } catch (e) {
      print('Sign out error (non-critical): $e');
      // Don't rethrow - sign out should always succeed even if Google sign out fails
    }
  }

  // Resend email verification
  Future<void> resendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      print('Resend verification error: $e');
      rethrow;
    }
  }

  // Reload user to check email verification status
  Future<bool> checkEmailVerified() async {
    try {
      await _auth.currentUser?.reload();
      return _auth.currentUser?.emailVerified ?? false;
    } catch (e) {
      print('Check email verified error: $e');
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