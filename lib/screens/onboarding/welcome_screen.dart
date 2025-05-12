import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:menstrual_health_ai/constants/app_colors.dart';
import 'package:menstrual_health_ai/constants/text_styles.dart';
import 'package:menstrual_health_ai/screens/auth/login_screen.dart';
import 'package:menstrual_health_ai/widgets/animated_gradient_button.dart';
import 'package:menstrual_health_ai/widgets/wave_clipper.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background gradient with wave
          ClipPath(
            clipper: WaveClipper(),
            child: Container(
              height: size.height * 0.6,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  
                  // App logo and name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
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
                            Icons.favorite_rounded,
                            color: AppColors.primary,
                            size: 36,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        "Luna AI",
                        style: TextStyles.heading1.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: -20, end: 0, curve: Curves.easeOutQuad),
                  
                  const SizedBox(height: 40),
                  
                  // Illustration
                  Container(
                    width: size.width * 0.8,
                    height: size.width * 0.8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.spa_rounded,
                        size: size.width * 0.4,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 800.ms)
                  .scale(delay: 300.ms, duration: 800.ms, curve: Curves.easeOutQuad),
                  
                  const Spacer(),
                  
                  // Welcome text
                  Text(
                    "Your Personal AI\nMenstrual Health Coach",
                    style: TextStyles.heading2.copyWith(
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  )
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 800.ms)
                  .slideY(delay: 600.ms, begin: 20, end: 0, curve: Curves.easeOutQuad),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    "Track your cycle, understand your body, and get personalized insights with AI technology",
                    style: TextStyles.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  )
                  .animate()
                  .fadeIn(delay: 800.ms, duration: 800.ms),
                  
                  const SizedBox(height: 40),
                  
                  // Get Started button
                  AnimatedGradientButton(
                    text: "Get Started",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                  )
                  .animate()
                  .fadeIn(delay: 1000.ms, duration: 800.ms)
                  .slideY(delay: 1000.ms, begin: 20, end: 0, curve: Curves.easeOutQuad),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
