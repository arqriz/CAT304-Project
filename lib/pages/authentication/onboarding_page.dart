import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Colors to match your theme
    const Color mossGreen = Color(0xFF5B6739);
    const Color creamWhite = Color(0xFFF9F9F0);

    return Scaffold(
      backgroundColor: mossGreen, // Full-screen green background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              
              // 1. Eco Leaves Icon/Logo
              const Icon(
                Icons.eco_rounded,
                color: creamWhite,
                size: 80,
              ),
              
              const SizedBox(height: 20),

              // 2. Main Title
              const Text(
                'SAVE\nTHE\nPLANET',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: creamWhite,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  height: 1.1,
                ),
              ),

              const Spacer(flex: 3),

              // 3. Start Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to Login or Dashboard
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: creamWhite,
                    foregroundColor: mossGreen,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Start',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}