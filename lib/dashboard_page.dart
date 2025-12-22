import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'pages/analytics/home_tab.dart';
import 'pages/participation/activities_tab.dart';
import 'pages/rewards/leaderboard_page.dart';
import 'pages/authentication/profile_tab.dart';
import 'pages/rewards/rewards_tab.dart';
import 'pages/participation/log_activity_page.dart';
import 'pages/admin/admin_panel.dart'; // Import the new Admin Panel

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = [
    const HomeTab(),
    const RewardsTab(),
    const ActivitiesTab(),
    const LeaderboardPage(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    const Color mossGreen = Color(0xFF5B6739); 
    final String? uid = fb_auth.FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text("EcoImpact", style: TextStyle(color: mossGreen, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // StreamBuilder checks for admin status in real-time
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData && (snapshot.data!.data() as Map<String, dynamic>)['isAdmin'] == true) {
                return IconButton(
                  icon: const Icon(Icons.admin_panel_settings_rounded, color: mossGreen),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AdminPanel())),
                );
              }
              return const SizedBox();
            },
          )
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: _tabs),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
        height: 85, 
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08), 
              blurRadius: 20, 
              offset: const Offset(0, 10)
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (i) => setState(() => _selectedIndex = i),
            backgroundColor: Colors.white,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: mossGreen,
            unselectedItemColor: Colors.grey.shade400,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.emoji_events_rounded), label: 'Rewards'),
              BottomNavigationBarItem(icon: Icon(Icons.recycling_rounded), label: 'History'),
              BottomNavigationBarItem(icon: Icon(Icons.leaderboard_rounded), label: 'Ranks'),
              BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LogActivityPage()),
          );
        },
        backgroundColor: mossGreen,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}