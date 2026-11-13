import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/logging/app_logger.dart';
import '../domain/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final Future<void> Function(UserModel user)? saveProfile;
  final Future<UserModel?> Function(String uid)? loadProfile;

  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    this.saveProfile,
    this.loadProfile,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserModel> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    User? createdUser;

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      createdUser = credential.user;
      if (createdUser == null) {
        throw AuthException('Registration failed', 'user-null');
      }

      if (displayName != null && displayName.isNotEmpty) {
        await createdUser.updateDisplayName(displayName);
      }

      final userModel = UserModel(
        uid: createdUser.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
      );

      try {
        await _createUserProfile(userModel);
      } catch (_) {
        // Registration should still succeed if cloud storage is temporarily
        // unavailable; the profile is cached locally and synced later.
      }

      return userModel;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // Recover accounts left behind by an earlier interrupted registration.
        final recovered =
            await _recoverExistingAccount(email, password, displayName);
        if (recovered != null) return recovered;
      }

      await _rollbackCreatedUser(createdUser);
      throw AuthException(_getErrorMessage(e.code), e.code);
    } catch (e) {
      await _rollbackCreatedUser(createdUser);
      if (e is AuthException) rethrow;
      throw AuthException('Registration failed: ${e.toString()}', 'unknown');
    }
  }

  Future<UserModel?> _recoverExistingAccount(
    String email,
    String password,
    String? displayName,
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) return null;

      final existingProfile = await getUserProfile(user.uid);
      if (existingProfile != null) return existingProfile;

      final userModel = UserModel(
        uid: user.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
      );

      try {
        await _createUserProfile(userModel);
      } catch (_) {
        // The onboarding step can persist the profile later.
      }

      return userModel;
    } catch (_) {
      return null;
    }
  }

  Future<void> _rollbackCreatedUser(User? user) async {
    if (user == null) return;

    // If profile creation fails after Firebase Auth created the account,
    // remove the orphaned account so the user can register again.
    try {
      await user.delete();
    } catch (_) {
      // Best-effort cleanup only.
    }
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw AuthException('Login failed', 'user-null');
      }

      final userModel = await getUserProfile(user.uid);
      if (userModel != null) {
        return userModel;
      }

      return UserModel(
        uid: user.uid,
        email: user.email ?? email,
        displayName: user.displayName,
        createdAt: DateTime.now(),
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e.code), e.code);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Login failed: ${e.toString()}', 'unknown');
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw AuthException('Logout failed: ${e.toString()}', 'logout-error');
    }
  }

  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e.code), e.code);
    } catch (e) {
      throw AuthException('Password reset failed: ${e.toString()}', 'unknown');
    }
  }

  Future<UserModel> completeProfile({
    required UserModel user,
    required String displayName,
    required int age,
    required String country,
    String? medicalConditions,
  }) async {
    try {
      final authUser = _auth.currentUser;
      if (authUser != null && authUser.displayName != displayName) {
        try {
          await authUser.updateDisplayName(displayName);
        } catch (_) {
          // The profile can still be saved even if the auth name update fails.
        }
      }

      final updatedProfile = user.copyWith(
        displayName: displayName,
        age: age,
        country: country,
        medicalConditions: medicalConditions,
        profileCompleted: true,
      );

      final saver = saveProfile;
      if (saver != null) {
        await saver(updatedProfile);
      } else {
        await _firestore
            .collection('users')
            .doc(updatedProfile.uid)
            .set(updatedProfile.toFirestore(), SetOptions(merge: true));
      }

      return updatedProfile;
    } catch (e) {
      throw AuthException(
        'Failed to save your profile: ${e.toString()}',
        'profile-update-error',
      );
    }
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final loader = loadProfile;
    if (loader != null) {
      try {
        return await loader(uid);
      } catch (e) {
        AppLogger.warning('Custom profile loader failed', tag: 'AUTH', data: e);
        return null;
      }
    }
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      AppLogger.error('Failed to load user profile', tag: 'AUTH', error: e);
      return null;
    }
  }

  Future<void> _createUserProfile(UserModel user) async {
    try {
      final saver = saveProfile;
      if (saver != null) {
        await saver(user);
        return;
      }
      await _firestore.collection('users').doc(user.uid).set(user.toFirestore());
    } catch (e) {
      throw AuthException(
        'Failed to create user profile: ${e.toString()}',
        'profile-create-error',
      );
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please log in or reset your password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'network-request-failed':
        return 'Check your internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}

class AuthException implements Exception {
  final String message;
  final String code;

  AuthException(this.message, this.code);

  @override
  String toString() => 'AuthException($code): $message';
}
