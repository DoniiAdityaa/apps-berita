import 'package:app_berita/config/constant.dart';
import 'package:app_berita/config/service_locator.dart';
import 'package:app_berita/config/user_preference.dart';
import 'package:app_berita/features/Navigation/navigation_screen.dart';
import 'package:app_berita/features/auth/country_selection/onboarding_flow_screen.dart';
import 'package:app_berita/features/auth/password_login_screen.dart';
import 'package:app_berita/features/auth/register_screen.dart';
import 'package:app_berita/firebase/firebase_apple_auth.dart';
import 'package:app_berita/firebase/firebase_google.auth.dart';
import 'package:app_berita/model/user_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app_berita/ui/color.dart';
import 'package:app_berita/ui/typography.dart';
import 'package:app_berita/ui/shared_widget/loading_indicator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseGoogleAuth _googleAuth = FirebaseGoogleAuth();
  final FirebaseAppleAuth _appleAuth = FirebaseAppleAuth();
  bool _isLoading = false;

  Future<void> _handleUserNavigation(
    String uid,
    String email,
    String name,
    String? photo,
  ) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final ref = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: firebaseDatabaseUrl,
      ).ref();
      // 1. Hapus titik setelah await
      final snapshot = await ref.child('users/$uid').get();
      // 2. Gunakan userPreference (huruf kecil)
      final userPreference = serviceLocator.get<UserPreference>();
      if (snapshot.exists) {
        final userData = Map<String, dynamic>.from(snapshot.value as Map);

        // 3. Gunakan UserModel (huruf besar)
        final userModel = UserModel.fromJson(userData);
        // 4. Sesuaikan panggilannya ke userPreference (huruf kecil) dan method yang benar
        await userPreference.setToken(uid);
        await userPreference.setUser(userModel);
        await userPreference.setHasSeenOnboarding(true);
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const NavigationScreen()),
            (route) => false,
          );
        }
      } else {
        // user baru -> arahkan ke onboarding flow
        await userPreference.setToken(uid);

        // buat data User dasar(sementara)
        final userModel = UserModel(
          id: uid,
          email: email,
          name: name,
          photo: photo,
        );
        await userPreference.setUser(userModel);

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const OnboardingFlowScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: Stack(
        children: [
          SafeArea(
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
                      icon: 'assets/images/icons8-google.svg',
                      text: 'Continue with Google',
                      onTap: () {
                        if (_isLoading) return;
                        setState(() {
                          _isLoading = true;
                        });
                        _googleAuth.signInWithGoogle(
                          onSuccess: (uid, email, firstName, lastName) {
                            final fullName = '$firstName $lastName'.trim();
                            _handleUserNavigation(uid, email, fullName, null);
                          },
                          onError: (message) {
                            setState(() {
                              _isLoading = false;
                            });
                            if (message.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Google Sign-In Error: $message')),
                              );
                            }
                          },
                        );
                      },
                    ),

                    // 3. Apple Login Button
                    _buildSocialButton(
                      icon: 'assets/images/icons8-apple.svg',
                      text: 'Continue with Apple',
                      onTap: () {
                        if (_isLoading) return;
                        setState(() {
                          _isLoading = true;
                        });
                        _appleAuth.signInWithApple(
                          onSuccess: (uid, appleId, name, email) {
                            _handleUserNavigation(uid, email, name, null);
                          },
                          onError: (message) {
                            setState(() {
                              _isLoading = false;
                            });
                            if (message.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Apple Sign-In Error: $message')),
                              );
                            }
                          },
                        );
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
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
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
              child: const Icon(Icons.newspaper, size: 50, color: primaryColor),
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
          style: smRegular.copyWith(color: textNeutralSecondary),
        ),
      ],
    );
  }

  /// Reusable outlined button for third-party authentications (Google, Apple)
  Widget _buildSocialButton({
    required String icon,
    required String text,
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
                child: SvgPicture.asset(icon, width: 22, height: 22),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                text,
                style: smSemiBold.copyWith(color: textNeutralPrimary),
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PasswordLoginScreen()),
            );
          },
          borderRadius: BorderRadius.circular(28),
          child: Center(
            child: Text(
              'Sign in with password',
              style: smBold.copyWith(color: Colors.white),
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
          style: smRegular.copyWith(color: textNeutralSecondary),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => RegisterScreen()),
            );
          },
          child: Text('Sign up', style: smBold.copyWith(color: primaryColor)),
        ),
      ],
    );
  }
}
