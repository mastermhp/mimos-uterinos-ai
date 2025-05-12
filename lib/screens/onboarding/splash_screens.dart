import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:menstrual_health_ai/constants/app_colors.dart';
import 'package:menstrual_health_ai/constants/text_styles.dart';
import 'package:menstrual_health_ai/screens/auth/login_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class SplashScreens extends StatefulWidget {
  const SplashScreens({super.key});

  @override
  State<SplashScreens> createState() => _SplashScreensState();
}

class _SplashScreensState extends State<SplashScreens> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;
  
  @override
  void initState() {
    super.initState();
    // Start auto-advancing timer
    _startAutoAdvance();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }
  
  void _startAutoAdvance() {
    // Auto-advance every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentPage < 3) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        // Navigate to login screen when all splash screens are shown
        _timer?.cancel();
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => const LoginScreen()),
        // );
      }
    });
  }


  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Page content
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              _buildSplashScreen1(),
              _buildSplashScreen2(),
              _buildSplashScreen3(),
              _buildSplashScreen4(),
            ],
          ),
          
          // Bottom navigation
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Page indicator
                SmoothPageIndicator(
                  controller: _pageController,
                  count: 4,
                  effect: ExpandingDotsEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    activeDotColor: AppColors.primary,
                    dotColor: Colors.grey.shade300,
                    spacing: 8,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Next button
                Center(
                  child: _buildNextButton(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplashScreen1() {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo image
          Image.asset(
            'assets/images/mimos_logo.png',
            width: 200,
            height: 200,
          ),
          
          const SizedBox(height: 20),
          
          // App name
          // Text(
          //   "MIMOS UTERINOS",
          //   style: TextStyle(
          //     fontSize: 28,
          //     fontWeight: FontWeight.w500,
          //     color: AppColors.primary,
          //     letterSpacing: 1.5,
          //     fontFamily: 'Montserrat',
          //   ),
          // ),
        ],
      ),
    )
    .animate()
    .fadeIn(duration: 800.ms)
    .scale(
      begin: const Offset(0.8, 0.8),
      end: const Offset(1, 1),
      duration: 800.ms,
      curve: Curves.easeOutQuad,
    );
  }

 Widget _buildSplashScreen2() {
  return SafeArea(
    child: LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        final imageHeight = screenHeight * 0.65; // 65% for image

        return Column(
          children: [
            // Full-width image with ~65% height
            SizedBox(
              width: double.infinity,
              height: imageHeight,
              child: Image.asset(
                'assets/images/tracker_mockup.png',
                fit: BoxFit.cover,
              ),
            ),

            // Spacer between image and text
            const SizedBox(height: 20),

            // App name
            const Text(
              "Mimos Uterinos",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                fontFamily: 'Montserrat',
              ),
            ),

            const SizedBox(height: 12),

            // Description
            const Text(
              "A Period Tracker &\nCalendar",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.3,
              ),
            ),
          ],
        )
        .animate()
        .fadeIn(duration: 800.ms)
        .slideX(begin: 1, end: 0, duration: 500.ms);

      },
    ),
  );
}


  Widget _buildSplashScreen3() {
  return SafeArea(
    child: LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        final imageHeight = screenHeight * 0.65;

        return Column(
          children: [
            // Full-width image with ~65% height
            SizedBox(
              width: double.infinity,
              height: imageHeight,
              child: Image.asset(
                'assets/images/track_mockup.png',
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            // Title
            const Text(
              "Track and Record with\nEase in One Place",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 12),

            // Description
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Effortlessly log your daily symptoms, moods, and activities. Use the intuitive calendar to keep track of your cycle and monitor.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
            ),
          ],
        )
        .animate()
        .fadeIn(duration: 800.ms)
        .slideX(begin: 1, end: 0, duration: 500.ms);

      },
    ),
  );
}


 Widget _buildSplashScreen4() {
  return SafeArea(
    child: LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        final imageHeight = screenHeight * 0.65;

        return Column(
          children: [
            // Full-width image with ~65% height
            SizedBox(
              width: double.infinity,
              height: imageHeight,
              child: Image.asset(
                'assets/images/knowledge_mockup.png',
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            // Title
            const Text(
              "Empower Yourself with\nKnowledge",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 12),

            // Description
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Explore a wealth of articles and tips on menstrual health, lifestyle, and well-being. Ready to get started?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
            ),
          ],
        )
        .animate()
        .fadeIn(duration: 800.ms)
        // .slideY(begin: 20, end: 0, duration: 800.ms);
        .slideX(begin: 1, end: 0, duration: 500.ms);

      },
    ),
  );
}

  Widget _buildNextButton() {
    return InkWell(
      onTap: _nextPage,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.arrow_forward_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}
