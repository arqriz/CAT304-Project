// lib/services/activity_service.dart

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../models/activity_model.dart';

class ActivityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Gamification Engine & Impact Simulation Logic ---
  Map<String, double> _getImpactAndPoints(String type, double quantity) {
    int points = 0;
    double co2Saved = 0.0;
    double recycledWeight = 0.0;

    // Implementation based on simple rule-based logic (can be expanded later)
    if (type == 'Plastic Bottles') {
      points = (quantity * 10).toInt(); // 10 points per bottle
      co2Saved = quantity * 0.08; 
      recycledWeight = quantity * 0.02; // Avg bottle weight 0.02 kg
    } else if (type == 'Paper (kg)') {
      points = (quantity * 5).toInt(); // 5 points per kg
      co2Saved = quantity * 1.7; // High CO2 savings for paper
      recycledWeight = quantity;
    } else if (type == 'Aluminium Cans') {
      points = (quantity * 20).toInt(); // 20 points per can
      co2Saved = quantity * 0.15; 
      recycledWeight = quantity * 0.015; // Avg can weight 0.015 kg
    } 
    // Event Participation logic would be handled by QR Scan

    return {
      'points': points.toDouble(),
      'co2Saved': co2Saved,
      'recycledWeight': recycledWeight,
    };
  }

  // --- Record Activity and Update User Profile using Firestore Transaction ---
  Future<void> recordActivity(String type, double quantity, String unit) async {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not authenticated.");
    }

    final impact = _getImpactAndPoints(type, quantity);
    final pointsEarned = impact['points']!.toInt();
    final co2Impact = impact['co2Saved']!;
    final recycledWeight = impact['recycledWeight']!;

    final newActivity = Activity(
      id: '', 
      userId: user.uid,
      timestamp: DateTime.now(),
      type: type,
      quantity: quantity,
      unit: unit,
      pointsEarned: pointsEarned,
      co2Impact: co2Impact,
    );

    // Use a Firestore transaction for atomic updates to ensure data integrity
    await _firestore.runTransaction((transaction) async {
      final userRef = _firestore.collection('users').doc(user.uid);
      final activityRef = _firestore.collection('activities').doc();

      final userDoc = await transaction.get(userRef);
      if (!userDoc.exists) {
        throw Exception("User profile missing in Firestore!");
      }

      // Calculate new user stats
      final currentPoints = (userDoc.data()?['points'] ?? 0) as int;
      final currentRecycled = (userDoc.data()?['totalRecycled'] ?? 0.0).toDouble();
      final currentCo2 = (userDoc.data()?['co2Saved'] ?? 0.0).toDouble();
      
      final newPoints = currentPoints + pointsEarned;
      final newRecycled = currentRecycled + recycledWeight;
      final newCo2 = currentCo2 + co2Impact;
      
      // TODO: Implement actual Level and Rank calculation based on newPoints here

      // 1. Update the user's document with new totals (Simulation & Analytics)
      transaction.update(userRef, {
        'points': newPoints,
        'totalRecycled': newRecycled,
        'co2Saved': newCo2,
        'level': 1, 
        'rank': 'N/A', 
      });

      // 2. Commit the new activity record
      transaction.set(activityRef, newActivity.toMap());
    });
  }
}