import 'package:app_berita/features/auth/register_screen.dart';
import 'package:app_berita/ui/shared_widget/success_dialog.dart';
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

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onTextChange);
    _passwordController.addListener(_onTextChange);
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
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            SuccessDialog.show(context);

            final navigator = Navigator.of(context);

            Future.delayed(const Duration(seconds: 3), () {
              navigator.pop(); // Close dialog

              navigator.pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const NavigationScreen(),
                ),
                (route) => false,
              );
            });
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: Text(
          'Sign in',
          style: smBold.copyWith(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
