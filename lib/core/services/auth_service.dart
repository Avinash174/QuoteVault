import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer' as developer;
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // ---------------------------------------------------------------------------
  // GETTERS
  // ---------------------------------------------------------------------------

  User? get currentUser => _auth.currentUser;

  Stream<User?> get onAuthStateChange => _auth.authStateChanges();

  // ---------------------------------------------------------------------------
  // EMAIL AUTH
  // ---------------------------------------------------------------------------

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    developer.log('Attempting sign up: $email', name: 'ThoughtVault.Auth');
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    developer.log(
      'User signed up: ${cred.user?.email}',
      name: 'ThoughtVault.Auth',
    );
    if (cred.user != null) {
      await _firestoreService.saveUser(cred.user!);
    }
    return cred;
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    developer.log('Attempting sign in: $email', name: 'ThoughtVault.Auth');
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    developer.log(
      'User signed in: ${cred.user?.email}',
      name: 'ThoughtVault.Auth',
    );
    if (cred.user != null) {
      await _firestoreService.saveUser(cred.user!);
    }
    return cred;
  }

  Future<void> resetPassword({required String email}) async {
    developer.log('Resetting password for: $email', name: 'ThoughtVault.Auth');
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    developer.log('User signing out', name: 'ThoughtVault.Auth');
    try {
      await GoogleSignIn().signOut();
    } catch (e) {
      // Ignore if google sign in wasn't used or fails
      developer.log(
        'Google sign out silent error: $e',
        name: 'ThoughtVault.Auth',
      );
    }
    await _auth.signOut();
  }

  // ---------------------------------------------------------------------------
  // GOOGLE SIGN-IN
  // ---------------------------------------------------------------------------

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in flow
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final cred = await _auth.signInWithCredential(credential);
      if (cred.user != null) {
        await _firestoreService.saveUser(cred.user!);
      }
      return cred;
    } catch (e) {
      developer.log(
        'Google Sign-In failed',
        name: 'ThoughtVault.Auth',
        error: e,
      );
      throw FirebaseAuthException(
        code: 'google-sign-in-failed',
        message: 'Google Sign-In failed: $e',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // APPLE SIGN-IN
  // ---------------------------------------------------------------------------

  Future<UserCredential> signInWithApple() async {
    // Apple Sign In is simpler with Firebase Auth on iOS, usually handled via
    // OAuthProvider('apple.com'). But for now, let's leave a placeholder or basic implementation
    // if using sign_in_with_apple package alongside firebase.
    // Simplifying to standard provider flow for now, or throw unimplemented if not critical.
    // Given the previous code used sign_in_with_apple manually, let's use the AppleAuthProvider if on iOS.

    // NOTE: This requires 'sign_in_with_apple' package for raw nonce generation usually,
    // but Firebase has a wrapper. For simplicity in this migration step, I'll use the
    // standard AppleAuthProvider flow which works with 'firebase_ui_auth' or manual creds.

    // Assuming simple flow:
    developer.log('Starting Apple Sign-In', name: 'ThoughtVault.Auth');
    final appleProvider = AppleAuthProvider();
    final cred = await _auth.signInWithProvider(appleProvider);
    developer.log(
      'Apple Sign-In successful: ${cred.user?.uid}',
      name: 'ThoughtVault.Auth',
    );
    if (cred.user != null) {
      await _firestoreService.saveUser(cred.user!);
    }
    return cred;
  }
}
