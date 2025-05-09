import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:menstrual_health_ai/constants/app_colors.dart';
import 'package:menstrual_health_ai/constants/text_styles.dart';
import 'package:menstrual_health_ai/widgets/animated_gradient_button.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  bool _periodReminder = true;
  bool _fertileWindowReminder = true;
  bool _medicationReminder = false;
  bool _waterReminder = true;
  bool _exerciseReminder = false;
  
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reminders"),
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
                _buildReminderTime(),
                const SizedBox(height: 24),
                _buildReminderTypes(),
                const SizedBox(height: 24),
                _buildCustomReminders(),
                const SizedBox(height: 32),
                _buildSaveButton(),
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
          "Reminders",
          style: TextStyles.heading2,
        ),
        const SizedBox(height: 8),
        Text(
          "Set up notifications to help you stay on track with your cycle and health goals.",
          style: TextStyles.subtitle1,
        ),
      ],
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildReminderTime() {
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
            "Reminder Time",
            style: TextStyles.heading4,
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: _reminderTime,
              );
              if (picked != null) {
                setState(() {
                  _reminderTime = picked;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Daily Reminder Time",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _reminderTime.format(context),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms, delay: 200.ms);
  }

  Widget _buildReminderTypes() {
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
            "Reminder Types",
            style: TextStyles.heading4,
          ),
          const SizedBox(height: 16),
          _buildReminderSwitch(
            "Period Start Reminder",
            "Get notified when your period is about to start",
            Icons.calendar_today_rounded,
            _periodReminder,
            (value) {
              setState(() {
                _periodReminder = value;
              });
            },
          ),
          const Divider(),
          _buildReminderSwitch(
            "Fertile Window Reminder",
            "Get notified during your fertile window",
            Icons.favorite_rounded,
            _fertileWindowReminder,
            (value) {
              setState(() {
                _fertileWindowReminder = value;
              });
            },
          ),
          const Divider(),
          _buildReminderSwitch(
            "Medication Reminder",
            "Get reminded to take your medication",
            Icons.medication_rounded,
            _medicationReminder,
            (value) {
              setState(() {
                _medicationReminder = value;
              });
            },
          ),
          const Divider(),
          _buildReminderSwitch(
            "Water Intake Reminder",
            "Get reminded to drink water throughout the day",
            Icons.water_drop_rounded,
            _waterReminder,
            (value) {
              setState(() {
                _waterReminder = value;
              });
            },
          ),
          const Divider(),
          _buildReminderSwitch(
            "Exercise Reminder",
            "Get reminded to exercise regularly",
            Icons.fitness_center_rounded,
            _exerciseReminder,
            (value) {
              setState(() {
                _exerciseReminder = value;
              });
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms, delay: 400.ms);
  }

  Widget _buildReminderSwitch(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomReminders() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Custom Reminders",
                style: TextStyles.heading4,
              ),
              IconButton(
                onPressed: () {
                  // Add custom reminder
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Custom reminders coming soon!"),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  size: 60,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  "No custom reminders yet",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Tap the + button to add a custom reminder",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms, delay: 600.ms);
  }

  Widget _buildSaveButton() {
    return AnimatedGradientButton(
      onPressed: () {
        // Save reminders
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Reminders saved successfully!"),
          ),
        );
        Navigator.pop(context);
      },
      text: "Save Reminders",
      icon: Icons.check,
    ).animate().fadeIn(duration: 800.ms, delay: 800.ms);
  }
}
