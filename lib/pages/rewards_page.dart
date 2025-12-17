import 'package:flutter/material.dart';

class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});

  final List<Map<String, dynamic>> badges = const [
    {'name': 'Eco Warrior', 'icon': Icons.eco, 'color': Colors.green, 'progress': 100},
    {'name': 'Plastic Crusher', 'icon': Icons.recycling, 'color': Colors.blue, 'progress': 75},
    {'name': 'Weekly Champion', 'icon': Icons.emoji_events, 'color': Colors.amber, 'progress': 100},
    {'name': 'Community Hero', 'icon': Icons.people, 'color': Colors.purple, 'progress': 30},
    {'name': 'Carbon Neutral', 'icon': Icons.co2, 'color': Colors.teal, 'progress': 60},
    {'name': 'Event Master', 'icon': Icons.event, 'color': Colors.orange, 'progress': 45},
  ];

  final List<Map<String, dynamic>> challenges = const [
    {'title': 'Daily Recycling', 'target': '5 items', 'points': 50, 'progress': 3},
    {'title': 'Plastic-Free Week', 'target': '7 days', 'points': 200, 'progress': 4},
    {'title': 'Monthly Collection', 'target': '20 kg', 'points': 500, 'progress': 15},
    {'title': 'Event Participation', 'target': '3 events', 'points': 300, 'progress': 2},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F2DD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF556B2F),
        title: const Text(
          "Rewards & Challenges",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Available Points
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF556B2F),
                    Color(0xFF7A8F5A),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Available Points",
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "1,250",
                        style: TextStyle(
                          fontSize: 36,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "≈ RM 12.50 value",
                        style: TextStyle(color: Colors.white.withOpacity(0.8)),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Redeem points
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF556B2F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Redeem"),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Badges Section
            const Text(
              "Your Badges",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF556B2F),
              ),
            ),
            
            const SizedBox(height: 16),
            
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              itemCount: badges.length,
              itemBuilder: (context, index) {
                final badge = badges[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: badge['color'].withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          badge['icon'],
                          color: badge['color'],
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        badge['name'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: badge['progress'] / 100,
                        backgroundColor: Colors.grey[200],
                        color: badge['color'],
                      ),
                    ],
                  ),
                );
              },
            ),
            
            const SizedBox(height: 30),
            
            // Challenges Section
            const Text(
              "Active Challenges",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF556B2F),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Column(
              children: challenges.map((challenge) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            challenge['title'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "${challenge['points']} pts",
                            style: const TextStyle(
                              color: Color(0xFFDAA520),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      Text(
                        "Target: ${challenge['target']}",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: challenge['progress'] / challenge['target'].toString().split(' ')[0],
                              backgroundColor: Colors.grey[200],
                              color: const Color(0xFF556B2F),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "${challenge['progress']}/${challenge['target'].toString().split(' ')[0]}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            // Log progress
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF556B2F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Update Progress"),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}