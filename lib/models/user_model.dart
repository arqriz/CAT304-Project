// lib/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String matricNo;
  final String faculty;
  final String residentialCollege;
  final int points;
  final int level;
  final String rank;
  final double totalRecycled;
  final double co2Saved;
  final List<String> badges;
  final DateTime joinDate;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.matricNo,
    required this.faculty,
    required this.residentialCollege,
    this.points = 0,
    this.level = 1,
    this.rank = 'Novice Recycler',
    this.totalRecycled = 0.0,
    this.co2Saved = 0.0,
    this.badges = const [],
    required this.joinDate,
  });

  // Factory constructor to create a User from a Firestore DocumentSnapshot
  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final joinDateTimestamp = data['joinDate'] as Timestamp?;
    
    return User(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      matricNo: data['matricNo'] ?? '',
      faculty: data['faculty'] ?? '',
      residentialCollege: data['residentialCollege'] ?? '',
      // Ensure data types are handled safely (Firestore integers often come as int)
      points: data['points'] is int ? data['points'] : (data['points'] ?? 0),
      level: data['level'] is int ? data['level'] : (data['level'] ?? 1),
      rank: data['rank'] ?? 'Novice Recycler',
      totalRecycled: (data['totalRecycled'] ?? 0.0).toDouble(), 
      co2Saved: (data['co2Saved'] ?? 0.0).toDouble(),
      badges: List<String>.from(data['badges'] ?? []), 
      joinDate: joinDateTimestamp?.toDate() ?? DateTime.now(),
    );
  }

  // Utility method to convert the User object to a map for Firestore upload
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'matricNo': matricNo,
      'faculty': faculty,
      'residentialCollege': residentialCollege,
      'points': points,
      'level': level,
      'rank': rank,
      'totalRecycled': totalRecycled,
      'co2Saved': co2Saved,
      'badges': badges,
      'joinDate': joinDate, // Firestore handles DateTime automatically
    };
  }
}