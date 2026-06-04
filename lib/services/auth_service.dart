import 'package:firebase_auth/firebase_auth.dart';

class AuthResult {
  final User? user;
  final String? errorMessage;
  AuthResult({this.user, this.errorMessage});
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<AuthResult> signUp(String email, String password, String fullName) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await result.user?.updateDisplayName(fullName);
      return AuthResult(user: result.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult(errorMessage: _handleError(e));
    } catch (e) {
      return AuthResult(errorMessage: "An unexpected error occurred.");
    }
  }

  Future<AuthResult> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AuthResult(user: result.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult(errorMessage: _handleError(e));
    } catch (e) {
      return AuthResult(errorMessage: "An unexpected error occurred.");
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<AuthResult> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult();
    } on FirebaseAuthException catch (e) {
      return AuthResult(errorMessage: _handleError(e));
    }
  }

  String _handleError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      default:
        return e.message ?? 'An unknown error occurred.';
    }
  }
}
