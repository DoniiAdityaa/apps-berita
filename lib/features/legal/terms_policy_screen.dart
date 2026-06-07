import 'package:app_berita/ui/color.dart';
import 'package:app_berita/ui/typography.dart';
import 'package:flutter/material.dart';

class TermsPolicyScreen extends StatelessWidget {
  const TermsPolicyScreen({super.key});

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
        title: const Text(
          'Terms & Policy',
          style: TextStyle(
            fontFamily: 'poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textNeutralPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Terms of Service',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: textNeutralPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Last updated: June 7, 2026',
                style: smRegular.copyWith(color: textNeutralSecondary),
              ),
              const SizedBox(height: 24),

              // Section 1
              _buildSection(
                '1. Acceptance of Terms',
                'By accessing or using the Newsline application ("App"), you agree to be bound by these Terms of Service ("Terms"). '
                    'If you do not agree with these Terms, you must not access or use the App.',
              ),

              // Section 2
              _buildSection(
                '2. User Accounts',
                'When you create an account, you must provide accurate and complete information. '
                    'You are responsible for maintaining the confidentiality of your account credentials and for all activities under your account. '
                    'You must notify us immediately of any unauthorized use of your account.',
              ),

              // Section 3
              _buildSection(
                '3. Content & Usage',
                'The App provides aggregated news content from various third-party sources. '
                    'We do not claim ownership of the content provided by these sources. '
                    'You may not copy, distribute, or modify content from the App without proper authorization.',
              ),

              // Section 4
              _buildSection(
                '4. User Conduct',
                'You agree not to:\n'
                    '• Use the App for any unlawful purpose\n'
                    '• Attempt to gain unauthorized access to any part of the App\n'
                    '• Interfere with or disrupt the App or servers\n'
                    '• Impersonate any person or entity\n'
                    '• Collect or store personal data about other users',
              ),

              // Section 5
              _buildSection(
                '5. Intellectual Property',
                'The App and its original content, features, and functionality are owned by Newsline '
                    'and are protected by international copyright, trademark, patent, trade secret, and other intellectual property laws.',
              ),

              const SizedBox(height: 16),
              const Divider(color: borderNeutral),
              const SizedBox(height: 16),

              // Privacy Policy Header
              const Text(
                'Privacy Policy',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: textNeutralPrimary,
                ),
              ),
              const SizedBox(height: 24),

              // Privacy Section 1
              _buildSection(
                '1. Information We Collect',
                'We collect the following types of information:\n'
                    '• Account information (name, email, profile picture)\n'
                    '• Usage data (topics of interest, reading history)\n'
                    '• Device information (device model, operating system)\n'
                    '• Location data (country selection for personalized news)',
              ),

              // Privacy Section 2
              _buildSection(
                '2. How We Use Your Information',
                'We use the collected information to:\n'
                    '• Provide personalized news content\n'
                    '• Send notifications about breaking news and daily digests\n'
                    '• Improve and optimize the App experience\n'
                    '• Communicate with you about updates and changes',
              ),

              // Privacy Section 3
              _buildSection(
                '3. Data Security',
                'We implement industry-standard security measures to protect your personal information. '
                    'Your data is stored securely using Firebase services with encryption in transit and at rest. '
                    'However, no method of electronic storage is 100% secure.',
              ),

              // Privacy Section 4
              _buildSection(
                '4. Your Rights',
                'You have the right to:\n'
                    '• Access your personal data\n'
                    '• Update or correct your information\n'
                    '• Delete your account and associated data\n'
                    '• Opt out of notifications at any time',
              ),

              // Privacy Section 5
              _buildSection(
                '5. Contact Us',
                'If you have any questions about these Terms or our Privacy Policy, '
                    'please contact us at support@newsline.app.',
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textNeutralPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: smRegular.copyWith(
              color: textNeutralSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
