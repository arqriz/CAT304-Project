import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../models/user_model.dart';
import '../admin/admin_panel.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  // Updated Dynamic Green Palette
  static const Color forestDeep = Color(0xFF1B261B);
  static const Color mossMain = Color(0xFF556B2F);
  static const Color sageBg = Color(0xFFE8EDD1); 
  static const Color leafCard = Color(0xFFF1F4E4); 
  static const Color accentGold = Color(0xFFC5A358);

  @override
  Widget build(BuildContext context) {
    final String? uid = fb_auth.FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Center(child: Text("Please log in again."));
    }

    return Scaffold(
      backgroundColor: sageBg,
      body: StreamBuilder<DocumentSnapshot>(
        // Direct stream to the user document
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          // 1. Handle Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: mossMain),
            );
          }

          // 2. Handle Document Missing (Common right after Signup)
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return _buildLoadingOrErrorState(context, "Finalizing your profile...");
          }

          // 3. Handle Errors (e.g., Permission Denied)
          if (snapshot.hasError) {
            return _buildErrorState(context, "Permission Denied. Check Rules.");
          }

          final user = User.fromFirestore(snapshot.data!);
          final Map<String, dynamic> rawData = snapshot.data!.data() as Map<String, dynamic>;
          final bool isAdmin = rawData['isAdmin'] ?? false;

          return Stack(
            children: [
              // Top Decorative Header
              Container(
                height: 240,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [forestDeep, mossMain],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(60),
                    bottomRight: Radius.circular(60),
                  ),
                ),
              ),

              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 70),
                      _buildHeaderCard(user, isAdmin),
                      const SizedBox(height: 25),
                      if (isAdmin) _buildPremiumAdminTile(context),
                      const SizedBox(height: 30),
                      _buildSectionLabel("Student Details"),
                      const SizedBox(height: 16),
                      _buildInfoGrid(user),
                      const SizedBox(height: 40),
                      _buildLogoutButton(context),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Row(
      children: [
        const Icon(Icons.eco, color: mossMain, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: forestDeep.withOpacity(0.8),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCard(User user, bool isAdmin) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: leafCard,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: forestDeep.withOpacity(0.12),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: forestDeep,
                child: Text(
                  user.name.isNotEmpty ? user.name.substring(0, 1).toUpperCase() : "?",
                  style: const TextStyle(fontSize: 40, color: sageBg, fontWeight: FontWeight.bold),
                ),
              ),
              const CircleAvatar(
                radius: 15,
                backgroundColor: accentGold,
                child: Icon(Icons.edit, size: 14, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            user.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: forestDeep),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: TextStyle(color: mossMain.withOpacity(0.7), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(User user) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildInfoCard(Icons.school, 'Faculty', user.faculty),
        _buildInfoCard(Icons.location_city, 'College', user.residentialCollege),
        _buildInfoCard(Icons.fingerprint, 'Matric No.', user.matricNo),
        _buildInfoCard(Icons.energy_savings_leaf, 'Impact', 'Elite Member'),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: leafCard,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: mossMain, size: 18),
          const Spacer(),
          Text(label, style: TextStyle(fontSize: 10, color: mossMain.withOpacity(0.6), fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, color: forestDeep, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildPremiumAdminTile(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF8B0000), Color(0xFFD32F2F)]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: ListTile(
        leading: const Icon(Icons.admin_panel_settings, color: Colors.white),
        title: const Text('Admin Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminPanel())),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          await fb_auth.FirebaseAuth.instance.signOut();
          if (context.mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
          }
        },
        icon: const Icon(Icons.logout, color: Colors.redAccent),
        label: const Text("Sign Out", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          side: const BorderSide(color: Colors.redAccent),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  Widget _buildLoadingOrErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: mossMain),
          const SizedBox(height: 20),
          Text(message, style: const TextStyle(color: mossMain)),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.redAccent)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => fb_auth.FirebaseAuth.instance.signOut(),
            child: const Text("Logout & Try Again"),
          )
        ],
      ),
    );
  }
}