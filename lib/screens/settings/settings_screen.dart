import 'package:flutter/material.dart';
import 'package:menstrual_health_ai/constants/app_colors.dart';
import 'package:menstrual_health_ai/constants/text_styles.dart';
import 'package:menstrual_health_ai/providers/theme_provider.dart';
import 'package:menstrual_health_ai/providers/user_data_provider.dart';
import 'package:menstrual_health_ai/screens/export/export_data_screen.dart';
import 'package:menstrual_health_ai/screens/help/help_support_screen.dart';
import 'package:menstrual_health_ai/screens/legal/privacy_policy_screen.dart';
import 'package:menstrual_health_ai/screens/legal/terms_of_service_screen.dart';
import 'package:menstrual_health_ai/screens/premium/premium_screen.dart';
import 'package:menstrual_health_ai/screens/profile/edit_profile_screen.dart';
import 'package:menstrual_health_ai/screens/reminders/reminders_screen.dart';
import 'package:menstrual_health_ai/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userDataProvider = Provider.of<UserDataProvider>(context);
    final userData = userDataProvider.userData;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomAppBar(
        title: "Settings",
        showBackButton: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account section
          _buildSectionHeader(context, "Account"),
          
          _buildSettingItem(
            context,
            icon: Icons.person_outline,
            title: "Edit Profile",
            subtitle: "Update your personal information",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
              );
            },
          ),
          
          _buildSettingItem(
            context,
            icon: Icons.notifications_outlined,
            title: "Reminders",
            subtitle: "Manage your reminders and notifications",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RemindersScreen()),
              );
            },
          ),
          
          _buildSettingItem(
            context,
            icon: Icons.workspace_premium_outlined,
            title: "Premium",
            subtitle: userData?.isPremium == true
              ? "Manage your subscription"
              : "Upgrade to premium",
            onTap: () {
            Navigator.push(
              context,
                          MaterialPageRoute(builder: (context) => const PremiumScreen()),
              );
            },
            showBadge: userData?.isPremium != true,

          ),
          
          const SizedBox(height: 24),
          
          // Preferences section
          _buildSectionHeader(context, "Preferences"),
          
          _buildSwitchItem(
            context,
            icon: Icons.dark_mode_outlined,
            title: "Dark Mode",
            subtitle: "Switch between light and dark theme",
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
          ),
          
          _buildSettingItem(
            context,
            icon: Icons.download_outlined,
            title: "Export Data",
            subtitle: "Export your health data",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExportDataScreen()),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // Support section
          _buildSectionHeader(context, "Support"),
          
          _buildSettingItem(
            context,
            icon: Icons.help_outline,
            title: "Help & Support",
            subtitle: "Get help with using the app",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
              );
            },
          ),
          
          _buildSettingItem(
            context,
            icon: Icons.privacy_tip_outlined,
            title: "Privacy Policy",
            subtitle: "Read our privacy policy",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
              );
            },
          ),
          
          _buildSettingItem(
            context,
            icon: Icons.description_outlined,
            title: "Terms of Service",
            subtitle: "Read our terms of service",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TermsOfServiceScreen()),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // App info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  "Luna AI",
                  style: TextStyles.heading3,
                ),
                const SizedBox(height: 4),
                Text(
                  "Version 1.0.0",
                  style: TextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "© 2025 Luna Health Technologies",
                  style: TextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Logout button
          TextButton(
            onPressed: () {
              // Show logout confirmation dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Log Out"),
                  content: const Text("Are you sure you want to log out?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        // Implement logout functionality
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Log Out",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              "Log Out",
              style: TextStyles.button.copyWith(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: TextStyles.subtitle1.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showBadge = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
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
        title: Text(
          title,
          style: TextStyles.subtitle2,
        ),
        subtitle: Text(
          subtitle,
          style: TextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showBadge)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "NEW",
                  style: TextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
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
        title: Text(
          title,
          style: TextStyles.subtitle2,
        ),
        subtitle: Text(
          subtitle,
          style: TextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
