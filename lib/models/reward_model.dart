import 'package:cloud_firestore/cloud_firestore.dart';

class Reward {
  final String id;
  final String title;
  final String description;
  final int pointCost;
  final String icon;

  Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.pointCost,
    required this.icon,
  });

  factory Reward.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Reward(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      pointCost: data['pointCost'] ?? 0,
      icon: data['icon'] ?? 'card_giftcard',
    );
  }
}