// ignore_for_file: library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:smartcook_cor/screens/index.dart';
import 'package:google_nav_bar/google_nav_bar.dart'; // Import google_nav_bar

class MainAppScreens extends StatefulWidget {
  final User? user;

  const MainAppScreens({Key? key, this.user}) : super(key: key);

  @override
  _MainAppScreensState createState() => _MainAppScreensState();
}

class _MainAppScreensState extends State<MainAppScreens> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const IngredientSelectionScreen(),
      const EatWhatScreen(),
      const FavoriteRecipesScreen(), // Assuming you have a FavoriteRecipesScreen
      ProfileScreen(user: FirebaseAuth.instance.currentUser),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              tabActiveBorder: Border.all(
                  color: Colors.black, width: 1), // tab button border
              activeColor: Colors.black,
              curve: Curves.fastOutSlowIn, // tab animation curves
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: Colors.white,
              color: Colors.black,
              tabs: const [
                GButton(
                  icon: LineIcons.home,
                  text: 'Home',
                ),
                GButton(
                  icon: LineIcons.utensils,
                  text: 'Eat What',
                ),
                GButton(
                  icon: LineIcons.heart,
                  text: 'Favorites',
                ),
                GButton(
                  icon: LineIcons.user,
                  text: 'Profile',
                ),
              ],
              selectedIndex: _currentIndex,
              onTabChange: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
