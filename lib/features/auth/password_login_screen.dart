import 'package:app_berita/config/constant.dart';
import 'package:app_berita/config/service_locator.dart';
import 'package:app_berita/config/user_preference.dart';
import 'package:app_berita/features/auth/country_selection/onboarding_flow_screen.dart';
import 'package:app_berita/features/auth/register_screen.dart';
import 'package:app_berita/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:app_berita/ui/color.dart';
import 'package:app_berita/ui/typography.dart';
import 'package:app_berita/features/Navigation/navigation_screen.dart';
import 'package:flutter_svg/svg.dart';

class PasswordLoginScreen extends StatefulWidget {
  const PasswordLoginScreen({super.key});

  @override
  State<PasswordLoginScreen> createState() => _PasswordLoginScreenState();
}

class _PasswordLoginScreenState extends State<PasswordLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Login ke Firebase Auth
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final uid = credential.user!.uid;
      final email = credential.user!.email ?? '';

      // Simpan atau hapus email sesuai checkbox Remember Me
      final prefs = serviceLocator.get<UserPreference>().prefs;
      if (_rememberMe) {
        await prefs.setString('remembered_email', _emailController.text.trim());
      } else {
        await prefs.remove('remembered_email');
      }

      // 2. Cek database: apakah profile user sudah lengkap?
      final ref = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: firebaseDatabaseUrl,
      ).ref();

      final snapshot = await ref.child('users/$uid').get();
      final userPreference = serviceLocator.get<UserPreference>();

      if (snapshot.exists) {
        // 3a. User lama (profile lengkap) → langsung ke Home
        final userData = Map<String, dynamic>.from(snapshot.value as Map);
        final userModel = UserModel.fromJson(userData);
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
        // 3b. User baru (belum isi profile) → ke OnboardingFlow
        await userPreference.setToken(uid);
        final userModel = UserModel(id: uid, email: email);
        await userPreference.setUser(userModel);

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const OnboardingFlowScreen()),
            (route) => false,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No account found with this email.';
          break;
        case 'wrong-password':
          message = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          message = 'Invalid email format.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        case 'invalid-credential':
          message = 'Invalid email or password.';
          break;
        default:
          message = e.message ?? 'An unexpected error occurred.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
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
  void initState() {
    super.initState();
    _emailController.addListener(_onTextChange);
    _passwordController.addListener(_onTextChange);
    _loadRememberedEmail();
  }

  Future<void> _loadRememberedEmail() async {
    final userPreference = serviceLocator.get<UserPreference>();
    final savedEmail = userPreference.prefs.getString('remembered_email');
    if (savedEmail != null && savedEmail.isNotEmpty) {
      _emailController.text = savedEmail;
      setState(() {
        _rememberMe = true;
      });
    }
  }

  void _onTextChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _emailController.removeListener(_onTextChange);
    _passwordController.removeListener(_onTextChange);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: bgLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textNeutralPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // 1. Welcome Header
                  _buildHeader(),
                  const SizedBox(height: 36),

                  // 2. Email Section
                  _buildEmailField(),
                  const SizedBox(height: 24),

                  // 3. Password Section
                  _buildPasswordField(),
                  const SizedBox(height: 16),

                  // 4. Remember me & Forgot password row
                  _buildRememberMeRow(),
                  const SizedBox(height: 40),

                  Divider(color: Colors.grey[200], thickness: 2),

                  // 5. Sign up Option Footer
                  const SizedBox(height: 40),

                  _buildSignUpFooter(),

                  const SizedBox(height: 40),

                  // 6. Bottom Sticky Sign in Button
                  _buildSignInButton(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Sub-Widget Helper Methods (Clean Code)
  // ===========================================================================

  /// Renders the Welcome back title and short instructions
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Welcome back',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: textNeutralPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Please enter your email & password to sign in.',
          style: smRegular.copyWith(color: textNeutralSecondary),
        ),
      ],
    );
  }

  /// Renders the Email input field with a descriptive label
  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Email', style: smSemiBold),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Email cannot be empty';
            }
            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
            if (!emailRegex.hasMatch(value.trim())) {
              return 'Please enter a valid email';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Email',
            hintStyle: smRegular.copyWith(
              color: textNeutralSecondary.withValues(alpha: 0.5),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: SvgPicture.asset(
                'assets/images/icons8-email-48.svg',
                width: 8,
                colorFilter: ColorFilter.mode(
                  _emailController.text.isNotEmpty
                      ? black800
                      : textNeutralSecondary,
                  BlendMode.srcIn,
                ),
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 16.0,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: borderNeutral),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: borderNeutral),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  /// Renders the Password input field with dynamic show/hide toggle
  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Password', style: smSemiBold),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password cannot be empty';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Password',
            hintStyle: smRegular.copyWith(
              color: textNeutralSecondary.withValues(alpha: 0.5),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: SvgPicture.asset(
                'assets/images/icons8-password-32.svg',
                width: 8,
                colorFilter: ColorFilter.mode(
                  _passwordController.text.isNotEmpty
                      ? black800
                      : textNeutralSecondary,
                  BlendMode.srcIn,
                ),
              ),
            ),
            suffixIcon: IconButton(
              icon: SvgPicture.asset(
                _obscurePassword
                    ? 'assets/images/icons8-invisible-24.svg'
                    : 'assets/images/icons8-eye-24.svg',
                width: 20,
                colorFilter: ColorFilter.mode(
                  _passwordController.text.isNotEmpty
                      ? black800
                      : textNeutralSecondary,
                  BlendMode.srcIn,
                ),
              ),
              // Icon(
              //   _obscurePassword
              //       ? Icons.visibility_off_outlined
              //       : Icons.visibility_outlined,
              //   color: iconNeutralPrimary,
              //   size: 22,
              // ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 16.0,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: borderNeutral),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: borderNeutral),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  /// Remember Me checkbox and Forgot Password text button
  Widget _buildRememberMeRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _rememberMe,
                activeColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                side: const BorderSide(color: primaryColor, width: 2),
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Remember me',
              style: smSemiBold.copyWith(color: textNeutralPrimary),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            // Handle Forgot Password
          },
          child: Text(
            'Forgot password?',
            style: smBold.copyWith(color: primaryColor),
          ),
        ),
      ],
    );
  }

  /// Bottom footer option for navigating to SignUp
  Widget _buildSignUpFooter() {
    return Center(
      child: Row(
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
                MaterialPageRoute(builder: (context) => const RegisterScreen()),
              );
              // Handle Register Navigation
            },
            child: Text('Sign up', style: smBold.copyWith(color: primaryColor)),
          ),
        ],
      ),
    );
  }

  /// The sticky "Sign in" action button at the bottom
  Widget _buildSignInButton() {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : () => _handleSignIn(),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                'Sign in',
                style: smBold.copyWith(color: Colors.white, fontSize: 16),
              ),
      ),
    );
  }
}
