import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:menstrual_health_ai/constants/app_colors.dart';
import 'package:menstrual_health_ai/providers/user_data_provider.dart';
import 'package:menstrual_health_ai/screens/dashboard/bottom_nav.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class OnboardingScreens extends StatefulWidget {
  const OnboardingScreens({super.key});

  @override
  State<OnboardingScreens> createState() => _OnboardingScreensState();
}

class _OnboardingScreensState extends State<OnboardingScreens> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 9; // Increased total pages to include age screen

  // User data
  String _name = "";
  int _age = 25; // Default age
  DateTime _birthdate = DateTime(1995, 12, 25);
  double _weight = 60.0;
  double _height = 165.0;
  int _periodLength = 4;
  bool _isRegularCycle = true;
  int _cycleLength = 28;
  DateTime _lastPeriodDate = DateTime.now().subtract(const Duration(days: 14));
  bool _isLoading = false;
  double _loadingProgress = 0.0;

  // Selected cycle days
  List<int> _selectedCycleDays = [26, 27, 28]; // Default for regular cycle

  // Health data for dynamic screens
  List<String> _selectedSymptoms = [];
  List<String> _selectedMoods = [];
  int _painLevel = 2;
  int _energyLevel = 3;
  int _sleepQuality = 3;

  // Available symptoms and moods
  final List<String> _availableSymptoms = [
    "Cramps", "Headache", "Bloating", "Fatigue",
    "Breast Tenderness", "Acne", "Backache", "Nausea"
  ];

  final List<String> _availableMoods = [
    "Happy", "Calm", "Irritable", "Anxious",
    "Sad", "Energetic", "Tired", "Emotional"
  ];

  @override
  void initState() {
    super.initState();
    // Add listener to detect when we reach the loading page
    _pageController.addListener(() {
      if (_pageController.page == 8 && !_isLoading) { // Updated for new page count
        setState(() {
          _isLoading = true;
        });
        _startLoadingAnimation();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startLoadingAnimation() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_loadingProgress < 1.0) {
        setState(() {
          _loadingProgress += 0.02; // Increment by 2% each time
        });
        _startLoadingAnimation();
      } else {
        // Save user data before navigating
        _saveUserData();

        // Navigate to home screen when loading is complete
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const BottomNav()),
          (route) => false,
        );
      }
    });
  }

  void _saveUserData() {
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    
    // Convert selected symptoms and moods to the required format
    final List<Map<String, dynamic>> symptoms = _selectedSymptoms.map((symptom) => {
      'name': symptom,
      'intensity': 1,
      'date': DateTime.now().toIso8601String(),
    }).toList();
    
    final List<Map<String, dynamic>> moods = _selectedMoods.map((mood) => {
      'name': mood,
      'intensity': 1,
      'date': DateTime.now().toIso8601String(),
    }).toList();
    
    // Calculate average cycle length from selected days
    int avgCycleLength = 0;
    if (_selectedCycleDays.isNotEmpty) {
      avgCycleLength = _selectedCycleDays.reduce((a, b) => a + b) ~/ _selectedCycleDays.length;
    } else {
      avgCycleLength = _cycleLength;
    }
    
    userDataProvider.saveOnboardingData(
      name: _name,
      birthDate: _birthdate,
      age: _age, // Use the age input directly
      weight: _weight,
      height: _height,
      periodLength: _periodLength,
      isRegularCycle: _isRegularCycle,
      cycleLength: avgCycleLength,
      lastPeriodDate: _lastPeriodDate,
      goals: [{'name': 'Track cycle', 'completed': false}],
      email: '',
      healthConditions: [],
      symptoms: symptoms,
      moods: moods,
      notes: [],
    );
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 24),
                    onPressed: _previousPage,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),

                  // Progress indicator
                  Text(
                    "${_currentPage + 1}/$_totalPages",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // Progress bar
            Container(
              width: double.infinity,
              height: 4,
              color: Colors.grey.shade200,
              child: Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width *
                        (_currentPage + 1) / _totalPages,
                    height: 4,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildNamePage(),
                  _buildAgePage(), // New age input page
                  _buildBirthdayPage(),
                  _buildWeightPage(),
                  _buildHeightPage(),
                  _buildPeriodLengthPage(),
                  _buildCycleLengthPage(),
                  _buildSymptomsAndMoodPage(),
                  _buildHealthMetricsPage(),
                  _buildLoadingPage(),
                ],
              ),
            ),

            // Next button (hide on loading page)
            if (_currentPage < 9) // Updated for new page count
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: _buildNextButton(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNamePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            "What's your name?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 40),
          TextField(
            onChanged: (value) {
              setState(() {
                _name = value;
              });
            },
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            decoration: const InputDecoration(
              hintText: "Isabella",
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const Divider(
            color: Colors.grey,
            thickness: 1,
          ),
        ],
      ),
    );
  }

  // New age input page
  Widget _buildAgePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            "How old are you?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 40),
          
          // Age display
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Decrement button
                GestureDetector(
                  onTap: () {
                    if (_age > 12) { // Minimum age
                      setState(() {
                        _age--;
                        // Update birthdate to match age
                        _birthdate = DateTime(
                          DateTime.now().year - _age,
                          _birthdate.month,
                          _birthdate.day,
                        );
                      });
                    }
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.remove,
                      color: Colors.black87,
                    ),
                  ),
                ),
                
                // Age value
                Container(
                  width: 120,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    "$_age",
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                // Increment button
                GestureDetector(
                  onTap: () {
                    if (_age < 70) { // Maximum age
                      setState(() {
                        _age++;
                        // Update birthdate to match age
                        _birthdate = DateTime(
                          DateTime.now().year - _age,
                          _birthdate.month,
                          _birthdate.day,
                        );
                      });
                    }
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Age slider
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 8,
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: Colors.grey.shade200,
              thumbColor: AppColors.primary,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 12,
              ),
            ),
            child: Slider(
              value: _age.toDouble(),
              min: 12, // Minimum age
              max: 70, // Maximum age
              divisions: 58, // (70-12)
              onChanged: (value) {
                setState(() {
                  _age = value.round();
                  // Update birthdate to match age
                  _birthdate = DateTime(
                    DateTime.now().year - _age,
                    _birthdate.month,
                    _birthdate.day,
                  );
                });
              },
            ),
          ),
          
          // Age range labels
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "12",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  "30",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  "50",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  "70",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Info text
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue.shade700,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Your age helps us provide more accurate cycle predictions and health insights.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBirthdayPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            "When is your birthday?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 40),

          // Date picker
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Month column
              Column(
                children: [
                  const Text(
                    "Month",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDatePickerColumn(
                    items: List.generate(12, (index) => (index + 1).toString().padLeft(2, '0')),
                    selectedIndex: _birthdate.month - 1,
                    onChanged: (value) {
                      setState(() {
                        _birthdate = DateTime(
                          _birthdate.year,
                          int.parse(value),
                          _birthdate.day,
                        );
                        // Update age based on birthdate
                        _age = DateTime.now().year - _birthdate.year;
                        if (DateTime.now().month < _birthdate.month || 
                            (DateTime.now().month == _birthdate.month && 
                             DateTime.now().day < _birthdate.day)) {
                          _age--;
                        }
                      });
                    },
                  ),
                ],
              ),

              // Day column
              Column(
                children: [
                  const Text(
                    "Day",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDatePickerColumn(
                    items: List.generate(31, (index) => (index + 1).toString().padLeft(2, '0')),
                    selectedIndex: _birthdate.day - 1,
                    onChanged: (value) {
                      setState(() {
                        _birthdate = DateTime(
                          _birthdate.year,
                          _birthdate.month,
                          int.parse(value),
                        );
                        // Update age based on birthdate
                        _age = DateTime.now().year - _birthdate.year;
                        if (DateTime.now().month < _birthdate.month || 
                            (DateTime.now().month == _birthdate.month && 
                             DateTime.now().day < _birthdate.day)) {
                          _age--;
                        }
                      });
                    },
                  ),
                ],
              ),

              // Year column
              Column(
                children: [
                  const Text(
                    "Year",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDatePickerColumn(
                    items: List.generate(50, (index) => (DateTime.now().year - 50 + index).toString()),
                    selectedIndex: _birthdate.year - (DateTime.now().year - 50),
                    onChanged: (value) {
                      setState(() {
                        _birthdate = DateTime(
                          int.parse(value),
                          _birthdate.month,
                          _birthdate.day,
                        );
                        // Update age based on birthdate
                        _age = DateTime.now().year - _birthdate.year;
                        if (DateTime.now().month < _birthdate.month || 
                            (DateTime.now().month == _birthdate.month && 
                             DateTime.now().day < _birthdate.day)) {
                          _age--;
                        }
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 40),
          
          // Display calculated age
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "You are $_age years old",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            "What's your weight?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 40),

          // Weight display
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _weight.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    "kg",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Weight slider
          Column(
            children: [
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 1,
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: Colors.grey.shade300,
                  thumbColor: AppColors.primary,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 12,
                    elevation: 0,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 20,
                  ),
                ),
                child: Slider(
                  value: _weight,
                  min: 30,
                  max: 150,
                  onChanged: (value) {
                    setState(() {
                      _weight = double.parse(value.toStringAsFixed(1));
                    });
                  },
                ),
              ),

              // Slider labels
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "30",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      "60",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      "90",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      "120",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      "150",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeightPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            "How tall are you?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 40),

          // Height display
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _height.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    "cm",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Height slider
          Column(
            children: [
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 1,
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: Colors.grey.shade300,
                  thumbColor: AppColors.primary,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 12,
                    elevation: 0,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 20,
                  ),
                ),
                child: Slider(
                  value: _height,
                  min: 120,
                  max: 210,
                  onChanged: (value) {
                    setState(() {
                      _height = double.parse(value.toStringAsFixed(1));
                    });
                  },
                ),
              ),

              // Slider labels
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "120",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      "140",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      "160",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      "180",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      "200",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodLengthPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            "How long does your period usually last?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 40),

          // Period length options
          Expanded(
            child: ListView.builder(
              itemCount: 6,
              itemBuilder: (context, index) {
                final days = index + 2; // 2-7 days
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _periodLength = days;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: _periodLength == days ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _periodLength == days ? AppColors.primary : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "$days",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: _periodLength == days ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "days",
                            style: TextStyle(
                              fontSize: 14,
                              color: _periodLength == days ? Colors.white : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCycleLengthPage() {
    // Define cycle length ranges based on regularity
    List<int> cycleDays = List.generate(8, (index) => index + 24); // 24-31 days
    
    // Update selected days when regularity changes
    if (_isRegularCycle && !_selectedCycleDays.any((day) => day >= 26 && day <= 28)) {
      _selectedCycleDays = [26, 27, 28];
    } else if (!_isRegularCycle && !_selectedCycleDays.any((day) => day >= 28 && day <= 30)) {
      _selectedCycleDays = [28, 29, 30];
    }
    
    // Calculate range text
    String rangeText = "";
    if (_selectedCycleDays.isNotEmpty) {
      int minDay = _selectedCycleDays.reduce((a, b) => a < b ? a : b);
      int maxDay = _selectedCycleDays.reduce((a, b) => a > b ? a : b);
      rangeText = "$minDay - $maxDay days";
    }
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            "How long does your cycle usually last?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),

          // Regular/Irregular toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildToggleButton(
                text: "Regular",
                isSelected: _isRegularCycle,
                onTap: () {
                  setState(() {
                    if (!_isRegularCycle) {
                      _isRegularCycle = true;
                      // Update selected days for regular cycle
                      _selectedCycleDays = [26, 27, 28];
                    }
                  });
                },
              ),
              const SizedBox(width: 16),
              _buildToggleButton(
                text: "Irregular",
                isSelected: !_isRegularCycle,
                onTap: () {
                  setState(() {
                    if (_isRegularCycle) {
                      _isRegularCycle = false;
                      // Update selected days for irregular cycle
                      _selectedCycleDays = [28, 29, 30];
                    }
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Cycle length options
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              childAspectRatio: 1.5,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: cycleDays.map((day) {
                final isSelected = _selectedCycleDays.contains(day);
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      // Toggle selection
                      if (isSelected) {
                        // Don't allow deselecting if it's the last selected day
                        if (_selectedCycleDays.length > 1) {
                          _selectedCycleDays.remove(day);
                        }
                      } else {
                        _selectedCycleDays.add(day);
                      }
                      
                      // Update cycle length based on average of selected days
                      if (_selectedCycleDays.isNotEmpty) {
                        _cycleLength = _selectedCycleDays.reduce((a, b) => a + b) ~/ _selectedCycleDays.length;
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "$day",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppColors.primary : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Selected range
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    rangeText,
                    style: TextStyle(
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
    );
  }

// New dynamic screen for symptoms and mood
  Widget _buildSymptomsAndMoodPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              "What symptoms do you typically experience?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            // Symptoms grid
            Wrap(
              spacing: 8,
              runSpacing: 12,
              children: _availableSymptoms.map((symptom) {
                final isSelected = _selectedSymptoms.contains(symptom);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedSymptoms.remove(symptom);
                      } else {
                        _selectedSymptoms.add(symptom);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      symptom,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            const Text(
              "How would you describe your typical mood?",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            // Moods grid
            Wrap(
              spacing: 8,
              runSpacing: 12,
              children: _availableMoods.map((mood) {
                final isSelected = _selectedMoods.contains(mood);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedMoods.remove(mood);
                      } else {
                        _selectedMoods.add(mood);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.secondary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.secondary : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      mood,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // Info text
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "This information helps us provide more personalized insights about your cycle.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade700,
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
    );
  }

// New dynamic screen for health metrics
  Widget _buildHealthMetricsPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              "Your Health Metrics",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Help us understand your typical health patterns",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),

            // Pain level
            _buildMetricSlider(
              title: "Pain Level",
              value: _painLevel,
              min: 0,
              max: 5,
              labels: const ["None", "Mild", "Moderate", "Strong", "Severe", "Extreme"],
              onChanged: (value) {
                setState(() {
                  _painLevel = value.round();
                });
              },
            ),

            const SizedBox(height: 24),

            // Energy level
            _buildMetricSlider(
              title: "Energy Level",
              value: _energyLevel,
              min: 0,
              max: 5,
              labels: const ["Very Low", "Low", "Moderate", "Good", "High", "Very High"],
              onChanged: (value) {
                setState(() {
                  _energyLevel = value.round();
                });
              },
            ),

            const SizedBox(height: 24),

            // Sleep quality
            _buildMetricSlider(
              title: "Sleep Quality",
              value: _sleepQuality,
              min: 0,
              max: 5,
              labels: const ["Very Poor", "Poor", "Fair", "Good", "Very Good", "Excellent"],
              onChanged: (value) {
                setState(() {
                  _sleepQuality = value.round();
                });
              },
            ),

            const SizedBox(height: 32),

            // AI personalization note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.secondary, Color(0xFF9D97FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "AI Personalization",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Our AI will analyze your data to provide personalized insights and recommendations.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricSlider({
    required String title,
    required int value,
    required int min,
    required int max,
    required List<String> labels,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          labels[value],
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: Colors.grey.shade200,
            thumbColor: AppColors.primary,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 10,
            ),
          ),
          child: Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              labels.first,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            Text(
              labels.last,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLastPeriodPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            "When did your last period start?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),

          // Month selector
          Center(
            child: Text(
              "August",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Calendar
          Expanded(
            child: Column(
              children: [
                // Weekday headers
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    Text("Sun", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text("Mon", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text("Tue", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text("Wed", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text("Thu", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text("Fri", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text("Sat", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),

                const SizedBox(height: 16),

                // Calendar grid
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 1,
                    ),
                    itemCount: 42, // 6 weeks
                    itemBuilder: (context, index) {
                      // This is a simplified calendar for the mockup
                      // In a real app, you'd calculate the actual days
                      final day = index - 2; // Start from -2 to align with the first day of the month

                      if (day < 1 || day > 31) {
                        return const SizedBox();
                      }

                      final isSelected = day == 20 || day == 21;
                      final isToday = day == 15;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _lastPeriodDate = DateTime(2023, 8, day);
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : (isToday ? Colors.grey.shade200 : Colors.transparent),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              "$day",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected || isToday ? FontWeight.w600 : FontWeight.normal,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Month selector
          Center(
            child: Text(
              "September",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "We're setting up your personalized calendar...",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),

          // Progress indicator
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: _loadingProgress,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                Text(
                  "${(_loadingProgress * 100).toInt()}%",
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 60),

          const Text(
            "This will only take a moment!",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerColumn({
    required List<String> items,
    required int selectedIndex,
    required Function(String) onChanged,
  }) {
    return Container(
      height: 150,
      width: 60,
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () {
              onChanged(items[index]);
            },
            child: Container(
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                items[index],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppColors.primary : Colors.black87,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildToggleButton({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return GestureDetector(
      onTap: _nextPage,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.arrow_forward_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}
