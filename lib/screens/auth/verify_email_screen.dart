import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menstrual_health_ai/constants/app_colors.dart';
import 'package:menstrual_health_ai/providers/auth_provider.dart';
import 'package:menstrual_health_ai/screens/dashboard/bottom_nav.dart';
import 'package:menstrual_health_ai/screens/onboarding/onboarding_screens.dart';
import 'package:menstrual_health_ai/widgets/animated_gradient_button.dart';
import 'package:menstrual_health_ai/widgets/wave_clipper.dart';
import 'package:provider/provider.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  final bool isNewUser;

  const VerifyEmailScreen({
    Key? key,
    required this.email,
    this.isNewUser = true,
  }) : super(key: key);

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  
  bool _isLoading = false;
  bool _isResending = false;
  String _errorMessage = '';
  int _remainingTime = 60;
  Timer? _timer;
  
  @override
  void initState() {
    super.initState();
    _startTimer();
    
    // Set up focus node listeners
    for (int i = 0; i < 6; i++) {
      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus && _controllers[i].text.isNotEmpty) {
          _controllers[i].selection = TextSelection(
            baseOffset: 0,
            extentOffset: _controllers[i].text.length,
          );
        }
      });
    }
    
    // Show verification code in debug mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDebugInfo();
    });
  }
  
  void _showDebugInfo() {
    // Only show in debug mode
    assert(() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Check the console for the verification code',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black.withOpacity(0.7),
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return true;
    }());
  }
  
  void _startTimer() {
    _remainingTime = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        timer.cancel();
      }
    });
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
  
  Future<void> _verifyCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    final code = _controllers.map((c) => c.text).join();
    if (code.length != 6) {
      setState(() {
        _errorMessage = 'Please enter all 6 digits';
        _isLoading = false;
      });
      return;
    }
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.verifyEmail(widget.email, code);
      
      if (success) {
        if (widget.isNewUser) {
          // New user, go to onboarding
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const OnboardingScreens()),
              (route) => false,
            );
          }
        } else {
          // Existing user, go to home
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const BottomNav()),
              (route) => false,
            );
          }
        }
      } else {
        setState(() {
          _errorMessage = 'Invalid verification code';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Verification failed: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _resendCode() async {
    if (_remainingTime > 0) return;
    
    setState(() {
      _isResending = true;
      _errorMessage = '';
    });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.resendVerificationCode(widget.email);
      
      if (success) {
        _startTimer();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Verification code sent successfully. Check the console for the code.',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to resend verification code';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }
  
  void _onDigitChanged(int index, String value) {
    if (value.length == 1) {
      // Move to next field
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Last field, hide keyboard
        _focusNodes[index].unfocus();
        // Auto-verify when all digits are entered
        _verifyCode();
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with wave
              ClipPath(
                clipper: WaveClipper(),
                child: Container(
                  height: 200,
                  color: AppColors.primary,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        const Icon(
                          Icons.email_outlined,
                          size: 60,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Verify Your Email',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Email display
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'We\'ve sent a verification code to:',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  widget.email,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Debug info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: const Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.amber, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Development Mode',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Since this is a development build, the verification code is printed to the console. Check your terminal/debug console to see the code.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // OTP input fields
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    6,
                    (index) => SizedBox(
                      width: 45,
                      height: 55,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        onChanged: (value) => _onDigitChanged(index, value),
                        decoration: InputDecoration(
                          counterText: '',
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Error message
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 24, right: 24),
                  child: Text(
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ),
              
              const SizedBox(height: 40),
              
              // Verify button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: AnimatedGradientButton(
                  text: _isLoading ? 'Verifying...' : 'Verify',
                  onPressed: _isLoading ? null : _verifyCode,
                  gradientColors: const [AppColors.primary, AppColors.secondary],
                  isLoading: _isLoading,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Resend code
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Didn\'t receive the code? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    _remainingTime > 0
                        ? Text(
                            'Resend in $_remainingTime s',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor.withOpacity(0.5),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : GestureDetector(
                            onTap: _isResending ? null : _resendCode,
                            child: Text(
                              _isResending ? 'Sending...' : 'Resend',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Instructions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Verification Tips',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Check your spam folder if you don\'t see the email\n'
                        '• The code expires in 10 minutes\n'
                        '• Make sure you entered the correct email',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
