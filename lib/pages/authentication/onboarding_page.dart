// lib/pages/authentication/onboarding_page.dart

import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  // Premium Palette
  static const Color primaryDark = Color(0xFF2D3B2D);
  static const Color deepOlive = Color(0xFF4A5D23);
  static const Color accentGold = Color(0xFFC5A358);
  static const Color softChampagne = Color(0xFFF5F5ED);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. DYNAMIC GRADIENT BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF5B6739), // Moss Green
                  Color(0xFF2D3B2D), // Deep Forest
                ],
              ),
            ),
          ),

          // 2. SUBTLE OVERLAY PATTERN (Optional: adding a slight glow)
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // 3. ANIMATED LOGO SECTION
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 1000),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.2)),
                          ),
                          child: const Icon(
                            Icons.eco_rounded,
                            color: accentGold,
                            size: 60,
                          ),
                        ),
                        const SizedBox(height: 40),
                        const Text(
                          'REGEN',
                          style: TextStyle(
                            color: accentGold,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 6.0,
                          ),
                        ),
                        const SizedBox(height: 10),
                        RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            style: TextStyle(
                              color: softChampagne,
                              fontSize: 42,
                              height: 1.1,
                              letterSpacing: -1,
                            ),
                            children: [
                              TextSpan(
                                text: 'SAVE THE\n',
                                style: TextStyle(fontWeight: FontWeight.w300),
                              ),
                              TextSpan(
                                text: 'PLANET',
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 3),

                  // 4. GLASSMORPHIC ACTION AREA
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 1200),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return Opacity(
                        opacity: value,
                        child: child,
                      );
                    },
                    child: Column(
                      children: [
                        Text(
                          "Join the movement of gamified recycling.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: softChampagne.withOpacity(0.7),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // PREMIUM START BUTTON
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/login'),
                          child: Container(
                            width: double.infinity,
                            height: 65,
                            decoration: BoxDecoration(
                              color: softChampagne,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'GET STARTED',
                                style: TextStyle(
                                  color: primaryDark,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
