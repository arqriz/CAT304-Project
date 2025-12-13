// lib/pages/register_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _matricController = TextEditingController();
  final _facultyController = TextEditingController();
  final _collegeController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  // --- UPDATED REGISTRATION LOGIC ---
  Future<void> _performRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      final success = await authService.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _matricController.text.trim(),
        _facultyController.text.trim(),
        _collegeController.text.trim(),
      );

      if (mounted) {
        if (success) {
          // Navigate to the main route, which leads to the Dashboard
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        } else {
          // If the Firebase call failed (e.g., email already in use)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration failed. Email might be in use.'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("An unexpected error occurred: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  // --- END UPDATED REGISTRATION LOGIC ---


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD7DCC3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      
                      // Logo
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF556B2F).withOpacity(0.1),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF556B2F).withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.eco_rounded,
                          size: 50,
                          color: Color(0xFF556B2F),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Title
                      const Text(
                        "Join REGEN",
                        style: TextStyle(
                          fontSize: 36,
                          color: Color(0xFF556B2F),
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        "Start your gamified recycling journey today! 🌎",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF7A8F5A),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Registration Form
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildTextFormField(_nameController, 'Full Name', Icons.person),
                            const SizedBox(height: 16),
                            _buildTextFormField(_matricController, 'Matric Number', Icons.credit_card),
                            const SizedBox(height: 16),
                            _buildTextFormField(_facultyController, 'Faculty/School', Icons.school),
                            const SizedBox(height: 16),
                            _buildTextFormField(_collegeController, 'Residential College', Icons.apartment),
                            const SizedBox(height: 16),
                            _buildTextFormField(_emailController, 'USM Email', Icons.email, 
                                keyboardType: TextInputType.emailAddress, 
                                validator: (value) {
                                  if (value == null || value.isEmpty || !value.contains('@')) {
                                    return 'Please enter a valid USM email';
                                  }
                                  if (!value.endsWith('@student.usm.my') && !value.endsWith('@usm.my')) {
                                    return 'Please use a USM email address';
                                  }
                                  return null;
                                }),
                            const SizedBox(height: 16),
                            _buildTextFormField(_passwordController, 'Password', Icons.lock, 
                                obscureText: _obscurePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                    color: const Color(0xFF556B2F),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                validator: (value) => value!.length < 6 ? 'Password must be at least 6 characters' : null
                            ),
                            
                            const SizedBox(height: 40),

                            // Register Button
                            SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _performRegister,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF556B2F),
                                  foregroundColor: const Color(0xFFF6F2DD),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  elevation: 4,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 3,
                                        ),
                                      )
                                    : const Text(
                                        "Register",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),
                            
                            const SizedBox(height: 30),

                            // Already have account
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Already have an account? ",
                                  style: TextStyle(
                                    color: Color(0xFF7A8F5A),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(context, '/login');
                                  },
                                  child: const Text(
                                    "Login",
                                    style: TextStyle(
                                      color: Color(0xFF556B2F),
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),
                            
                            // Back to Onboarding
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.arrow_back,
                                    size: 16,
                                    color: Color(0xFF556B2F),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Back to Home",
                                    style: TextStyle(
                                      color: Color(0xFF556B2F),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper for consistent text field styling
  Widget _buildTextFormField(
    TextEditingController controller, 
    String label, 
    IconData icon, 
    {TextInputType keyboardType = TextInputType.text, bool obscureText = false, Widget? suffixIcon, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF7A8F5A)),
        prefixIcon: Icon(icon, color: const Color(0xFF556B2F)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF6F2DD), // Using the theme color
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      keyboardType: keyboardType,
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $label';
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _matricController.dispose();
    _facultyController.dispose();
    _collegeController.dispose();
    super.dispose();
  }
}