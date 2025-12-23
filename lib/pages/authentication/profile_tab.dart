import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../admin/admin_panel.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  // Updated Dynamic Green Palette
  static const Color forestDeep = Color(0xFF1B261B);
  static const Color mossMain = Color(0xFF556B2F);
  static const Color sageBg =
      Color(0xFFE8EDD1); // Soft attractive green background
  static const Color leafCard = Color(0xFFF1F4E4); // Very light green for cards
  static const Color accentGold = Color(0xFFC5A358);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    if (user == null) {
      return const Center(child: CircularProgressIndicator(color: mossMain));
    }

    return Scaffold(
      backgroundColor: sageBg, // Full page background green
      body: Stack(
        children: [
          // 1. Top Decorative Header with Depth
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

          // 2. Main Content
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 70),

                  // --- Identity Header ---
                  _buildHeaderCard(user),

                  const SizedBox(height: 25),

                  // --- Admin Action (If applicable) ---
                  if (user.isAdmin) _buildPremiumAdminTile(context),

                  const SizedBox(height: 30),

                  // --- Section Title ---
                  Row(
                    children: [
                      const Icon(Icons.eco, color: mossMain, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "Student Details",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: forestDeep.withOpacity(0.8),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- Info Grid ---
                  _buildInfoGrid(user),

                  const SizedBox(height: 40),

                  // --- Logout Action ---
                  _buildLogoutButton(context, authService),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: leafCard, // Light Green Card
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
          // Profile Avatar with Gold Accent
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: forestDeep,
                child: Text(
                  user.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                      fontSize: 40, color: sageBg, fontWeight: FontWeight.bold),
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
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: forestDeep,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user.email,
                style: TextStyle(
                    color: mossMain.withOpacity(0.7),
                    fontWeight: FontWeight.w500),
              ),
              if (user.isAdmin) ...[
                const SizedBox(width: 6),
                const Icon(Icons.verified, color: Colors.blueAccent, size: 18),
              ]
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(user) {
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
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: mossMain.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: mossMain, size: 18),
          ),
          const Spacer(),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: mossMain.withOpacity(0.6),
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: forestDeep, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumAdminTile(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF8B0000), Color(0xFFD32F2F)]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.red.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6))
        ],
      ),
      child: ListTile(
        leading: const CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.settings, color: Colors.white)),
        title: const Text('Admin Dashboard',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const AdminPanel())),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthService authService) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () {
          authService.logout();
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/login', (route) => false);
        },
        icon: const Icon(Icons.power_settings_new, color: Colors.redAccent),
        label: const Text("Sign Out ",
            style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          backgroundColor: Colors.redAccent.withOpacity(0.05),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Colors.redAccent, width: 1.2)),
        ),
      ),
    );
  }
}
