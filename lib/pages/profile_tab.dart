import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'admin_panel.dart'; // Ensure this exists

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  // Theme Colors matching your modern interface
  static const Color mossGreen = Color(0xFF5B6739);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    if (user == null) {
      return const Center(child: CircularProgressIndicator(color: mossGreen));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          
          // Profile Picture
          const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFFDAA520),
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          
          const SizedBox(height: 16),
          
          // Name and Admin Badge Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold, 
                  color: mossGreen
                ),
              ),
              if (user.isAdmin) ...[
                const SizedBox(width: 8),
                const Icon(Icons.verified, color: Colors.blue, size: 20),
              ]
            ],
          ),
          
          Text(user.email, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 32),
          
          // Info Cards Section
          _buildInfoSection(user),

          const SizedBox(height: 20),

          // --- ADMIN PANEL BUTTON (Logic Enabled) ---
          if (user.isAdmin)
            _buildAdminButton(context),

          const SizedBox(height: 40),
          
          // Logout Button
          _buildLogoutButton(context, authService),
          
          const SizedBox(height: 100), // Navigation spacer
        ],
      ),
    );
  }

  Widget _buildInfoSection(user) {
    return Column(
      children: [
        _infoTile(Icons.school_outlined, 'Faculty', user.faculty),
        _infoTile(Icons.apartment_outlined, 'College', user.residentialCollege),
        _infoTile(Icons.badge_outlined, 'Matric No.', user.matricNo),
      ],
    );
  }

  Widget _buildAdminButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: ListTile(
        leading: const Icon(Icons.admin_panel_settings, color: Colors.red),
        title: const Text(
          'Admin Dashboard', 
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
        onTap: () {
          // --- NAVIGATION ENABLED ---
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminPanel()),
          );
        },
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthService authService) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          authService.logout();
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.red,
          elevation: 0,
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: const Text('Logout'),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: mossGreen),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(
                value, 
                style: const TextStyle(fontWeight: FontWeight.w600, color: mossGreen)
              ),
            ],
          ),
        ],
      ),
    );
  }
}