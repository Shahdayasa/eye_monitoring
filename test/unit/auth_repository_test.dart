import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eye_monitoring/features/authentication/data/auth_repository.dart';
import 'package:eye_monitoring/features/authentication/domain/user_model.dart';

class FakeUser implements User {
  FakeUser({required this.uid, this.email});

  @override
  final String uid;

  @override
  final String? email;

  @override
  Future<void> updateDisplayName(String? displayName) async {}

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeUserCredential implements UserCredential {
  FakeUserCredential(this.user);

  @override
  final User? user;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeFirebaseAuth implements FirebaseAuth {
  FakeFirebaseAuth({
    this.onCreateUser,
    this.onSignIn,
    this.onSendReset,
    this.onSignOut,
  });

  final Future<UserCredential> Function(String email, String password)?
      onCreateUser;
  final Future<UserCredential> Function(String email, String password)?
      onSignIn;
  final Future<void> Function(String email)? onSendReset;
  final Future<void> Function()? onSignOut;

  int signOutCalls = 0;

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return onCreateUser!(email, password);
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return onSignIn!(email, password);
  }

  @override
  Future<void> sendPasswordResetEmail({
    required String email,
    ActionCodeSettings? actionCodeSettings,
  }) {
    return onSendReset!(email);
  }

  @override
  Future<void> signOut() {
    signOutCalls++;
    return onSignOut!();
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeFirebaseFirestore implements FirebaseFirestore {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeFirebaseFirestore mockFirestore;
  late List<UserModel> savedProfiles;

  setUp(() {
    mockFirestore = FakeFirebaseFirestore();
    savedProfiles = [];
  });

  AuthRepository buildRepository(
    FakeFirebaseAuth auth, {
    Future<UserModel?> Function(String uid)? loadProfile,
  }) {
    return AuthRepository(
      auth: auth,
      firestore: mockFirestore,
      saveProfile: (user) async => savedProfiles.add(user),
      loadProfile: loadProfile ?? (uid) async => null,
    );
  }

  group('AuthRepository', () {
    group('register', () {
      test('should register user successfully', () async {
        final user = FakeUser(uid: 'test-uid', email: 'test@example.com');
        final auth = FakeFirebaseAuth(
          onCreateUser: (email, password) async =>
              FakeUserCredential(user),
        );
        final authRepository = buildRepository(auth);

        final result = await authRepository.register(
          email: 'test@example.com',
          password: 'password123',
          displayName: 'Test User',
        );

        expect(result, isA<UserModel>());
        expect(result.uid, equals('test-uid'));
        expect(result.email, equals('test@example.com'));
        expect(savedProfiles, hasLength(1));
      });

      test('should throw AuthException on email-already-in-use', () async {
        final auth = FakeFirebaseAuth(
          onCreateUser: (email, password) async =>
              throw FirebaseAuthException(code: 'email-already-in-use'),
        );
        final authRepository = buildRepository(auth);

        expect(
          () => authRepository.register(
            email: 'test@example.com',
            password: 'password123',
          ),
          throwsA(isA<AuthException>()),
        );
      });

      test('should throw AuthException on invalid-email', () async {
        final auth = FakeFirebaseAuth(
          onCreateUser: (email, password) async =>
              throw FirebaseAuthException(code: 'invalid-email'),
        );
        final authRepository = buildRepository(auth);

        expect(
          () => authRepository.register(
            email: 'invalid',
            password: 'password123',
          ),
          throwsA(isA<AuthException>()),
        );
      });

      test('should throw AuthException on weak-password', () async {
        final auth = FakeFirebaseAuth(
          onCreateUser: (email, password) async =>
              throw FirebaseAuthException(code: 'weak-password'),
        );
        final authRepository = buildRepository(auth);

        expect(
          () => authRepository.register(
            email: 'test@example.com',
            password: '123',
          ),
          throwsA(isA<AuthException>()),
        );
      });
    });

    group('login', () {
      test('should login user successfully', () async {
        final user = FakeUser(uid: 'test-uid', email: 'test@example.com');
        final auth = FakeFirebaseAuth(
          onSignIn: (email, password) async => FakeUserCredential(user),
        );
        final profile = UserModel(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
          createdAt: DateTime(2024),
        );
        final authRepository = buildRepository(
          auth,
          loadProfile: (uid) async => profile,
        );

        final result = await authRepository.login(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(result, isA<UserModel>());
        expect(result.uid, equals('test-uid'));
      });

      test('should throw AuthException on wrong-password', () async {
        final auth = FakeFirebaseAuth(
          onSignIn: (email, password) async =>
              throw FirebaseAuthException(code: 'wrong-password'),
        );
        final authRepository = buildRepository(auth);

        expect(
          () => authRepository.login(
            email: 'test@example.com',
            password: 'wrongpassword',
          ),
          throwsA(isA<AuthException>()),
        );
      });

      test('should throw AuthException on user-not-found', () async {
        final auth = FakeFirebaseAuth(
          onSignIn: (email, password) async =>
              throw FirebaseAuthException(code: 'user-not-found'),
        );
        final authRepository = buildRepository(auth);

        expect(
          () => authRepository.login(
            email: 'nonexistent@example.com',
            password: 'password123',
          ),
          throwsA(isA<AuthException>()),
        );
      });

      test('should throw AuthException on invalid-credential', () async {
        final auth = FakeFirebaseAuth(
          onSignIn: (email, password) async =>
              throw FirebaseAuthException(code: 'invalid-credential'),
        );
        final authRepository = buildRepository(auth);

        expect(
          () => authRepository.login(
            email: 'test@example.com',
            password: 'wrongpassword',
          ),
          throwsA(isA<AuthException>()),
        );
      });
    });

    group('logout', () {
      test('should logout user successfully', () async {
        final auth = FakeFirebaseAuth(onSignOut: () async {});
        final authRepository = buildRepository(auth);

        await authRepository.logout();

        expect(auth.signOutCalls, equals(1));
      });
    });

    group('resetPassword', () {
      test('should send password reset email successfully', () async {
        String? sentTo;
        final auth = FakeFirebaseAuth(
          onSendReset: (email) async => sentTo = email,
        );
        final authRepository = buildRepository(auth);

        await authRepository.resetPassword(email: 'test@example.com');

        expect(sentTo, equals('test@example.com'));
      });

      test('should throw AuthException on invalid-email', () async {
        final auth = FakeFirebaseAuth(
          onSendReset: (email) async =>
              throw FirebaseAuthException(code: 'invalid-email'),
        );
        final authRepository = buildRepository(auth);

        expect(
          () => authRepository.resetPassword(email: 'invalid'),
          throwsA(isA<AuthException>()),
        );
      });
    });

    group('error messages', () {
      test('should return correct message for network-request-failed', () async {
        final auth = FakeFirebaseAuth(
          onSignIn: (email, password) async =>
              throw FirebaseAuthException(code: 'network-request-failed'),
        );
        final authRepository = buildRepository(auth);

        try {
          await authRepository.login(
            email: 'test@example.com',
            password: 'password123',
          );
          fail('Expected AuthException');
        } on AuthException catch (e) {
          expect(e.message, equals('Check your internet connection.'));
        }
      });

      test('should return correct message for too-many-requests', () async {
        final auth = FakeFirebaseAuth(
          onSignIn: (email, password) async =>
              throw FirebaseAuthException(code: 'too-many-requests'),
        );
        final authRepository = buildRepository(auth);

        try {
          await authRepository.login(
            email: 'test@example.com',
            password: 'password123',
          );
          fail('Expected AuthException');
        } on AuthException catch (e) {
          expect(e.message, equals('Too many attempts. Please try again later.'));
        }
      });
    });
  });
}
