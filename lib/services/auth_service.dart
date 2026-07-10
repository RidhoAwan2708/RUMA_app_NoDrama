import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authState => _auth.authStateChanges();

  RumaUser? _currentUser;
  RumaUser? get currentUser => _currentUser;

  Future<RumaUser?> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _loadUser(cred.user!.uid);
  }

  Future<RumaUser?> signUp({
    required String email,
    required String password,
    required String name,
    required String nimNip,
    required UserRole role,
    String? jurusan,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = RumaUser(
      uid: cred.user!.uid,
      email: email,
      name: name,
      nimNip: nimNip,
      role: role,
      jurusan: jurusan,
    );
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
    _currentUser = user;
    return user;
  }

  Future<RumaUser?> _loadUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      _currentUser = RumaUser.fromMap(doc.data()!);
      return _currentUser;
    }
    return null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
  }
}
