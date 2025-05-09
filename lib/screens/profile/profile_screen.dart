import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:menstrual_health_ai/constants/app_colors.dart';
import 'package:menstrual_health_ai/constants/text_styles.dart';
import 'package:menstrual_health_ai/models/user_data.dart';
import 'package:menstrual_health_ai/providers/theme_provider.dart';
import 'package:menstrual_health_ai/providers/user_data_provider.dart';
import 'package:menstrual_health_ai/screens/doctor/doctor_mode_screen.dart';
import 'package:menstrual_health_ai/screens/export/export_data_screen.dart';
import 'package:menstrual_health_ai/screens/help/help_support_screen.dart';
import 'package:menstrual_health_ai/screens/legal/privacy_policy_screen.dart';
import 'package:menstrual_health_ai/screens/legal/terms_of_service_screen.dart';
import 'package:menstrual_health_ai/screens/premium/premium_screen.dart';
import 'package:menstrual_health_ai/screens/profile/edit_profile_screen.dart';
import 'package:menstrual_health_ai/screens/reminders/reminders_screen.dart';
import 'package:menstrual_health_ai/screens/settings/settings_screen.dart';
import 'package:menstrual_health_ai/widgets/animated_gradient_button.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserDataProvider>(context).userData;
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final backgroundColor = isDarkMode ? AppColors.darkBackground : Colors.white;
    final cardColor = isDarkMode ? AppColors.darkCardBackground : Colors.white;
    final textColor = isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final secondaryTextColor = isDarkMode ? AppColors.darkTextSecondary : Colors.grey.shade600;
    
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              _buildProfileHeader(context, userData, isDarkMode, textColor, secondaryTextColor),
              
              // Stats Section
              _buildStatsSection(context, userData, isDarkMode, textColor, secondaryTextColor, cardColor),
              
              // Options Section
              _buildOptionsSection(context, isDarkMode, textColor, secondaryTextColor, cardColor),
              
              // Account Section
              _buildAccountSection(context, isDarkMode, textColor, secondaryTextColor, cardColor),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildProfileHeader(BuildContext context, UserData? userData, bool isDarkMode, Color textColor, Color secondaryTextColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.1),
                  border: Border.all(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userData?.name ?? "Guest User",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userData?.email ?? "No email provided",
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      userData?.isPremium ?? false ? "Premium Member" : "Free Plan",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            icon: Icon(
              Icons.settings_outlined,
              color: textColor,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -10, end: 0);
  }
  
  Widget _buildStatsSection(BuildContext context, UserData? userData, bool isDarkMode, Color textColor, Color secondaryTextColor, Color cardColor) {
    int cyclesTracked = 0;
    String avgCycleLength = "N/A";
    String avgPeriodLength = "N/A";
    
    if (userData != null) {
      cyclesTracked = userData.cyclesTracked ?? 0;
      avgCycleLength = "${userData.cycleLength} days";
      avgPeriodLength = "${userData.periodLength} days";
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "My Stats",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  "Cycles Tracked", 
                  cyclesTracked.toString(), 
                  Icons.loop_rounded,
                  textColor,
                  secondaryTextColor,
                ),
                _buildStatItem(
                  "Avg. Cycle Length", 
                  avgCycleLength, 
                  Icons.calendar_today_rounded,
                  textColor,
                  secondaryTextColor,
                ),
                _buildStatItem(
                  "Avg. Period Length", 
                  avgPeriodLength, 
                  Icons.water_drop_rounded,
                  textColor,
                  secondaryTextColor,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms, delay: 200.ms);
  }
  
  Widget _buildStatItem(
    String title, 
    String value, 
    IconData icon,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: secondaryTextColor,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildOptionsSection(BuildContext context, bool isDarkMode, Color textColor, Color secondaryTextColor, Color cardColor) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Options",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildOptionItem(
            context,
            "Settings",
            "Customize app preferences",
            Icons.settings_outlined,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            isDarkMode,
            textColor,
            secondaryTextColor,
            cardColor,
          ),
          _buildOptionItem(
            context,
            "Doctor Mode",
            "View medical reports",
            Icons.medical_services_outlined,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DoctorModeScreen(),
                ),
              );
            },
            isDarkMode,
            textColor,
            secondaryTextColor,
            cardColor,
          ),
          _buildOptionItem(
            context,
            "Reminders",
            "Set up notifications",
            Icons.notifications_outlined,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RemindersScreen(),
                ),
              );
            },
            isDarkMode,
            textColor,
            secondaryTextColor,
            cardColor,
          ),
          _buildOptionItem(
            context,
            "Export Data",
            "Download your data",
            Icons.download_outlined,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExportDataScreen(),
                ),
              );
            },
            isDarkMode,
            textColor,
            secondaryTextColor,
            cardColor,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms, delay: 400.ms);
  }
  
  Widget _buildOptionItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
    bool isDarkMode,
    Color textColor,
    Color secondaryTextColor,
    Color cardColor,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: secondaryTextColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAccountSection(BuildContext context, bool isDarkMode, Color textColor, Color secondaryTextColor, Color cardColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Account",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          AnimatedGradientButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PremiumScreen(),
                ),
              );
            },
            text: "Upgrade to Premium",
            gradientColors: const [
              Color(0xFFFFD700),
              Color(0xFFFFA500),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
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
              children: [
                _buildAccountItem(
                  "Edit Profile",
                  Icons.edit_outlined,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    );
                  },
                  textColor,
                  isDarkMode,
                ),
                Divider(color: isDarkMode ? AppColors.darkDivider : AppColors.divider),
                _buildAccountItem(
                  "Privacy Policy",
                  Icons.privacy_tip_outlined,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacyPolicyScreen(),
                      ),
                    );
                  },
                  textColor,
                  isDarkMode,
                ),
                Divider(color: isDarkMode ? AppColors.darkDivider : AppColors.divider),
                _buildAccountItem(
                  "Terms of Service",
                  Icons.description_outlined,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TermsOfServiceScreen(),
                      ),
                    );
                  },
                  textColor,
                  isDarkMode,
                ),
                Divider(color: isDarkMode ? AppColors.darkDivider : AppColors.divider),
                _buildAccountItem(
                  "Help & Support",
                  Icons.help_outline_rounded,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpSupportScreen(),
                      ),
                    );
                  },
                  textColor,
                  isDarkMode,
                ),
                Divider(color: isDarkMode ? AppColors.darkDivider : AppColors.divider),
                _buildAccountItem(
                  "Log Out",
                  Icons.logout_rounded,
                  () {
                    _showLogoutDialog(context, isDarkMode);
                  },
                  textColor,
                  isDarkMode,
                  isLogout: true,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms, delay: 600.ms);
  }
  
  Widget _buildAccountItem(
    String title,
    IconData icon,
    VoidCallback onTap,
    Color textColor,
    bool isDarkMode, {
    bool isLogout = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isLogout ? Colors.red : AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isLogout ? Colors.red : textColor,
              ),
            ),
            const Spacer(),
            if (!isLogout)
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
  
  void _showLogoutDialog(BuildContext context, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? AppColors.darkCardBackground : Colors.white,
        title: Text(
          "Log Out",
          style: TextStyle(
            color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        content: Text(
          "Are you sure you want to log out?",
          style: TextStyle(
            color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(
                color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to login screen
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text("Log Out"),
          ),
        ],
      ),
    );
  }
}
