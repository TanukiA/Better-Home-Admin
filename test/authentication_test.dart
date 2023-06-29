import 'package:better_home_admin/models/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockAuthService extends Mock implements AuthService {
  final MockFirebaseAuth _firebaseAuth;

  MockAuthService(this._firebaseAuth);

  @override
  Future<bool> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      return false;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Sign out failed');
    }
  }
}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late MockAuthService authService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUserCredential mockUserCredential;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    authService = MockAuthService(mockFirebaseAuth);
    mockUserCredential = MockUserCredential();
  });

  group('Admin Login', () {
    test('Validate email and password (positive input)', () async {
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockUserCredential);

      final result =
          await authService.signIn('bukubukuu47@gmail.com', 'abc123');

      verify(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: 'bukubukuu47@gmail.com',
            password: 'abc123',
          )).called(1);
      expect(result, true);
    });

    test('Validate email and password (negative input)', () async {
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(FirebaseAuthException(code: 'invalid-email'));

      final result = await authService.signIn('bukubukuu47@gmail.com', 'sam');

      verify(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: 'bukubukuu47@gmail.com',
            password: 'sam',
          )).called(1);
      expect(result, false);
    });

    test('Admin logout succeed', () async {
      when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {
        return Future.value();
      });

      await authService.signOut();

      verify(() => mockFirebaseAuth.signOut()).called(1);
    });

    test('Admin logout failed', () async {
      when(() => mockFirebaseAuth.signOut())
          .thenThrow(Exception('Sign out failed'));

      expect(
        () async => await authService.signOut(),
        throwsA(isA<Exception>()),
      );

      verify(() => mockFirebaseAuth.signOut()).called(1);
    });
  });
}
