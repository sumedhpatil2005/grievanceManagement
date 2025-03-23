import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if the user is already logged in
  Future<bool> checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('isLoggedIn') ?? false;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save login status
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      // Notify listeners
      notifyListeners();

      return userCredential.user;
    } catch (e) {
      print('Login failed: $e');
      throw Exception('Login failed: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      print('Attempting to sign out...');

      // Check if there's a current user
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('No user is currently signed in.');
        return;
      }

      // Sign out from Firebase Auth
      await _auth.signOut();
      print('Firebase Auth sign-out successful.');

      // Clear login status in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      print('Login status cleared in SharedPreferences.');

      // Notify listeners (if using ChangeNotifier)
      notifyListeners();
      print('User signed out successfully.');
    } catch (e) {
      print('Error signing out: $e');
      throw Exception('Error signing out: $e');
    }
  }

  // Register a new user
  Future<User?> register(
    String name,
    String email,
    String password,
    String role,
    String? department,
    String? year,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Save user details to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'role': role,
        if (year != null) 'year': year,
        if (department != null) 'department': department,
      });

      // Save login status
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      // Notify listeners
      notifyListeners();

      return userCredential.user;
    } catch (e) {
      print('Registration failed: $e');
      throw Exception('Registration failed: $e');
    }
  }

  // Get user details from Firestore
  Future<UserModel?> getUserDetails(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error fetching user details: $e');
      throw Exception('Error fetching user details: $e');
    }
  }

  // Get the current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Stream of the current user
  Stream<User?> get userStream {
    return _auth.authStateChanges();
  }
}
