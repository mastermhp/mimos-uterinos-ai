import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:menstrual_health_ai/constants/app_colors.dart';
import 'package:menstrual_health_ai/providers/auth_provider.dart';
import 'package:menstrual_health_ai/screens/auth/login_screen.dart';
import 'package:menstrual_health_ai/widgets/animated_gradient_button.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  bool _isLoading = false;
  bool _emailSent = false;
  
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
  
  // Request password reset
  Future<void> _requestPasswordReset() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.requestPasswordReset(
      _emailController.text.trim(),
    );
    
    setState(() {
      _isLoading = false;
      _emailSent = success;
    });
    
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Failed to send reset email'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Forgot Password",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _emailSent ? _buildSuccessView() : _buildRequestView(),
          ),
        ),
      ),
    );
  }
  
  Widget _buildRequestView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon
          Icon(
            Icons.lock_reset_rounded,
            size: 80,
            color: AppColors.primary,
          )
          .animate()
          .fadeIn(duration: 600.ms)
          .scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1, 1),
            duration: 600.ms,
          ),
          
          const SizedBox(height: 24),
          
          // Title
          Text(
            "Reset Your Password",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          )
          .animate()
          .fadeIn(delay: 200.ms, duration: 600.ms),
          
          const SizedBox(height: 16),
          
          // Description
          Text(
            "Enter your email address and we'll send you a link to reset your password.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          )
          .animate()
          .fadeIn(delay: 400.ms, duration: 600.ms),
          
          const SizedBox(height: 40),
          
          // Email field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Email",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Enter your email",
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: Colors.grey.shade500,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
              ),
            ],
          )
          .animate()
          .fadeIn(delay: 600.ms, duration: 600.ms),
          
          const SizedBox(height: 40),
          
          // Reset button
          AnimatedGradientButton(
            onPressed: _isLoading ? null : _requestPasswordReset,
            text: _isLoading ? "Sending..." : "Send Reset Link",
            gradientColors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
            isLoading: _isLoading,
          )
          .animate()
          .fadeIn(delay: 800.ms, duration: 600.ms),
          
          const SizedBox(height: 24),
          
          // Back to login
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
            child: Text(
              "Back to Login",
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
          .animate()
          .fadeIn(delay: 1000.ms, duration: 600.ms),
        ],
      ),
    );
  }
  
  Widget _buildSuccessView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Success icon
        Icon(
          Icons.check_circle_outline_rounded,
          size: 100,
          color: Colors.green,
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          duration: 600.ms,
        ),
        
        const SizedBox(height: 24),
        
        // Title
        Text(
          "Email Sent!",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        )
        .animate()
        .fadeIn(delay: 200.ms, duration: 600.ms),
        
        const SizedBox(height: 16),
        
        // Description
        Text(
          "We've sent a password reset link to ${_emailController.text}. Please check your email and follow the instructions to reset your password.",
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        )
        .animate()
        .fadeIn(delay: 400.ms, duration: 600.ms),
        
        const SizedBox(height: 40),
        
        // Note
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.blue.shade200,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Colors.blue.shade700,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  "If you don't see the email, please check your spam folder.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 600.ms, duration: 600.ms),
        
        const SizedBox(height: 40),
        
        // Back to login button
        AnimatedGradientButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
            );
          },
          text: "Back to Login",
          gradientColors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        )
        .animate()
        .fadeIn(delay: 800.ms, duration: 600.ms),
      ],
    );
  }
}
