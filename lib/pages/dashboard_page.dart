import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import '../models/user_model.dart';
import '../models/activity_model.dart'; 
import '../services/auth_service.dart';

// --------------------------------------------------------------------------
// DASHBOARD SHELL (DashboardPage)
// --------------------------------------------------------------------------

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  
  // Using a list of widgets for the navigation tabs
  static final List<Widget> _pages = [
    const HomeTab(),
    const ActivitiesTab(),
    const LeaderboardPage(), 
    const ProfileTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('REGEN Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Implement Notifications screen
            },
          ),
        ],
      ),
      // Use IndexedStack to keep page states alive when switching tabs
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Keeps all labels visible
        currentIndex: _selectedIndex,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.recycling), label: 'Activities'),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'Leaderboard'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigates to the QR Scanner module
          Navigator.of(context).pushNamed('/scan_qr');
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.qr_code_scanner, color: Colors.white),
      ),
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,// comment bcs just to web cannot scan qr
    );
  }
}

// --------------------------------------------------------------------------
// HOME TAB (FIREBASE REAL-TIME DATA DISPLAY)
// --------------------------------------------------------------------------

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final userUid = fb_auth.FirebaseAuth.instance.currentUser?.uid;

    if (userUid == null) {
      return const Center(child: Text('User not authenticated.'));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(userUid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading data: ${snapshot.error}'));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('User profile data not found.'));
        }

        final User user = User.fromFirestore(snapshot.data!);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(context, user),
              const SizedBox(height: 24),
              _buildStatsGrid(user),
              const SizedBox(height: 24),
              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF556B2F)),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton(
                    icon: Icons.qr_code_scanner,
                    label: 'Scan QR',
                    color: const Color(0xFF556B2F),
                    onTap: () { Navigator.of(context).pushNamed('/scan_qr'); },
                  ),
                  _buildActionButton(
                    icon: Icons.add_circle,
                    label: 'Log Activity',
                    color: const Color(0xFF228B22),
                    onTap: () { Navigator.of(context).pushNamed('/log_activity'); },
                  ),
                  _buildActionButton(
                    icon: Icons.event,
                    label: 'Events',
                    color: const Color(0xFF4682B4),
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Recent Activities',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF556B2F)),
              ),
              const SizedBox(height: 16),
              // Stream only the 3 most recent activities for the home dashboard
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('activities')
                    .where('userId', isEqualTo: userUid)
                    .orderBy('timestamp', descending: true)
                    .limit(3)
                    .snapshots(),
                builder: (context, activitySnapshot) {
                  if (!activitySnapshot.hasData || activitySnapshot.data!.docs.isEmpty) {
                    return const Text("No recent activities.");
                  }
                  return Column(
                    children: activitySnapshot.data!.docs.map((doc) {
                      final act = Activity.fromFirestore(doc);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _ActivityItem(
                          title: act.type,
                          subtitle: '${act.quantity} ${act.unit} • +${act.pointsEarned} points',
                          time: DateFormat('h:mm a').format(act.timestamp),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeCard(BuildContext context, User user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Color(0xFF556B2F),
            child: Icon(Icons.person, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Welcome back!', style: TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF556B2F))),
                Text(user.faculty, style: const TextStyle(fontSize: 14, color: Color(0xFF7A8F5A))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(User user) {
    final pointsFormatter = NumberFormat('#,###');
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _StatCard(title: 'Points', value: pointsFormatter.format(user.points), icon: Icons.eco, color: const Color(0xFF6B8E23)),
        _StatCard(title: 'Rank', value: user.rank, icon: Icons.emoji_events, color: const Color(0xFFDAA520)),
        _StatCard(title: 'Recycled', value: '${user.totalRecycled.toStringAsFixed(1)} kg', icon: Icons.recycling, color: const Color(0xFF228B22)),
        _StatCard(title: 'CO₂ Saved', value: '${user.co2Saved.toStringAsFixed(1)} kg', icon: Icons.co2, color: const Color(0xFF4682B4)),
      ],
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(width: 60, height: 60, decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 30)),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------------
// HELPER WIDGETS
// --------------------------------------------------------------------------

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 14, color: Color(0xFF7A8F5A))),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF556B2F))),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String title, subtitle, time;
  const _ActivityItem({required this.title, required this.subtitle, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 1))]),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF556B2F).withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.recycling, color: Color(0xFF556B2F), size: 20)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF556B2F))), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF7A8F5A)))])) ,
          Text(time, style: const TextStyle(fontSize: 12, color: Color(0xFF7A8F5A))),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------------------
// ACTIVITIES TAB
// --------------------------------------------------------------------------

class ActivitiesTab extends StatelessWidget {
  const ActivitiesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final userUid = fb_auth.FirebaseAuth.instance.currentUser?.uid;

    if (userUid == null) return const Center(child: Text('Please log in.'));
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('activities').where('userId', isEqualTo: userUid).orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        
        if (snapshot.hasError) {
          // Display the index creation URL if missing
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: SelectableText('Error: ${snapshot.error}\n\nIf you see a "Failed Precondition" error, copy the link from your debug console to create the index.'),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return const Center(child: Text('No activities logged yet.'));

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final activity = Activity.fromFirestore(docs[index]);
            return _ActivityItem(
              title: activity.type,
              subtitle: '${activity.quantity} ${activity.unit} • +${activity.pointsEarned} points',
              time: DateFormat('MMM d').format(activity.timestamp),
            );
          },
        );
      },
    );
  }
}

// --------------------------------------------------------------------------
// LEADERBOARD PAGE
// --------------------------------------------------------------------------

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').orderBy('points', descending: true).limit(20).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final user = User.fromFirestore(docs[index]);
            return ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(user.name),
              subtitle: Text(user.residentialCollege),
              trailing: Text('${user.points} pts', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
            );
          },
        );
      },
    );
  }
}

// --------------------------------------------------------------------------
// PROFILE TAB
// --------------------------------------------------------------------------

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    if (user == null) return const Center(child: Text('User data not available.'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
          const SizedBox(height: 10),
          Text(user.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(user.email, style: const TextStyle(color: Colors.grey)),
          const Divider(height: 30),
          ListTile(leading: const Icon(Icons.school), title: const Text('Faculty'), subtitle: Text(user.faculty)),
          ListTile(leading: const Icon(Icons.badge), title: const Text('Matric No.'), subtitle: Text(user.matricNo)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () { authService.logout(); Navigator.of(context).pushReplacementNamed('/'); },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}