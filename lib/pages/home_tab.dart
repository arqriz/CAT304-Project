import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../models/user_model.dart';
import '../models/activity_model.dart';
import '../services/activity_service.dart';
import 'log_activity_page.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  // Theme Colors
  static const Color mossGreen = Color(0xFF5B6739);
  static const Color lightSage = Color(0xFFDDE2C9);
  static const Color creamWhite = Color(0xFFF9F9F0);

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Database for Search Functionality
  final List<Map<String, String>> _recyclableItems = [
    {"name": "Plastic Bottle", "points": "10 pts/unit", "category": "Plastic"},
    {"name": "Aluminum Can", "points": "15 pts/unit", "category": "Metal"},
    {"name": "Cardboard Box", "points": "20 pts/kg", "category": "Paper"},
    {"name": "Glass Jar", "points": "12 pts/unit", "category": "Glass"},
    {"name": "Newspaper", "points": "5 pts/kg", "category": "Paper"},
    {"name": "Steel Can", "points": "10 pts/unit", "category": "Metal"},
  ];

  // Logic to handle Claiming the Reward
  Future<void> _claimDailyReward(String uid, int rewardAmount) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month}-${now.day}";

    try {
      await userRef.update({
        'points': FieldValue.increment(rewardAmount), 
        'lastClaimedDate': todayStr,
      });

      if (!mounted) return;
      _showCelebrationDialog(rewardAmount);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error claiming reward: $e")),
      );
    }
  }

  void _showCelebrationDialog(int reward) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: creamWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text("🎉 Reward Claimed!", style: TextStyle(color: mossGreen, fontWeight: FontWeight.bold)),
        content: Text("You've earned +$reward bonus Carbon Points for completing your daily quest. Nature thanks you!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Awesome!", style: TextStyle(color: mossGreen, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = fb_auth.FirebaseAuth.instance.currentUser?.uid;
    final ActivityService activityService = ActivityService();

    final filteredItems = _recyclableItems
        .where((item) => item['name']!.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

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
        
        final Map<String, dynamic> userData = userSnapshot.data!.data() as Map<String, dynamic>;
        final String lastClaimed = userData['lastClaimedDate'] ?? "";
        final todayStr = "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";
        final bool alreadyClaimed = lastClaimed == todayStr;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModernHeader(user),

              if (_searchQuery.isEmpty) ...[
                _buildSectionHeader("Daily Quest"),
                // UPDATED: Now passing UID to calculate real-time progress using Admin settings
                _buildFunctionalQuest(uid!, alreadyClaimed), 

                _buildSectionHeader("Your Digital Tree"),
                _buildDigitalTree(user.points),

                _buildSectionHeader("Leaderboard Preview"),
                _buildLeaderboardPreview(),

                _buildSectionHeader("Quick Actions"),
                _buildQuickActions(),

                _buildSectionHeader("Popular themes"),
                _buildPopularThemes(),

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

                _buildRecentActivitiesList(activityService),

                const SizedBox(height: 120),
              ] else ...[
                _buildSectionHeader("Search Results for '$_searchQuery'"),
                _buildSearchResults(filteredItems),
                const SizedBox(height: 100),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildFunctionalQuest(String userId, bool alreadyClaimed) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('app_settings').doc('daily_quest').snapshots(),
      builder: (context, settingsSnapshot) {
        // Default values if settings haven't been set by Admin yet
        int target = 3;
        int rewardAmount = 50;

        if (settingsSnapshot.hasData && settingsSnapshot.data!.exists) {
          target = settingsSnapshot.data!['target'] ?? 3;
          rewardAmount = settingsSnapshot.data!['reward'] ?? 50;
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('activities')
              .where('userId', isEqualTo: userId)
              .where('timestamp', isGreaterThanOrEqualTo: todayStart)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text("Waiting for Firestore Index..."));
            }

            int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
            double progress = (count / target).clamp(0.0, 1.0);
            bool isDone = count >= target;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 25),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: alreadyClaimed 
                      ? [Colors.grey.shade400, Colors.grey.shade600] 
                      : (isDone ? [Colors.orange, Colors.deepOrange] : [mossGreen, const Color(0xFF7A8950)]),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(alreadyClaimed ? "Quest Completed!" : (isDone ? "Reward Ready!" : "Daily Quest"), 
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Icon(alreadyClaimed ? Icons.check_circle_rounded : Icons.bolt_rounded, color: Colors.white, size: 30),
                    ],
                  ),
                  const SizedBox(height: 15),
                  LinearProgressIndicator(
                    value: progress, 
                    backgroundColor: Colors.white24, 
                    color: Colors.white, 
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  const SizedBox(height: 15),
                  if (isDone && !alreadyClaimed)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _claimDailyReward(userId, rewardAmount),
                        child: Text("CLAIM +$rewardAmount POINTS", style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    )
                  else
                    Text(alreadyClaimed ? "Bonus Claimed Today" : "$count / $target items logged", 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          },
        );
      }
    );
  }

  Widget _buildDigitalTree(int points) {
    
    IconData treeIcon = points < 100 ? Icons.grass : (points < 500 ? Icons.spa : Icons.park);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: creamWhite, borderRadius: BorderRadius.circular(30)),
      child: Row(
        children: [
          Icon(treeIcon, size: 60, color: mossGreen),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Impact Progress", style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text(points < 500 ? "Growing Sprout" : "Mature Stage", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: mossGreen)),
                const SizedBox(height: 10),
                ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: (points % 500) / 500, backgroundColor: lightSage, color: mossGreen, minHeight: 8)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLeaderboardPreview() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .orderBy('points', descending: true)
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 25),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: creamWhite,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: mossGreen.withOpacity(0.1)),
          ),
          child: Column(
            children: snapshot.data!.docs.asMap().entries.map((entry) {
              int index = entry.key;
              var data = entry.value;
              return ListTile(
                dense: true,
                leading: CircleAvatar(
                  backgroundColor: index == 0 ? Colors.amber : (index == 1 ? Colors.grey : Colors.brown),
                  radius: 12,
                  child: Text("${index + 1}", style: const TextStyle(fontSize: 10, color: Colors.white)),
                ),
                title: Text(data['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                trailing: Text("${data['points']} pts", style: const TextStyle(color: mossGreen, fontWeight: FontWeight.bold)),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildPopularThemes() {
    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 25),
        children: [
          _buildThemeCard("Eco friendly", Icons.brush_rounded, "How to use sustainable materials."),
          _buildThemeCard("Useful items", Icons.shopping_basket_rounded, "Minimal packaging guides."),
          _buildThemeCard("Energy Saving", Icons.bolt_rounded, "Electricity saving tips."),
          _buildThemeCard("Water Waste", Icons.yard_rounded, "Minimize garden water consumption."),
        ],
      ),
    );
  }

  Widget _buildModernHeader(User user) {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 60, 25, 40),
      decoration: const BoxDecoration(color: mossGreen, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Welcome, ${user.name.split(' ')[0]}!", style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
              const Icon(Icons.whatshot_rounded, color: Colors.orange, size: 28),
            ],
          ),
          const SizedBox(height: 8),
          Text("${user.points} Carbon Points", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
          const SizedBox(height: 25),
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _actionButton(Icons.add_chart_rounded, "Log", () => Navigator.push(context, MaterialPageRoute(builder: (c) => const LogActivityPage()))),
          _actionButton(Icons.menu_book_outlined, "Guide", () => _showInfoDialog("Recycling Guide", "1. Clean containers\n2. Flatten boxes\n3. Check symbols.")),
          _actionButton(Icons.lightbulb_outline, "Tips", () => _showInfoDialog("Daily Tip", "Recycling one glass bottle saves energy to power a PC for 25 mins!")),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: creamWhite, borderRadius: BorderRadius.circular(20), border: Border.all(color: mossGreen.withOpacity(0.1))),
            child: Icon(icon, color: mossGreen, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: mossGreen)),
      ],
    );
  }

  Widget _buildThemeCard(String title, IconData icon, String description) {
    return GestureDetector(
      onTap: () => _showInfoDialog(title, description),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(color: creamWhite, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(icon, size: 45, color: mossGreen.withOpacity(0.6)), const SizedBox(height: 10), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: mossGreen))],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(15)),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: "Search items...",
          hintStyle: const TextStyle(color: Colors.white60),
          border: InputBorder.none,
          icon: const Icon(Icons.search, color: Colors.white60),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(padding: const EdgeInsets.fromLTRB(25, 30, 25, 15), child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: mossGreen)));
  }

  Widget _statCard(String label, String val, IconData icon, Color iconColor) {
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: creamWhite, borderRadius: BorderRadius.circular(24)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: iconColor, size: 30), const SizedBox(height: 8), Text(val, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: mossGreen)), Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey))]));
  }

  Widget _buildRecentActivitiesList(ActivityService service) {
    return StreamBuilder<List<Activity>>(
      stream: service.getUserActivities(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox();
        final recent = snapshot.data!.take(3).toList();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(children: recent.map((a) => _buildActivityItem(a)).toList()),
        );
      },
    );
  }

  Widget _buildActivityItem(Activity activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: creamWhite, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: mossGreen, size: 24),
          const SizedBox(width: 15),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(activity.type, style: const TextStyle(fontWeight: FontWeight.bold, color: mossGreen)), Text("${activity.quantity} ${activity.unit}", style: const TextStyle(fontSize: 12, color: Colors.grey))])),
          Text("+${activity.pointsEarned}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<Map<String, String>> items) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 25),
      itemCount: items.length,
      itemBuilder: (context, i) => Card(
        color: creamWhite,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          leading: const Icon(Icons.recycling_rounded, color: mossGreen),
          title: Text(items[i]['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(items[i]['category']!),
          trailing: Text(items[i]['points']!, style: const TextStyle(color: mossGreen, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: creamWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(color: mossGreen, fontWeight: FontWeight.bold)),
        content: Text(content),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Got it!", style: TextStyle(color: mossGreen, fontWeight: FontWeight.bold)))],
      ),
    );
  }
}