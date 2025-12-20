import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/activity_model.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  static const Color mossGreen = Color(0xFF5B6739);
  
  // Lighter UI Colors
  static const Color lightBackground = Color(0xFFFDFDF8); 
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // --- Logic: Edit User Points ---
  Future<void> _showEditPointsDialog(User user) async {
    final TextEditingController pointsController = 
        TextEditingController(text: user.points.toString());

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Points for ${user.name}"),
        content: TextField(
          controller: pointsController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "New Point Total"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              int? newPoints = int.tryParse(pointsController.text);
              if (newPoints != null) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.id)
                    .update({'points': newPoints});
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  // --- Logic: Delete User ---
  Future<void> _showDeleteConfirmation(User user) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: Text("Are you sure you want to delete ${user.name}? This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('users').doc(user.id).delete();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${user.name} has been removed.")),
                );
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        title: const Text('Admin Console'),
        backgroundColor: mossGreen,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [Tab(text: "User Management"), Tab(text: "Community Logs")],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildUserTab(), _buildActivityTab()],
      ),
    );
  }

  // --- Tab 1: User Management ---
  Widget _buildUserTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        final users = snapshot.data!.docs.map((doc) => User.fromFirestore(doc)).toList();
        final filtered = users.where((u) => u.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search users...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filtered.length,
                itemBuilder: (context, i) {
                  final user = filtered[i];
                  return Card(
                    color: Colors.white,
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      leading: Icon(user.isAdmin ? Icons.verified_user : Icons.person, color: mossGreen),
                      title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("${user.points} pts | ${user.matricNo}"),
                      trailing: PopupMenuButton<String>(
                        onSelected: (val) {
                          if (val == 'pts') _showEditPointsDialog(user);
                          if (val == 'admin') {
                            FirebaseFirestore.instance.collection('users').doc(user.id).update({'isAdmin': !user.isAdmin});
                          }
                          if (val == 'delete') _showDeleteConfirmation(user);
                        },
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(value: 'pts', child: Text("Edit Points")),
                          PopupMenuItem(value: 'admin', child: Text(user.isAdmin ? "Remove Admin" : "Make Admin")),
                          const PopupMenuItem(value: 'delete', child: Text("Delete User", style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // --- Tab 2: Community Logs ---
  Widget _buildActivityTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('activities')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text("Access Denied: ${snapshot.error}"));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        final logs = snapshot.data!.docs.map((doc) => Activity.fromFirestore(doc)).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: logs.length,
          itemBuilder: (context, i) {
            final act = logs[i];
            return Card(
              color: Colors.white,
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                title: Text("${act.type} (${act.quantity}${act.unit})", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("User ID: ${act.userId}\nEarned: ${act.pointsEarned} pts"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () async {
                    // Revert points when activity is deleted
                    await FirebaseFirestore.instance.collection('activities').doc(act.id).delete();
                    await FirebaseFirestore.instance.collection('users').doc(act.userId).update({
                      'points': FieldValue.increment(-act.pointsEarned),
                    });
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}