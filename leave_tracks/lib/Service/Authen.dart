import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        return {
          'email': user.email,
          'displayName': user.displayName,
          'firebaseUid': user.uid,
          'authProvider': 'google',
          'photoURL': user.photoURL,
          'phoneNumber': user.phoneNumber,
          'isEmailVerified': user.emailVerified,
        };
      }
    } catch (e) {
      print('Error during Google sign in: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> signUp(
      String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = userCredential.user;
      if (user != null) {
        return {
          'email': user.email,
          'displayName': user.displayName,
          'firebaseUid': user.uid,
          'authProvider': 'email',
          'isEmailVerified': user.emailVerified,
        };
      }
    } catch (e) {
      print('Error during sign up: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> signIn(
      String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = userCredential.user;
      if (user != null) {
        return {
          'email': user.email,
          'displayName': user.displayName,
          'firebaseUid': user.uid,
          'authProvider': 'email',
          'isEmailVerified': user.emailVerified,
        };
      }
    } catch (e) {
      print('Error during sign in: $e');
    }
    return null;
  }

  static Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
