import 'package:app_berita/config/service_locator.dart';
import 'package:app_berita/config/user_preference.dart';
import 'package:app_berita/features/Navigation/navigation_screen.dart';
import 'package:app_berita/features/Navigation/onboarding/onboarding_screen.dart';
import 'package:app_berita/features/auth/login_screen.dart';
import 'package:app_berita/ui/shared_widget/loading_indicator.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 3), () {
      _navigateNext();
    });
    super.initState();
  }

  void _navigateNext() {
    final userPreference = serviceLocator.get<UserPreference>();
    final hasSeenOnboarding = userPreference.hasSeenOnboarding();
    final isLoggedIn = userPreference.getToken() != null;

    if (!hasSeenOnboarding) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        (route) => false,
      );
    } else if (isLoggedIn) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => NavigationScreen()),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildMainView();
  }

  Widget _buildMainView() {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Logo & Teks (Persis di Tengah Layar)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize
                  .min, // Agar ukuran Column hanya sebatas isinya saja
              children: [
                Image.asset(
                  'assets/images/img_splash_screen.png',
                  width: 210,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 24), // Jarak logo ke teks
                const Text(
                  'Newsline',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // 2. Loading Indicator (Di Bagian Bawah Layar)
          Positioned(
            bottom: 60, // Jarak 60 piksel dari bawah layar
            left: 0,
            right: 0,
            child: const Center(
              child: GradientCircularProgressIndicator(
                size: 45,
                strokeWidth: 7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
