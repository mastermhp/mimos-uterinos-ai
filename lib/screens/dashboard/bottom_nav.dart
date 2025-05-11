import 'package:flutter/material.dart';
import 'package:menstrual_health_ai/constants/app_colors.dart';
import 'package:menstrual_health_ai/screens/ai_features/ai_coach_screen.dart';
import 'package:menstrual_health_ai/screens/cycle/cycle_calendar_screen.dart';
import 'package:menstrual_health_ai/screens/dashboard/home_screen.dart';
import 'package:menstrual_health_ai/screens/profile/profile_screen.dart';
import 'package:menstrual_health_ai/screens/reports/reports_screen.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = [
    const HomeScreen(),
    const CycleCalendarScreen(),
    const ReportsScreen(),
    const AiCoachScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        height: 100, // Increased height for more padding
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Stack(
          children: [
            // Pink curved background
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary, // Pink color from the image
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                // Add padding at the top and bottom
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
                    _buildNavItem(1, Icons.calendar_today_rounded, Icons.calendar_today_outlined, 'Calendar'),
                    _buildNavItem(2, Icons.bar_chart, Icons.bar_chart_rounded, 'Reports'),
                    _buildNavItem(3, Icons.chat_bubble_rounded, Icons.chat_bubble_outline_rounded, 'AI Coach'),
                    _buildNavItem(4, Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: isSelected ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.8),
                  blurRadius: 4,
                  spreadRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ] : null,
            ),
            child: Center(
              child: Icon(
                isSelected ? activeIcon : inactiveIcon,
                color: isSelected ? AppColors.primary : Colors.grey.shade600,
                size: 26,
              ),
            ),
          ),
          // Uncomment this if you want to show labels below icons
          // const SizedBox(height: 4),
          // Text(
          //   label,
          //   style: TextStyle(
          //     color: isSelected ? AppColors.primary : Colors.grey.shade400,
          //     fontSize: 10,
          //     fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          //   ),
          // ),
        ],
      ),
    );
  }
}