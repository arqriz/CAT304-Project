// lib/pages/leaderboard_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/user_model.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Stream data from the 'users' collection, ordered by 'points' descending
    final leaderboardStream = FirebaseFirestore.instance
        .collection('users')
        .orderBy('points', descending: true)
        // We will start with a limit to keep the initial load fast
        .limit(50) 
        .snapshots();

    return Scaffold(
      body: Column(
        children: [
          // Header for Leaderboard (can be used for filters later)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Top Recyclers (Global)',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          
          // Leaderboard List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: leaderboardStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final documents = snapshot.data!.docs;
                if (documents.isEmpty) {
                  return const Center(child: Text('No users found in the leaderboard.'));
                }

                return ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final User user = User.fromFirestore(documents[index]);
                    final rank = index + 1; // Rank is determined by list position

                    return _buildLeaderboardTile(
                      rank: rank,
                      user: user,
                      // Highlight the top 3 visually
                      isTopThree: rank <= 3,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildLeaderboardTile({
  required int rank,
  required User user,
  required bool isTopThree,
}) {
  final pointsFormatter = NumberFormat('#,###');
  Color rankColor = Colors.grey.shade600;
  if (rank == 1) rankColor = const Color(0xFFDAA520); // Gold
  else if (rank == 2) rankColor = Colors.grey.shade400; // Silver
  else if (rank == 3) rankColor = const Color(0xFFCD7F32); // Bronze
  
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: isTopThree ? rankColor.withOpacity(0.1) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isTopThree ? rankColor : Colors.transparent,
        width: isTopThree ? 2 : 0,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: rankColor,
        child: Text(
          '$rank',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        user.name,
        style: TextStyle(
          fontWeight: isTopThree ? FontWeight.bold : FontWeight.w600,
          color: isTopThree ? rankColor.withOpacity(0.8) : const Color(0xFF556B2F),
        ),
      ),
      subtitle: Text(user.residentialCollege), // Display college for competition context
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            pointsFormatter.format(user.points),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: rankColor,
            ),
          ),
          const Text(
            'Points',
            style: TextStyle(fontSize: 12, color: Color(0xFF7A8F5A)),
          ),
        ],
      ),
    ),
  );
}