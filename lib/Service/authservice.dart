import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_app/Service/local_status.dart';
import '../Models/auth_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalStorageService _local = LocalStorageService();

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// 🔥 SIGN UP
  Future<AppUser?> signUp({
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
        final appUser = AppUser(
          uid: user.uid,
          name: name,
          email: email,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(appUser.toMap());

        /// 🔥 SAVE LOCAL
        await _local.saveUser(user.uid);

        return appUser;
      }
    } catch (e) {
      print("🔥 SignUp Error: $e");
      rethrow;
  }}

  Future<AppUser?> login({
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
        final doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        await _local.saveUser(user.uid);

        return AppUser.fromMap(doc.data()!);
      }
    } catch (e) {
    }
    return null;
  }


  Future<AppUser?> getUserData() async {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        final doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        return AppUser.fromMap(doc.data()!);
      }
    } catch (e) {
    }
    return null;
  }
}