import 'package:flutter/material.dart';
import 'package:app_berita/ui/color.dart';
import 'package:app_berita/ui/typography.dart';
import 'package:app_berita/config/constant.dart';
import 'package:app_berita/features/Navigation/navigation_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:app_berita/config/notification_manager.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_berita/features/auth/login_screen.dart';

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  // 1. Country selection state variables
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCountryCode;

  // 2. Topic selection state variables
  final List<String> _topics = [
    'Politics',
    'Technology',
    'Business',
    'Science',
    'Health',
    'Sports',
    'Entertainment',
    'Gaming',
    'Finance',
    'Movies',
    'Music',
    'Travel',
    'Food',
    'Fashion',
  ];
  final Set<String> _selectedTopics = {};

  // 3. Notification preferences state variables
  bool _breakingNewsEnabled = true;
  bool _dailyDigestEnabled = true;

  // 4. Create Profile state variables
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  String? _selectedAvatarUrl;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fullNameController.addListener(_onProfileFieldsChanged);
    _usernameController.addListener(_onProfileFieldsChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
  }

  void _onProfileFieldsChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    _fullNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _onBackPress() {
    if (_currentPageIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _toggleTopic(String topic) {
    setState(() {
      if (_selectedTopics.contains(topic)) {
        _selectedTopics.remove(topic);
      } else {
        if (_selectedTopics.length < 5) {
          _selectedTopics.add(topic);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You can select up to 5 topics'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Dynamically calculate progress bar target value
    // Page 0 -> 0.25, Page 1 -> 0.50, Page 2 -> 0.75, Page 3 -> 1.00
    final double targetProgress = _currentPageIndex == 0
        ? 0.25
        : _currentPageIndex == 1
        ? 0.50
        : _currentPageIndex == 2
        ? 0.75
        : 1.0;

    // Build conditional sticky bottom button
    Widget? bottomButton;
    if (_currentPageIndex == 0) {
      if (_selectedCountryCode != null) {
        bottomButton = _buildContinueButton();
      }
    } else if (_currentPageIndex == 1) {
      if (_selectedTopics.length >= 3) {
        bottomButton = _buildContinueButton();
      }
    } else if (_currentPageIndex == 2) {
      bottomButton = _buildNotificationActions();
    } else {
      bottomButton = _buildProfileActions();
    }

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: bgLight,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textNeutralPrimary),
          onPressed: _onBackPress,
        ),
        // TweenAnimationBuilder makes the progress bar animate smoothly on page change
        title: SizedBox(
          width: 180,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              tween: Tween<double>(begin: 0.25, end: targetProgress),
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: borderNeutral,
                  valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
                  minHeight: 12,
                  borderRadius: BorderRadius.circular(6),
                );
              },
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics:
              const NeverScrollableScrollPhysics(), // Disable swipe to force selection validation
          onPageChanged: (index) {
            setState(() {
              _currentPageIndex = index;
            });
          },
          children: [
            _buildCountryPage(),
            _buildTopicPage(),
            _buildNotificationPage(),
            _buildProfilePage(),
          ],
        ),
      ),
      // AnimatedSwitcher provides smooth fade & size transition for the sticky button
      bottomNavigationBar: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SizeTransition(sizeFactor: animation, child: child),
        ),
        child: bottomButton ?? const SizedBox.shrink(),
      ),
    );
  }

  // ===========================================================================
  // PAGE 1: Country Selection Page
  // ===========================================================================

  Widget _buildCountryPage() {
    final filteredCountries = supportedCOuntry.where((country) {
      final name = country['name']?.toLowerCase() ?? '';
      return name.contains(_searchQuery);
    }).toList();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Header
                  const Text(
                    'Where do you come from?',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: textNeutralPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Select your country of origin. This will help us to make the best recommendations for you.',
                    style: smRegular.copyWith(
                      color: textNeutralSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Search Box
                  _buildSearchField(),
                  const SizedBox(height: 24),

                  // Country List
                  if (filteredCountries.isEmpty)
                    _buildEmptyState()
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredCountries.length,
                      itemBuilder: (context, index) {
                        final country = filteredCountries[index];
                        final code = country['code']!;
                        final name = country['name']!;
                        final isSelected = _selectedCountryCode == code;

                        return _buildCountryTile(name, code, isSelected);
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextFormField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search country',
        hintStyle: smRegular.copyWith(
          color: textNeutralSecondary.withValues(alpha: 0.5),
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: iconNeutralPrimary,
          size: 22,
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: iconNeutralPrimary,
                ),
                onPressed: () {
                  _searchController.clear();
                },
              )
            : null,
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
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No countries found',
              style: smBold.copyWith(color: textNeutralSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching for another country name.',
              style: smRegular.copyWith(
                color: textNeutralSecondary.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountryTile(String name, String code, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCountryCode = code;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryColor : borderNeutral,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  '$flagCdnUrl/$code.png',
                  width: 64,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 64,
                    height: 40,
                    color: Colors.grey[200],
                    child: const Icon(Icons.flag_rounded, color: Colors.grey),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 64,
                        height: 40,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  name,
                  style: smSemiBold.copyWith(
                    color: textNeutralPrimary,
                    fontSize: 16,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: primaryColor,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        bottom: 24.0,
        top: 12.0,
      ),
      child: SizedBox(
        height: 56,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 0,
          ),
          child: Text(
            'Continue',
            style: smBold.copyWith(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // PAGE 2: Topic Selection Page
  // ===========================================================================

  Widget _buildTopicPage() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Header
                  const Text(
                    'Select your favorite topics',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: textNeutralPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Choose 3 to 5 categories you are interested in. We will use them to customize your feed. (${_selectedTopics.length}/5 selected)',
                    style: smRegular.copyWith(
                      color: textNeutralSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Topics list
                  Wrap(
                    spacing: 12,
                    runSpacing: 16,
                    children: _topics.map((topic) {
                      final isSelected = _selectedTopics.contains(topic);
                      return _buildTopicCard(topic, isSelected);
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopicCard(String topic, bool isSelected) {
    return GestureDetector(
      onTap: () => _toggleTopic(topic),
      child: Container(
        key: ValueKey(topic), // ensures stable widget identity for animations
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? primaryColor : borderNeutral,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              topic,
              style: smSemiBold.copyWith(
                color: isSelected ? Colors.white : textNeutralPrimary,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSelected
                  ? Icons.check_circle
                  : Icons.add_circle_outline_rounded,
              color: isSelected ? Colors.white : iconNeutralPrimary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // PAGE 3: Enable Notification Page
  // ===========================================================================

  Widget _buildNotificationPage() {
    // Determine dynamic mock notification content based on selected topics
    String mockTitle = 'Breaking News';
    String mockBody =
        'Stay updated with the latest headlines from around the world.';
    String mockCategory = 'Global';

    if (_selectedTopics.isNotEmpty) {
      final firstTopic = _selectedTopics.first;
      if (firstTopic == 'Technology' || firstTopic == 'Gaming') {
        mockTitle = 'Tech & Gaming Update';
        mockBody =
            'Nintendo announces details on their next-gen console and major game releases!';
        mockCategory = 'Technology';
      } else if (firstTopic == 'Sports') {
        mockTitle = 'Sports Alert';
        mockBody =
            'The final match is set! Read about the player transfers and tournament predictions.';
        mockCategory = 'Sports';
      } else if (firstTopic == 'Business' || firstTopic == 'Finance') {
        mockTitle = 'Market Alert';
        mockBody =
            'Global stocks surge following new interest rate announcements. Read the full analysis.';
        mockCategory = 'Business';
      } else if (firstTopic == 'Science' || firstTopic == 'Health') {
        mockTitle = 'Science & Health';
        mockBody =
            'Researchers discover a breakthrough treatment that could halt cellular aging.';
        mockCategory = 'Science';
      } else if (firstTopic == 'Politics') {
        mockTitle = 'Political Briefing';
        mockBody =
            'Upcoming election debates set to begin next week. Get the schedules and predictions.';
        mockCategory = 'Politics';
      } else if (firstTopic == 'Entertainment' ||
          firstTopic == 'Movies' ||
          firstTopic == 'Music') {
        mockTitle = 'Entertainment News';
        mockBody =
            'The nominations for this year\'s biggest film awards have been announced!';
        mockCategory = 'Entertainment';
      } else if (firstTopic == 'Travel' ||
          firstTopic == 'Food' ||
          firstTopic == 'Fashion') {
        mockTitle = 'Lifestyle Digest';
        mockBody =
            'The top 10 travel destinations for the upcoming holiday season revealed.';
        mockCategory = 'Lifestyle';
      }
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Header
                  const _FadeSlideIn(
                    child: Text(
                      'Stay in the loop',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: textNeutralPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _FadeSlideIn(
                    delay: const Duration(milliseconds: 100),
                    child: Text(
                      'Enable notifications to receive real-time breaking news and custom daily digests based on your chosen topics.',
                      style: smRegular.copyWith(
                        color: textNeutralSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Beautiful Mock Notification Card
                  _FadeSlideIn(
                    delay: const Duration(milliseconds: 200),
                    child: Center(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: borderNeutral),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // App icon placeholder
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.newspaper_rounded,
                                  color: primaryColor,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        mockCategory.toUpperCase(),
                                        style: const TextStyle(
                                          fontFamily: 'poppins',
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      const Text(
                                        'now',
                                        style: TextStyle(
                                          fontFamily: 'poppins',
                                          fontSize: 11,
                                          color: textNeutralSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    mockTitle,
                                    style: const TextStyle(
                                      fontFamily: 'poppins',
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: textNeutralPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    mockBody,
                                    style: const TextStyle(
                                      fontFamily: 'poppins',
                                      fontSize: 13,
                                      color: textNeutralSecondary,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Notification Preferences Toggle Section
                  _FadeSlideIn(
                    delay: const Duration(milliseconds: 300),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Customize notifications',
                          style: TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textNeutralPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Toggle 1: Breaking News
                        _buildPreferenceToggle(
                          title: 'Breaking News',
                          subtitle:
                              'Instant alerts for critical global headlines.',
                          value: _breakingNewsEnabled,
                          onChanged: (val) {
                            setState(() {
                              _breakingNewsEnabled = val;
                            });
                          },
                        ),
                        const Divider(color: borderNeutral, height: 24),

                        // Toggle 2: Daily Digest
                        _buildPreferenceToggle(
                          title: 'Daily Digest',
                          subtitle:
                              'A summary of stories from your favorite topics at 8 AM.',
                          value: _dailyDigestEnabled,
                          onChanged: (val) {
                            setState(() {
                              _dailyDigestEnabled = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreferenceToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textNeutralPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 12,
                  color: textNeutralSecondary,
                ),
              ),
            ],
          ),
        ),
        Switch(
          key: ValueKey(title),
          value: value,
          onChanged: onChanged,
          activeThumbColor: primaryColor,
          activeTrackColor: primaryColor.withValues(alpha: 0.3),
        ),
      ],
    );
  }

  Widget _buildNotificationActions() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        bottom: 16.0,
        top: 12.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 56,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _enableNotificationAndNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: Text(
                'Allow Notification',
                style: smBold.copyWith(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _skipNotificationAndNext,
            style: TextButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
            ),
            child: Text(
              'Maybe Later',
              style: smSemiBold.copyWith(
                color: textNeutralSecondary,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _enableNotificationAndNext() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', true);
    await prefs.setBool('breaking_news_enabled', _breakingNewsEnabled);
    await prefs.setBool('daily_digest_enabled', _dailyDigestEnabled);

    // 1. Request FCM Permission
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);
    } catch (e) {
      debugPrint('FCM permissions error: $e');
    }

    // 2. Request Local Notification Permission & Setup
    try {
      // Request OS-level permission using permission_handler
      final status = await Permission.notification.request();
      debugPrint('Notification permission status: $status');

      // Initialize the Local Notifications Plugin
      await NotificationManager.getInstance().init();

      // Trigger Welcome Notification after 5 seconds using Future.delayed for robust emulator simulation
      Future.delayed(const Duration(seconds: 5), () async {
        try {
          await NotificationManager.getInstance().showNotification(
            id: 100,
            channelId: 'welcome',
            channelName: 'Welcome Notification',
            channelDescription: 'Shows welcome notification after onboarding',
            title: 'Welcome to App Berita! 🎉',
            body:
                'Explore breaking news and personalized feeds tailored to your interest.',
            payload: 'welcome_onboarding',
          );
        } catch (e) {
          debugPrint('Welcome notification delay error: $e');
        }
      });

      // Schedule Daily Digest at 8:00 AM if enabled
      if (_dailyDigestEnabled) {
        await NotificationManager.getInstance().scheduleDailyNotification(
          id: 99,
          channelId: 'daily_digest',
          channelName: 'Daily Digest',
          channelDescription: 'Daily reminder to read your personalized news',
          title: 'Daily Digest 📰',
          body:
              'Your custom morning news digest is ready! Open the app to start reading.',
          hour: 8,
          minute: 0,
        );
      }
    } catch (e) {
      debugPrint('Local notifications setup error: $e');
    }

    if (mounted) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _skipNotificationAndNext() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', false);

    if (mounted) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  // ===========================================================================
  // PAGE 4: Create Public Profile Page
  // ===========================================================================

  Widget _buildProfilePage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Header (Omitted Earth Icon per user request)
            const _FadeSlideIn(
              child: Text(
                'Create public profile',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: textNeutralPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _FadeSlideIn(
              delay: const Duration(milliseconds: 100),
              child: Text(
                'This profile will appear public, so people can find you and the stories you share.',
                style: smRegular.copyWith(
                  color: textNeutralSecondary,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Circular Avatar with Edit/Add overlay
            _FadeSlideIn(
              delay: const Duration(milliseconds: 200),
              child: Center(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: _showAvatarPicker,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryColor, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _selectedAvatarUrl == null
                              ? Container(
                                  color: bgSurfaceNeutral,
                                  child: const Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 40,
                                    color: iconNeutralSecondary,
                                  ),
                                )
                              : Image.network(
                                  _selectedAvatarUrl!,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Shimmer.fromColors(
                                          baseColor: Colors.grey[300]!,
                                          highlightColor: Colors.grey[100]!,
                                          child: Container(color: Colors.white),
                                        );
                                      },
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        color: bgSurfaceNeutral,
                                        child: const Icon(
                                          Icons.person_rounded,
                                          size: 60,
                                          color: iconNeutralSecondary,
                                        ),
                                      ),
                                ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showAvatarPicker,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _selectedAvatarUrl == null
                                ? Icons.add_rounded
                                : Icons.edit_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Form Fields group
            _FadeSlideIn(
              delay: const Duration(milliseconds: 300),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Full Name input field
                  _buildFieldLabel('Full Name'),
                  const SizedBox(height: 8),
                  _buildProfileTextField(
                    controller: _fullNameController,
                    hintText: 'Your full name',
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: 24),

                  // Username input field
                  _buildFieldLabel('Username'),
                  const SizedBox(height: 8),
                  _buildProfileTextField(
                    controller: _usernameController,
                    hintText: 'Your username',
                    keyboardType: TextInputType.text,
                    prefixText: '@',
                    onChanged: (value) {
                      if (value.startsWith('@')) {
                        _usernameController.text = value.substring(1);
                        _usernameController
                            .selection = TextSelection.fromPosition(
                          TextPosition(offset: _usernameController.text.length),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // Bio input field
                  _buildFieldLabel('Bio'),
                  const SizedBox(height: 8),
                  _buildProfileTextField(
                    controller: _bioController,
                    hintText:
                        'Tech enthusiast, likes to share stories and connect...',
                    keyboardType: TextInputType.multiline,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'poppins',
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: textNeutralPrimary,
      ),
    );
  }

  Widget _buildProfileTextField({
    required TextEditingController controller,
    required String hintText,
    required TextInputType keyboardType,
    int maxLines = 1,
    String? prefixText,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      style: const TextStyle(
        fontFamily: 'poppins',
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: textNeutralPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: smRegular.copyWith(
          color: textNeutralSecondary.withValues(alpha: 0.4),
        ),
        prefixText: prefixText,
        prefixStyle: const TextStyle(
          fontFamily: 'poppins',
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: textNeutralPrimary,
        ),
        filled: true,
        fillColor: bgSurfaceNeutral,
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
      ),
    );
  }

  Widget _buildProfileActions() {
    final bool isEnabled =
        _fullNameController.text.trim().isNotEmpty &&
        _usernameController.text.trim().isNotEmpty &&
        _selectedAvatarUrl != null;

    return Padding(
      padding: const EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        bottom: 24.0,
        top: 12.0,
      ),
      child: SizedBox(
        height: 56,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isEnabled ? _saveProfileAndFinish : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            disabledBackgroundColor: primaryColor.withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 0,
          ),
          child: Text(
            'Finish',
            style: smBold.copyWith(
              color: isEnabled
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.6),
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        String tempAvatarUrl = _selectedAvatarUrl ?? supportedAvatars[0];

        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  top: 20.0,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
                ),
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
                      'Choose Your Persona',
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textNeutralPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select an avatar that represents you',
                      style: smRegular.copyWith(color: textNeutralSecondary),
                    ),
                    const SizedBox(height: 24),

                    // Cute Live Preview Avatar
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: primaryColor, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          tempAvatarUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(color: Colors.white),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: bgSurfaceNeutral,
                                child: const Icon(
                                  Icons.person_rounded,
                                  size: 50,
                                  color: iconNeutralSecondary,
                                ),
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Grid selection
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: supportedAvatars.length,
                      itemBuilder: (context, index) {
                        final avatarUrl = supportedAvatars[index];
                        final isSelected = tempAvatarUrl == avatarUrl;

                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              tempAvatarUrl = avatarUrl;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? primaryColor
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: ClipOval(
                                child: Image.network(
                                  avatarUrl,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Shimmer.fromColors(
                                          baseColor: Colors.grey[300]!,
                                          highlightColor: Colors.grey[100]!,
                                          child: Container(color: Colors.white),
                                        );
                                      },
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        color: bgSurfaceNeutral,
                                        child: const Icon(
                                          Icons.person_rounded,
                                          color: iconNeutralSecondary,
                                        ),
                                      ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Cute save button inside bottom sheet
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedAvatarUrl = tempAvatarUrl;
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Save Avatar',
                          style: TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveProfileAndFinish() async {
    final prefs = await SharedPreferences.getInstance();

    if (_selectedCountryCode != null) {
      await prefs.setString('selected_country_code', _selectedCountryCode!);
    }
    await prefs.setStringList('selected_topics', _selectedTopics.toList());

    await prefs.setString('profile_full_name', _fullNameController.text.trim());

    String username = _usernameController.text.trim();
    if (!username.startsWith('@')) {
      username = '@$username';
    }
    await prefs.setString('profile_username', username);
    await prefs.setString('profile_bio', _bioController.text.trim());
    await prefs.setString('profile_avatar_url', _selectedAvatarUrl ?? '');
    await prefs.setBool('onboarding_completed', true);

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const NavigationScreen()),
        (route) => false,
      );
    }
  }
}

class _FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const _FadeSlideIn({required this.child, this.delay = Duration.zero});

  @override
  State<_FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<_FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}
