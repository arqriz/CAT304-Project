import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

class RewardsTab extends StatelessWidget {
  const RewardsTab({super.key});

  static const Color mossGreen = Color(0xFF5B6739);
  static const Color creamWhite = Color(0xFFF9F9F0);

  @override
  Widget build(BuildContext context) {
    final uid = fb_auth.FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Impact Rewards', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: mossGreen,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final int points = userData['points'] ?? 0;

          return ListView(
            padding: const EdgeInsets.all(25),
            children: [
              _buildProgressCard(points),
              const SizedBox(height: 30),
              const Text("Badges to Unlock", 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: mossGreen)),
              const SizedBox(height: 15),
              _buildBadgeGrid(points),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressCard(int points) {
    double progress = (points % 500) / 500; // Progress toward next level
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: mossGreen,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          const Text("Next Milestone", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 10),
          Text("${500 - (points % 500)} pts to Level Up", 
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white24,
            color: Colors.white,
            minHeight: 10,
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeGrid(int userPoints) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      children: [
        _badgeItem("Eco Sprout", 100, Icons.eco, userPoints),
        _badgeItem("Paper Saver", 300, Icons.description, userPoints),
        _badgeItem("Plastic Hero", 600, Icons.water_drop, userPoints),
        _badgeItem("Carbon Master", 1000, Icons.cloud_done, userPoints),
      ],
    );
  }

  Widget _badgeItem(String name, int required, IconData icon, int userPoints) {
    bool isUnlocked = userPoints >= required;
    return Container(
      decoration: BoxDecoration(
        color: isUnlocked ? creamWhite : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: isUnlocked ? Border.all(color: mossGreen, width: 2) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: isUnlocked ? mossGreen : Colors.grey),
          const SizedBox(height: 10),
          Text(name, style: TextStyle(
            fontWeight: FontWeight.bold, 
            color: isUnlocked ? mossGreen : Colors.grey
          )),
          Text("$required pts", style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}