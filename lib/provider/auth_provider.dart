import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/auth_model.dart';
import '../Service/authservice.dart';

class AuthProviderPage extends ChangeNotifier {
  final AuthService _authService = AuthService();
  AppUser? _user;
  bool _isLoading = false;
  AppUser? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> loginWithApproval({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final appUser = await _authService.login(
        email: email,
        password: password,
      );

      if (appUser == null) {
        throw Exception("Login failed");
      }

      _user = appUser;

      final uid = appUser.uid;

      // 🔹 Firestore approval check
      final doc = await FirebaseFirestore.instance
          .collection("students")
          .doc(uid)
          .get();

      final bool approved = doc.data()?["approved"] == true;

      // 🔹 Save locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("isLoggedIn", true);
      await prefs.setString("userId", uid);
      await prefs.setBool("isApproved", approved);
      await prefs.setBool("isWaiting", !approved);

    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.login(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔹 SIGNUP
  Future<void> signUp(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.signUp(
        name: name,
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }



  // 🔹 CHECK CURRENT USER
  Future<void> checkUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("userId");

      if (userId != null) {
        // 🔥 Fetch user from Firestore
        final doc = await FirebaseFirestore.instance
            .collection("students")
            .doc(userId)
            .get();

        if (doc.exists) {
          final data = doc.data()!;

          _user = AppUser(
            uid: userId,
            name: data["name"] ?? "",
            email: data["email"] ?? "", createdAt: DateTime.now(),
          );
        }
      } else {
        _user = null;
      }

    } catch (e) {
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}