import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

class RewardsTab extends StatelessWidget {
  const RewardsTab({super.key});

  static const Color mossGreen = Color(0xFF5B6739);
  static const Color lightSage = Color(0xFFDDE2C9);
  static const Color creamWhite = Color(0xFFF9F9F0);

  @override
  Widget build(BuildContext context) {
    final uid = fb_auth.FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: lightSage,
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
            padding: const EdgeInsets.symmetric(vertical: 10),
            children: [
              _buildProgressCard(points),
              _buildSectionHeader("Active Challenges"),
              // UPDATED: Now dynamic from Firestore
              _buildFunctionalChallengeSlider(), 
              _buildSectionHeader("Achievements"),
              _buildBadgeGrid(points),
              const SizedBox(height: 100),
            ],
          );
        },
      ),
    );
  }

  // NEW: Logic to fetch challenges from a global 'challenges' collection
  Widget _buildFunctionalChallengeSlider() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('challenges').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Text("No global challenges active. Check back later!", style: TextStyle(color: Colors.grey, fontSize: 12)),
          );
        }

        return SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 25),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final challenge = snapshot.data!.docs[index];
              return _challengeCard(
                challenge['title'] ?? 'Challenge', 
                challenge['description'] ?? 'Log activities', 
                challenge['pointsReward'] ?? 0
              );
            },
          ),
        );
      },
    );
  }

  Widget _challengeCard(String title, String subtitle, int rewardPts) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: creamWhite, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: mossGreen)),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("+$rewardPts pts", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
            ],
          )
        ],
      ),
    );
  }

  // --- BADGE GRID & PROGRESS CARD Helpers ---
  Widget _buildSectionHeader(String title) {
    return Padding(padding: const EdgeInsets.fromLTRB(25, 25, 25, 15), child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: mossGreen)));
  }

  Widget _buildProgressCard(int points) {
    double progress = (points % 500) / 500;
    return Container(margin: const EdgeInsets.symmetric(horizontal: 25), padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: mossGreen, borderRadius: BorderRadius.circular(30)), child: Column(children: [const Text("Points Balance", style: TextStyle(color: Colors.white70)), Text("$points pts", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)), const SizedBox(height: 20), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Lvl ${points ~/ 500 + 1}", style: const TextStyle(color: Colors.white)), Text("${500 - (points % 500)} pts to level up", style: const TextStyle(color: Colors.white70, fontSize: 12))]), const SizedBox(height: 8), LinearProgressIndicator(value: progress, backgroundColor: Colors.white24, color: Colors.amber, minHeight: 10, borderRadius: BorderRadius.circular(10))]));
  }

  Widget _buildBadgeGrid(int userPoints) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 25), child: GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, mainAxisSpacing: 15, crossAxisSpacing: 15, children: [_badgeItem("Eco Sprout", 100, Icons.eco, userPoints), _badgeItem("Recycle Rookie", 300, Icons.auto_awesome, userPoints), _badgeItem("Plastic Hero", 600, Icons.water_drop, userPoints), _badgeItem("Carbon Master", 1000, Icons.cloud_done, userPoints)]));
  }

  Widget _badgeItem(String name, int required, IconData icon, int userPoints) {
    bool isUnlocked = userPoints >= required;
    return Container(decoration: BoxDecoration(color: isUnlocked ? creamWhite : Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(25), border: isUnlocked ? Border.all(color: Colors.amber, width: 2) : null), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 40, color: isUnlocked ? mossGreen : Colors.grey), const SizedBox(height: 10), Text(name, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: isUnlocked ? mossGreen : Colors.grey, fontSize: 13)), Text("$required pts", style: const TextStyle(fontSize: 11, color: Colors.grey))]));
  }
}