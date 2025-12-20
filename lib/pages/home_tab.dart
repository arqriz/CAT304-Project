import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../models/user_model.dart';
import '../models/activity_model.dart';
import '../services/activity_service.dart'; //

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  // Theme Colors
  static const Color mossGreen = Color(0xFF5B6739);
  static const Color lightSage = Color(0xFFDDE2C9);
  static const Color creamWhite = Color(0xFFF9F9F0);

  @override
  Widget build(BuildContext context) {
    final uid = fb_auth.FirebaseAuth.instance.currentUser?.uid;
    final ActivityService activityService = ActivityService(); // Initialize Service

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: mossGreen));
        }

        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return const Center(child: Text("User data not found"));
        }

        final user = User.fromFirestore(userSnapshot.data!);

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TOP CURVED HEADER
              _buildModernHeader(user),

              // 2. DIGITAL TREE (PROGRESS SECTION)
              _buildSectionHeader("Your Digital Tree"),
              _buildDigitalTree(user.points),

              // 3. POPULAR THEMES
              _buildSectionHeader("Popular themes"),
              SizedBox(
                height: 160,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 25),
                  children: [
                    _buildThemeCard("Eco friendly", Icons.brush_rounded),
                    _buildThemeCard("Useful items", Icons.shopping_basket_rounded),
                  ],
                ),
              ),

              // 4. STATS GRID (YOUR IMPACT)
              _buildSectionHeader("Your Impact"),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _statCard('CO2 Saved', '${user.co2Saved.toStringAsFixed(1)}kg', Icons.co2, Colors.blue),
                    _statCard('Recycled', '${user.totalRecycled.toStringAsFixed(1)}kg', Icons.recycling, Colors.green),
                  ],
                ),
              ),

              // 5. RECENT ACTIVITIES (Refactored to use ActivityService)
              _buildSectionHeader("Recent Activities"),
              _buildRecentActivitiesList(activityService), //

              const SizedBox(height: 120), // Padding for Floating Nav Bar
            ],
          ),
        );
      },
    );
  }

  // --- DIGITAL TREE LOGIC ---
  Widget _buildDigitalTree(int points) {
    IconData treeIcon;
    String stageName;
    double iconSize;
    Color treeColor;

    if (points < 100) {
      treeIcon = Icons.fiber_manual_record; // Seed
      stageName = "Seed Stage";
      iconSize = 40;
      treeColor = Colors.brown;
    } else if (points < 500) {
      treeIcon = Icons.spa; // Sprout
      stageName = "Sprouting Stage";
      iconSize = 60;
      treeColor = Colors.greenAccent;
    } else if (points < 1000) {
      treeIcon = Icons.grass; // Sapling
      stageName = "Sapling Stage";
      iconSize = 80;
      treeColor = Colors.green;
    } else {
      treeIcon = Icons.park; // Mature Tree
      stageName = "Mature Forest Tree";
      iconSize = 100;
      treeColor = mossGreen;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: creamWhite,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(seconds: 1),
            child: Icon(treeIcon, size: iconSize, color: treeColor),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Impact Progress", style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text(stageName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: mossGreen)),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (points % 500) / 500,
                    backgroundColor: lightSage,
                    color: mossGreen,
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- UI HELPER METHODS ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 30, 25, 15),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: mossGreen),
      ),
    );
  }

  Widget _buildModernHeader(User user) {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 60, 25, 40),
      decoration: const BoxDecoration(
        color: mossGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Welcome, ${user.name.split(' ')[0]}",
              style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("${user.points} Carbon Points Earned",
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
          const SizedBox(height: 25),
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(15)),
            child: const TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search items...",
                hintStyle: TextStyle(color: Colors.white60),
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.white60),
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),
        const Icon(Icons.qr_code_scanner, color: Colors.white),
      ],
    );
  }

  Widget _buildThemeCard(String title, IconData icon) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(color: creamWhite, borderRadius: BorderRadius.circular(25)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 45, color: mossGreen.withOpacity(0.6)),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: mossGreen)),
        ],
      ),
    );
  }

  Widget _statCard(String label, String val, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: creamWhite, borderRadius: BorderRadius.circular(24)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 30),
          const SizedBox(height: 8),
          Text(val, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: mossGreen)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  // UPDATED: Uses ActivityService and Activity Model
  Widget _buildRecentActivitiesList(ActivityService activityService) {
    return StreamBuilder<List<Activity>>(
      stream: activityService.getUserActivities(), //
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(left: 25),
            child: Text("No activities yet.", style: TextStyle(color: Colors.grey)),
          );
        }

        // Only show the 3 most recent activities on the Home tab
        final recentActivities = snapshot.data!.take(3).toList(); //

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: recentActivities.map((activity) {
              return _buildActivityItem(activity);
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildActivityItem(Activity activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: creamWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: mossGreen, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.type, style: const TextStyle(fontWeight: FontWeight.bold, color: mossGreen)),
                Text("${activity.quantity} ${activity.unit}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Text("+${activity.pointsEarned}", 
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
        ],
      ),
    );
  }
}