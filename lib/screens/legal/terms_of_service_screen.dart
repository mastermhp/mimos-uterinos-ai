import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:menstrual_health_ai/constants/app_colors.dart';
import 'package:menstrual_health_ai/constants/text_styles.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms of Service"),
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
                  "1. Acceptance of Terms",
                  "By accessing or using our app, you agree to be bound by these Terms of Service and all applicable laws and regulations. If you do not agree with any of these terms, you are prohibited from using or accessing this app.",
                ),
                _buildSection(
                  "2. Use License",
                  "Permission is granted to temporarily download one copy of the app for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title, and under this license you may not:\n\n• Modify or copy the materials;\n\n• Use the materials for any commercial purpose;\n\n• Attempt to decompile or reverse engineer any software contained in the app;\n\n• Remove any copyright or other proprietary notations from the materials; or\n\n• Transfer the materials to another person or 'mirror' the materials on any other server.",
                ),
                _buildSection(
                  "3. Disclaimer",
                  "The materials on our app are provided on an 'as is' basis. We make no warranties, expressed or implied, and hereby disclaim and negate all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.",
                ),
                _buildSection(
                  "4. Limitations",
                  "In no event shall we or our suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials on our app, even if we or an authorized representative has been notified orally or in writing of the possibility of such damage.",
                ),
                _buildSection(
                  "5. Revisions and Errata",
                  "The materials appearing on our app could include technical, typographical, or photographic errors. We do not warrant that any of the materials on our app are accurate, complete or current. We may make changes to the materials contained on our app at any time without notice.",
                ),
                _buildSection(
                  "6. Links",
                  "We have not reviewed all of the sites linked to our app and are not responsible for the contents of any such linked site. The inclusion of any link does not imply endorsement by us of the site. Use of any such linked website is at the user's own risk.",
                ),
                _buildSection(
                  "7. Modifications to Terms of Service",
                  "We may revise these terms of service for our app at any time without notice. By using this app you are agreeing to be bound by the then current version of these terms of service.",
                ),
                _buildSection(
                  "8. Governing Law",
                  "These terms and conditions are governed by and construed in accordance with the laws and you irrevocably submit to the exclusive jurisdiction of the courts in that location.",
                ),
                _buildSection(
                  "9. Contact Us",
                  "If you have any questions about these Terms of Service, please contact us at: terms@mimosapp.com",
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
          "Terms of Service",
          style: TextStyles.heading2,
        ),
        const SizedBox(height: 8),
        Text(
          "Please read these Terms of Service carefully before using our app.",
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
