import 'package:flutter_test/flutter_test.dart';
import 'package:takenote/services/auth/auth_exceptions.dart';
import 'package:takenote/services/auth/auth_provider.dart';
import 'package:takenote/services/auth/auth_user.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();
    test('Should not initialize', () {
      expect(provider.isInitialized, false);
    });
    test('Logout not initialized ', () {
      expect(
        provider.logOut(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });
    test('Should be able to initialize', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });
    test('User should be null after initialization', () {
      expect(provider.currentUser, null);
    });
    test(
      'Should be able to initialize in less than 2 seconds',
      () async {
        await provider.initialize();
        expect(provider.initialize(), true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );
    test('Create user should delegate log in func', () async {
      final badEmailUser = provider.createUser(
        email: 'foo@bar.com',
        password: 'anypassword',
        firstname: 'Foo',
        lastname: 'Bar',
        isEmailVerified: false,
      );
      expect(badEmailUser,
          throwsA(const TypeMatcher<UserNotFoundAuthException>()));

      final badPass = provider.createUser(
        email: 'someone@bar.com',
        password: 'foobar',
        firstname: 'Foo',
        lastname: 'Bar',
        isEmailVerified: false,
      );
      expect(badPass, throwsA(const TypeMatcher<WrongPasswordAuthException>()));
      final user = await provider.createUser(
        email: 'foo',
        password: 'bar',
        firstname: 'Foo',
        lastname: 'Bar',
      );
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });
    test('Logged in user should be able to verify', () {
      expect(provider.sendEmailVerification(), throwsA(isA<Exception>()));
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser(
      // ignore: avoid_positional_boolean_parameters
      {required String email,
      required String password,
      required String firstname,
      required String lastname,
      bool isEmailVerified = false}) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(
      const Duration(seconds: 1),
    );
    return logIn(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(
      const Duration(seconds: 1),
    );
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) {
    if (!isInitialized) throw NotInitializedException();
    if (email == 'Foo@bar.com') throw UserNotFoundAuthException();
    if (password == 'anypassword') throw WrongPasswordAuthException();
    const user = AuthUser(
      isEmailVerified: false,
      email: '',
      id: 'my_id',
      firstName: 'Foo',
      lastName: 'Bar',
    );
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(
      isEmailVerified: true,
      email: 'foo@gmail.com',
      id: 'my_id',
    );
    _user = newUser;
  }

  @override
  Future<void> sendPasswordResetEmail({required String toEmail}) {
    throw UnimplementedError();
  }
}

//MainKT
// import androidx.annotation.NonNull;
// import io.flutter.embedding.android.FlutterFragmentActivity
// import io.flutter.embedding.engine.FlutterEngine
// import io.flutter.plugins.GeneratedPluginRegistrant

// class MainActivity: FlutterFragmentActivity() {
// override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
// GeneratedPluginRegistrant.registerWith(flutterEngine);
// }
// }
