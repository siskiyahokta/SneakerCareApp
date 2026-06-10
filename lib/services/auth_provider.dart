import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserRole {
  none,
  customer,
  owner,
}

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'profile',
    ],
  );

  UserRole _role = UserRole.none;
  String _name = '';
  String _email = '';
  String _photoUrl = '';
  bool _isLoading = false;
  String? _errorMessage;

  UserRole get role => _role;
  String get name => _name;
  String get email => _email;
  String get photoUrl => _photoUrl;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isLoggedIn => _role != UserRole.none;
  bool get isCustomer => _role == UserRole.customer;
  bool get isOwner => _role == UserRole.owner;

  AuthProvider() {
    loadSession();
  }

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();

    final savedRole = prefs.getString('role') ?? 'none';
    _name = prefs.getString('name') ?? '';
    _email = prefs.getString('email') ?? '';
    _photoUrl = prefs.getString('photoUrl') ?? '';

    if (savedRole == 'customer') {
      _role = UserRole.customer;
    } else if (savedRole == 'owner') {
      _role = UserRole.owner;
    } else {
      _role = UserRole.none;
    }

    notifyListeners();
  }

  Future<bool> loginCustomerWithGoogle() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      debugPrint('Mulai login Google customer...');

      // Biar account picker muncul ulang dan tidak nyangkut di akun lama.
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _errorMessage = 'Login Google dibatalkan.';
        debugPrint(_errorMessage);
        _setLoading(false);
        return false;
      }

      debugPrint('Akun Google dipilih: ${googleUser.email}');

      try {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        if (googleAuth.idToken == null && googleAuth.accessToken == null) {
          debugPrint('Token Google kosong, masuk memakai sesi lokal sementara.');
          await _completeGoogleLoginFromAccount(googleUser);
          _setLoading(false);
          return true;
        }

        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
            await _firebaseAuth.signInWithCredential(credential);

        final User? user = userCredential.user;

        if (user == null) {
          debugPrint('User Firebase kosong, masuk memakai data akun Google.');
          await _completeGoogleLoginFromAccount(googleUser);
          _setLoading(false);
          return true;
        }

        _role = UserRole.customer;
        _name = user.displayName ?? googleUser.displayName ?? 'Customer Sneakimy';
        _email = user.email ?? googleUser.email;
        _photoUrl = user.photoURL ?? googleUser.photoUrl ?? '';
        _errorMessage = null;

        await _saveSession();

        debugPrint('Login Firebase berhasil: $_email');
        _setLoading(false);
        return true;
      } on FirebaseAuthException catch (e) {
        debugPrint('FirebaseAuth gagal: ${e.code} - ${e.message}');
        debugPrint('Akun Google sudah dipilih, lanjut masuk dengan sesi lokal.');

        await _completeGoogleLoginFromAccount(googleUser);
        _setLoading(false);
        return true;
      } catch (e) {
        debugPrint('Firebase credential/token gagal: $e');
        debugPrint('Akun Google sudah dipilih, lanjut masuk dengan sesi lokal.');

        await _completeGoogleLoginFromAccount(googleUser);
        _setLoading(false);
        return true;
      }
    } catch (e) {
      _errorMessage = 'Login Google gagal: $e';
      debugPrint(_errorMessage);
      _setLoading(false);
      return false;
    }
  }

  Future<bool> registerCustomerWithGoogle() async {
    return loginCustomerWithGoogle();
  }

  Future<void> _completeGoogleLoginFromAccount(
    GoogleSignInAccount googleUser,
  ) async {
    _role = UserRole.customer;
    _name = googleUser.displayName ?? 'Customer Sneakimy';
    _email = googleUser.email;
    _photoUrl = googleUser.photoUrl ?? '';
    _errorMessage = null;

    await _saveSession();

    debugPrint('Login Google lokal berhasil: $_email');
  }

  Future<bool> loginOwner({
    required String username,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    await Future.delayed(const Duration(milliseconds: 500));

    if (username.trim() == 'admin' && password.trim() == 'admin123') {
      _role = UserRole.owner;
      _name = 'Pemilik Sneakimy Care';
      _email = 'owner@sneakimycare.com';
      _photoUrl = '';
      _errorMessage = null;

      await _saveSession();

      _setLoading(false);
      return true;
    }

    _errorMessage = 'Username atau password pemilik usaha salah.';
    _setLoading(false);
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      await _firebaseAuth.signOut();
    } catch (_) {}

    try {
      await _googleSignIn.signOut();
    } catch (_) {}

    await prefs.remove('role');
    await prefs.remove('name');
    await prefs.remove('email');
    await prefs.remove('photoUrl');

    _role = UserRole.none;
    _name = '';
    _email = '';
    _photoUrl = '';
    _errorMessage = null;

    notifyListeners();
  }

  Future<void> _saveSession() async {
    final prefs = await SharedPreferences.getInstance();

    String roleString = 'none';

    if (_role == UserRole.customer) {
      roleString = 'customer';
    } else if (_role == UserRole.owner) {
      roleString = 'owner';
    }

    await prefs.setString('role', roleString);
    await prefs.setString('name', _name);
    await prefs.setString('email', _email);
    await prefs.setString('photoUrl', _photoUrl);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
