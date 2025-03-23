// lib/providers/user_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _uid;
  String? _role;
  String? _name;
  String? _department;
  bool _isLoading = true;
  String? year;

  String? get uid => _uid;
  String? get role => _role;
  String? get name => _name;
  String? get department => _department;
  bool get isLoading => _isLoading;

  UserProvider() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _loadUserData(user.uid);
      } else {
        _clearUserData();
      }
    });
  }

  Future<void> _loadUserData(String uid) async {
    try {
      _isLoading = true;
      notifyListeners();
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        _uid = uid;
        _role = userDoc['role'];
        _name = userDoc['name'];
        _department = userDoc['department'] ?? "Not applicable";
        year = userDoc['year'] ?? "Null";
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _clearUserData() {
    _uid = null;
    _role = null;
    _name = null;
    _department = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
