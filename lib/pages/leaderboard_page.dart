// lib/pages/leaderboard_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Top Recyclers (Global)')),
      body: StreamBuilder<QuerySnapshot>(
        // Fetch users sorted by points
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('points', descending: true)
            .limit(10)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;
              return ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(userData['displayName'] ?? 'Anonymous'),
                subtitle: Text('Level ${userData['level'] ?? 1}'),
                trailing: Text('${userData['points'] ?? 0} pts', 
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              );
            },
          );
        },
      ),
    );
  }
}