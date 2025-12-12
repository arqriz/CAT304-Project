import 'package:flutter/material.dart';
import '../widgets/leaderboard_podium.dart';
import '../widgets/rank_highlight.dart';
import '../widgets/leaderboard_tile.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  final List<Map<String, dynamic>> leaderboardData = const [
    {'rank': 1, 'name': 'Ali Rahman', 'points': 3245, 'faculty': 'Computer Sciences'},
    {'rank': 2, 'name': 'Siti Aisyah', 'points': 2980, 'faculty': 'Biological Sciences'},
    {'rank': 3, 'name': 'Raj Kumar', 'points': 2750, 'faculty': 'Chemical Sciences'},
    {'rank': 4, 'name': 'Mei Ling', 'points': 2540, 'faculty': 'Physics'},
    {'rank': 5, 'name': 'Ahmad Adib', 'points': 1250, 'faculty': 'Computer Sciences'},
    {'rank': 6, 'name': 'Fatimah Zahra', 'points': 1150, 'faculty': 'Mathematics'},
    {'rank': 7, 'name': 'John Lim', 'points': 980, 'faculty': 'HBP'},
    {'rank': 8, 'name': 'Sarah Tan', 'points': 870, 'faculty': 'Computer Sciences'},
    {'rank': 9, 'name': 'David Chen', 'points': 750, 'faculty': 'Biological Sciences'},
    {'rank': 10, 'name': 'Nurul Iman', 'points': 620, 'faculty': 'Chemical Sciences'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F2DD),

      appBar: AppBar(
        backgroundColor: const Color(0xFF556B2F),
        title: const Text(
          "Leaderboard",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            LeaderboardPodium(
              firstName: leaderboardData[0]['name'],
              firstPoints: leaderboardData[0]['points'],
              secondName: leaderboardData[1]['name'],
              secondPoints: leaderboardData[1]['points'],
              thirdName: leaderboardData[2]['name'],
              thirdPoints: leaderboardData[2]['points'],
            ),

            const SizedBox(height: 20),

            const YourRankHighlight(
              name: "Ahmad Adib",
              rank: 5,
              points: 1250,
              faculty: "Computer Sciences",
            ),

            const SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: leaderboardData.map((user) {
                  return LeaderboardTile(
                    rank: user['rank'],
                    name: user['name'],
                    faculty: user['faculty'],
                    points: user['points'],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
