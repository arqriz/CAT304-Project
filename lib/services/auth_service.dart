// lib/services/auth_service.dart

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService with ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  // NEW: Constructor calls init to check login status on app startup
  AuthService() {
    _init();
  }

  // NEW: Automatically detects if a user is already logged in
  void _init() {
    _auth.authStateChanges().listen((fb_auth.User? fbUser) async {
      if (fbUser != null) {
        await _fetchAndSetUser(fbUser.uid);
      } else {
        _currentUser = null;
        _isAuthenticated = false;
        notifyListeners();
      }
    });
  }

  Future<void> _fetchAndSetUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUser = User.fromFirestore(doc);
        _isAuthenticated = true;
      } else {
        _currentUser = null;
        _isAuthenticated = false;
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Fetch User Error: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        // _init() will handle fetching the user data via authStateChanges
        return true;
      }
      return false;
    } on fb_auth.FirebaseAuthException catch (e) {
      if (kDebugMode) print('Login Error: ${e.code}');
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, 
                        String matricNo, String faculty, String college) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        final uid = userCredential.user!.uid;
        final newUser = User(
          id: uid,
          name: name,
          email: email,
          matricNo: matricNo,
          faculty: faculty,
          residentialCollege: college,
          points: 0,
          level: 1,
          rank: 'New Recycler',
          totalRecycled: 0.0,
          co2Saved: 0.0,
          badges: ['New Recruit'],
          joinDate: DateTime.now(),
        );

        // Ensure the document is written to Firestore
        await _firestore.collection('users').doc(uid).set(newUser.toMap());
        
        _currentUser = newUser;
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
      return false;
    } on fb_auth.FirebaseAuthException catch (e) {
      if (kDebugMode) print('Registration Error: ${e.code}');
      return false;
    }
  }

  void logout() async {
    await _auth.signOut();
    // _init() will automatically clear _currentUser and _isAuthenticated
  }
}