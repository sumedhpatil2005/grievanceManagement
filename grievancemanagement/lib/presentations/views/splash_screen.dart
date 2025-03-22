import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grievancemanagement/main.dart'; // Import your main app file

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Animation duration
    );

    // Define the animation (from 0.5 to 1.5 times the original size)
    _animation = Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut, // Smooth animation curve
      ),
    );

    // Start the animation
    _controller.forward();

    // Navigate to AuthWrapper after 3 seconds
    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthWrapper()),
      );
    });
  }

  @override
  void dispose() {
    // Dispose the animation controller to avoid memory leaks
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.blue.shade900, // Set your desired background color
      body: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.scale(
              scale:
                  _animation.value, // Scale the image based on animation value
              child: Image.asset(
                'assets/allassets/ytcemlogo.png', // Replace with your logo asset path
                width: 150,
                height: 150,
              ),
            );
          },
        ),
      ),
    );
  }
}
