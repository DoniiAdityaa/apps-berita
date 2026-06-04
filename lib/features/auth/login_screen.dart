import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:app_berita/ui/color.dart';
import 'package:app_berita/ui/typography.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),

                // 1. Logo & App Title
                _buildLogoHeader(),

                const SizedBox(height: 48),

                // 2. Google Login Button
                _buildSocialButton(
                  icon: FontAwesomeIcons.google,
                  text: 'Continue with Google',
                  iconColor: const Color(0xFFDE4032), // Google Brand Red
                  onTap: () {
                    // Handle Google Login
                  },
                ),

                // 3. Apple Login Button
                _buildSocialButton(
                  icon: FontAwesomeIcons.apple,
                  text: 'Continue with Apple',
                  iconColor: Colors.black, // Apple Brand Black
                  onTap: () {
                    // Handle Apple Login
                  },
                ),

                const SizedBox(height: 32),

                // 4. Sign in with password Button (Tosca)
                _buildPasswordSignInButton(),

                const SizedBox(height: 48),

                // 5. Sign up Option
                _buildSignUpFooter(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Sub-Widget Helper Methods (Clean Code)
  // ===========================================================================

  /// Header widget containing logo, app name, and subtitle
  Widget _buildLogoHeader() {
    return Column(
      children: [
        // App logo or fallback placeholder
        Image.asset(
          'assets/images/img_splash_screen.png',
          width: 100,
          height: 100,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback in case the image fails to load
            return Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.newspaper,
                size: 50,
                color: primaryColor,
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        // App title (Georgia)
        const Text(
          'Newsline',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: textNeutralPrimary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        // Subtitle
        Text(
          "Welcome! Let's dive in into your account!",
          textAlign: TextAlign.center,
          style: smRegular.copyWith(
            color: textNeutralSecondary,
          ),
        ),
      ],
    );
  }

  /// Reusable outlined button for third-party authentications (Google, Apple)
  Widget _buildSocialButton({
    required FaIconData icon,
    required String text,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 56,
      margin: const EdgeInsets.only(bottom: 16),
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: borderNeutral),
          shape: const StadiumBorder(),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: FaIcon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                text,
                style: smSemiBold.copyWith(
                  color: textNeutralPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Solid main password sign-in button
  Widget _buildPasswordSignInButton() {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: Material(
        color: primaryColor,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: () {
            // Action to navigate to traditional password input screen
          },
          borderRadius: BorderRadius.circular(28),
          child: Center(
            child: Text(
              'Sign in with password',
              style: smBold.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Footer widget asking users to sign up
  Widget _buildSignUpFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: smRegular.copyWith(
            color: textNeutralSecondary,
          ),
        ),
        GestureDetector(
          onTap: () {
            // Navigate to register/sign-up screen
          },
          child: Text(
            'Sign up',
            style: smBold.copyWith(
              color: primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
