import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:menstrual_health_ai/constants/app_colors.dart';
import 'package:menstrual_health_ai/constants/text_styles.dart';
import 'package:menstrual_health_ai/screens/cycle/log_symptoms_screen.dart';
import 'package:menstrual_health_ai/screens/date/new_date_screen.dart';
import 'package:menstrual_health_ai/screens/doctor/doctor_mode_screen.dart';
import 'package:menstrual_health_ai/screens/reports/reports_screen.dart';
import 'package:menstrual_health_ai/widgets/animated_gradient_button.dart';
import 'package:table_calendar/table_calendar.dart';

class CycleCalendarScreen extends StatefulWidget {
  const CycleCalendarScreen({super.key});

  @override
  State<CycleCalendarScreen> createState() => _CycleCalendarScreenState();
}

class _CycleCalendarScreenState extends State<CycleCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  // Mock data for period days
  final List<DateTime> _periodDays = [
    DateTime.now().subtract(const Duration(days: 2)),
    DateTime.now().subtract(const Duration(days: 1)),
    DateTime.now(),
    DateTime.now().add(const Duration(days: 1)),
    DateTime.now().add(const Duration(days: 2)),
  ];
  
  // Mock data for fertile days
  final List<DateTime> _fertileDays = [
    DateTime.now().add(const Duration(days: 12)),
    DateTime.now().add(const Duration(days: 13)),
    DateTime.now().add(const Duration(days: 14)),
    DateTime.now().add(const Duration(days: 15)),
    DateTime.now().add(const Duration(days: 16)),
  ];
  
  // Mock data for ovulation day
  final DateTime _ovulationDay = DateTime.now().add(const Duration(days: 14));
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "My Cycle",
                          style: TextStyles.heading2,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Track your period and symptoms",
                          style: TextStyles.subtitle2,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NewDateScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.calendar_month),
                          color: AppColors.primary,
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DoctorModeScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.medical_services_outlined),
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: -10, end: 0),
              
              // Calendar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
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
                child: TableCalendar(
                  firstDay: DateTime.utc(2023, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    weekendTextStyle: const TextStyle(color: Colors.red),
                    holidayTextStyle: const TextStyle(color: Colors.red),
                    todayDecoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: true,
                    formatButtonDecoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    formatButtonTextStyle: TextStyle(
                      color: AppColors.primary,
                    ),
                    titleTextStyle: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      final isPeriodDay = _periodDays.any((d) => isSameDay(d, date));
                      final isFertileDay = _fertileDays.any((d) => isSameDay(d, date));
                      final isOvulationDay = isSameDay(_ovulationDay, date);
                      
                      if (isPeriodDay) {
                        return Positioned(
                          bottom: 1,
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      }
                      
                      if (isOvulationDay) {
                        return Positioned(
                          bottom: 1,
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      }
                      
                      if (isFertileDay) {
                        return Positioned(
                          bottom: 1,
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      }
                      
                      return null;
                    },
                  ),
                ),
              ).animate().fadeIn(duration: 800.ms, delay: 200.ms),
              
              // Legend
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLegendItem("Period", AppColors.primary.withOpacity(0.3)),
                    _buildLegendItem("Fertile Window", Colors.green.withOpacity(0.2)),
                    _buildLegendItem("Ovulation", Colors.purple.withOpacity(0.3)),
                  ],
                ),
              ).animate().fadeIn(duration: 800.ms, delay: 400.ms),

              // AI Prediction Card
              _buildAIPredictionCard(),
              
              // Cycle Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: double.infinity,
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
                        "Cycle Information",
                        style: TextStyles.heading3,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCycleInfoItem(
                            "Cycle Length",
                            "28 days",
                            Icons.loop_rounded,
                            AppColors.primary,
                          ),
                          _buildCycleInfoItem(
                            "Period Length",
                            "5 days",
                            Icons.calendar_today_rounded,
                            Colors.red,
                          ),
                          _buildCycleInfoItem(
                            "Ovulation",
                            "Day 14",
                            Icons.egg_alt_rounded,
                            Colors.purple,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 800.ms, delay: 600.ms),
              
              // Action Buttons
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AnimatedGradientButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LogSymptomsScreen(),
                                ),
                              );
                            },
                            text: "Log Symptoms",
                            icon: Icons.add_circle_outline_rounded,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AnimatedGradientButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const NewDateScreen(),
                                ),
                              );
                            },
                            text: "Set Period Date",
                            icon: Icons.calendar_today_rounded,
                            gradientColors: [
                              Colors.purple,
                              Colors.purpleAccent,
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: AnimatedGradientButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DoctorModeScreen(),
                                ),
                              );
                            },
                            text: "Doctor Mode",
                            icon: Icons.medical_services_rounded,
                            gradientColors: [
                              Colors.blue,
                              Colors.lightBlueAccent,
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AnimatedGradientButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ReportsScreen(),
                                ),
                              );
                            },
                            text: "View Reports",
                            icon: Icons.bar_chart_rounded,
                            gradientColors: [
                              Colors.orange,
                              Colors.amber,
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 800.ms, delay: 800.ms),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildLegendItem(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
  
  Widget _buildCycleInfoItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAIPredictionCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6A11CB),
            Color(0xFF2575FC),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "AI Prediction",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPredictionItem(
            icon: Icons.calendar_today,
            title: "Next Period",
            prediction: "Likely to start around May 29",
          ),
          const SizedBox(height: 12),
          _buildPredictionItem(
            icon: Icons.egg_alt,
            title: "Ovulation Window",
            prediction: "Expected around May 13-15",
          ),
          const SizedBox(height: 12),
          _buildPredictionItem(
            icon: Icons.water_drop,
            title: "Fertile Days",
            prediction: "May 11-16 (6 days)",
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 16,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Predictions improve with more cycle data. Log your periods regularly for better accuracy.",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms, delay: 1000.ms);
  }

  Widget _buildPredictionItem({
    required IconData icon,
    required String title,
    required String prediction,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 16,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              prediction,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
