import 'package:flutter/material.dart';

class LeaderboardPodium extends StatelessWidget {
  final String firstName;
  final int firstPoints;

  final String secondName;
  final int secondPoints;

  final String thirdName;
  final int thirdPoints;

  const LeaderboardPodium({
    super.key,
    required this.firstName,
    required this.firstPoints,
    required this.secondName,
    required this.secondPoints,
    required this.thirdName,
    required this.thirdPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _podiumTile(
            rank: 2,
            name: secondName,
            points: secondPoints,
            size: 80,
            color: Colors.grey,
          ),
          _podiumTile(
            rank: 1,
            name: firstName,
            points: firstPoints,
            size: 110,
            color: Colors.amber,
          ),
          _podiumTile(
            rank: 3,
            name: thirdName,
            points: thirdPoints,
            size: 80,
            color: Colors.brown,
          ),
        ],
      ),
    );
  }

  Widget _podiumTile({
    required int rank,
    required String name,
    required int points,
    required double size,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                blurRadius: 6,
                offset: const Offset(0, 4),
                color: color.withOpacity(0.4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              rank.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(
          "$points pts",
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
