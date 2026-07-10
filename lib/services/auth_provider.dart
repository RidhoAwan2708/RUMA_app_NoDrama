import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RumaUser? _user;
  bool _loading = false;
  String? _error;

  RumaUser? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
      notifyListeners();
      return;
    }
    await _loadUser(firebaseUser.uid);
  }

  Future<void> _loadUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _user = RumaUser.fromMap(doc.data()!);
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email, password: password,
      );
      await _loadUser(cred.user!.uid);
      _loading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.code == 'user-not-found'
          ? 'Akun tidak ditemukan'
          : e.code == 'wrong-password'
              ? 'Password salah'
              : e.code == 'invalid-credential'
                  ? 'Email atau password salah'
                  : 'Gagal masuk: ${e.message}';
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Terjadi kesalahan: $e';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String nimNip,
    required UserRole role,
    String? jurusan,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password,
      );
      final newUser = RumaUser(
        uid: cred.user!.uid,
        email: email,
        name: name,
        nimNip: nimNip,
        role: role,
        jurusan: jurusan,
      );
      await _firestore.collection('users').doc(newUser.uid).set(newUser.toMap());
      _user = newUser;
      _loading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.code == 'email-already-in-use'
          ? 'Email sudah terdaftar'
          : 'Gagal daftar: ${e.message}';
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Terjadi kesalahan: $e';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
