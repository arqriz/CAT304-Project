import 'package:flutter/material.dart';
import 'home_tab.dart';
import 'activities_tab.dart';
import 'leaderboard_page.dart';
import 'profile_tab.dart';
// import 'rewards_tab.dart'; // Commented out to prevent import errors if not created yet

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = [
    const HomeTab(),
    const Center(child: Text("Rewards Coming Soon")), // Placeholder for RewardsTab
    const ActivitiesTab(),
    const LeaderboardPage(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    const Color mossGreen = Color(0xFF5B6739); 

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _selectedIndex, children: _tabs),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
        height: 85, // INCREASED from 75 to 85 to fix the overflow error
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
        // DISABLED QR SCANNER: Commented out navigation to prevent crashes
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("QR Scanner is disabled on this emulator.")),
          );
        },
        backgroundColor: Colors.grey, // Changed color to grey to show it is disabled
        shape: const CircleBorder(),
        child: const Icon(Icons.qr_code_scanner, color: Colors.white),
      ),
    );
  }
}