import 'package:app_berita/features/home/home_screen.dart';
import 'package:app_berita/features/profile/profile_screen.dart';
import 'package:app_berita/ui/color.dart';
import 'package:app_berita/ui/typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key, this.goToHistoryTransaction = false});

  final bool? goToHistoryTransaction;

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _OnboardScreenWidget extends StatelessWidget {
  final String title;

  const _OnboardScreenWidget({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Georgia',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textNeutralPrimary,
          ),
        ),
      ),
    );
  }
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _initialIndex = 0;

  final List<Widget> screens = [
    const HomeScreen(),
    const _OnboardScreenWidget(title: 'Explore Screen'),
    const _OnboardScreenWidget(title: 'Bookmark Screen'),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_initialIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: bgLight,
        elevation: 1,
        selectedLabelStyle: xxsRegular,
        unselectedLabelStyle: xxsRegular,
        iconSize: 25,
        currentIndex: _initialIndex,
        enableFeedback: false,
        selectedItemColor: textPrimary,
        unselectedItemColor: textDarkSecondary,
        onTap: (index) {
          setState(() {
            _initialIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            label: 'Home',
            icon: SvgPicture.asset(
              'assets/images/home.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                _initialIndex == 0 ? iconPrimary : iconDarkSecondary,
                BlendMode.srcIn,
              ),
            ),
          ),
          BottomNavigationBarItem(
            label: 'Explore',
            icon: SvgPicture.asset(
              'assets/images/explore.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                _initialIndex == 1 ? iconPrimary : iconDarkSecondary,
                BlendMode.srcIn,
              ),
            ),
          ),
          BottomNavigationBarItem(
            label: 'Bookmark',
            icon: SvgPicture.asset(
              'assets/images/bookmark.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                _initialIndex == 2 ? iconPrimary : iconDarkSecondary,
                BlendMode.srcIn,
              ),
            ),
          ),
          BottomNavigationBarItem(
            label: 'Profile',
            icon: SvgPicture.asset(
              'assets/images/user.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                _initialIndex == 3 ? iconPrimary : iconDarkSecondary,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
