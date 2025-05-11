import 'package:flutter/material.dart';
import 'package:menstrual_health_ai/constants/app_colors.dart';
import 'package:menstrual_health_ai/models/user_data.dart';
import 'package:menstrual_health_ai/providers/user_data_provider.dart';
import 'package:menstrual_health_ai/screens/dashboard/bottom_nav.dart';
import 'package:menstrual_health_ai/services/ai_service.dart';
import 'package:menstrual_health_ai/widgets/animated_gradient_button.dart';
import 'package:provider/provider.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;
  List<String> _aiTips = [];

  // User data
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _cycleLengthController = TextEditingController(text: '28');
  final TextEditingController _periodLengthController = TextEditingController(text: '5');
  DateTime _lastPeriodDate = DateTime.now().subtract(const Duration(days: 14));
  DateTime _birthDate = DateTime.now().subtract(const Duration(days: 365 * 25)); // Default to 25 years old
  final List<String> _selectedGoals = [];
  final List<String> _availableGoals = [
    'Track my cycle',
    'Manage symptoms',
    'Plan pregnancy',
    'Avoid pregnancy',
    'Understand my body better',
    'Improve my health',
  ];
  bool _isRegularCycle = true;
  
  get age => null;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _cycleLengthController.dispose();
    _periodLengthController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _saveUserData();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _saveUserData() async {
    if (_nameController.text.isEmpty || _ageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Generate AI tips
      await _generateAITips();

      // Save user data
      final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
      
      // Convert goals to the required format
      final List<Map<String, dynamic>> formattedGoals = _selectedGoals.map((goal) => {
        'name': goal,
        'completed': false,
        'date': DateTime.now().toIso8601String(),
      }).toList();
      
      await userDataProvider.saveOnboardingData(
        name: _nameController.text,
        age: age,
        birthDate: _birthDate,
        lastPeriodDate: _lastPeriodDate,
        cycleLength: int.parse(_cycleLengthController.text),
        periodLength: int.parse(_periodLengthController.text),
        height: double.parse(_heightController.text),
        weight: double.parse(_weightController.text),
        healthConditions: [],
        email: '',
        goals: formattedGoals,
        isRegularCycle: _isRegularCycle,
        symptoms: [],
        moods: [],
        notes: [],
      );

      // name: _nameController.text,
      //     age: age,
      //     weight: double.tryParse(_weightController.text) ?? 0.0,
      //     height: double.tryParse(_heightController.text) ?? 0.0,
      //     cycleLength: int.tryParse(_cycleLengthController.text) ?? 28,
      //     periodLength: int.tryParse(_periodLengthController.text) ?? 5,
      //     lastPeriodDate: _lastPeriodDate ?? DateTime.now(),
      //     birthDate: _birthDate ?? DateTime.now(),
      //     email: _emailController.text,
      //     healthConditions: _healthConditions,
          

      // Show AI tips page
      setState(() {
        _currentPage = 4;
        _isLoading = false;
      });
      _pageController.jumpToPage(4);
    } catch (e) {
      print('Error saving user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateAITips() async {
    try {
      final aiService = AIService();
      
      // Create a temporary UserData object for the AI service
      final userData = UserData(
        id: 'temp',
        name: _nameController.text,
        age: int.parse(_ageController.text),
        weight: double.parse(_weightController.text),
        height: double.parse(_heightController.text),
        cycleLength: int.parse(_cycleLengthController.text),
        periodLength: int.parse(_periodLengthController.text),
        lastPeriodDate: _lastPeriodDate,
        birthDate: _birthDate,
        goals: [{'name': 'Track cycle', 'completed': false}],
        healthConditions: [],
        symptoms: [],
        moods: [],
        notes: [],
        isPremium: false,
        email: '',
        periodHistory: [],
        notificationSettings: {},
        language: 'en',
        medications: [],
        exercises: [],
        nutritionLogs: [],
        sleepLogs: [],
        waterIntake: [],
        preferences: {},
        cyclesTracked: 0,
      );
      
      final insights = await aiService.generateDailyInsights(userData);
      setState(() {
        _aiTips = insights;
      });
    } catch (e) {
      print('Error generating AI tips: $e');
      setState(() {
        _aiTips = [
          'Track your cycle regularly for more accurate predictions.',
          'Stay hydrated, especially during your period.',
          'Regular exercise can help reduce period pain and improve mood.'
        ];
      });
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const BottomNav()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: LinearProgressIndicator(
                value: (_currentPage + 1) / 5,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            
            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildBasicInfoPage(),
                  _buildCycleInfoPage(),
                  _buildGoalsPage(),
                  _buildHealthInfoPage(),
                  _buildAITipsPage(),
                ],
              ),
            ),
            
            // Navigation buttons
            if (_currentPage < 4)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentPage > 0)
                      TextButton(
                        onPressed: _previousPage,
                        child: const Text('Back'),
                      )
                    else
                      const SizedBox(width: 80),
                    _isLoading
                      ? const CircularProgressIndicator()
                      : AnimatedGradientButton(
                          onPressed: _isLoading ? null : _nextPage,
                          text: _currentPage < 3 ? 'Next' : 'Finish',
                          isLoading: _isLoading,
                          width: 120,
                          height: 50,
                        ), 
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tell us about yourself',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'We\'ll use this information to personalize your experience',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          
          // Name field
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          
          // Age field
          TextField(
            controller: _ageController,
            decoration: const InputDecoration(
              labelText: 'Age',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          
          // Height field
          TextField(
            controller: _heightController,
            decoration: const InputDecoration(
              labelText: 'Height (cm)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          
          // Weight field
          TextField(
            controller: _weightController,
            decoration: const InputDecoration(
              labelText: 'Weight (kg)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          
          // Birth date picker
          const Text(
            'Birth Date',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: _birthDate,
                firstDate: DateTime(1950),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null) {
                setState(() {
                  _birthDate = pickedDate;
                  _ageController.text = (DateTime.now().year - pickedDate.year).toString();
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_birthDate.day}/${_birthDate.month}/${_birthDate.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Icon(Icons.calendar_today),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCycleInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your cycle information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This helps us predict your cycle and provide personalized insights',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          
          // Last period date
          const Text(
            'When did your last period start?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: _lastPeriodDate,
                firstDate: DateTime.now().subtract(const Duration(days: 90)),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null) {
                setState(() {
                  _lastPeriodDate = pickedDate;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_lastPeriodDate.day}/${_lastPeriodDate.month}/${_lastPeriodDate.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Icon(Icons.calendar_today),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // Cycle length
          const Text(
            'How long is your typical cycle?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'The number of days from the first day of one period to the first day of the next',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _cycleLengthController,
            decoration: const InputDecoration(
              labelText: 'Cycle length (days)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 32),
          
          // Period length
          const Text(
            'How long does your period typically last?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _periodLengthController,
            decoration: const InputDecoration(
              labelText: 'Period length (days)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 32),
          
          // Regular cycle
          const Text(
            'Is your cycle regular?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text('Yes'),
                  value: true,
                  groupValue: _isRegularCycle,
                  onChanged: (value) {
                    setState(() {
                      _isRegularCycle = value!;
                    });
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text('No'),
                  value: false,
                  groupValue: _isRegularCycle,
                  onChanged: (value) {
                    setState(() {
                      _isRegularCycle = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What are your goals?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select all that apply',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          
          // Goals
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableGoals.map((goal) {
              final isSelected = _selectedGoals.contains(goal);
              return FilterChip(
                label: Text(goal),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedGoals.add(goal);
                    } else {
                      _selectedGoals.remove(goal);
                    }
                  });
                },
                backgroundColor: Colors.grey[200],
                selectedColor: AppColors.primary.withOpacity(0.2),
                checkmarkColor: AppColors.primary,
              );
            }).toList(),
          ),
          
          const SizedBox(height: 32),
          
          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Your goals help us personalize your experience and provide relevant insights.',
                    style: TextStyle(color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Health Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This information helps us provide more accurate insights and recommendations',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          
          // Health conditions section
          const Text(
            'Do you have any health conditions?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Health conditions chips would go here
          const Text(
            'No health conditions selected',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Medications section
          const Text(
            'Are you taking any medications?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Medications chips would go here
          const Text(
            'No medications selected',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Privacy note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.privacy_tip_outlined, color: Colors.purple.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Privacy Note',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Your health information is private and secure. We use this information only to provide personalized insights and recommendations.',
                  style: TextStyle(color: Colors.purple.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAITipsPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI-Generated Tips',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Based on your information, here are some personalized tips:',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          
          // AI tips
          Expanded(
            child: ListView.builder(
              itemCount: _aiTips.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.lightbulb_outline,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _aiTips[index],
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Continue button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: SizedBox(
              width: double.infinity,
              child:
              
              AnimatedGradientButton(
                          onPressed: _isLoading ? null : _navigateToHome,
                          text: 'Continue to Home',
                          isLoading: _isLoading,
                          width: 120,
                          height: 50,
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
