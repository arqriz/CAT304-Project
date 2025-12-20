import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});

  static const Color mossGreen = Color(0xFF5B6739);
  static const Color creamWhite = Color(0xFFF9F9F0);

  // Method to Update Points
  Future<void> _updateUserPoints(BuildContext context, String userId, int currentPoints) async {
    final TextEditingController pointsController = TextEditingController(text: currentPoints.toString());

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit User Points"),
        content: TextField(
          controller: pointsController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "New Point Balance"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              int? newPoints = int.tryParse(pointsController.text);
              if (newPoints != null) {
                await FirebaseFirestore.instance.collection('users').doc(userId).update({'points': newPoints});
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // Method to Delete User
  Future<void> _deleteUser(BuildContext context, String userId, String name) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: Text("Are you sure you want to delete $name? This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('users').doc(userId).delete();
              Navigator.pop(context);
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
      backgroundColor: const Color(0xFFDDE2C9),
      appBar: AppBar(
        title: const Text('Admin Control Center'),
        backgroundColor: mossGreen,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final users = snapshot.data!.docs.map((doc) => User.fromFirestore(doc)).toList();
          
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: creamWhite,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: mossGreen.withOpacity(0.1), child: const Icon(Icons.person, color: mossGreen)),
                  title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${user.points} pts • ${user.matricNo}"),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') _updateUserPoints(context, user.id, user.points);
                      if (value == 'delete') _deleteUser(context, user.id, user.name);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text("Edit Points")])),
                      const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 18), SizedBox(width: 8), Text("Delete User", style: TextStyle(color: Colors.red))])),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}