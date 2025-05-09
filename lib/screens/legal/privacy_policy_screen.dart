import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:menstrual_health_ai/constants/app_colors.dart';
import 'package:menstrual_health_ai/constants/text_styles.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
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
                _buildLastUpdated(),
                const SizedBox(height: 24),
                _buildSection(
                  "1. Information We Collect",
                  "We collect information that you provide directly to us, such as when you create an account, update your profile, use the interactive features of our app, participate in a contest, promotion, survey, or other marketing activities, request customer support, or otherwise communicate with us.",
                ),
                _buildSection(
                  "2. How We Use Your Information",
                  "We use the information we collect to provide, maintain, and improve our services, such as to administer your account, deliver the products and services you request, and customize your experience with us.",
                ),
                _buildSection(
                  "3. Sharing of Information",
                  "We may share the information we collect as follows:\n\n• With third-party vendors, consultants, and other service providers who need access to such information to carry out work on our behalf;\n\n• In response to a request for information if we believe disclosure is in accordance with any applicable law, regulation, or legal process;\n\n• If we believe your actions are inconsistent with the spirit or language of our user agreements or policies, or to protect the rights, property, and safety of Mimos or others.",
                ),
                _buildSection(
                  "4. Data Security",
                  "We take reasonable measures to help protect information about you from loss, theft, misuse and unauthorized access, disclosure, alteration and destruction.",
                ),
                _buildSection(
                  "5. Your Choices",
                  "You can access and update certain information about you from within the app. You can also request to delete your account at any time.",
                ),
                _buildSection(
                  "6. Changes to This Policy",
                  "We may change this Privacy Policy from time to time. If we make changes, we will notify you by revising the date at the top of the policy and, in some cases, we may provide you with additional notice.",
                ),
                _buildSection(
                  "7. Contact Us",
                  "If you have any questions about this Privacy Policy, please contact us at: privacy@mimosapp.com",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Privacy Policy",
          style: TextStyles.heading2,
        ),
        const SizedBox(height: 8),
        Text(
          "This Privacy Policy describes how we collect, use, and disclose your information when you use our app.",
          style: TextStyles.subtitle1,
        ),
      ],
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildLastUpdated() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.calendar_today_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          SizedBox(width: 12),
          Text(
            "Last Updated: May 1, 2025",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms, delay: 200.ms);
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyles.heading4,
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms, delay: 400.ms);
  }
}
