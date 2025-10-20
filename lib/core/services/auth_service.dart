import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email & password
  Future<UserModel?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _convertToUserModel(result.user);
    } catch (e) {
      print('Sign in error: $e');
      return null;
    }
  }

  // Register with email & password
  Future<UserModel?> register(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name
      await result.user?.updateDisplayName(name);
      
      return _convertToUserModel(result.user);
    } catch (e) {
      print('Register error: $e');
      return null;
    }
  }

    // Sign in with Google
  Future<UserModel?> signInWithGoogle(String accessToken, String idToken) async {
    try {
      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      return _convertToUserModel(result.user);
    } catch (e) {
      print('Google sign in error: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Helper: Convert Firebase User to UserModel
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