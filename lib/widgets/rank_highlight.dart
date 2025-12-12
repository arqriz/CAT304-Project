import 'package:flutter/material.dart';

class YourRankHighlight extends StatelessWidget {
  final String name;
  final int rank;
  final int points;
  final String faculty;

  const YourRankHighlight({
    super.key,
    required this.name,
    required this.rank,
    required this.points,
    required this.faculty,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF556B2F).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF556B2F), width: 2),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFDAA520),
            child: Text(
              rank.toString(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$name (You)",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF556B2F),
                  ),
                ),
                Text(
                  "$faculty • $points pts",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          const Icon(Icons.emoji_events, color: Color(0xFFDAA520)),
        ],
      ),
    );
  }
}
