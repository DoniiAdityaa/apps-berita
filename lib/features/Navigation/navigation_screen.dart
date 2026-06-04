import 'package:app_berita/features/home/home_screen.dart';
import 'package:app_berita/ui/color.dart';
import 'package:app_berita/ui/typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

// ignore: must_be_immutable
class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key, this.goToHistoryTransaction = false});

  final bool? goToHistoryTransaction;

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _initialIndex = 0;

  final List<Widget> screens = [
    HomeScreen(),
    // AllBottomSheet(),
    // AssignmentScreen(),
    // TransactionScreen(),
    // ProfileScreen(),
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
              color: _initialIndex == 0 ? iconPrimary : iconDarkSecondary,
            ),
          ),
          BottomNavigationBarItem(
            label: 'Explore',
            icon: SvgPicture.asset(
              'assets/images/explore.svg',
              color: _initialIndex == 1 ? iconPrimary : iconDarkSecondary,
            ),
          ),
          BottomNavigationBarItem(
            label: 'Bookmark',
            icon: SvgPicture.asset(
              'assets/images/bookmark.svg',
              color: _initialIndex == 2 ? iconPrimary : iconDarkSecondary,
            ),
          ),
          BottomNavigationBarItem(
            label: 'Profile',
            icon: SvgPicture.asset(
              'assets/images/profile.svg',
              color: _initialIndex == 3 ? iconPrimary : iconDarkSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
