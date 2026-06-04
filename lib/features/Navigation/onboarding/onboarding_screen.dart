import 'package:flutter/material.dart';
import 'package:app_berita/ui/color.dart';
import 'package:app_berita/ui/typography.dart';
import 'package:app_berita/features/Navigation/navigation_screen.dart';
import 'package:app_berita/config/service_locator.dart';
import 'package:app_berita/config/user_preference.dart';
import 'package:app_berita/features/auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<_OnboardingPageData> _pages = const [
    _OnboardingPageData(
      title: 'Stay Informed, Anytime,\nAnywhere',
      subtitle:
          'Welcome to our news app, your go-to source for breaking news, exclusive stories, and personalized content.',
    ),
    _OnboardingPageData(
      title: 'Read Articles &\nShare with Friends',
      subtitle:
          'Dive deep into topics that matter to you. Bookmark, highlight, and share interesting stories with your network.',
    ),
    _OnboardingPageData(
      title: 'Get Personalized Feed\n& Notifications',
      subtitle:
          'Customize your interests and receive real-time notifications about hot topics and breaking news.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleSkip() {
    _finishOnboarding();
  }

  void _handleContinue() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() async {
    final userPreference = serviceLocator.get<UserPreference>();
    
    // Save onboarding status so user doesn't see it again
    await userPreference.setHasSeenOnboarding(true);

    // Check login status
    final isLoggedIn = userPreference.getToken() != null;

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => isLoggedIn ? NavigationScreen() : const LoginScreen(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        top: false, // Allows image to go full bleed at the top
        bottom: true,
        child: Column(
          children: [
            // PageView for content sliding (Image, Title, Subtitle)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildContentPage(_pages[index]);
                },
              ),
            ),

            // Indicator Dots & Divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: _buildPageDots(),
              ),
            ),

            // Horizontal Divider
            const Divider(
              height: 1,
              thickness: 1,
              color: borderNeutral,
            ),

            // Bottom Buttons (Skip & Continue)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: _buildActionButtonRow(),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Sub-Widget Helper Methods (Clean Code)
  // ===========================================================================

  /// Page content layout (Image placeholder + Title & Subtitle Texts)
  Widget _buildContentPage(_OnboardingPageData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top 55% area: Image placeholder
        Expanded(
          flex: 11,
          child: _buildImagePlaceholder(),
        ),

        // Bottom 45% area: Text details
        Expanded(
          flex: 9,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: textNeutralPrimary,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  data.subtitle,
                  style: smRegular.copyWith(
                    color: textNeutralSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Stylized "X" placeholder indicating an image will be placed here
  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      color: primaryColor.withValues(alpha: 0.06), // Light premium teal background
      child: Center(
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.close,
            size: 40,
            color: primaryColor,
          ),
        ),
      ),
    );
  }

  /// Animating Page Indicator Dots
  Widget _buildPageDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_pages.length, (index) {
        final isActive = index == _currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(right: 6.0),
          width: isActive ? 24.0 : 6.0,
          height: 6.0,
          decoration: BoxDecoration(
            color: isActive ? primaryColor : const Color(0xFFE4E4E7),
            borderRadius: BorderRadius.circular(3.0),
          ),
        );
      }),
    );
  }

  /// Skip and Continue side-by-side buttons
  Widget _buildActionButtonRow() {
    final isLastPage = _currentIndex == _pages.length - 1;

    return SizedBox(
      height: 56,
      child: Row(
        children: [
          // Skip Button
          Expanded(
            child: Material(
              color: primaryColor.withValues(alpha: 0.08), // Translucent primary color
              borderRadius: BorderRadius.circular(28),
              child: InkWell(
                onTap: _handleSkip,
                borderRadius: BorderRadius.circular(28),
                child: Center(
                  child: Text(
                    'Skip',
                    style: smBold.copyWith(
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Continue / Get Started Button
          Expanded(
            child: Material(
              color: primaryColor,
              borderRadius: BorderRadius.circular(28),
              child: InkWell(
                onTap: _handleContinue,
                borderRadius: BorderRadius.circular(28),
                child: Center(
                  child: Text(
                    isLastPage ? 'Get Started' : 'Continue',
                    style: smBold.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Data class holding info for each onboarding page
class _OnboardingPageData {
  final String title;
  final String subtitle;

  const _OnboardingPageData({
    required this.title,
    required this.subtitle,
  });
}
