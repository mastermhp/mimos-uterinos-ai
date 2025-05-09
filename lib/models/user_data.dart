import 'package:flutter/material.dart';

class UserData {
  final String id;
  final String name;
  final int age;
  final int cyclesTracked;
  final DateTime birthDate;
  final DateTime lastPeriodDate;
  final int cycleLength;
  final int periodLength;
  final double height;
  final double weight;
  final List<String> healthConditions;
  final List<Map<String, dynamic>> symptoms;
  final List<Map<String, dynamic>> moods;
  final List<String> notes;
  final bool isPremium;
  final String email;
  final String? profileImageUrl;
  final List<Map<String, dynamic>> periodHistory;
  final Map<String, bool> notificationSettings;
  final String? theme;
  final String language;
  final List<Map<String, dynamic>> medications;
  final List<Map<String, dynamic>> exercises;
  final List<Map<String, dynamic>> nutritionLogs;
  final List<Map<String, dynamic>> sleepLogs;
  final List<Map<String, dynamic>> waterIntake;
  final List<Map<String, dynamic>> goals;
  final Map<String, dynamic> preferences;

  UserData({
    required this.id,
    required this.name,
    required this.age,
    this.cyclesTracked = 0,
    required this.birthDate,
    required this.lastPeriodDate,
    required this.cycleLength,
    required this.periodLength,
    required this.height,
    required this.weight,
    required this.healthConditions,
    required this.symptoms,
    required this.moods,
    required this.notes,
    required this.isPremium,
    required this.email,
    this.profileImageUrl,
    required this.periodHistory,
    required this.notificationSettings,
    this.theme,
    required this.language,
    required this.medications,
    required this.exercises,
    required this.nutritionLogs,
    required this.sleepLogs,
    required this.waterIntake,
    required this.goals,
    required this.preferences,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      cyclesTracked: json['cyclesTracked'] ?? 0,
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'])
          : DateTime.now(),
      lastPeriodDate: json['lastPeriodDate'] != null
          ? DateTime.parse(json['lastPeriodDate'])
          : DateTime.now(),
      cycleLength: json['cycleLength'] ?? 28,
      periodLength: json['periodLength'] ?? 5,
      height: (json['height'] ?? 0).toDouble(),
      weight: (json['weight'] ?? 0).toDouble(),
      healthConditions: List<String>.from(json['healthConditions'] ?? []),
      symptoms: List<Map<String, dynamic>>.from(json['symptoms'] ?? []),
      moods: List<Map<String, dynamic>>.from(json['moods'] ?? []),
      notes: List<String>.from(json['notes'] ?? []),
      isPremium: json['isPremium'] ?? false,
      email: json['email'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      periodHistory: List<Map<String, dynamic>>.from(json['periodHistory'] ?? []),
      notificationSettings: Map<String, bool>.from(json['notificationSettings'] ?? {}),
      theme: json['theme'],
      language: json['language'] ?? 'en',
      medications: List<Map<String, dynamic>>.from(json['medications'] ?? []),
      exercises: List<Map<String, dynamic>>.from(json['exercises'] ?? []),
      nutritionLogs: List<Map<String, dynamic>>.from(json['nutritionLogs'] ?? []),
      sleepLogs: List<Map<String, dynamic>>.from(json['sleepLogs'] ?? []),
      waterIntake: List<Map<String, dynamic>>.from(json['waterIntake'] ?? []),
      goals: List<Map<String, dynamic>>.from(json['goals'] ?? []),
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'cyclesTracked': cyclesTracked,
      'birthDate': birthDate.toIso8601String(),
      'lastPeriodDate': lastPeriodDate.toIso8601String(),
      'cycleLength': cycleLength,
      'periodLength': periodLength,
      'height': height,
      'weight': weight,
      'healthConditions': healthConditions,
      'symptoms': symptoms,
      'moods': moods,
      'notes': notes,
      'isPremium': isPremium,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'periodHistory': periodHistory,
      'notificationSettings': notificationSettings,
      'theme': theme,
      'language': language,
      'medications': medications,
      'exercises': exercises,
      'nutritionLogs': nutritionLogs,
      'sleepLogs': sleepLogs,
      'waterIntake': waterIntake,
      'goals': goals,
      'preferences': preferences,
    };
  }

  UserData copyWith({
    String? id,
    String? name,
    int? age,
    int? cyclesTracked,
    DateTime? birthDate,
    DateTime? lastPeriodDate,
    int? cycleLength,
    int? periodLength,
    double? height,
    double? weight,
    List<String>? healthConditions,
    List<Map<String, dynamic>>? symptoms,
    List<Map<String, dynamic>>? moods,
    List<String>? notes,
    bool? isPremium,
    String? email,
    String? profileImageUrl,
    List<Map<String, dynamic>>? periodHistory,
    Map<String, bool>? notificationSettings,
    String? theme,
    String? language,
    List<Map<String, dynamic>>? medications,
    List<Map<String, dynamic>>? exercises,
    List<Map<String, dynamic>>? nutritionLogs,
    List<Map<String, dynamic>>? sleepLogs,
    List<Map<String, dynamic>>? waterIntake,
    List<Map<String, dynamic>>? goals,
    Map<String, dynamic>? preferences,
  }) {
    return UserData(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      cyclesTracked: cyclesTracked ?? this.cyclesTracked,
      birthDate: birthDate ?? this.birthDate,
      lastPeriodDate: lastPeriodDate ?? this.lastPeriodDate,
      cycleLength: cycleLength ?? this.cycleLength,
      periodLength: periodLength ?? this.periodLength,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      healthConditions: healthConditions ?? this.healthConditions,
      symptoms: symptoms ?? this.symptoms,
      moods: moods ?? this.moods,
      notes: notes ?? this.notes,
      isPremium: isPremium ?? this.isPremium,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      periodHistory: periodHistory ?? this.periodHistory,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      medications: medications ?? this.medications,
      exercises: exercises ?? this.exercises,
      nutritionLogs: nutritionLogs ?? this.nutritionLogs,
      sleepLogs: sleepLogs ?? this.sleepLogs,
      waterIntake: waterIntake ?? this.waterIntake,
      goals: goals ?? this.goals,
      preferences: preferences ?? this.preferences,
    );
  }
}
