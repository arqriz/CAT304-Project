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

  // Utility to fetch user data from Firestore
  Future<void> _fetchAndSetUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      _currentUser = User.fromFirestore(doc);
      _isAuthenticated = true;
      notifyListeners();
    } else {
      _currentUser = null;
      _isAuthenticated = false;
    }
  }

  // --- Login with Firebase Authentication ---
  Future<bool> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        await _fetchAndSetUser(userCredential.user!.uid);
        return true;
      }
      return false;
    } on fb_auth.FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Login Error: ${e.code}');
      }
      return false;
    }
  }

  // --- Register with Firebase Authentication and Firestore ---
  Future<bool> register(String name, String email, String password, 
                        String matricNo, String faculty, String college) async {
    if (kDebugMode) print('1. Starting registration process...');
    try {
      // 1. AUTHENTICATION STEP
      final startAuth = DateTime.now();
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final endAuth = DateTime.now();
      if (kDebugMode) print('2. Auth completed in ${endAuth.difference(startAuth).inMilliseconds}ms');

      
      if (userCredential.user != null) {
        final uid = userCredential.user!.uid;
        
        // Create initial user model
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

        // 2. FIRESTORE WRITE STEP
        final startFirestore = DateTime.now();
        await _firestore.collection('users').doc(uid).set(newUser.toMap());
        final endFirestore = DateTime.now();
        if (kDebugMode) print('3. Firestore write completed in ${endFirestore.difference(startFirestore).inMilliseconds}ms');
        
        // Set current user state
        _currentUser = newUser;
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
      return false;
    } on fb_auth.FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Registration Error: ${e.code}');
      }
      return false;
    }
  }

  // --- Logout with Firebase Authentication ---
  void logout() async {
    await _auth.signOut();
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}