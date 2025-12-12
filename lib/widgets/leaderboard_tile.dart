import 'package:flutter/material.dart';

class LeaderboardTile extends StatelessWidget {
  final int rank;
  final String name;
  final String faculty;
  final int points;

  const LeaderboardTile({
    super.key,
    required this.rank,
    required this.name,
    required this.faculty,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: rank <= 3 ? const Color(0xFF556B2F) : Colors.grey[300],
            child: Text(
              rank.toString(),
              style: TextStyle(
                color: rank <= 3 ? Colors.white : Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  faculty,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            "$points pts",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF556B2F),
            ),
          ),
        ],
      ),
    );
  }
}
