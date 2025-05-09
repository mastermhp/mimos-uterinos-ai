import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:menstrual_health_ai/constants/app_colors.dart';
import 'package:menstrual_health_ai/constants/text_styles.dart';
import 'package:menstrual_health_ai/models/user_data.dart';
import 'package:menstrual_health_ai/providers/theme_provider.dart';
import 'package:menstrual_health_ai/providers/user_data_provider.dart';
import 'package:menstrual_health_ai/services/ai_service.dart';
import 'package:menstrual_health_ai/widgets/animated_gradient_button.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class DoctorModeScreen extends StatefulWidget {
  const DoctorModeScreen({super.key});

  @override
  State<DoctorModeScreen> createState() => _DoctorModeScreenState();
}

class _DoctorModeScreenState extends State<DoctorModeScreen> {
  final AIService _aiService = AIService();
  bool _isLoading = true;
  Map<String, dynamic> _report = {};

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userData = Provider.of<UserDataProvider>(context, listen: false).userData;
      if (userData != null) {
        final report = await _aiService.generateDoctorReport(userData);
        setState(() {
          _report = report;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading doctor report: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateAndSharePDF() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userData = Provider.of<UserDataProvider>(context, listen: false).userData;
      if (userData == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Show a message that PDF generation is not available in this version
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF generation is not available in this version. Please install the pdf and share_plus packages.'),
          duration: Duration(seconds: 3),
        ),
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error generating PDF: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to generate PDF. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final userData = Provider.of<UserDataProvider>(context).userData;

    return Theme(
      data: themeProvider.getTheme(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Doctor Mode"),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadReport,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              )
            : userData == null
                ? const Center(
                    child: Text("No user data available"),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(userData),
                        const SizedBox(height: 24),
                        _buildSummaryCard(),
                        const SizedBox(height: 24),
                        _buildMedicationsCard(),
                        const SizedBox(height: 24),
                        _buildRecommendationsCard(),
                        const SizedBox(height: 32),
                        AnimatedGradientButton(
                          text: "Generate PDF Report",
                          onPressed: _generateAndSharePDF,
                          icon: Icons.picture_as_pdf,
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "This report is generated by AI and should be reviewed by a healthcare professional. It is not a substitute for professional medical advice.",
                                  style: TextStyles.caption.copyWith(
                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildHeader(UserData userData) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFFE899B8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
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
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.medical_information_outlined,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Medical Report",
                      style: TextStyles.heading3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "For Dr. Review",
                      style: TextStyles.body2.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(
            color: Colors.white24,
            height: 1,
          ),
          const SizedBox(height: 20),
          _buildPatientInfoRow("Name", userData.name),
          const SizedBox(height: 8),
          _buildPatientInfoRow("Age", "${userData.age} years"),
          const SizedBox(height: 8),
          _buildPatientInfoRow("Height", "${userData.height} cm"),
          const SizedBox(height: 8),
          _buildPatientInfoRow("Weight", "${userData.weight} kg"),
          const SizedBox(height: 8),
          _buildPatientInfoRow("Cycle Length", "${userData.cycleLength} days"),
          const SizedBox(height: 8),
          _buildPatientInfoRow("Period Length", "${userData.periodLength} days"),
          const SizedBox(height: 8),
          _buildPatientInfoRow(
            "Last Period",
            userData.lastPeriodDate.toString().split(' ')[0],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 20, end: 0);
  }

  Widget _buildPatientInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          "$label: ",
          style: TextStyles.body2.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        Text(
          value,
          style: TextStyles.body2.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.summarize_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Summary",
                style: TextStyles.subtitle1.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _report['summary'] ?? 'No summary available.',
            style: TextStyles.body2,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Next Period Expected",
                        style: TextStyles.body2.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _report['nextPeriodStart'] != null
                            ? DateTime.parse(_report['nextPeriodStart']).toString().split(' ')[0]
                            : 'Not available',
                        style: TextStyles.body2.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(delay: 200.ms, begin: 20, end: 0);
  }

  Widget _buildMedicationsCard() {
    final medications = _report['medications'] as List<dynamic>? ?? [];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.medication_outlined,
                  color: AppColors.secondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Medications",
                style: TextStyles.subtitle1.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (medications.isNotEmpty)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: medications.length,
              separatorBuilder: (context, index) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final medication = medications[index];
                return Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.medication_liquid_outlined,
                        color: AppColors.secondary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medication['name'] ?? '',
                            style: TextStyles.body1.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${medication['dosage'] ?? ''} - ${medication['days'] ?? ''} days",
                            style: TextStyles.body2.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            )
          else
            Text(
              "No medications recommended.",
              style: TextStyles.body2,
            ),
          const SizedBox(height: 16),
          Text(
            _report['medicationNotes'] ?? '',
            style: TextStyles.body2.copyWith(
              fontStyle: FontStyle.italic,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(delay: 400.ms, begin: 20, end: 0);
  }

  Widget _buildRecommendationsCard() {
    final recommendations = _report['recommendations'] as List<dynamic>? ?? [];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.recommend_outlined,
                  color: AppColors.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Recommendations",
                style: TextStyles.subtitle1.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (recommendations.isNotEmpty)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recommendations.length,
              separatorBuilder: (context, index) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final recommendation = recommendations[index];
                final IconData icon = _getRecommendationIcon(recommendation['type'] as String? ?? 'general');
                final Color color = _getRecommendationColor(recommendation['type'] as String? ?? 'general');
                
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recommendation['title'] ?? '',
                            style: TextStyles.body1.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            recommendation['description'] ?? '',
                            style: TextStyles.body2,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            )
          else
            Text(
              "No recommendations available.",
              style: TextStyles.body2,
            ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms, duration: 600.ms).slideY(delay: 600.ms, begin: 20, end: 0);
  }

  IconData _getRecommendationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'hydration':
        return Icons.water_drop_outlined;
      case 'nutrition':
        return Icons.restaurant_outlined;
      case 'exercise':
        return Icons.fitness_center_outlined;
      case 'sleep':
        return Icons.bedtime_outlined;
      case 'medication':
        return Icons.medication_outlined;
      case 'stress':
        return Icons.spa_outlined;
      default:
        return Icons.recommend_outlined;
    }
  }

  Color _getRecommendationColor(String type) {
    switch (type.toLowerCase()) {
      case 'hydration':
        return Colors.blue;
      case 'nutrition':
        return Colors.green;
      case 'exercise':
        return Colors.orange;
      case 'sleep':
        return Colors.indigo;
      case 'medication':
        return Colors.purple;
      case 'stress':
        return Colors.teal;
      default:
        return AppColors.accent;
    }
  }
}
