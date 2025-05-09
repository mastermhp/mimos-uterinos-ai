// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:menstrual_health_ai/models/user_data.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class UserDataProvider with ChangeNotifier {
//   UserData? _userData;
//   bool _hasCompletedOnboarding = false;

//   UserData? get userData => _userData;
//   bool get hasCompletedOnboarding => _hasCompletedOnboarding;

//   UserDataProvider() {
//     _loadUserData();
//   }

// Future<void> setUserData(UserData userData) async {
//     _userData = userData;
    
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('userData', json.encode(userData.toJson()));
    
//     notifyListeners();
//   }


//   Future<void> _loadUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final userDataJson = prefs.getString('userData');
//     final hasCompleted = prefs.getBool('hasCompletedOnboarding') ?? false;

//     if (userDataJson != null) {
//       try {
//         _userData = UserData.fromJson(json.decode(userDataJson));
//       } catch (e) {
//         print('Error loading user data: $e');
//         _userData = null;
//       }
//     }

//     _hasCompletedOnboarding = hasCompleted;
//     notifyListeners();
//   }



//   Future<void> saveUserData(UserData userData) async {
//     _userData = userData;
    
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('userData', json.encode(userData.toJson()));
    
//     notifyListeners();
//   }

//   Future<void> saveOnboardingData({
//     required String name,
//     required DateTime birthdate,
//     required double weight,
//     required double height,
//     required int periodLength,
//     required bool isRegularCycle,
//     required int cycleLength,
//     required DateTime lastPeriodDate,
//   }) async {
//     final age = DateTime.now().year - birthdate.year;
    
//     final userData = UserData(
//       name: name,
//       age: age,
//       birthdate: birthdate,
//       weight: weight,
//       height: height,
//       periodLength: periodLength,
//       isRegularCycle: isRegularCycle,
//       cycleLength: cycleLength,
//       lastPeriodDate: lastPeriodDate,
//       goals: [],
//       email: null,
//       isPremium: false,
//       cyclesTracked: 0,
//     );
    
//     await saveUserData(userData);
//     await setOnboardingComplete();
//   }

//   Future<void> setOnboardingComplete() async {
//     _hasCompletedOnboarding = true;
    
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('hasCompletedOnboarding', true);
    
//     notifyListeners();
//   }

//   Future<void> updateUserData({
//     String? name,
//     String? email,
//     int? age,
//     double? weight,
//     double? height,
//     int? cycleLength,
//     int? periodLength,
//     DateTime? lastPeriodDate,
//     DateTime? birthdate,
//     List<String>? goals,
//     bool? isRegularCycle,
//     bool? isPremium,
//     int? cyclesTracked,
//   }) async {
//     if (_userData == null) return;

//     _userData = _userData!.copyWith(
//       name: name,
//       email: email,
//       age: age,
//       weight: weight,
//       height: height,
//       cycleLength: cycleLength,
//       periodLength: periodLength,
//       lastPeriodDate: lastPeriodDate,
//       birthdate: birthdate,
//       goals: goals,
//       isRegularCycle: isRegularCycle,
//       isPremium: isPremium,
//       cyclesTracked: cyclesTracked,
//     );

//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('userData', json.encode(_userData!.toJson()));

//     notifyListeners();
//   }

//   Future<void> clearUserData() async {
//     _userData = null;
//     _hasCompletedOnboarding = false;
    
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('userData');
//     await prefs.remove('hasCompletedOnboarding');
    
//     notifyListeners();
//   }
// }




import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:menstrual_health_ai/models/user_data.dart';

class UserDataProvider with ChangeNotifier {
  UserData? _userData;
  bool _isLoading = false;
  String? _error;

  UserData? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  UserDataProvider() {
    loadUserData();
  }

  Future<void> setUserData(UserData userData) async {
    _userData = userData;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userData', json.encode(userData.toJson()));
    
    notifyListeners();
  }

  Future<void> loadUserData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataJson = prefs.getString('userData');

      if (userDataJson != null) {
        final Map<String, dynamic> userDataMap = json.decode(userDataJson);
        _userData = UserData.fromJson(userDataMap);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load user data: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveUserData(UserData userData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataJson = json.encode(userData.toJson());
      await prefs.setString('userData', userDataJson);
      _userData = userData;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to save user data: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserData({
    String? name,
    int? age,
    DateTime? birthDate,
    DateTime? lastPeriodDate,
    int? cycleLength,
    int? periodLength,
    double? height,
    double? weight,
    List<String>? healthConditions,
    String? email,
    String? profileImageUrl,
    Map<String, bool>? notificationSettings,
    String? theme,
    String? language,
  }) async {
    if (_userData == null) {
      _error = 'No user data to update';
      notifyListeners();
      return;
    }

    final updatedUserData = _userData!.copyWith(
      name: name,
      age: age,
      birthDate: birthDate,
      lastPeriodDate: lastPeriodDate,
      cycleLength: cycleLength,
      periodLength: periodLength,
      height: height,
      weight: weight,
      healthConditions: healthConditions,
      email: email,
      profileImageUrl: profileImageUrl,
      notificationSettings: notificationSettings,
      theme: theme,
      language: language,
    );

    await saveUserData(updatedUserData);
  }

  Future<void> updatePeriodHistory(Map<String, dynamic> periodData) async {
    if (_userData == null) {
      _error = 'No user data to update';
      notifyListeners();
      return;
    }

    final updatedPeriodHistory = List<Map<String, dynamic>>.from(_userData!.periodHistory);
    updatedPeriodHistory.add(periodData);

    final updatedUserData = _userData!.copyWith(
      periodHistory: updatedPeriodHistory,
    );

    await saveUserData(updatedUserData);
  }

  Future<void> updateLastPeriodDate(DateTime date) async {
    if (_userData == null) {
      _error = 'No user data to update';
      notifyListeners();
      return;
    }

    final updatedUserData = _userData!.copyWith(
      lastPeriodDate: date,
    );

    await saveUserData(updatedUserData);
  }

  Future<void> updateNotificationSettings(Map<String, bool> settings) async {
    if (_userData == null) {
      _error = 'No user data to update';
      notifyListeners();
      return;
    }

    final updatedUserData = _userData!.copyWith(
      notificationSettings: settings,
    );

    await saveUserData(updatedUserData);
  }

  Future<void> updateTheme(String theme) async {
    if (_userData == null) {
      _error = 'No user data to update';
      notifyListeners();
      return;
    }

    final updatedUserData = _userData!.copyWith(
      theme: theme,
    );

    await saveUserData(updatedUserData);
  }

  Future<void> updateLanguage(String language) async {
    if (_userData == null) {
      _error = 'No user data to update';
      notifyListeners();
      return;
    }

    final updatedUserData = _userData!.copyWith(
      language: language,
    );

    await saveUserData(updatedUserData);
  }

  Future<void> saveOnboardingData({
    required String name,
    required DateTime birthDate,
    required DateTime lastPeriodDate,
    required int cycleLength,
    required int periodLength,
    required double height,
    required double weight,
    required List<String> healthConditions,
    required String email,
  }) async {
    final String id = DateTime.now().millisecondsSinceEpoch.toString();
    final int age = DateTime.now().year - birthDate.year;
    
    final userData = UserData(
      id: id,
      name: name,
      age: age,
      birthDate: birthDate,
      lastPeriodDate: lastPeriodDate,
      cycleLength: cycleLength,
      periodLength: periodLength,
      height: height,
      weight: weight,
      healthConditions: healthConditions,
      symptoms: [],
      moods: [],
      notes: [],
      isPremium: false,
      email: email,
      profileImageUrl: null,
      periodHistory: [
        {
          'date': lastPeriodDate.toIso8601String(),
          'flow': 'medium',
          'symptoms': [],
          'notes': '',
        }
      ],
      notificationSettings: {
        'periodReminders': true,
        'medicationReminders': false,
        'hydrationReminders': false,
        'exerciseReminders': false,
      },
      theme: 'light',
      language: 'en',
      medications: [],
      exercises: [],
      nutritionLogs: [],
      sleepLogs: [],
      waterIntake: [],
      goals: [],
      preferences: {
        'showCyclePhase': true,
        'showFertilityWindow': true,
        'showMoodTracking': true,
        'showSymptomTracking': true,
      },
    );

    await saveUserData(userData);
  }

  Future<void> logSymptom(String symptom, int severity, String date) async {
    if (_userData == null) {
      _error = 'No user data to update';
      notifyListeners();
      return;
    }

    final symptomData = {
      'symptom': symptom,
      'severity': severity,
      'date': date,
    };

    final updatedSymptoms = List<Map<String, dynamic>>.from(_userData!.symptoms);
    updatedSymptoms.add(symptomData);

    final updatedUserData = _userData!.copyWith(
      symptoms: updatedSymptoms,
    );

    await saveUserData(updatedUserData);
  }

  Future<void> logMood(String mood, int intensity, String date) async {
    if (_userData == null) {
      _error = 'No user data to update';
      notifyListeners();
      return;
    }

    final moodData = {
      'mood': mood,
      'intensity': intensity,
      'date': date,
    };

    final updatedMoods = List<Map<String, dynamic>>.from(_userData!.moods);
    updatedMoods.add(moodData);

    final updatedUserData = _userData!.copyWith(
      moods: updatedMoods,
    );

    await saveUserData(updatedUserData);
  }

  Future<void> addNote(String note) async {
    if (_userData == null) {
      _error = 'No user data to update';
      notifyListeners();
      return;
    }

    final updatedNotes = List<String>.from(_userData!.notes);
    updatedNotes.add(note);

    final updatedUserData = _userData!.copyWith(
      notes: updatedNotes,
    );

    await saveUserData(updatedUserData);
  }

  Future<void> logMedication(String medication, double dosage, String unit, String time, bool taken) async {
    if (_userData == null) {
      _error = 'No user data to update';
      notifyListeners();
      return;
    }

    final medicationData = {
      'medication': medication,
      'dosage': dosage,
      'unit': unit,
      'time': time,
      'taken': taken,
      'date': DateTime.now().toIso8601String(),
    };

    final updatedMedications = List<Map<String, dynamic>>.from(_userData!.medications);
    updatedMedications.add(medicationData);

    final updatedUserData = _userData!.copyWith(
      medications: updatedMedications,
    );

    await saveUserData(updatedUserData);
  }

  Future<void> logExercise(String type, int duration, int intensity, String date) async {
    if (_userData == null) {
      _error = 'No user data to update';
      notifyListeners();
      return;
    }

    final exerciseData = {
      'type': type,
      'duration': duration,
      'intensity': intensity,
      'date': date,
    };

    final updatedExercises = List<Map<String, dynamic>>.from(_userData!.exercises);
    updatedExercises.add(exerciseData);

    final updatedUserData = _userData!.copyWith(
      exercises: updatedExercises,
    );

    await saveUserData(updatedUserData);
  }

  Future<void> logNutrition(String meal, List<String> foods, int calories, String date) async {
    if (_userData == null) {
      _error = 'No user data to update';
      notifyListeners();
      return;
    }

    final nutritionData = {
      'meal': meal,
      'foods': foods,
      'calories': calories,
      'date': date,
    };

    final updatedNutritionLogs = List<Map<String, dynamic>>.from(_userData!.nutritionLogs);
    updatedNutritionLogs.add(nutritionData);

    final updatedUserData = _userData!.copyWith(
      nutritionLogs: updatedNutritionLogs,
    );

    await saveUserData(updatedUserData);
  }

  Future<void> logSleep(DateTime startTime, DateTime endTime, int quality) async {
    if (_userData == null) {
      _error = 'No user data to update';
      notifyListeners();
      return;
    }

    final sleepData = {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'duration': endTime.difference(startTime).inMinutes,
      'quality': quality,
      'date': DateTime.now().toIso8601String(),
    };

    final updatedSleepLogs = List<Map<String, dynamic>>.from(_userData!.sleepLogs);
    updatedSleepLogs.add(sleepData);

    final updatedUserData = _userData!.copyWith(
      sleepLogs: updatedSleepLogs,
    );

    await saveUserData(updatedUserData);
  }

  Future<void> logWaterIntake(double amount, String unit, String time) async {
    if (_userData == null) {
      _error = 'No user data to update';
      notifyListeners();
      return;
    }

    final waterData = {
      'amount': amount,
      'unit': unit,
      'time': time,
      'date': DateTime.now().toIso8601String(),
    };

    final updatedWaterIntake = List<Map<String, dynamic>>.from(_userData!.waterIntake);
    updatedWaterIntake.add(waterData);

    final updatedUserData = _userData!.copyWith(
      waterIntake: updatedWaterIntake,
    );

    await saveUserData(updatedUserData);
  }

  Future<void> addGoal(String title, String description, DateTime deadline, bool completed) async {
    if (_userData == null) {
      _error = 'No user data to update';
      notifyListeners();
      return;
    }

    final goalData = {
      'title': title,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'completed': completed,
      'createdAt': DateTime.now().toIso8601String(),
    };

    final updatedGoals = List<Map<String, dynamic>>.from(_userData!.goals);
    updatedGoals.add(goalData);

    final updatedUserData = _userData!.copyWith(
      goals: updatedGoals,
    );

    await saveUserData(updatedUserData);
  }

  Future<void> updatePreferences(Map<String, dynamic> preferences) async {
    if (_userData == null) {
      _error = 'No user data to update';
      notifyListeners();
      return;
    }

    final updatedPreferences = Map<String, dynamic>.from(_userData!.preferences);
    updatedPreferences.addAll(preferences);

    final updatedUserData = _userData!.copyWith(
      preferences: updatedPreferences,
    );

    await saveUserData(updatedUserData);
  }

  Future<void> clearUserData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userData');
      _userData = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to clear user data: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> upgradeToPremium() async {
    if (_userData == null) {
      _error = 'No user data to update';
      notifyListeners();
      return;
    }

    final updatedUserData = _userData!.copyWith(
      isPremium: true,
    );

    await saveUserData(updatedUserData);
  }
}
