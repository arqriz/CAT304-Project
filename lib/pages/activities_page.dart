import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/activity_model.dart';

class ActivityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // This method creates the 'activities' collection automatically
  Future<void> recordActivity(String type, double quantity, String unit) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No user logged in");

    // Calculation logic for points and CO2
    int pointsEarned = (quantity * 10).toInt(); 
    double co2Saved = quantity * 0.5;

    // Create the activity document
    await _db.collection('activities').add({
      'userId': user.uid,
      'type': type,
      'quantity': quantity,
      'unit': unit,
      'pointsEarned': pointsEarned,
      'timestamp': FieldValue.serverTimestamp(), // Crucial for the history list
    });

    // Update the user's total stats in the 'users' collection
    await _db.collection('users').doc(user.uid).update({
      'points': FieldValue.increment(pointsEarned),
      'totalRecycled': FieldValue.increment(quantity),
      'co2Saved': FieldValue.increment(co2Saved),
    });
  }

  // Fetches the data for your Activities Tab
  Stream<List<Activity>> getUserActivities() {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    return _db
        .collection('activities')
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true) // REQUIRES INDEX
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Activity.fromFirestore(doc)).toList());
  }
}