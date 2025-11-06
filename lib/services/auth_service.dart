import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum AuthResultType {
  success,
  emailNotVerified,
  userNotFound,
  wrongPassword,
  emailAlreadyInUse,
  weakPassword,
  invalidEmail,
  error,
}

class AuthResult {
  final bool isSuccess;
  final AuthResultType type;
  final String message;
  final User? user;

  AuthResult({
    required this.isSuccess,
    this.type = AuthResultType.success,
    this.message = '',
    this.user,
  });

  factory AuthResult.success({String message = 'Success', User? user}) {
    return AuthResult(isSuccess: true, message: message, user: user);
  }

  factory AuthResult.error(AuthResultType type, String message) {
    return AuthResult(isSuccess: false, type: type, message: message);
  }
}

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get userChanges => _auth.authStateChanges();

  static Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(name);
        await user.sendEmailVerification();
        
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'emailVerified': false,
        });

        return AuthResult.success(
          message: 'Account created! Please verify your email to sign in.',
          user: user,
        );
      }
      return AuthResult.error(AuthResultType.error, 'Failed to create account');
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          return AuthResult.error(AuthResultType.weakPassword, 'Password is too weak');
        case 'email-already-in-use':
          return AuthResult.error(AuthResultType.emailAlreadyInUse, 'Email already in use');
        case 'invalid-email':
          return AuthResult.error(AuthResultType.invalidEmail, 'Invalid email address');
        default:
          return AuthResult.error(AuthResultType.error, e.message ?? 'Sign up failed');
      }
    }
  }

  static Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        await user.reload();
        if (!user.emailVerified) {
          await _auth.signOut();
          return AuthResult.error(
            AuthResultType.emailNotVerified,
            'Please verify your email before signing in',
          );
        }

        await _firestore.collection('users').doc(user.uid).update({
          'emailVerified': true,
          'lastSignIn': FieldValue.serverTimestamp(),
        });

        return AuthResult.success(message: 'Welcome back!', user: user);
      }
      return AuthResult.error(AuthResultType.error, 'Sign in failed');
    } on FirebaseAuthException catch (e) {
      // For invalid-credential, check if user exists to give better error message
      if (e.code == 'invalid-credential') {
        final userExists = await _checkIfUserExists(email);
        if (!userExists) {
          return AuthResult.error(AuthResultType.userNotFound, 'No account found');
        } else {
          return AuthResult.error(AuthResultType.wrongPassword, 'Incorrect password');
        }
      }
      
      switch (e.code) {
        case 'user-not-found':
          return AuthResult.error(AuthResultType.userNotFound, 'No account found');
        case 'wrong-password':
          return AuthResult.error(AuthResultType.wrongPassword, 'Incorrect password');
        case 'invalid-email':
          return AuthResult.error(AuthResultType.invalidEmail, 'Invalid email');
        case 'too-many-requests':
          return AuthResult.error(AuthResultType.error, 'Too many attempts. Try again later');
        default:
          return AuthResult.error(AuthResultType.error, e.message ?? 'Sign in failed');
      }
    }
  }

  static Future<bool> _checkIfUserExists(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  static Future<AuthResult> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult.success(message: 'Password reset email sent!');
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return AuthResult.error(AuthResultType.userNotFound, 'No user found with this email');
        case 'invalid-email':
          return AuthResult.error(AuthResultType.invalidEmail, 'Invalid email address');
        default:
          return AuthResult.error(AuthResultType.error, e.message ?? 'Failed to send reset email');
      }
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }
}
