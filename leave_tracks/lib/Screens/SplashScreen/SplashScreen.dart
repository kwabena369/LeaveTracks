import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Map<String, dynamic>? _userData;


  @override
  void initState() {
    // _loadUserData();
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacementNamed('/Authentication');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Pattern
          CustomPaint(
            painter: BackgroundPatternPainter(),
            size: Size.infinite,
          ),

          // Main Content
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Main Logo
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              'assets/_Factory/Accra_City.jpeg', // Replace with your logo path
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Company Name
                        const Text(
                          'Phrontlyne', //  the one
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3142),
                            letterSpacing: 1.2,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Tagline
                        const Text(
                          'phronting the line', // Replace with your tagline
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF9B9B9B),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Small Logo in Corner
          Positioned(
            bottom: 30,
            right: 30,
            child: Image.asset(
              'assets/_Factory/phrontlyne_logo.svg', // Replace with your small logo path
              width: 40,
              height: 40,
            ),
          ),
        ],
      ),
    );
  }
}

class BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF5F5F5)
      ..style = PaintingStyle.fill;

    final path = Path();

    // Top right curve
    path.moveTo(size.width * 0.7, 0);
    path.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.3,
      size.width,
      size.height * 0.4,
    );
    path.lineTo(size.width, 0);
    path.close();

    // Bottom left curve
    final bottomPath = Path();
    bottomPath.moveTo(0, size.height * 0.6);
    bottomPath.quadraticBezierTo(
      size.width * 0.15,
      size.height * 0.7,
      0,
      size.height,
    );
    bottomPath.lineTo(0, size.height * 0.6);
    bottomPath.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(bottomPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
