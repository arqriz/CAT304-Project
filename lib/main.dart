import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'firebase_options.dart';

// Pages
import 'dashboard_page.dart';
import 'pages/authentication/onboarding_page.dart';
import 'pages/authentication/login_page.dart';
import 'pages/authentication/register_page.dart';
import 'pages/participation/log_activity_page.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Defining specific Moss Green Palette
    const Color mossGreen = Color(0xFF5B6739);
    const Color lightSage = Color(0xFFDDE2C9);
    const Color creamWhite = Color(0xFFF9F9F0);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'REGEN',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: mossGreen,
        
        colorScheme: ColorScheme.fromSeed(
          seedColor: mossGreen,
          primary: mossGreen,
          secondary: const Color(0xFF94A684),
          surface: creamWhite,
          onSurface: mossGreen,
        ),
        
        scaffoldBackgroundColor: lightSage,

        cardTheme: CardThemeData(
          color: creamWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),

        textTheme: const TextTheme(
          displayLarge: TextStyle(color: mossGreen, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(color: mossGreen, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: mossGreen),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: creamWhite,
            foregroundColor: mossGreen,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      
      // UPDATED: Auth State Check to prevent hanging/black screens
      home: StreamBuilder<fb_auth.User?>(
        stream: fb_auth.FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // If we have user data, go to Dashboard immediately
          if (snapshot.hasData) {
            return const DashboardPage();
          }
          
          // Only show loading if we are still waiting for the initial auth state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: lightSage,
              body: Center(child: CircularProgressIndicator(color: mossGreen)),
            );
          }
          
          // Otherwise, return to Onboarding
          return const OnboardingPage();
        },
      ),
      
      // Route Definitions
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/log_activity': (context) => const LogActivityPage(),
      },
    );
  }
}