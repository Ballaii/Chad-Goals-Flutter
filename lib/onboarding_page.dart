import 'package:flutter/material.dart';
import 'login_page.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {


  final PageController _controller = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF41318D), Colors.black],
            stops: [0.29, 1.0],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                children: [
                  buildPage(
                    "Welcome to Chad Goals",
                    "Ready to achieve your best form?",
                    "assets/onboarding1.png", // Replace with actual assets
                  ),
                  buildPage(
                    "Track your progress",
                    "The app will allow you to track your fitness progress and meals",
                    "assets/onboarding2.png",
                  ),
                  buildPage(
                    "Start your journey",
                    "Build strength, endurance, and the best version of yourself!",
                    "assets/onboarding3.png",
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  width: _currentIndex == index ? 12 : 8,
                  height: _currentIndex == index ? 12 : 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index ? Colors.purpleAccent : Colors.deepPurple.shade800,
                  ),
                );
              }),
            ),
            SizedBox(height: 40),
            _currentIndex == 2
                ? Padding(
                padding: EdgeInsets.only(bottom: 20),
                child:  ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 15),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => LoginPage(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                  ),
                );
              },
              child: Text("Continue",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            )
                )
            )
                : SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget buildPage(String title, String description, String imagePath) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(imagePath, height: 250),
        SizedBox(height: 20),
        Text(title, style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Text(description, style: TextStyle(fontSize: 16, color: Colors.white70), textAlign: TextAlign.center),
      ],
    );
  }
}