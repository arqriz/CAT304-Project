import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/activity_model.dart';

class ActivityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // New & Better: Logic to save activity and update user stats simultaneously
  Future<void> recordActivity(String type, double quantity, String unit) async {
    final user = _auth.currentUser;
    if (user == null) return;

    int points = (quantity * 10).toInt(); // 10 points per unit
    double co2 = quantity * 0.5; // 0.5kg CO2 saved per unit

    // 1. Log the activity
    await _db.collection('activities').add({
      'userId': user.uid,
      'type': type,
      'quantity': quantity,
      'unit': unit,
      'pointsEarned': points,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // 2. Update user document with the new points and CO2
    await _db.collection('users').doc(user.uid).update({
      'points': FieldValue.increment(points),
      'totalRecycled': FieldValue.increment(quantity),
      'co2Saved': FieldValue.increment(co2),
    });
  }

  // Stream for the Activities Tab
  Stream<List<Activity>> getUserActivities() {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    return _db
        .collection('activities')
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true) // REQUIRES INDEX
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Activity.fromFirestore(doc)).toList());
  }
}