import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';
import 'workout_screen.dart';
import 'food_tracker_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  final user = FirebaseAuth.instance.currentUser;

  final List<Widget> _pages = const [
    DashboardScreen(),
    ProfileScreen(),
    WorkoutPage(),
    FoodTrackerPage(),
  ];

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: _pages,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(0),
        child: Container(
          height: 83,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF41318D).withValues(),
                const Color(0xFF120E27).withValues(),
              ],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(
                  Icons.grid_view,
                  color: _selectedIndex == 0 ? Colors.purple.shade300 : Colors.white,
                ),
                onPressed: () => _onItemTapped(0),
              ),
              IconButton(
                icon: Icon(
                  Icons.person,
                  color: _selectedIndex == 1 ? Colors.purple.shade300 : Colors.white,
                ),
                onPressed: () => _onItemTapped(1),
              ),
              IconButton(
                icon: Icon(
                  Icons.fitness_center,
                  color: _selectedIndex == 2 ? Colors.purple.shade300 : Colors.white,
                ),
                onPressed: () => _onItemTapped(2),
              ),
              IconButton(
                icon: Icon(
                  Icons.restaurant,
                  color: _selectedIndex == 3 ? Colors.purple.shade300 : Colors.white,
                ),
                onPressed: () => _onItemTapped(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
