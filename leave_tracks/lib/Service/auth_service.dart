import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final String backendUrl = 'https://leave-tracks-backend.vercel.app/auth'; // Replace with your backend URL

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream for auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final userModel = await _syncWithBackend(user);
        return userModel;
      }
      return null;
    } catch (e) {
      print('Google Sign In Error: $e');
      rethrow;
    }
  }

  // Sign in with Email/Password
  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;

      if (user != null) {
        final userModel = await _syncWithBackend(user);
        return userModel;
      }
      return null;
    } catch (e) {
      print('Email Sign In Error: $e');
      rethrow;
    }
  }

  // Register with Email/Password
  Future<UserModel?> registerWithEmail(String email, String password, String username) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;

      if (user != null) {
        await user.updateDisplayName(username);
        final userModel = await _syncWithBackend(user);
        return userModel;
      }
      return null;
    } catch (e) {
      print('Registration Error: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Sync with backend
  Future<UserModel> _syncWithBackend(User user) async {
    try {
      final response = await http.post(
        Uri.parse('$backendUrl/auth/sync'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'uid': user.uid,
          'username': user.displayName,
          'email': user.email,
          'googleid': user.providerData.any((info) => info.providerId == 'google.com')
              ? user.uid
              : null,
          'avatar_url': user.photoURL,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserModel.fromJson(json.decode(response.body));
      }
      throw Exception('Failed to sync with backend');
    } catch (e) {
      print('Backend Sync Error: $e');
      return UserModel(
        uid: user.uid,
        username: user.displayName,
        email: user.email,
        googleId: user.providerData.any((info) => info.providerId == 'google.com')
            ? user.uid
            : null,
        avatarUrl: user.photoURL,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }
}