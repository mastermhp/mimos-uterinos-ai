import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menstrual_health_ai/constants/app_colors.dart';
import 'package:menstrual_health_ai/constants/text_styles.dart';
import 'package:menstrual_health_ai/widgets/animated_gradient_button.dart';
import 'package:menstrual_health_ai/widgets/custom_app_bar.dart';

class ExportDataScreen extends StatefulWidget {
  const ExportDataScreen({Key? key}) : super(key: key);

  @override
  _ExportDataScreenState createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends State<ExportDataScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  String _selectedFormat = 'PDF';
  final List<String> _formats = ['PDF', 'CSV', 'JSON'];
  
  String _selectedDataType = 'All Data';
  final List<String> _dataTypes = ['All Data', 'Cycle History', 'Symptoms', 'Moods', 'Notes'];
  
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 90));
  DateTime _endDate = DateTime.now();
  
  bool _includeNotes = true;
  bool _includeSymptoms = true;
  bool _includeMoods = true;
  bool _includeAnalytics = true;
  
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _exportData() {
    setState(() {
      _isExporting = true;
    });
    
    // Simulate export process
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isExporting = false;
      });
      
      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Export Successful'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                'Your data has been successfully exported as $_selectedFormat.',
                style: TextStyles.body1,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'OK',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'Export Data',
        showBackButton: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(),
                const SizedBox(height: 24),
                _buildFormatSelector(),
                const SizedBox(height: 24),
                _buildDataTypeSelector(),
                const SizedBox(height: 24),
                _buildDateRange(),
                const SizedBox(height: 24),
                _buildIncludeOptions(),
                const SizedBox(height: 32),
                Center(
                  child: _isExporting
                      ? const CircularProgressIndicator(color: AppColors.primary)
                      : AnimatedGradientButton(
                          text: 'Export Data',
                          onPressed: _exportData,
                          width: double.infinity,
                          height: 56,
                          // borderRadius: 28,
                          gradientColors: const [
                            AppColors.primary,
                            AppColors.secondary,
                          ],
                          icon: Icons.download,
                        ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF0F7FF),
            Color(0xFFF5F3FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
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
              const Icon(
                Icons.info_outline,
                color: Color(0xFF6366F1),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Export Your Data',
                style: TextStyles.heading4.copyWith(
                  fontSize: 18,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'You can export your data in different formats for personal records or to share with healthcare providers.',
            style: TextStyles.body1.copyWith(
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your data privacy is important to us. Exported files are encrypted and can only be accessed by you.',
            style: TextStyles.body1.copyWith(
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Export Format',
          style: TextStyles.heading4.copyWith(
            fontSize: 18,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: _formats.map((format) {
            final isSelected = format == _selectedFormat;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedFormat = format;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getFormatIcon(format),
                        color: isSelected ? Colors.white : Colors.grey,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        format,
                        style: TextStyles.body2.copyWith(
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  IconData _getFormatIcon(String format) {
    switch (format) {
      case 'PDF':
        return Icons.picture_as_pdf;
      case 'CSV':
        return Icons.table_chart;
      case 'JSON':
        return Icons.code;
      default:
        return Icons.file_present;
    }
  }

  Widget _buildDataTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data Type',
          style: TextStyles.heading4.copyWith(
            fontSize: 18,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedDataType,
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
              items: _dataTypes.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedDataType = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateRange() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: TextStyles.heading4.copyWith(
            fontSize: 18,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDateSelector(
                title: 'From',
                date: _startDate,
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate: DateTime(2020),
                    lastDate: _endDate,
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: AppColors.primary,
                            onPrimary: Colors.white,
                            onSurface: AppColors.secondary,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() {
                      _startDate = picked;
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateSelector(
                title: 'To',
                date: _endDate,
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _endDate,
                    firstDate: _startDate,
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: AppColors.primary,
                            onPrimary: Colors.white,
                            onSurface: AppColors.secondary,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() {
                      _endDate = picked;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSelector({
    required String title,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyles.body2.copyWith(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM d, yyyy').format(date),
                    style: TextStyles.body2.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.calendar_today,
              color: AppColors.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncludeOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Include',
          style: TextStyles.heading4.copyWith(
            fontSize: 18,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 16),
        _buildCheckboxOption(
          title: 'Notes & Comments',
          value: _includeNotes,
          onChanged: (value) {
            setState(() {
              _includeNotes = value!;
            });
          },
        ),
        _buildCheckboxOption(
          title: 'Symptoms & Health Data',
          value: _includeSymptoms,
          onChanged: (value) {
            setState(() {
              _includeSymptoms = value!;
            });
          },
        ),
        _buildCheckboxOption(
          title: 'Mood Tracking',
          value: _includeMoods,
          onChanged: (value) {
            setState(() {
              _includeMoods = value!;
            });
          },
        ),
        _buildCheckboxOption(
          title: 'Analytics & Predictions',
          value: _includeAnalytics,
          onChanged: (value) {
            setState(() {
              _includeAnalytics = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCheckboxOption({
    required String title,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
        ),
      ),
      child: CheckboxListTile(
        title: Text(
          title,
          style: TextStyles.body1.copyWith(
            fontSize: 16,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        checkColor: Colors.white,
        controlAffinity: ListTileControlAffinity.trailing,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
