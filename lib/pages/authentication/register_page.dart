// lib/pages/authentication/register_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _matricController = TextEditingController();

  // Dropdown Selections
  String? _selectedFaculty;
  String? _selectedCollege;

  bool _isLoading = false;
  bool _obscurePassword = true;

  // Premium Color Palette
  static const Color forestDeep = Color(0xFF1B261B);
  static const Color mossMain = Color(0xFF556B2F);
  static const Color leafLight = Color(0xFFDDE4C1);

  // Data Lists
  final List<String> _faculties = [
    'Computer Science',
    'Biological Sciences',
    'Chemical Sciences',
    'Mathematical Sciences',
    'Physics',
    'Humanities',
    'Social Sciences',
    'Management',
    'Arts',
    'Educational Studies',
  ];

  final List<String> _colleges = [
    'Aman Damai',
    'Bakti Permai',
    'Cahaya Gemilang',
    'Fajar Harapan',
    'Indah Kembara',
    'Restu',
    'Saujana',
    'Tekun',
  ];

  Future<void> _performRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      final success = await authService.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _matricController.text.trim(),
        _selectedFaculty ?? '',
        _selectedCollege ?? '',
      );

      if (mounted) {
        if (success) {
          // Success: Navigate to login immediately
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Registration successful! Please login.'),
                backgroundColor: mossMain),
          );
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          // Failure: Stop loading and show error
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Registration failed. Email might already be in use.'),
                backgroundColor: Colors.redAccent),
          );
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _buildBackgroundPainter(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildGlassCard(),
                    const SizedBox(height: 20),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: forestDeep.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          padding: const EdgeInsets.all(28.0),
          child: Column(
            children: [
              _buildIconHeader(),
              const SizedBox(height: 20),
              const Text(
                "Join REGEN",
                style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: forestDeep,
                    letterSpacing: -1.2),
              ),
              const SizedBox(height: 30),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildInput(_nameController, "Full Name", Icons.person_outline),
                    _buildInput(_matricController, "Matric Number", Icons.badge_outlined),
                    _buildDropdown(
                      label: "Select Faculty/School",
                      icon: Icons.school_outlined,
                      items: _faculties,
                      value: _selectedFaculty,
                      onChanged: (val) => setState(() => _selectedFaculty = val),
                    ),
                    _buildDropdown(
                      label: "Residential College",
                      icon: Icons.apartment_outlined,
                      items: _colleges,
                      value: _selectedCollege,
                      onChanged: (val) => setState(() => _selectedCollege = val),
                    ),
                    _buildInput(_emailController, "USM Email", Icons.alternate_email_rounded, 
                      validator: (val) => (val != null && !val.contains('@student.usm.my')) ? 'Must be USM email' : null),
                    _buildInput(
                      _passwordController,
                      "Password",
                      Icons.lock_open_rounded,
                      isPass: true,
                      validator: (val) => (val != null && val.length < 6) ? 'Min 6 characters' : null,
                      suffix: IconButton(
                        icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: mossMain),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildRegisterButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required List<String> items,
    required String? value,
    required ValueChanged<String?> onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 14))))
            .toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? 'Selection required' : null,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: mossMain, size: 22),
          labelText: label,
          labelStyle: const TextStyle(color: forestDeep, fontWeight: FontWeight.w500),
          filled: true,
          fillColor: Colors.white.withOpacity(0.5),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: mossMain, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
          ),
        ),
        dropdownColor: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildIconHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: mossMain,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: mossMain.withOpacity(0.4), blurRadius: 20, spreadRadius: 2)
        ],
      ),
      child: const Icon(Icons.eco_rounded, size: 45, color: Colors.white),
    );
  }

  Widget _buildBackgroundPainter() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [leafLight, Colors.white]),
      ),
      child: CustomPaint(painter: WavePainter()),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String label, IconData icon,
      {bool isPass = false, Widget? suffix, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        obscureText: isPass ? _obscurePassword : false,
        validator: validator ?? (val) => (val == null || val.isEmpty) ? 'Required' : null,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: mossMain, size: 22),
          suffixIcon: suffix,
          labelText: label,
          labelStyle: const TextStyle(color: forestDeep, fontWeight: FontWeight.w500),
          filled: true,
          fillColor: Colors.white.withOpacity(0.5),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: mossMain, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(colors: [mossMain, forestDeep]),
        boxShadow: [
          BoxShadow(color: forestDeep.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _performRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : const Text("Create Account",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Already a member? ", style: TextStyle(color: forestDeep, fontSize: 15)),
            GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(context, '/login'),
              child: const Text("Login Now",
                  style: TextStyle(color: mossMain, fontWeight: FontWeight.w800, decoration: TextDecoration.underline)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.keyboard_backspace_rounded, size: 18, color: forestDeep),
          label: const Text("Back to Start", style: TextStyle(color: forestDeep, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = const Color(0xFF556B2F).withOpacity(0.15)..style = PaintingStyle.fill;
    var path = Path();
    path.moveTo(0, size.height * 0.3);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.35, size.width * 0.5, size.height * 0.3);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.25, size.width, size.height * 0.3);
    path.lineTo(size.width, 0); path.lineTo(0, 0);
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}