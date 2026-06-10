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

      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();

      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      if (googleAuth.idToken == null) {
        _errorMessage = 'ID Token Google tidak ditemukan.';
        _setLoading(false);
        return false;
      }

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user == null) {
        _errorMessage = 'Data user Firebase tidak ditemukan.';
        _setLoading(false);
        return false;
      }

      _role = UserRole.customer;
      _name = user.displayName ?? 'Customer Sneakimy';
      _email = user.email ?? 'customer@sneakimycare.com';
      _photoUrl = user.photoURL ?? '';

      await _saveSession();

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Login Google Firebase gagal.';
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Login Google dibatalkan atau gagal: $e';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> registerCustomerWithGoogle() async {
    return loginCustomerWithGoogle();
  }

  Future<bool> loginOwner({
    required String username,
    required String password,
  }) async {
    _setLoading(true);

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

    if (_role == UserRole.customer) {
      await _firebaseAuth.signOut();

      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {}
    }

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