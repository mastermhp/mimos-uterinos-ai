import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:menstrual_health_ai/constants/app_colors.dart';
import 'package:menstrual_health_ai/constants/text_styles.dart';
import 'package:menstrual_health_ai/models/user_data.dart';
import 'package:menstrual_health_ai/providers/user_data_provider.dart';
import 'package:menstrual_health_ai/screens/ai_features/ai_coach_screen.dart';
import 'package:menstrual_health_ai/screens/cycle/cycle_calendar_screen.dart';
import 'package:menstrual_health_ai/screens/cycle/log_symptoms_screen.dart';
import 'package:menstrual_health_ai/screens/doctor/doctor_mode_screen.dart';
import 'package:menstrual_health_ai/screens/premium/premium_screen.dart';
import 'package:menstrual_health_ai/screens/reminders/reminders_screen.dart';
import 'package:menstrual_health_ai/services/ai_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final AIService _aiService = AIService();
  List<String> _aiInsights = [];
  bool _isLoadingInsights = true;
  bool _showReminders = false;
  List<Map<String, dynamic>> _reminders = [];
  bool _isLoadingReminders = true;
  Map<String, dynamic> _predictions = {};
  bool _isLoadingPredictions = true;
  Map<String, dynamic> _recommendations = {};
  bool _isLoadingRecommendations = true;
  DateTime _selectedDate = DateTime.now();
  
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAIData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadAIData() async {
    setState(() {
      _isLoadingInsights = true;
      _isLoadingReminders = true;
      _isLoadingPredictions = true;
      _isLoadingRecommendations = true;
    });
    
    final userData = Provider.of<UserDataProvider>(context, listen: false).userData;
    
    if (userData != null) {
      // Load insights
      final insights = await _aiService.generateDailyInsights(userData);
      
      // Load reminders
      final behaviorPatterns = {
        'sleep': 'Irregular',
        'stress': 'High',
        'exercise': 'Moderate',
        'hydration': 'Low',
        'medication': 'None'
      };
      final reminders = await _aiService.generateSmartReminders(userData);
      
      // Load predictions
      final predictions = await _aiService.getCalendarPredictions(userData);
      
      // Load recommendations
      final today = DateTime.now();
      final daysSinceLastPeriod = today.difference(userData.lastPeriodDate).inDays;
      final currentCycleDay = (daysSinceLastPeriod % userData.cycleLength) + 1;
      
      String currentPhase;
      if (currentCycleDay <= userData.periodLength) {
        currentPhase = "Menstrual";
      } else if (currentCycleDay <= userData.cycleLength / 2) {
        currentPhase = "Follicular";
      } else if (currentCycleDay == (userData.cycleLength / 2).round()) {
        currentPhase = "Ovulation";
      } else {
        currentPhase = "Luteal";
      }
      
      final recommendations = await _aiService.generatePersonalizedRecommendations(userData);
      
      setState(() {
        _aiInsights = insights;
        _reminders = reminders;
        _predictions = predictions;
        _recommendations = recommendations;
        _isLoadingInsights = false;
        _isLoadingReminders = false;
        _isLoadingPredictions = false;
        _isLoadingRecommendations = false;
      });
    } else {
      setState(() {
        _aiInsights = [
          "Complete your profile to get personalized insights.",
          "Track your cycle to receive tailored recommendations.",
          "Your data helps us provide better guidance for your health."
        ];
        _reminders = [
          {
            'title': 'Complete Profile',
            'description': 'Set up your profile to get personalized reminders',
            'timing': 'Now',
            'icon': 'person'
          }
        ];
        _predictions = {
          'nextPeriod': 'Complete your profile',
          'ovulation': 'Complete your profile',
          'fertileWindow': 'Complete your profile',
        };
        _recommendations = {
          'nutrition': ['Complete your profile to get personalized nutrition recommendations'],
          'exercise': ['Complete your profile to get personalized exercise recommendations'],
          'sleep': ['Complete your profile to get personalized sleep recommendations'],
          'selfCare': ['Complete your profile to get personalized self-care recommendations']
        };
        _isLoadingInsights = false;
        _isLoadingReminders = false;
        _isLoadingPredictions = false;
        _isLoadingRecommendations = false;
      });
    }
  }
  
  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    // You can add additional logic here to update other parts of the UI based on the selected date
    // For example, load symptoms or data specific to the selected date
  }
  
  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserDataProvider>(context).userData;
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _loadAIData,
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 400, // Increased to accommodate calendar strip
              floating: false,
              pinned: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  "Mimos Uterinos",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Gradient background
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            AppColors.primary,
                            AppColors.primaryDark,
                          ],
                        ),
                      ),
                    ),
                    // Decorative circles
                    Positioned(
                      top: -50,
                      right: -80,
                      child: Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -90,
                      left: -90,
                      child: Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    // User greeting and cycle info
                    Positioned(
                      top: 120,
                      left: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hello, ${userData?.name ?? 'there'}!",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _getCycleStatusText(userData),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Calendar strip
                    Positioned(
                      top: 240,
                      left: 0,
                      right: 0,
                      child: _buildCalendarStrip(userData),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.notifications_outlined, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _showReminders = !_showReminders;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.settings_outlined, color: Colors.white),
                  onPressed: () {
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
              ],
            ),
            
            // Reminders panel (conditionally shown)
            if (_showReminders)
              SliverToBoxAdapter(
                child: _buildRemindersPanel(),
              ),
            
            // Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  "Quick Actions",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            
            SliverToBoxAdapter(
              child: Container(
                // width: 300,
                height: 100,
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildQuickActionCard(
                      icon: Icons.edit_note_rounded,
                      title: "Log Symptoms",
                      color: AppColors.primary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LogSymptomsScreen()),
                        );
                      },
                    ),
                    _buildQuickActionCard(
                      icon: Icons.calendar_month_rounded,
                      title: "View Calendar",
                      color: Color(0xFF6C63FF),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CycleCalendarScreen()),
                        );
                      },
                    ),
                    _buildQuickActionCard(
                      icon: Icons.auto_awesome,
                      title: "AI Coach",
                      color: Color(0xFF00D9C6),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AiCoachScreen()),
                        );
                      },
                    ),
                    _buildQuickActionCard(
                      icon: Icons.medical_services_outlined,
                      title: "Doctor Mode",
                      color: Color(0xFFFF5C8A),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DoctorModeScreen()),
                        );
                      },
                    ),
                    _buildQuickActionCard(
                      icon: Icons.notifications_active_outlined,
                      title: "Reminders",
                      color: Color(0xFFFFB347),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RemindersScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            // Cycle Predictions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Cycle Predictions",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CycleCalendarScreen()),
                        );
                      },
                      child: const Text(
                        "View Calendar",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SliverToBoxAdapter(
              child: _buildPredictionsCard(),
            ),
            
            // AI Insights
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Today's Insights",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AiCoachScreen()),
                        );
                      },
                      child: const Text(
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
            ),
            
            SliverToBoxAdapter(
              child: _buildInsightsCard(),
            ),
            
            // Personalized Recommendations
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Recommendations",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PremiumScreen()),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(Icons.star, color: Color(0xFFFFD700), size: 16),
                          SizedBox(width: 4),
                          Text(
                            "Premium",
                            style: TextStyle(
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
            ),
            
            SliverToBoxAdapter(
              child: _buildRecommendationsCard(),
            ),
            
            // Bottom padding
            SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCalendarStrip(UserData? userData) {
    // Get today's date
    final today = DateTime.now();
    
    // Generate dates for the strip (3 days before today, today, and 1 day after)
    final dates = List.generate(
      6,
      (index) => today.subtract(Duration(days: 4 - index)),
    );

    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary,
          ],
        ),
      ),
      child: Column(
        children: [
          // Day of week labels
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 40.0, right: 40.0, bottom: 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: dates.map((date) {
                final dayLetter = DateFormat('E').format(date)[0];
                return Expanded(
                  child: Text(
                    dayLetter,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Date numbers
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: dates.map((date) {
                  final isToday = _isSameDay(date, today);
                  final isTomorrow = _isSameDay(date, today.add(Duration(days: 1)));
                  final isSelected = _isSameDay(date, _selectedDate);
                  
                  // Check if this date is in period (for highlighting)
                  bool isInPeriod = false;
                  if (userData != null) {
                    final daysSinceLastPeriod = date.difference(userData.lastPeriodDate).inDays;
                    final cycleDay = (daysSinceLastPeriod % userData.cycleLength) + 1;
                    isInPeriod = cycleDay <= userData.periodLength;
                  }

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _onDateSelected(date),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isToday)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 0.0),
                              child: Text(
                                "TODAY",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Date container
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: isTomorrow 
                                      ? Border.all(
                                          color: Colors.white,
                                          width: 2,
                                          // style: BorderStyle.dotted,
                                        )
                                      : null,
                                  color: isToday 
                                      ? Colors.white 
                                      : Colors.transparent,
                                ),
                                child: Center(
                                  child: Text(
                                    date.day.toString(),
                                    style: TextStyle(
                                      color: isToday 
                                          ? AppColors.primary 
                                          : Colors.white,
                                      fontSize: isToday ? 18 : isTomorrow ? 18 : 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              
                              // Period indicator (small dot at bottom)
                              if (isInPeriod && !isToday)
                                Positioned(
                                  bottom: 5,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
  
  String _getCycleStatusText(UserData? userData) {
    if (userData == null) {
      return "Complete your profile to track your cycle";
    }
    
    final today = DateTime.now();
    final daysSinceLastPeriod = today.difference(userData.lastPeriodDate).inDays;
    final currentCycleDay = (daysSinceLastPeriod % userData.cycleLength) + 1;
    
    if (currentCycleDay <= userData.periodLength) {
      return "Day $currentCycleDay of your period";
    } else {
      final daysUntilNextPeriod = userData.cycleLength - currentCycleDay + 1;
      return "Day $currentCycleDay of your cycle • $daysUntilNextPeriod days until next period";
    }
  }
  
  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(10),
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
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRemindersPanel() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
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
                "Smart Reminders",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, size: 20),
                onPressed: () {
                  setState(() {
                    _showReminders = false;
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 8),
          if (_isLoadingReminders)
            Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          else
            Column(
              children: _reminders.map((reminder) {
                IconData iconData;
                switch (reminder['icon']) {
                  case 'water_drop':
                    iconData = Icons.water_drop;
                    break;
                  case 'pill':
                    iconData = Icons.medication;
                    break;
                  case 'sleep':
                    iconData = Icons.bedtime;
                    break;
                  case 'exercise':
                    iconData = Icons.fitness_center;
                    break;
                  case 'person':
                    iconData = Icons.person;
                    break;
                  default:
                    iconData = Icons.notifications;
                }
                
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          iconData,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reminder['title'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              reminder['description'],
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          reminder['timing'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RemindersScreen()),
                );
              },
              icon: Icon(Icons.settings, size: 16),
              label: Text("Manage Reminders"),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPredictionsCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6A11CB),
            Color(0xFF2575FC),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF6A11CB).withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.calendar_month,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Text(
                "Cycle Predictions",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          if (_isLoadingPredictions)
            Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          else
            Column(
              children: [
                _buildPredictionRow(
                  icon: Icons.calendar_today,
                  title: "Next Period",
                  value: _predictions['nextPeriod'] ?? 'Unable to predict',
                ),
                SizedBox(height: 16),
                _buildPredictionRow(
                  icon: Icons.egg_alt,
                  title: "Ovulation",
                  value: _predictions['ovulation'] ?? 'Unable to predict',
                ),
                SizedBox(height: 16),
                _buildPredictionRow(
                  icon: Icons.favorite,
                  title: "Fertile Window",
                  value: _predictions['fertileWindow'] ?? 'Unable to predict',
                ),
              ],
            ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
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
    );
  }
  
  Widget _buildPredictionRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
        ),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildInsightsCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Text(
                "AI Insights",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (_isLoadingInsights)
            Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _aiInsights.map((insight) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          insight,
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
  
  Widget _buildRecommendationsCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Tab bar
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: [
                Tab(text: "Nutrition"),
                Tab(text: "Exercise"),
                Tab(text: "Sleep"),
                Tab(text: "Self-Care"),
              ],
            ),
          ),
          
          // Tab content
          Container(
            height: 200,
            padding: EdgeInsets.all(20),
            child: _isLoadingRecommendations
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRecommendationsList(_recommendations['nutrition'] ?? []),
                      _buildRecommendationsList(_recommendations['exercise'] ?? []),
                      _buildRecommendationsList(_recommendations['sleep'] ?? []),
                      _buildRecommendationsList(_recommendations['selfCare'] ?? []),
                    ],
                  ),
          ),
          
          // Premium button
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.star,
                  color: Color(0xFFFFD700),
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Upgrade to Premium for more personalized recommendations",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PremiumScreen()),
                    );
                  },
                  child: Text(
                    "Upgrade",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
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
  
  Widget _buildRecommendationsList(List<dynamic> recommendations) {
    return ListView.builder(
      itemCount: recommendations.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(top: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  recommendations[index],
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}