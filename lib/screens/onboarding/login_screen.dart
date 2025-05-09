import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:menstrual_health_ai/constants/app_colors.dart';
import 'package:menstrual_health_ai/constants/text_styles.dart';
import 'package:menstrual_health_ai/screens/dashboard/bottom_nav.dart';
import 'package:menstrual_health_ai/screens/onboarding/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                
                // Logo
                Center(
                  child: Image.asset(
                    'assets/images/mimos_logo.png',
                    width: 100,
                    height: 100,
                  ),
                )
                .animate()
                .fadeIn(duration: 800.ms)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1, 1),
                  duration: 800.ms,
                  curve: Curves.easeOutQuad,
                ),
                
                const SizedBox(height: 40),
                
                // Title
                const Text(
                  "Let's Get Started!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                )
                .animate()
                .fadeIn(delay: 200.ms, duration: 600.ms),
                
                const SizedBox(height: 16),
                
                // Subtitle
                const Text(
                  "Let's dive in into your account",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                )
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms),
                
                const SizedBox(height: 60),
                
                // Social login buttons
                _buildSocialLoginButton(
                  icon: 'assets/images/google_icon.png',
                  text: "Continue with Google",
                  delay: 600,
                ),
                
                const SizedBox(height: 16),
                
                _buildSocialLoginButton(
                  icon: 'assets/images/apple_icon.png',
                  text: "Continue with Apple",
                  delay: 800,
                ),
                
                const SizedBox(height: 16),
                
                _buildSocialLoginButton(
                  icon: 'assets/images/facebook_icon.png',
                  text: "Continue with Facebook",
                  delay: 1000,
                ),
                
                const SizedBox(height: 16),
                
                _buildSocialLoginButton(
                  icon: 'assets/images/x_icon.png',
                  text: "Continue with X",
                  delay: 1200,
                ),
                
                const SizedBox(height: 40),
                
                // Sign up button
                _buildPrimaryButton(
                  text: "Sign up",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  delay: 1400,
                ),
                
                const SizedBox(height: 16),
                
                // Sign in button
                _buildSecondaryButton(
                  text: "Sign in",
                  onPressed: () {
                    // For existing users, navigate directly to the main app
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const BottomNav()),
                    );
                  },
                  delay: 1600,
                ),
                
                const SizedBox(height: 24),
                
                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Privacy Policy",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    const Text(
                      "•",
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Terms of Service",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                )
                .animate()
                .fadeIn(delay: 1800.ms, duration: 600.ms),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLoginButton({
    required String icon,
    required String text,
    required int delay,
  }) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Image.asset(
            icon,
            width: 24,
            height: 24,
          ),
          Expanded(
            child: Center(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    )
    .animate()
    .fadeIn(delay: Duration(milliseconds: delay), duration: 600.ms)
    .slideY(delay: Duration(milliseconds: delay), begin: 20, end: 0);
  }

  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback onPressed,
    required int delay,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(0.8),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    )
    .animate()
    .fadeIn(delay: Duration(milliseconds: delay), duration: 600.ms)
    .slideY(delay: Duration(milliseconds: delay), begin: 20, end: 0);
  }

  Widget _buildSecondaryButton({
    required String text,
    required VoidCallback onPressed,
    required int delay,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: AppColors.primary,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    )
    .animate()
    .fadeIn(delay: Duration(milliseconds: delay), duration: 600.ms)
    .slideY(delay: Duration(milliseconds: delay), begin: 20, end: 0);
  }
}
