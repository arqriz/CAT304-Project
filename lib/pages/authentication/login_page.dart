// lib/pages/authentication/login_page.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // PREMIUM COLOR PALETTE
  static const Color primaryDark = Color(0xFF2D3B2D);
  static const Color accentGold = Color(0xFFC5A358);
  static const Color softChampagne = Color(0xFFF5F5ED);
  static const Color deepOlive = Color(0xFF4A5D23);

  Future<void> _performLogin(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      final success = await authService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (mounted) {
        if (success) {
          // SUCCESS: Pop the login page to reveal the Dashboard underneath.
          // We use pop() because the StreamBuilder in main.dart is already 
          // switching the 'home' widget to DashboardPage.
          Navigator.of(context).pop(); 
        } else {
          _showErrorSnackBar("Login failed. Check your credentials.");
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar("An unexpected error occurred. Please try again.");
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. DYNAMIC GRADIENT BACKGROUND
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [softChampagne, Color(0xFFE2E8D5), Color(0xFFD0D7BD)],
              ),
            ),
          ),
          
          // Background Depth Shape
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: deepOlive.withOpacity(0.08),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 2. LOGO WITH ENTRANCE ANIMATION
                    TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 1000),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, double value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.scale(
                              scale: 0.8 + (0.2 * value), child: child),
                        );
                      },
                      child: Hero(
                        tag: 'app_logo',
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(45),
                            boxShadow: [
                              BoxShadow(
                                color: primaryDark.withOpacity(0.2),
                                blurRadius: 40,
                                offset: const Offset(0, 20),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(45),
                            child: Image.asset(
                              'assets/images/first.png',
                              height: 180, // Optimized size
                              width: 180,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.eco_rounded,
                                      size: 100, color: primaryDark),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // 3. LOGIN CARD WITH GLASS-MORPHISM EFFECT
                    TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 1200),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, double value, child) {
                        return Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: Opacity(opacity: value, child: child),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(35),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.65),
                              borderRadius: BorderRadius.circular(35),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                                width: 1.5,
                              ),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    "Welcome Back",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w900,
                                      color: primaryDark,
                                      letterSpacing: -1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Sign in to continue your impact",
                                    style: TextStyle(
                                      color: primaryDark.withOpacity(0.5),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 35),
                                  
                                  // Email Field
                                  _buildTextField(
                                    controller: _emailController,
                                    label: "Student Email",
                                    icon: Icons.alternate_email_rounded,
                                    validator: (val) {
                                      if (val == null || val.isEmpty) return 'Email is required';
                                      if (!val.contains('@student.usm.my')) {
                                        return 'Use @student.usm.my email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 18),
                                  
                                  // Password Field
                                  _buildTextField(
                                    controller: _passwordController,
                                    label: "Password",
                                    icon: Icons.lock_outline_rounded,
                                    isPassword: true,
                                    obscure: _obscurePassword,
                                    onToggleVisibility: () => setState(() =>
                                        _obscurePassword = !_obscurePassword),
                                    validator: (val) => (val == null || val.isEmpty) 
                                        ? 'Password is required' : null,
                                  ),
                                  const SizedBox(height: 40),

                                  // Sign In Button
                                  _buildAnimatedButton(context),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // 4. REGISTER LINK
                    _buildRegisterLink(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedButton(BuildContext context) {
    return GestureDetector(
      onTap: _isLoading ? null : () => _performLogin(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(colors: [primaryDark, deepOlive]),
          boxShadow: [
            BoxShadow(
              color: primaryDark.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                      color: accentGold, strokeWidth: 2))
              : const Text(
                  "SIGN IN",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 2.0,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("New here? ",
            style: TextStyle(
                color: primaryDark.withOpacity(0.7),
                fontSize: 15,
                fontWeight: FontWeight.w500)),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/register'),
          child: const Text(
            "Create Account",
            style: TextStyle(
              color: deepOlive,
              fontWeight: FontWeight.w800,
              fontSize: 15,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      cursorColor: primaryDark,
      style: const TextStyle(
          color: primaryDark, fontWeight: FontWeight.w600, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: primaryDark.withOpacity(0.4),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(icon, color: primaryDark.withOpacity(0.6), size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(obscure ? Icons.visibility_off : Icons.visibility,
                    color: primaryDark.withOpacity(0.3), size: 20),
                onPressed: onToggleVisibility,
              )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.3),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: accentGold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
    );
  }
}