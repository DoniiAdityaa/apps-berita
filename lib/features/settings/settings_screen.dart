import 'dart:ui';
import 'package:app_berita/ui/typography.dart';
import 'package:flutter/material.dart';
import 'package:app_berita/ui/color.dart';
import 'package:app_berita/config/service_locator.dart';
import 'package:app_berita/config/user_preference.dart';
import 'package:app_berita/features/profile/edit_profile_screen.dart';
import 'package:app_berita/features/legal/terms_policy_screen.dart';
import 'package:app_berita/features/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _isLoading = false;

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseAuth.instance.signOut();

      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {}

      final userPref = serviceLocator.get<UserPreference>();
      final rememberedEmail = userPref.prefs.getString('remembered_email');
      userPref.clearData();
      if (rememberedEmail != null) {
        await userPref.prefs.setString('remembered_email', rememberedEmail);
      }

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showLogoutBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: borderNeutral,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Logout',
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: borderNeutral, height: 1),
                  const SizedBox(height: 24),
                  const Text(
                    'Are you sure you want to log out?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textNeutralPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor.withValues(
                                alpha: 0.08,
                              ),
                              foregroundColor: primaryColor,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontFamily: 'poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    Navigator.pop(context);
                                    _logout();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text(
                              'Yes, Logout',
                              style: TextStyle(
                                fontFamily: 'poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: bgLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textNeutralPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textNeutralPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: primaryColor),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildSectionHeader('General'),
                      const SizedBox(height: 8),
                      _buildSettingItem(
                        icon: Icons.grid_view_rounded,
                        title: 'Customize Interests',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Customize Interests clicked'),
                            ),
                          );
                        },
                      ),
                      _buildSettingItem(
                        icon: Icons.person_outline_rounded,
                        title: 'Personal Info',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditProfileScreen(),
                            ),
                          );
                        },
                      ),
                      _buildSettingItem(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notification',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Notification settings clicked'),
                            ),
                          );
                        },
                      ),
                      _buildSettingItem(
                        icon: Icons.shield_outlined,
                        title: 'Security',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Security settings clicked'),
                            ),
                          );
                        },
                      ),
                      _buildSettingItem(
                        icon: Icons.translate_rounded,
                        title: 'Language',
                        value: 'English (US)',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Language selection clicked'),
                            ),
                          );
                        },
                      ),
                      _buildSettingItem(
                        icon: Icons.visibility_outlined,
                        title: 'Dark Mode',
                        isSwitch: true,
                        switchValue: _isDarkMode,
                        onSwitchChanged: (value) {
                          setState(() {
                            _isDarkMode = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildSectionHeader('About'),
                      const SizedBox(height: 8),
                      _buildSettingItem(
                        icon: Icons.explore_outlined,
                        title: 'Follow us on Social Media',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Social Media clicked'),
                            ),
                          );
                        },
                      ),
                      _buildSettingItem(
                        icon: Icons.help_outline_rounded,
                        title: 'Help Center',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Help Center clicked'),
                            ),
                          );
                        },
                      ),
                      _buildSettingItem(
                        icon: Icons.description_outlined,
                        title: 'Privacy Policy',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TermsPolicyScreen(),
                            ),
                          );
                        },
                      ),
                      _buildSettingItem(
                        icon: Icons.info_outline_rounded,
                        title: 'About Newsline',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('About Newsline clicked'),
                            ),
                          );
                        },
                      ),
                      _buildSettingItem(
                        icon: Icons.logout_rounded,
                        title: 'Logout',
                        titleColor: Colors.red,
                        iconColor: Colors.red,
                        showChevron: false,
                        onTap: _showLogoutBottomSheet,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'poppins',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textDarkTertiary,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Divider(color: borderNeutral, thickness: 1)),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    Color? titleColor,
    Color? iconColor,
    String? value,
    bool isSwitch = false,
    bool switchValue = false,
    ValueChanged<bool>? onSwitchChanged,
    bool showChevron = true,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: isSwitch ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? iconNeutralPrimary, size: 24),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: smSemiBold)),
            if (value != null) ...[
              Text(value, style: smSemiBold),
              const SizedBox(width: 8),
            ],
            if (isSwitch)
              Switch(
                value: switchValue,
                onChanged: onSwitchChanged,
                activeThumbColor: primaryColor,
                activeTrackColor: primaryColor.withValues(alpha: 0.5),
              )
            else if (showChevron)
              const Icon(
                Icons.chevron_right_rounded,
                color: iconDarkTertiary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
