// lib/pages/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import '../models/user_model.dart';
import '../models/activity_model.dart'; // REQUIRED for ActivitiesTab
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
  
  // The pages list uses the fully implemented tabs.
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
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.recycling),
            label: 'Activities',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement QR Code Scanner logic 
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.qr_code_scanner, color: Colors.white),
      ),
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

    // StreamBuilder listens to real-time changes in the user's Firestore document
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

        // Convert the live Firestore snapshot to your local User model
        final User user = User.fromFirestore(snapshot.data!);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeCard(context, user),

              const SizedBox(height: 24),

              // Stats Grid (Real-time gamification stats)
              _buildStatsGrid(user),

              const SizedBox(height: 24),

              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF556B2F),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton(
                    icon: Icons.qr_code_scanner,
                    label: 'Scan QR',
                    color: const Color(0xFF556B2F),
                    onTap: () { /* Floating action button logic */ },
                  ),
                  _buildActionButton(
                    icon: Icons.add_circle,
                    label: 'Log Activity',
                    color: const Color(0xFF228B22),
                    onTap: () {
                      Navigator.of(context).pushNamed('/log_activity');
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.event,
                    label: 'Events',
                    color: const Color(0xFF4682B4),
                    onTap: () {
                      // TODO: Navigate to Events Page 
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Recent Activities (Placeholder - should be replaced by a StreamBuilder for recent activities)
              const Text(
                'Recent Activities',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF556B2F),
                ),
              ),
              const SizedBox(height: 16),
              Column(
                children: const [
                  _ActivityItem(
                    title: 'Plastic Bottles Recycled',
                    subtitle: '5 bottles • +50 points',
                    time: '2 hours ago',
                  ),
                  SizedBox(height: 12),
                  _ActivityItem(
                    title: 'Campus Clean-up Event',
                    subtitle: 'Participated • +100 points',
                    time: 'Yesterday',
                  ),
                  SizedBox(height: 12),
                  _ActivityItem(
                    title: 'Paper Recycling',
                    subtitle: '3 kg • +30 points',
                    time: '2 days ago',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Helper Widgets Methods for HomeTab ---

  Widget _buildWelcomeCard(BuildContext context, User user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
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
                const Text(
                  'Welcome back!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF556B2F),
                  ),
                ),
                Text(
                  user.faculty,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7A8F5A),
                  ),
                ),
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
        _StatCard(
          title: 'Points',
          value: pointsFormatter.format(user.points),
          icon: Icons.eco,
          color: const Color(0xFF6B8E23),
        ),
        _StatCard(
          title: 'Rank',
          value: user.rank,
          icon: Icons.emoji_events,
          color: const Color(0xFFDAA520),
        ),
        _StatCard(
          title: 'Recycled',
          value: '${user.totalRecycled.toStringAsFixed(1)} kg',
          icon: Icons.recycling,
          color: const Color(0xFF228B22),
        ),
        _StatCard(
          title: 'CO₂ Saved',
          value: '${user.co2Saved.toStringAsFixed(1)} kg',
          icon: Icons.co2,
          color: const Color(0xFF4682B4),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------------
// HELPER WIDGETS (Reused across the dashboard)
// --------------------------------------------------------------------------

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7A8F5A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF556B2F),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;

  const _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF556B2F).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.recycling,
              color: Color(0xFF556B2F),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF556B2F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7A8F5A),
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF7A8F5A),
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------------------
// ACTIVITIES TAB (User Participation Module: Activity History Log)
// --------------------------------------------------------------------------

class ActivitiesTab extends StatelessWidget {
  const ActivitiesTab({super.key});

  // Simple utility function to format time
  String _formatTimeAgo(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, h:mm a').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userUid = fb_auth.FirebaseAuth.instance.currentUser?.uid;

    if (userUid == null) {
      return const Center(child: Text('Please log in to view activities.'));
    }
    
    // Stream activities for the current user, ordered by most recent (timestamp)
    final activitiesStream = FirebaseFirestore.instance
        .collection('activities')
        .where('userId', isEqualTo: userUid)
        .orderBy('timestamp', descending: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: activitiesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading activities: ${snapshot.error}'));
        }

        final documents = snapshot.data?.docs ?? [];

        if (documents.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.recycling, size: 60, color: Theme.of(context).primaryColor.withOpacity(0.4)),
                const SizedBox(height: 16),
                const Text(
                  'No activities logged yet.',
                  style: TextStyle(fontSize: 18, color: Color(0xFF556B2F)),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/log_activity');
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Log Your First Activity'),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: documents.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            // We use ActivityModel to parse the Firestore document
            final activity = Activity.fromFirestore(documents[index]);
            
            // Format time and subtitle dynamically
            final timeAgo = _formatTimeAgo(activity.timestamp);
            final subtitle = '${activity.quantity.toStringAsFixed(0)} ${activity.unit} • +${activity.pointsEarned} points';

            return _ActivityItem(
              title: activity.type,
              subtitle: subtitle,
              time: timeAgo,
            );
          },
        );
      },
    );
  }
}

// --------------------------------------------------------------------------
// LEADERBOARD PAGE (Leaderboard and Reward Module UI)
// --------------------------------------------------------------------------

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Stream data from the 'users' collection, ordered by 'points' descending
    final leaderboardStream = FirebaseFirestore.instance
        .collection('users')
        .orderBy('points', descending: true)
        .limit(50) 
        .snapshots();

    return Scaffold(
      body: Column(
        children: [
          // Header for Leaderboard 
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
                    final rank = index + 1; 

                    return _buildLeaderboardTile(
                      rank: rank,
                      user: user,
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

  Widget _buildLeaderboardTile({
    required int rank,
    required User user,
    required bool isTopThree,
  }) {
    final pointsFormatter = NumberFormat('#,###');
    Color rankColor = Colors.grey.shade600;
    if (rank == 1) rankColor = const Color(0xFFDAA520); 
    else if (rank == 2) rankColor = Colors.grey.shade400; 
    else if (rank == 3) rankColor = const Color(0xFFCD7F32); 
    
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
        subtitle: Text(user.residentialCollege),
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
}

// --------------------------------------------------------------------------
// PROFILE TAB (User Profile and Logout)
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xFFDAA520),
                  child: Icon(Icons.person, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 10),
                Text(
                  user.name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF556B2F)),
                ),
                Text(
                  user.email,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoTile(Icons.school, 'Faculty', user.faculty),
          _buildInfoTile(Icons.apartment, 'College', user.residentialCollege),
          _buildInfoTile(Icons.badge, 'Matric No.', user.matricNo),
          _buildInfoTile(Icons.calendar_today, 'Joined', DateFormat.yMMMd().format(user.joinDate)),
          const SizedBox(height: 30),
          // Logout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                authService.logout();
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF7A8F5A)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}