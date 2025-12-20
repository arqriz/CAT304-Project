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

  // Constructor calls init to check login status on app startup
  AuthService() {
    _init();
  }

  // Automatically detects if a user is already logged in
  void _init() {
    _auth.authStateChanges().listen((fb_auth.User? fbUser) async {
      if (fbUser != null) {
        // User is logged into Firebase Auth
        await _fetchAndSetUser(fbUser.uid);
      } else {
        // User is logged out
        _currentUser = null;
        _isAuthenticated = false;
        notifyListeners();
      }
    });
  }

  // UPDATED: Prevents black screen loops by allowing login even if profile fails
  Future<void> _fetchAndSetUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get()
          .timeout(const Duration(seconds: 10));
      
      if (doc.exists) {
        _currentUser = User.fromFirestore(doc);
        _isAuthenticated = true;
      } else {
        // FIX: If Auth is logged in but doc is missing, stay on Dashboard
        // so the user isn't stuck on a black screen
        _currentUser = null;
        _isAuthenticated = true; 
        if (kDebugMode) print('Warning: No Firestore document for user $uid');
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Fetch User Error: $e');
      _isAuthenticated = true; // Keep app stable during error
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user != null;
    } on fb_auth.FirebaseAuthException catch (e) {
      if (kDebugMode) print('Login Error: ${e.code}');
      return false;
    }
  }

  // UPDATED: Added safety timeout for registration
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

        // Save to Firestore with a timeout to prevent long loading
        await _firestore.collection('users').doc(uid).set(newUser.toMap())
            .timeout(const Duration(seconds: 10));
        
        _currentUser = newUser;
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
      return false;
    } on fb_auth.FirebaseAuthException catch (e) {
      if (kDebugMode) print('Registration Error: ${e.code}');
      return false;
    } catch (e) {
      if (kDebugMode) print('Unexpected Error: $e');
      return false;
    }
  }

  void logout() async {
    await _auth.signOut();
  }
}