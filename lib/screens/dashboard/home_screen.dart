import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menstrual_health_ai/constants/app_colors.dart';
import 'package:menstrual_health_ai/models/user_data.dart';
import 'package:menstrual_health_ai/providers/user_data_provider.dart';
import 'package:menstrual_health_ai/screens/ai_features/ai_coach_screen.dart';
import 'package:menstrual_health_ai/screens/cycle/cycle_calendar_screen.dart';
import 'package:menstrual_health_ai/screens/cycle/log_symptoms_screen.dart';
import 'package:menstrual_health_ai/screens/doctor/doctor_mode_screen.dart';
import 'package:menstrual_health_ai/services/ai_service.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AIService _aiService = AIService();
  List<String> _aiInsights = [];
  bool _isLoadingInsight = true;
  int _selectedTabIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
    _loadAIInsights();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadAIInsights() async {
    setState(() {
      _isLoadingInsight = true;
    });
    
    try {
      final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
      final userData = userDataProvider.userData;
      
      if (userData != null) {
        final insights = await _aiService.generateDailyInsights(userData);
        setState(() {
          _aiInsights = insights;
          _isLoadingInsight = false;
        });
      } else {
        setState(() {
          _aiInsights = ['Please complete your profile to get personalized insights.'];
          _isLoadingInsight = false;
        });
      }
    } catch (e) {
      setState(() {
        _aiInsights = ['Unable to load insights at this time. Please try again later.'];
        _isLoadingInsight = false;
      });
      print('Error loading AI insights: $e');
    }
  }
  
  int _calculateCycleDay(DateTime lastPeriodDate, int cycleLength) {
    final today = DateTime.now();
    final difference = today.difference(lastPeriodDate).inDays;
    return (difference % cycleLength) + 1;
  }
  
  int _calculateDaysUntilNextPeriod(DateTime lastPeriodDate, int cycleLength) {
    final today = DateTime.now();
    final difference = today.difference(lastPeriodDate).inDays;
    final daysInCurrentCycle = difference % cycleLength;
    return cycleLength - daysInCurrentCycle;
  }
  
  String _getCyclePhase(int cycleDay, int cycleLength) {
    final periodLength = Provider.of<UserDataProvider>(context, listen: false).userData?.periodLength ?? 5;
    
    if (cycleDay <= periodLength) {
      return 'menstrual phase';
    } else if (cycleDay <= 14) {
      return 'follicular phase';
    } else if (cycleDay == 14 || cycleDay == 15) {
      return 'ovulation phase';
    } else {
      return 'luteal phase';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final userDataProvider = Provider.of<UserDataProvider>(context);
    final userData = userDataProvider.userData;
    
    if (userData == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    final cycleDay = _calculateCycleDay(userData.lastPeriodDate, userData.cycleLength);
    final daysUntilNextPeriod = _calculateDaysUntilNextPeriod(userData.lastPeriodDate, userData.cycleLength);
    final cyclePhase = _getCyclePhase(cycleDay, userData.cycleLength);
    
    return Scaffold(
      body: Column(
        children: [
          // Header with gradient background
          Container(
            padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
              ),
            ),
            child: Column(
              children: [
                // App title and icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Spacer(),
                    const Text(
                      "Mimos Uterinos",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                      onPressed: () {
                        // Navigate to notifications
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () {
                        // Navigate to settings
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Today's Insights section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Today's Insights",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AiCoachScreen()),
                    );
                  },
                  child: Text(
                    "Ask AI Coach",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // AI Insights card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // AI Insights header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.auto_awesome,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "AI Insights",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // AI Insights content
                    _isLoadingInsight
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _aiInsights.isEmpty
                                ? [
                                    // Default insights if AI insights are empty
                                    _buildInsightItem(
                                      "Okay, ${userData.name.toLowerCase()}, here are some personalized insights for you on cycle day $cycleDay, in your $cyclePhase:"
                                    ),
                                    const SizedBox(height: 16),
                                    _buildInsightItem(
                                      "Physical Well-being: ${_getPhysicalWellbeingText(cyclePhase)}"
                                    ),
                                    const SizedBox(height: 16),
                                    _buildInsightItem(
                                      "Emotional Well-being: ${_getEmotionalWellbeingText(cyclePhase)}"
                                    ),
                                  ]
                                : _aiInsights.map((insight) => _buildInsightItem(insight)).toList(),
                          ),
                  ],
                ),
              ),
            ),
          ),
          
          // Recommendations section
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Recommendations",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Premium",
                      style: TextStyle(
                        color: Colors.amber[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Recommendation tabs
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: "Nutrition"),
                Tab(text: "Exercise"),
                Tab(text: "Sleep"),
                Tab(text: "Self-Care"),
              ],
            ),
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNutritionTab(cyclePhase),
                _buildExerciseTab(cyclePhase),
                _buildSleepTab(cyclePhase),
                _buildSelfCareTab(cyclePhase),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInsightItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 6, right: 8),
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
  
  String _getPhysicalWellbeingText(String cyclePhase) {
    if (cyclePhase == 'luteal phase') {
      return "You might experience some PMS symptoms like bloating or breast tenderness due to hormonal shifts in the luteal phase, so prioritize gentle movement and hydration.";
    } else if (cyclePhase == 'menstrual phase') {
      return "During your period, you may experience cramps or fatigue. Gentle movement and warm compresses can help ease discomfort.";
    } else if (cyclePhase == 'follicular phase') {
      return "Your energy levels are likely increasing. This is a great time for more challenging workouts and new activities.";
    } else {
      return "You're likely at your peak energy levels during ovulation. Take advantage with challenging workouts or activities that require coordination.";
    }
  }
  
  String _getEmotionalWellbeingText(String cyclePhase) {
    if (cyclePhase == 'luteal phase') {
      return "It's common to feel more introspective or sensitive during this phase; allow yourself extra rest and avoid over-scheduling.";
    } else if (cyclePhase == 'menstrual phase') {
      return "You may feel more reflective during your period. Take time for self-care and emotional processing.";
    } else if (cyclePhase == 'follicular phase') {
      return "This is typically a time of increasing optimism and creativity. Great time for social activities and new projects.";
    } else {
      return "During ovulation, you may experience high confidence and improved communication skills. Ideal for important conversations and social events.";
    }
  }
  
  Widget _buildNutritionTab(String cyclePhase) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildRecommendationCard(
          icon: Icons.restaurant,
          title: "Focus on Iron-Rich Foods",
          description: cyclePhase == 'menstrual phase'
              ? "During your period, focus on iron-rich foods like spinach, lentils, and lean red meat to replenish iron lost during menstruation."
              : cyclePhase == 'follicular phase'
                  ? "Incorporate foods rich in B vitamins like whole grains, eggs, and leafy greens to support energy production during this active phase."
                  : cyclePhase == 'ovulation phase'
                      ? "Eat antioxidant-rich foods like berries, nuts, and colorful vegetables to support hormonal balance during ovulation."
                      : "Include magnesium-rich foods like dark chocolate, avocados, and nuts to help reduce PMS symptoms during the luteal phase.",
        ),
        const SizedBox(height: 16),
        _buildRecommendationCard(
          icon: Icons.water_drop,
          title: "Hydration Tips",
          description: "Increase your water intake to at least 8-10 glasses per day. Add lemon or cucumber for flavor and added benefits.",
        ),
        const SizedBox(height: 16),
        _buildRecommendationCard(
          icon: Icons.no_food,
          title: "Foods to Avoid",
          description: cyclePhase == 'luteal phase'
              ? "Limit salt, caffeine, and sugar which can worsen bloating and mood swings during the luteal phase."
              : "Minimize processed foods, excessive caffeine, and alcohol which can disrupt hormonal balance.",
        ),
      ],
    );
  }
  
  Widget _buildExerciseTab(String cyclePhase) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildRecommendationCard(
          icon: Icons.fitness_center,
          title: "Recommended Activities",
          description: cyclePhase == 'menstrual phase'
              ? "Gentle exercises like walking, light yoga, or swimming can help reduce cramps and improve mood during your period."
              : cyclePhase == 'follicular phase'
                  ? "Your energy is increasing! This is a great time for more intense workouts like HIIT, strength training, or cardio."
                  : cyclePhase == 'ovulation phase'
                      ? "You're likely at your peak energy levels. Take advantage with challenging workouts, team sports, or dance classes."
                      : "As energy decreases, focus on moderate activities like pilates, cycling, or barre workouts during the luteal phase.",
        ),
        const SizedBox(height: 16),
        _buildRecommendationCard(
          icon: Icons.schedule,
          title: "Optimal Workout Duration",
          description: "Aim for 30-45 minutes of exercise most days of the week, adjusting intensity based on your energy levels and how you feel.",
        ),
        const SizedBox(height: 16),
        _buildRecommendationCard(
          icon: Icons.tips_and_updates,
          title: "Exercise Tips",
          description: "Listen to your body and adjust your workout intensity accordingly. Remember that consistency is more important than intensity.",
        ),
      ],
    );
  }
  
  Widget _buildSleepTab(String cyclePhase) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildRecommendationCard(
          icon: Icons.nightlight_round,
          title: "Sleep Duration",
          description: "Aim for 7-9 hours of quality sleep each night. Your body may need more sleep during your menstrual phase and late luteal phase.",
        ),
        const SizedBox(height: 16),
        _buildRecommendationCard(
          icon: Icons.bedtime,
          title: "Bedtime Routine",
          description: "Establish a calming bedtime routine: dim lights, avoid screens 1 hour before bed, and try relaxation techniques like deep breathing.",
        ),
        const SizedBox(height: 16),
        _buildRecommendationCard(
          icon: Icons.thermostat,
          title: "Sleep Environment",
          description: cyclePhase == 'luteal phase'
              ? "Your body temperature may be higher during the luteal phase. Keep your bedroom cool (65-68°F/18-20°C) for better sleep."
              : "Create a cool, dark, and quiet sleep environment. Consider using a white noise machine if needed.",
        ),
      ],
    );
  }
  
  Widget _buildSelfCareTab(String cyclePhase) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildRecommendationCard(
          icon: Icons.spa,
          title: "Stress Management",
          description: cyclePhase == 'luteal phase'
              ? "PMS can increase stress sensitivity. Practice mindfulness meditation, deep breathing, or gentle yoga to reduce stress."
              : "Regular stress management practices like meditation, journaling, or time in nature can help balance hormones throughout your cycle.",
        ),
        const SizedBox(height: 16),
        _buildRecommendationCard(
          icon: Icons.bathtub,
          title: "Self-Care Rituals",
          description: "Schedule regular self-care activities like warm baths, massage, or facial treatments. These can be especially helpful during your period or luteal phase.",
        ),
        const SizedBox(height: 16),
        _buildRecommendationCard(
          icon: Icons.psychology,
          title: "Emotional Wellbeing",
          description: "Honor your emotional needs throughout your cycle. Consider tracking your moods to identify patterns and implement supportive practices.",
        ),
      ],
    );
  }
  
  Widget _buildRecommendationCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
