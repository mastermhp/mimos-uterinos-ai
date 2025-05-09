import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:menstrual_health_ai/constants/app_colors.dart';
import 'package:menstrual_health_ai/constants/text_styles.dart';
import 'package:menstrual_health_ai/widgets/animated_gradient_button.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  int _selectedPlanIndex = 1; // Default to yearly plan
  
  final List<String> _planTitles = ["Monthly", "Yearly", "Lifetime"];
  final List<String> _planPrices = ["\$4.99/month", "\$39.99/year", "\$99.99"];
  final List<String> _planSavings = ["", "Save 33%", "Best Value"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upgrade to Premium"),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildPlanSelection(),
                const SizedBox(height: 24),
                _buildFeatures(),
                const SizedBox(height: 32),
                _buildSubscribeButton(),
                const SizedBox(height: 16),
                _buildRestorePurchases(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(
          Icons.star_rounded,
          size: 80,
          color: Color(0xFFFFD700),
        ),
        const SizedBox(height: 16),
        Text(
          "Unlock Premium Features",
          style: TextStyles.heading2,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          "Get the most out of your cycle tracking experience with premium features.",
          style: TextStyles.subtitle1,
          textAlign: TextAlign.center,
        ),
      ],
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildPlanSelection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Choose Your Plan",
            style: TextStyles.heading4,
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(
              _planTitles.length,
              (index) => Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPlanIndex = index;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                      right: index < _planTitles.length - 1 ? 8 : 0,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedPlanIndex == index
                          ? AppColors.primary
                          : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: _selectedPlanIndex == index
                          ? Border.all(
                              color: AppColors.primary,
                              width: 2,
                            )
                          : null,
                    ),
                    child: Column(
                      children: [
                        Text(
                          _planTitles[index],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _selectedPlanIndex == index
                                ? Colors.white
                                : AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _planPrices[index],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _selectedPlanIndex == index
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                        if (_planSavings[index].isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _selectedPlanIndex == index
                                  ? Colors.white
                                  : const Color(0xFFFFD700),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _planSavings[index],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _selectedPlanIndex == index
                                    ? AppColors.primary
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms, delay: 200.ms);
  }

  Widget _buildFeatures() {
    final features = [
      {
        "title": "Ad-Free Experience",
        "description": "Enjoy the app without any advertisements",
        "icon": Icons.block_rounded,
      },
      {
        "title": "Advanced Analytics",
        "description": "Get detailed insights about your cycle",
        "icon": Icons.analytics_rounded,
      },
      {
        "title": "Unlimited Notes",
        "description": "Add as many notes as you want",
        "icon": Icons.note_rounded,
      },
      {
        "title": "Health Reports",
        "description": "Generate comprehensive health reports",
        "icon": Icons.description_rounded,
      },
      {
        "title": "AI Predictions",
        "description": "Get personalized predictions based on your data",
        "icon": Icons.psychology_rounded,
      },
      {
        "title": "Priority Support",
        "description": "Get priority customer support",
        "icon": Icons.support_agent_rounded,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Premium Features",
            style: TextStyles.heading4,
          ),
          const SizedBox(height: 16),
          ...features.map((feature) => _buildFeatureItem(
                feature["title"] as String,
                feature["description"] as String,
                feature["icon"] as IconData,
              )),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms, delay: 400.ms);
  }

  Widget _buildFeatureItem(
    String title,
    String description,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle_rounded,
            color: Colors.green,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildSubscribeButton() {
    return AnimatedGradientButton(
      onPressed: () {
        // Show purchase confirmation
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Confirm Purchase"),
            content: Text(
              "You are about to subscribe to the ${_planTitles[_selectedPlanIndex]} plan for ${_planPrices[_selectedPlanIndex]}. Would you like to proceed?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Show success dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Purchase Successful"),
                      content: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 60,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Thank you for upgrading to Premium! You now have access to all premium features.",
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: const Text("Start Exploring"),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text("Confirm"),
              ),
            ],
          ),
        );
      },
      text: "Subscribe Now",
      gradientColors: const [
        Color(0xFFFFD700),
        Color(0xFFFFA500),
      ],
      icon: Icons.star_rounded,
    ).animate().fadeIn(duration: 800.ms, delay: 600.ms);
  }

  Widget _buildRestorePurchases() {
    return Center(
      child: TextButton(
        onPressed: () {
          // Restore purchases
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Restoring purchases..."),
            ),
          );
        },
        child: const Text(
          "Restore Purchases",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
        ),
      ),
    ).animate().fadeIn(duration: 800.ms, delay: 800.ms);
  }
}
