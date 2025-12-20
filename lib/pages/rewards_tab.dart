import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/reward_model.dart';

class RewardsTab extends StatelessWidget {
  const RewardsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    const Color mossGreen = Color(0xFF5B6739);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F0),
      appBar: AppBar(
        title: const Text("Rewards Shop"),
        backgroundColor: mossGreen,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final userData = userSnapshot.data!.data() as Map<String, dynamic>;
          final int currentPoints = userData['points'] ?? 0;

          return Column(
            children: [
              // Points Display Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                color: mossGreen,
                child: Column(
                  children: [
                    const Text("Your Balance", style: TextStyle(color: Colors.white70)),
                    Text("$currentPoints Points", 
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              
              // Rewards List
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('rewards').snapshots(),
                  builder: (context, rewardSnapshot) {
                    if (!rewardSnapshot.hasData) return const SizedBox();
                    
                    final rewards = rewardSnapshot.data!.docs
                        .map((doc) => Reward.fromFirestore(doc))
                        .toList();

                    return ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: rewards.length,
                      itemBuilder: (context, index) {
                        final reward = rewards[index];
                        final bool canAfford = currentPoints >= reward.pointCost;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFFDDE2C9),
                              child: Icon(Icons.redeem, color: mossGreen),
                            ),
                            title: Text(reward.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("${reward.pointCost} Points"),
                            trailing: ElevatedButton(
                              onPressed: canAfford ? () => _redeemReward(context, uid!, reward) : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: canAfford ? mossGreen : Colors.grey,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Redeem"),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _redeemReward(BuildContext context, String uid, Reward reward) async {
    try {
      // Deduct points from user
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'points': FieldValue.increment(-reward.pointCost),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Successfully redeemed ${reward.title}!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
}