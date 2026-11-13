import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/auth_repository.dart';
import '../domain/user_model.dart';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
  loading,
}

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthProvider(this._authRepository) {
    _init();
  }

  AuthStatus _status = AuthStatus.unknown;
  UserModel? _user;
  String? _errorMessage;
  bool _isLoading = false;
  bool _authActionInProgress = false;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isProfileComplete => _user?.profileCompleted ?? false;

  Stream<User?> get authStateChanges => _authRepository.authStateChanges;

  UserModel? _authUserFallback({String? uid}) {
    final authUser = _authRepository.currentUser;
    if (authUser == null) return null;
    if (uid != null && authUser.uid != uid) return null;

    return UserModel(
      uid: authUser.uid,
      email: authUser.email ?? '',
      displayName: authUser.displayName,
      createdAt: DateTime.now(),
    );
  }

  void _init() {
    _authRepository.authStateChanges.listen((user) {
      if (_authActionInProgress) return;

      if (user != null) {
        _loadUserProfile(user.uid);
      } else {
        _status = AuthStatus.unauthenticated;
        _user = null;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserProfile(String uid) async {
    try {
      _setLoading(true);
      final remoteProfile = await _authRepository.getUserProfile(uid);
      final resolvedProfile =
          remoteProfile ?? _authUserFallback(uid: uid) ?? _user;

      // Never replace a completed profile with a stale/incomplete read.
      if (_user?.profileCompleted == true &&
          resolvedProfile?.profileCompleted != true) {
        _setLoading(false);
        return;
      }

      _user = resolvedProfile;
      _status = AuthStatus.authenticated;
      _setLoading(false);
    } catch (e) {
      if (_user == null) {
        _user = _authUserFallback(uid: uid);
        _status = AuthStatus.authenticated;
      }
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _authActionInProgress = true;
    try {
      _setLoading(true);
      _clearError();

      final userModel = await _authRepository.register(
        email: email,
        password: password,
        displayName: displayName,
      );

      _user = userModel;
      _status = AuthStatus.authenticated;
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Registration failed. Please try again.');
      _setLoading(false);
      return false;
    } finally {
      _authActionInProgress = false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _authActionInProgress = true;
    try {
      _setLoading(true);
      _clearError();

      final userModel = await _authRepository.login(
        email: email,
        password: password,
      );

      _user = userModel;
      _status = AuthStatus.authenticated;
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Login failed. Please try again.');
      _setLoading(false);
      return false;
    } finally {
      _authActionInProgress = false;
    }
  }

  Future<bool> saveProfile({
    required String displayName,
    required int age,
    required String country,
    String? medicalConditions,
  }) async {
    final currentUser = _user ?? _authUserFallback();
    if (currentUser == null) {
      _setError('Please sign in again to continue.');
      return false;
    }

    _authActionInProgress = true;
    try {
      _setLoading(true);
      _clearError();

      final updatedProfile = await _authRepository.completeProfile(
        user: currentUser,
        displayName: displayName,
        age: age,
        country: country,
        medicalConditions: medicalConditions,
      );

      _user = updatedProfile;
      _status = AuthStatus.authenticated;
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (_) {
      _setError(
        'Could not save your profile to the cloud. '
        'Check your connection and try again.',
      );
      _setLoading(false);
      return false;
    } finally {
      _authActionInProgress = false;
    }
  }

  Future<bool> logout() async {
    _authActionInProgress = true;
    try {
      _setLoading(true);
      _clearError();

      await _authRepository.logout();

      _user = null;
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Logout failed. Please try again.');
      _setLoading(false);
      return false;
    } finally {
      _authActionInProgress = false;
    }
  }

  Future<bool> resetPassword({required String email}) async {
    try {
      _setLoading(true);
      _clearError();

      await _authRepository.resetPassword(email: email);

      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Password reset failed. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
