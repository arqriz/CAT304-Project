import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String id;
  final String userId;
  final DateTime timestamp;
  final String type; 
  final double quantity; 
  final String unit; 
  final int pointsEarned;
  final double co2Impact; 

  Activity({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.type,
    required this.quantity,
    required this.unit,
    required this.pointsEarned,
    required this.co2Impact,
  });

  factory Activity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Activity(
      id: doc.id,
      userId: data['userId'] ?? '',
      // Safe fallback for null or pending server timestamps
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: data['type'] ?? 'Unknown',
      quantity: (data['quantity'] ?? 0.0).toDouble(),
      unit: data['unit'] ?? 'units',
      pointsEarned: data['pointsEarned'] is int ? data['pointsEarned'] : (data['pointsEarned'] ?? 0),
      co2Impact: (data['co2Impact'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'timestamp': timestamp,
      'type': type,
      'quantity': quantity,
      'unit': unit,
      'pointsEarned': pointsEarned,
      'co2Impact': co2Impact,
    };
  }
}