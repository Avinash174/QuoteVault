import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
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
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (cred.user != null) {
      await _firestoreService.saveUser(cred.user!);
    }
    return cred;
  }

  Future<void> resetPassword({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
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
    final appleProvider = AppleAuthProvider();
    final cred = await _auth.signInWithProvider(appleProvider);
    if (cred.user != null) {
      await _firestoreService.saveUser(cred.user!);
    }
    return cred;
  }
}
