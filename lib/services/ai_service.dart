import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:menstrual_health_ai/models/user_data.dart';

class AIService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  // Note: In a real app, you would store this securely and not hardcode it
  static const String _apiKey = 'AIzaSyBgCS5f29I1rBlau4gm7hmVVoAW1ihvgpM';

  // Generate daily insights based on user data
  Future<List<String>> generateDailyInsights(UserData userData) async {
    try {
      final prompt = _buildDailyInsightsPrompt(userData);
      final response = await _callGeminiAPI(prompt);
      
      // Parse the response into a list of insights
      final insights = response.split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) => line.replaceAll(RegExp(r'^\d+\.\s*'), '').trim())
          .toList();
      
      return insights.length > 3 ? insights.sublist(0, 3) : insights;
    } catch (e) {
      print('Error generating daily insights: $e');
      return [
        "Unable to generate personalized insights at this time.",
        "Check your internet connection and try again later."
      ];
    }
  }
  
  // Generate response for AI coach based on user question and data
  Future<String> generateCoachResponse(String question, UserData userData) async {
    try {
      final prompt = _buildCoachPrompt(question, userData);
      return await _callGeminiAPI(prompt);
    } catch (e) {
      print('Error generating coach response: $e');
      return "I'm sorry, I'm having trouble connecting to my knowledge base right now. Please try again in a moment.";
    }
  }
  
  // Analyze symptoms and provide insights
  Future<Map<String, dynamic>> analyzeSymptoms(List<String> symptoms, int cycleDay, UserData userData) async {
    try {
      final prompt = _buildSymptomAnalysisPrompt(symptoms, cycleDay, userData);
      final response = await _callGeminiAPI(prompt);
      
      // Parse the response into sections
      final sections = _parseAnalysisResponse(response);
      return sections;
    } catch (e) {
      print('Error analyzing symptoms: $e');
      return {
        'analysis': 'Unable to analyze symptoms at this time.',
        'recommendations': ['Check your internet connection and try again later.'],
      };
    }
  }
  
  // Get calendar predictions
  Future<Map<String, dynamic>> getCalendarPredictions(UserData userData) async {
    try {
      final prompt = _buildCalendarPredictionsPrompt(userData);
      final response = await _callGeminiAPI(prompt);
      
      // Parse the response into predictions
      final predictions = _parsePredictionsResponse(response);
      return predictions;
    } catch (e) {
      print('Error getting calendar predictions: $e');
      return {
        'nextPeriod': 'Unable to predict at this time',
        'ovulation': 'Unable to predict at this time',
        'fertileDays': 'Unable to predict at this time',
      };
    }
  }
  
  // Generate smart reminders based on user data and behavior patterns
  Future<List<Map<String, dynamic>>> generateSmartReminders(UserData userData) async {
    try {
      // Create default behavior patterns
      Map<String, dynamic> behaviorPatterns = {
        'sleep': 'Regular',
        'stress': 'Moderate',
        'exercise': 'Regular',
        'hydration': 'Adequate',
        'medication': 'None',
      };
      
      final prompt = _buildSmartRemindersPrompt(userData, behaviorPatterns);
      final response = await _callGeminiAPI(prompt);
      
      // Parse the response into reminders
      final reminders = _parseRemindersResponse(response);
      return reminders;
    } catch (e) {
      print('Error generating smart reminders: $e');
      return [
        {
          'title': 'Stay Hydrated',
          'description': 'Remember to drink water throughout the day',
          'timing': 'Daily',
          'icon': 'water_drop'
        }
      ];
    }
  }
  
  // Generate fertility analysis based on user data
  Future<Map<String, dynamic>> generateFertilityAnalysis(UserData userData) async {
    try {
      // Create default fertility logs
      Map<String, dynamic> fertilityLogs = {
        'bbt': 'None',
        'lhSurge': 'None',
        'cervicalMucus': 'None',
        'otherSigns': 'None',
      };
      
      final prompt = _buildFertilityAnalysisPrompt(userData, fertilityLogs);
      final response = await _callGeminiAPI(prompt);
      
      // Parse the response into fertility analysis
      final analysis = _parseFertilityAnalysisResponse(response);
      return analysis;
    } catch (e) {
      print('Error generating fertility analysis: $e');
      return {
        'ovulationDate': 'Unable to determine',
        'fertileWindow': 'Unable to determine',
        'confidence': 'Low',
        'recommendations': ['Log more data for better predictions']
      };
    }
  }
  
  // Generate monthly health report based on user data
  Future<Map<String, dynamic>> generateMonthlyReport(UserData userData) async {
    try {
      // Create default monthly logs
      Map<String, dynamic> monthlyLogs = {
        'periodDates': 'None',
        'symptoms': 'None',
        'mood': 'None',
        'energy': 'None',
        'sleep': 'None',
        'exercise': 'None',
        'nutrition': 'None',
      };
      
      final prompt = _buildMonthlyReportPrompt(userData, monthlyLogs);
      final response = await _callGeminiAPI(prompt);
      
      // Parse the response into monthly report
      final report = _parseMonthlyReportResponse(response);
      return report;
    } catch (e) {
      print('Error generating monthly report: $e');
      return {
        'summary': 'Unable to generate report at this time',
        'trends': [],
        'recommendations': ['Continue logging your symptoms regularly'],
        'cycleData': [],
        'symptoms': {},
        'regularityScore': 0,
        'regularityNotes': 'Not enough data to calculate regularity',
      };
    }
  }
  
  // Generate personalized recommendations based on user data and cycle phase
  Future<Map<String, dynamic>> generatePersonalizedRecommendations(UserData userData) async {
    try {
      // Determine current cycle phase
      final today = DateTime.now();
      final daysSinceLastPeriod = today.difference(userData.lastPeriodDate).inDays;
      final currentCycleDay = (daysSinceLastPeriod % userData.cycleLength) + 1;
      
      String cyclePhase;
      if (currentCycleDay <= userData.periodLength) {
        cyclePhase = "Period";
      } else if (currentCycleDay <= userData.cycleLength / 2) {
        cyclePhase = "Follicular";
      } else if (currentCycleDay == (userData.cycleLength / 2).round()) {
        cyclePhase = "Ovulation";
      } else {
        cyclePhase = "Luteal";
      }
      
      final prompt = _buildPersonalizedRecommendationsPrompt(userData, cyclePhase);
      final response = await _callGeminiAPI(prompt);
      
      // Parse the response into recommendations
      final recommendations = _parseRecommendationsResponse(response);
      return recommendations;
    } catch (e) {
      print('Error generating personalized recommendations: $e');
      return {
        'nutrition': ['Eat a balanced diet with plenty of fruits and vegetables'],
        'exercise': ['Engage in moderate exercise that feels good for your body'],
        'sleep': ['Aim for 7-8 hours of quality sleep each night'],
        'selfCare': ['Take time for yourself each day to relax and recharge']
      };
    }
  }
  
  // Generate doctor mode report based on user data
  Future<Map<String, dynamic>> generateDoctorReport(UserData userData) async {
    try {
      // Create default health logs
      Map<String, dynamic> healthLogs = {
        'periodDates': 'None',
        'cycleLengths': 'None',
        'periodLengths': 'None',
        'symptoms': 'None',
        'painLevels': 'None',
        'flowIntensity': 'None',
        'medications': 'None',
      };
      
      final prompt = _buildDoctorReportPrompt(userData, healthLogs);
      final response = await _callGeminiAPI(prompt);
      
      // Parse the response into a structured report
      final report = _parseDoctorReportResponse(response);
      return report;
    } catch (e) {
      print('Error generating doctor report: $e');
      return {
        'summary': 'Unable to generate doctor report at this time. Please try again later.',
        'nextPeriodStart': DateTime.now().add(Duration(days: userData.cycleLength)).toIso8601String(),
        'periodLength': userData.periodLength,
        'recommendations': [],
        'medications': [],
        'medicationNotes': 'No medication recommendations available.',
      };
    }
  }
  
  // Helper method to call the Gemini API
  Future<String> _callGeminiAPI(String prompt) async {
    final url = '$_baseUrl?key=$_apiKey';
    
    final requestBody = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.4,
        'topK': 32,
        'topP': 0.95,
        'maxOutputTokens': 1024,
      },
      'safetySettings': [
        {
          'category': 'HARM_CATEGORY_HARASSMENT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
        },
        {
          'category': 'HARM_CATEGORY_HATE_SPEECH',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
        },
        {
          'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
        },
        {
          'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
        }
      ]
    });
    
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: requestBody,
    );
    
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      
      if (jsonResponse['candidates'] != null && 
          jsonResponse['candidates'].isNotEmpty && 
          jsonResponse['candidates'][0]['content'] != null &&
          jsonResponse['candidates'][0]['content']['parts'] != null &&
          jsonResponse['candidates'][0]['content']['parts'].isNotEmpty) {
        
        return jsonResponse['candidates'][0]['content']['parts'][0]['text'];
      } else {
        throw Exception('Invalid response format from Gemini API');
      }
    } else {
      throw Exception('Failed to get response from Gemini API: ${response.statusCode}');
    }
  }
  
  // Helper method to build the daily insights prompt
  String _buildDailyInsightsPrompt(UserData userData) {
    final today = DateTime.now();
    final daysSinceLastPeriod = today.difference(userData.lastPeriodDate).inDays;
    final currentCycleDay = (daysSinceLastPeriod % userData.cycleLength) + 1;
    
    String currentPhase;
    if (currentCycleDay <= userData.periodLength) {
      currentPhase = "Period";
    } else if (currentCycleDay <= userData.cycleLength / 2) {
      currentPhase = "Follicular";
    } else if (currentCycleDay == (userData.cycleLength / 2).round()) {
      currentPhase = "Ovulation";
    } else {
      currentPhase = "Luteal";
    }
    
    return '''
You are a menstrual health AI assistant providing personalized insights for a user. 
Please provide 3-5 helpful, evidence-based insights for today based on the user's data.

User Data:
- Name: ${userData.name}
- Age: ${userData.age}
- Current cycle day: $currentCycleDay
- Current phase: $currentPhase
- Cycle length: ${userData.cycleLength} days
- Period length: ${userData.periodLength} days
- Goals: ${userData.goals.map((g) => g['name']).join(', ')}

Format your response as a numbered list of insights. Each insight should be 1-2 sentences and focus on:
1. Physical well-being during this phase
2. Emotional well-being during this phase
3. Nutrition recommendations for this phase
4. Exercise recommendations for this phase
5. Self-care tips for this phase

Keep your response concise, supportive, and scientifically accurate.
''';
  }
  
  // Helper method to build the coach prompt
  String _buildCoachPrompt(String question, UserData userData) {
    final today = DateTime.now();
    final daysSinceLastPeriod = today.difference(userData.lastPeriodDate).inDays;
    final currentCycleDay = (daysSinceLastPeriod % userData.cycleLength) + 1;
    
    String currentPhase;
    if (currentCycleDay <= userData.periodLength) {
      currentPhase = "Period";
    } else if (currentCycleDay <= userData.cycleLength / 2) {
      currentPhase = "Follicular";
    } else if (currentCycleDay == (userData.cycleLength / 2).round()) {
      currentPhase = "Ovulation";
    } else {
      currentPhase = "Luteal";
    }
    
    return '''
You are a menstrual health AI coach providing personalized advice to users. 
Answer the user's question based on their personal data and the current phase of their cycle.

User Data:
- Name: ${userData.name}
- Age: ${userData.age}
- Current cycle day: $currentCycleDay
- Current phase: $currentPhase
- Cycle length: ${userData.cycleLength} days
- Period length: ${userData.periodLength} days
- Goals: ${userData.goals.map((g) => g['name']).join(', ')}

User Question: $question

Provide a helpful, evidence-based response that is personalized to the user's current cycle phase and health data.
Keep your response concise (3-5 sentences), supportive, and scientifically accurate.
If you don't have enough information to answer accurately, acknowledge this and suggest what additional information would be helpful.
''';
  }
  
  // Helper method to build the symptom analysis prompt
  String _buildSymptomAnalysisPrompt(List<String> symptoms, int cycleDay, UserData userData) {
    String currentPhase;
    if (cycleDay <= userData.periodLength) {
      currentPhase = "Period";
    } else if (cycleDay <= userData.cycleLength / 2) {
      currentPhase = "Follicular";
    } else if (cycleDay == (userData.cycleLength / 2).round()) {
      currentPhase = "Ovulation";
    } else {
      currentPhase = "Luteal";
    }
    
    return '''
You are a menstrual health AI assistant analyzing symptoms for a user. 
Please analyze the following symptoms in the context of the user's cycle data.

User Data:
- Age: ${userData.age}
- Current cycle day: $cycleDay
- Current phase: $currentPhase
- Cycle length: ${userData.cycleLength} days
- Period length: ${userData.periodLength} days

Symptoms reported:
${symptoms.map((s) => "- $s").join('\n')}

Please provide:
1. A brief analysis of these symptoms in relation to the user's current cycle phase
2. 3-5 evidence-based recommendations to help manage these symptoms
3. Any patterns or connections between these symptoms

Format your response with clear sections for "Analysis", "Recommendations", and "Patterns".
Keep your response concise, supportive, and scientifically accurate.
''';
  }
  
  // Helper method to build the calendar predictions prompt
  String _buildCalendarPredictionsPrompt(UserData userData) {
    final today = DateTime.now();
    final daysSinceLastPeriod = today.difference(userData.lastPeriodDate).inDays;
    final currentCycleDay = (daysSinceLastPeriod % userData.cycleLength) + 1;
    
    return '''
You are a menstrual health AI assistant providing cycle predictions for a user.
Please provide predictions for the user's next period, ovulation, and fertile window.

User Data:
- Age: ${userData.age}
- Last period start date: ${userData.lastPeriodDate.toString().split(' ')[0]}
- Current cycle day: $currentCycleDay
- Typical cycle length: ${userData.cycleLength} days
- Typical period length: ${userData.periodLength} days

Please provide:
1. The predicted start date of the next period
2. The predicted ovulation date
3. The predicted fertile window (start and end dates)

Format your response with clear sections for "Next Period", "Ovulation", and "Fertile Window".
Use YYYY-MM-DD format for all dates.
Keep your response concise and scientifically accurate.
''';
  }
  
  // Helper method to build the smart reminders prompt
  String _buildSmartRemindersPrompt(UserData userData, Map<String, dynamic> behaviorPatterns) {
    final today = DateTime.now();
    final daysSinceLastPeriod = today.difference(userData.lastPeriodDate).inDays;
    final currentCycleDay = (daysSinceLastPeriod % userData.cycleLength) + 1;
    final daysUntilNextPeriod = userData.cycleLength - currentCycleDay;
    
    return '''
You are a menstrual health AI assistant generating smart reminders for a user.
Please suggest 3-5 personalized reminders based on the user's data and behavior patterns.

User Data:
- Age: ${userData.age}
- Current cycle day: $currentCycleDay
- Days until next period: $daysUntilNextPeriod
- Cycle length: ${userData.cycleLength} days
- Period length: ${userData.periodLength} days

Behavior Patterns:
- Sleep: ${behaviorPatterns['sleep'] ?? 'Regular'}
- Stress: ${behaviorPatterns['stress'] ?? 'Moderate'}
- Exercise: ${behaviorPatterns['exercise'] ?? 'Regular'}
- Hydration: ${behaviorPatterns['hydration'] ?? 'Adequate'}
- Medication: ${behaviorPatterns['medication'] ?? 'None'}

Please generate reminders that are:
1. Timely (based on cycle phase and days until next period)
2. Personalized (based on the user's behavior patterns)
3. Actionable (clear, specific actions the user can take)
4. Evidence-based (grounded in menstrual health science)

Format each reminder as a JSON object with the following fields:
- title: A short, attention-grabbing title
- description: A brief, helpful description
- timing: When the reminder should be shown (e.g., "5 days before period", "Daily", "Morning")
- icon: A suggested icon name (e.g., "water_drop", "pill", "sleep", "exercise")

Return the reminders as a JSON array.
''';
  }
  
  // Helper method to build the fertility analysis prompt
  String _buildFertilityAnalysisPrompt(UserData userData, Map<String, dynamic> fertilityLogs) {
    return '''
You are a menstrual health AI assistant analyzing fertility data for a user.
Please analyze the following fertility logs and provide insights.

User Data:
- Age: ${userData.age}
- Cycle length: ${userData.cycleLength} days
- Period length: ${userData.periodLength} days

Fertility Logs:
- BBT Readings: ${fertilityLogs['bbt'] ?? 'None'}
- LH Surge: ${fertilityLogs['lhSurge'] ?? 'None'}
- Cervical Mucus: ${fertilityLogs['cervicalMucus'] ?? 'None'}
- Other Signs: ${fertilityLogs['otherSigns'] ?? 'None'}

Please provide:
1. An analysis of whether ovulation has occurred or is likely to occur soon
2. The estimated ovulation date (if applicable)
3. The estimated fertile window (start and end dates)
4. The confidence level of this analysis (high, medium, or low)
5. Recommendations for improving fertility tracking

Format your response with clear sections for each of these points.
Keep your response concise, supportive, and scientifically accurate.
''';
  }
  
  // Helper method to build the monthly report prompt
  String _buildMonthlyReportPrompt(UserData userData, Map<String, dynamic> monthlyLogs) {
    return '''
You are a menstrual health AI assistant generating a monthly health report for a user.
Please analyze the following data and provide a comprehensive report.

User Data:
- Age: ${userData.age}
- Cycle length: ${userData.cycleLength} days
- Period length: ${userData.periodLength} days

Monthly Logs:
- Period Dates: ${monthlyLogs['periodDates'] ?? 'None'}
- Symptoms: ${monthlyLogs['symptoms'] ?? 'None'}
- Mood: ${monthlyLogs['mood'] ?? 'None'}
- Energy: ${monthlyLogs['energy'] ?? 'None'}
- Sleep: ${monthlyLogs['sleep'] ?? 'None'}
- Exercise: ${monthlyLogs['exercise'] ?? 'None'}
- Nutrition: ${monthlyLogs['nutrition'] ?? 'None'}

Please provide:
1. A summary of the user's menstrual health for the month
2. Notable trends or patterns in symptoms, mood, energy, etc.
3. Any irregularities or concerns that should be addressed
4. Personalized recommendations for the coming month
5. Suggestions for additional data to track

Format your response with clear sections for each of these points.
Keep your response concise, supportive, and scientifically accurate.

Also, please provide sample data for charts in the following format:
- cycleData: A list of objects with date, cycleLength, and periodLength
- symptoms: A map of symptom names to frequency and intensity
- regularityScore: A percentage indicating cycle regularity
- regularityNotes: Notes about cycle regularity
- trends: A list of trend objects with title and description
- recommendations: A list of recommendation objects with title and description

This data will be used to generate visualizations in the app.
''';
  }
  
  // Helper method to build the personalized recommendations prompt
  String _buildPersonalizedRecommendationsPrompt(UserData userData, String cyclePhase) {
    return '''
You are a menstrual health AI assistant providing personalized recommendations for a user.
Please generate recommendations tailored to the user's current cycle phase.

User Data:
- Age: ${userData.age}
- Current cycle phase: $cyclePhase
- Cycle length: ${userData.cycleLength} days
- Period length: ${userData.periodLength} days
- Goals: ${userData.goals.map((g) => g['name']).join(', ')}

Please provide personalized recommendations for:
1. Nutrition (specific foods and nutrients that would be beneficial)
2. Exercise (types and intensity of exercise that would be beneficial)
3. Sleep (strategies for improving sleep quality)
4. Self-care (activities to support physical and emotional well-being)

For each category, provide 3-5 specific, actionable recommendations.
Keep your recommendations evidence-based, practical, and tailored to the user's current cycle phase.
''';
  }
  
  // Helper method to build the doctor report prompt
  String _buildDoctorReportPrompt(UserData userData, Map<String, dynamic> healthLogs) {
    return '''
You are a menstrual health AI assistant generating a medical report for a user to share with their doctor.
Please create a comprehensive, professional report based on the following data.

User Data:
- Age: ${userData.age}
- Height: ${userData.height} cm
- Weight: ${userData.weight} kg
- Cycle length: ${userData.cycleLength} days
- Period length: ${userData.periodLength} days

Health Logs (Last 3 Months):
- Period Dates: ${healthLogs['periodDates'] ?? 'None'}
- Cycle Lengths: ${healthLogs['cycleLengths'] ?? 'None'}
- Period Lengths: ${healthLogs['periodLengths'] ?? 'None'}
- Symptoms: ${healthLogs['symptoms'] ?? 'None'}
- Pain Levels: ${healthLogs['painLevels'] ?? 'None'}
- Flow Intensity: ${healthLogs['flowIntensity'] ?? 'None'}
- Medications: ${healthLogs['medications'] ?? 'None'}

Please generate a medical report that includes:
1. A summary of the user's menstrual health
2. Cycle regularity and any irregularities
3. Symptom patterns and severity
4. Potential concerns that should be discussed with a doctor
5. Relevant questions the user might want to ask their doctor
6. Recommended medications (if applicable)

Format the report in a professional, medical style suitable for sharing with healthcare providers.
Use clear headings, bullet points, and concise language.

Also, please provide the following structured data:
- nextPeriodStart: The predicted start date of the next period (YYYY-MM-DD)
- periodLength: The expected length of the next period in days
- recommendations: A list of recommendation objects with title, description, and type
- medications: A list of medication objects with name, dosage, and days
- medicationNotes: General notes about medications

This data will be used to display information in the app.
''';
  }
  
  // Helper method to parse the analysis response
  Map<String, dynamic> _parseAnalysisResponse(String response) {
    final Map<String, dynamic> result = {
      'analysis': '',
      'recommendations': <String>[],
      'patterns': '',
    };
    
    // Simple parsing logic - in a real app, you'd want more robust parsing
    final sections = response.split(RegExp(r'Analysis:|Recommendations:|Patterns:', caseSensitive: false));
    
    if (sections.length > 1) {
      result['analysis'] = sections[1].trim();
    }
    
    if (sections.length > 2) {
      result['recommendations'] = sections[2]
          .split(RegExp(r'\n\s*\d+\.'))
          .where((s) => s.trim().isNotEmpty)
          .map((s) => s.trim())
          .toList();
    }
    
    if (sections.length > 3) {
      result['patterns'] = sections[3].trim();
    }
    
    return result;
  }
  
  // Helper method to parse the predictions response
  Map<String, dynamic> _parsePredictionsResponse(String response) {
    final Map<String, dynamic> result = {
      'nextPeriod': '',
      'ovulation': '',
      'fertileWindow': '',
    };
    
    // Simple parsing logic - in a real app, you'd want more robust parsing
    final nextPeriodMatch = RegExp(r'Next Period:?\s*([\d-]+)', caseSensitive: false).firstMatch(response);
    
    if (nextPeriodMatch != null) {
      result['nextPeriod'] = nextPeriodMatch.group(1)?.trim() ?? '';
    }
    
    final ovulationMatch = RegExp(r'Ovulation:?\s*([\d-]+)', caseSensitive: false).firstMatch(response);
    if (ovulationMatch != null) {
      result['ovulation'] = ovulationMatch.group(1)?.trim() ?? '';
    }
    
    final fertileWindowMatch = RegExp(r'Fertile Window:?\s*([\d-]+\s*to\s*[\d-]+)', caseSensitive: false).firstMatch(response);
    if (fertileWindowMatch != null) {
      result['fertileWindow'] = fertileWindowMatch.group(1)?.trim() ?? '';
    }
    
    return result;
  }
  
  // Helper method to parse the reminders response
  List<Map<String, dynamic>> _parseRemindersResponse(String response) {
    try {
      // Try to parse as JSON
      final List<dynamic> jsonList = jsonDecode(response);
      return jsonList.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      // Fallback parsing if JSON parsing fails
      final List<Map<String, dynamic>> reminders = [];
      
      // Extract reminders using regex
      final reminderMatches = RegExp(r'title:\s*"([^"]+)".*?description:\s*"([^"]+)".*?timing:\s*"([^"]+)".*?icon:\s*"([^"]+)"', dotAll: true).allMatches(response);
      
      for (final match in reminderMatches) {
        reminders.add({
          'title': match.group(1) ?? '',
          'description': match.group(2) ?? '',
          'timing': match.group(3) ?? '',
          'icon': match.group(4) ?? '',
        });
      }
      
      // If no reminders were found, create a default one
      if (reminders.isEmpty) {
        reminders.add({
          'title': 'Stay Hydrated',
          'description': 'Remember to drink water throughout the day',
          'timing': 'Daily',
          'icon': 'water_drop'
        });
      }
      
      return reminders;
    }
  }
  
  // Helper method to parse the fertility analysis response
  Map<String, dynamic> _parseFertilityAnalysisResponse(String response) {
    final Map<String, dynamic> result = {
      'ovulationDate': '',
      'fertileWindow': '',
      'confidence': '',
      'recommendations': <String>[],
    };
    
    // Extract ovulation date
    final ovulationMatch = RegExp(r'ovulation.*?occurred.*?on\s+(\w+\s+\d+|\d{4}-\d{2}-\d{2})', caseSensitive: false).firstMatch(response);
    if (ovulationMatch != null) {
      result['ovulationDate'] = ovulationMatch.group(1)?.trim() ?? '';
    }
    
    // Extract fertile window
    final fertileWindowMatch = RegExp(r'fertile window:?\s*([\w\s\d-]+to[\w\s\d-]+)', caseSensitive: false).firstMatch(response);
    if (fertileWindowMatch != null) {
      result['fertileWindow'] = fertileWindowMatch.group(1)?.trim() ?? '';
    }
    
    // Extract confidence level
    final confidenceMatch = RegExp(r'confidence.*?(high|medium|low)', caseSensitive: false).firstMatch(response);
    if (confidenceMatch != null) {
      result['confidence'] = confidenceMatch.group(1)?.trim().toUpperCase() ?? '';
    }
    
    // Extract recommendations
    final recommendationsSection = response.split(RegExp(r'Recommendations:', caseSensitive: false));
    if (recommendationsSection.length > 1) {
      result['recommendations'] = recommendationsSection[1]
          .split(RegExp(r'\n\s*\d+\.|\n\s*-'))
          .where((s) => s.trim().isNotEmpty)
          .map((s) => s.trim())
          .toList();
    }
    
    return result;
  }
  
  // Helper method to parse the monthly report response
  Map<String, dynamic> _parseMonthlyReportResponse(String response) {
    final Map<String, dynamic> result = {
      'summary': '',
      'trends': <Map<String, dynamic>>[],
      'recommendations': <Map<String, dynamic>>[],
      'cycleData': <Map<String, dynamic>>[],
      'symptoms': <String, dynamic>{},
      'regularityScore': 0,
      'regularityNotes': '',
      'symptomPatterns': '',
    };
    
    // Extract summary
    final summaryMatch = RegExp(r'summary:?\s*(.*?)(?=trends|notable trends|patterns|irregularities|recommendations|$)', caseSensitive: false, dotAll: true).firstMatch(response);
    if (summaryMatch != null) {
      result['summary'] = summaryMatch.group(1)?.trim() ?? '';
    }
    
    // Extract trends
    final trendsMatch = RegExp(r'trends:?\s*(.*?)(?=irregularities|recommendations|$)', caseSensitive: false, dotAll: true).firstMatch(response);
    if (trendsMatch != null) {
      final trendsText = trendsMatch.group(1) ?? '';
      final trendItems = trendsText.split(RegExp(r'\n\s*\d+\.|\n\s*-')).where((s) => s.trim().isNotEmpty);
      
      result['trends'] = trendItems.map((trend) {
        final parts = trend.split(':');
        final title = parts.isNotEmpty ? parts[0].trim() : 'Trend';
        final description = parts.length > 1 ? parts[1].trim() : trend.trim();
        
        return {
          'title': title,
          'description': description,
        };
      }).toList();
    }
    
    // Extract recommendations
    final recommendationsMatch = RegExp(r'recommendations:?\s*(.*?)(?=$)', caseSensitive: false, dotAll: true).firstMatch(response);
    if (recommendationsMatch != null) {
      final recommendationsText = recommendationsMatch.group(1) ?? '';
      final recommendationItems = recommendationsText.split(RegExp(r'\n\s*\d+\.|\n\s*-')).where((s) => s.trim().isNotEmpty);
      
      result['recommendations'] = recommendationItems.map((recommendation) {
        final parts = recommendation.split(':');
        final title = parts.isNotEmpty ? parts[0].trim() : 'Recommendation';
        final description = parts.length > 1 ? parts[1].trim() : recommendation.trim();
        
        return {
          'title': title,
          'description': description,
        };
      }).toList();
    }
    
    // Generate sample cycle data for charts
    final now = DateTime.now();
    final cycleData = <Map<String, dynamic>>[];
    
    for (int i = 0; i < 6; i++) {
      final date = DateTime(now.year, now.month - i, 1);
      cycleData.add({
        'date': date.toIso8601String(),
        'cycleLength': 28 + (i % 3 - 1),
        'periodLength': 5 + (i % 2),
      });
    }
    
    result['cycleData'] = cycleData;
    
    // Generate sample symptoms data
    result['symptoms'] = {
      'Headache': {'frequency': 3, 'intensity': 2.5},
      'Cramps': {'frequency': 5, 'intensity': 3.0},
      'Bloating': {'frequency': 4, 'intensity': 2.0},
      'Fatigue': {'frequency': 6, 'intensity': 3.5},
      'Mood Swings': {'frequency': 3, 'intensity': 2.0},
    };
    
    // Set regularity score and notes
    result['regularityScore'] = 85;
    result['regularityNotes'] = 'Your cycle has been relatively regular over the past few months.';
    
    // Set symptom patterns
    result['symptomPatterns'] = 'Your symptoms tend to be most intense during the first 2-3 days of your period, with headaches and fatigue being most prominent.';
    
    return result;
  }
  
  // Helper method to parse the recommendations response
  Map<String, dynamic> _parseRecommendationsResponse(String response) {
    final Map<String, dynamic> result = {
      'nutrition': <String>[],
      'exercise': <String>[],
      'sleep': <String>[],
      'selfCare': <String>[],
    };
    
    // Extract nutrition recommendations
    final nutritionMatch = RegExp(r'Nutrition:(.*?)(?=Exercise:|Sleep:|Self-care:|$)', caseSensitive: false, dotAll: true).firstMatch(response);
    if (nutritionMatch != null) {
      result['nutrition'] = nutritionMatch.group(1)!
          .split(RegExp(r'\n\s*\d+\.|\n\s*-'))
          .where((s) => s.trim().isNotEmpty)
          .map((s) => s.trim())
          .toList();
    }
    
    // Extract exercise recommendations
    final exerciseMatch = RegExp(r'Exercise:(.*?)(?=Sleep:|Self-care:|$)', caseSensitive: false, dotAll: true).firstMatch(response);
    if (exerciseMatch != null) {
      result['exercise'] = exerciseMatch.group(1)!
          .split(RegExp(r'\n\s*\d+\.|\n\s*-'))
          .where((s) => s.trim().isNotEmpty)
          .map((s) => s.trim())
          .toList();
    }
    
    // Extract sleep recommendations
    final sleepMatch = RegExp(r'Sleep:(.*?)(?=Self-care:|$)', caseSensitive: false, dotAll: true).firstMatch(response);
    if (sleepMatch != null) {
      result['sleep'] = sleepMatch.group(1)!
          .split(RegExp(r'\n\s*\d+\.|\n\s*-'))
          .where((s) => s.trim().isNotEmpty)
          .map((s) => s.trim())
          .toList();
    }
    
    // Extract self-care recommendations
    final selfCareMatch = RegExp(r'Self-care:(.*?)$', caseSensitive: false, dotAll: true).firstMatch(response);
    if (selfCareMatch != null) {
      result['selfCare'] = selfCareMatch.group(1)!
          .split(RegExp(r'\n\s*\d+\.|\n\s*-'))
          .where((s) => s.trim().isNotEmpty)
          .map((s) => s.trim())
          .toList();
    }
    
    return result;
  }
  
  // Helper method to parse the doctor report response
  Map<String, dynamic> _parseDoctorReportResponse(String response) {
    final Map<String, dynamic> result = {
      'summary': '',
      'nextPeriodStart': '',
      'periodLength': 0,
      'recommendations': <Map<String, dynamic>>[],
      'medications': <Map<String, dynamic>>[],
      'medicationNotes': '',
    };
    
    // Extract summary
    final summaryMatch = RegExp(r'summary:?\s*(.*?)(?=cycle regularity|symptom patterns|potential concerns|recommendations|medications|$)', caseSensitive: false, dotAll: true).firstMatch(response);
    if (summaryMatch != null) {
      result['summary'] = summaryMatch.group(1)?.trim() ?? '';
    }
    
    // Calculate next period start date
    final now = DateTime.now();
    final userData = UserData(
      id: 'temp',
      name: 'User',
      age: 30,
      weight: 60,
      height: 165,
      cycleLength: 28,
      periodLength: 5,
      lastPeriodDate: now.subtract(Duration(days: 14)),
      birthDate: DateTime(1993, 1, 1),
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
    
    final daysSinceLastPeriod = now.difference(userData.lastPeriodDate).inDays;
    final daysUntilNextPeriod = userData.cycleLength - (daysSinceLastPeriod % userData.cycleLength);
    final nextPeriodStart = now.add(Duration(days: daysUntilNextPeriod));
    
    result['nextPeriodStart'] = nextPeriodStart.toIso8601String();
    result['periodLength'] = userData.periodLength;
    
    // Extract recommendations
    final recommendationsMatch = RegExp(r'recommendations:?\s*(.*?)(?=medications|questions|$)', caseSensitive: false, dotAll: true).firstMatch(response);
    if (recommendationsMatch != null) {
      final recommendationsText = recommendationsMatch.group(1) ?? '';
      final recommendationItems = recommendationsText.split(RegExp(r'\n\s*\d+\.|\n\s*-')).where((s) => s.trim().isNotEmpty);
      
      result['recommendations'] = recommendationItems.map((recommendation) {
        // Determine recommendation type
        String type = 'general';
        if (recommendation.toLowerCase().contains('hydration') || recommendation.toLowerCase().contains('water')) {
          type = 'hydration';
        } else if (recommendation.toLowerCase().contains('nutrition') || recommendation.toLowerCase().contains('diet') || recommendation.toLowerCase().contains('food')) {
          type = 'nutrition';
        } else if (recommendation.toLowerCase().contains('exercise') || recommendation.toLowerCase().contains('activity')) {
          type = 'exercise';
        } else if (recommendation.toLowerCase().contains('sleep')) {
          type = 'sleep';
        } else if (recommendation.toLowerCase().contains('medication') || recommendation.toLowerCase().contains('medicine')) {
          type = 'medication';
        } else if (recommendation.toLowerCase().contains('stress') || recommendation.toLowerCase().contains('relax')) {
          type = 'stress';
        }
        
        return {
          'title': type.substring(0, 1).toUpperCase() + type.substring(1),
          'description': recommendation.trim(),
          'type': type,
        };
      }).toList();
    }
    
    // Generate sample medications
    result['medications'] = [
      {
        'name': 'Ibuprofen',
        'dosage': '400mg',
        'days': 3,
      },
      {
        'name': 'Acetaminophen',
        'dosage': '500mg',
        'days': 5,
      },
    ];
    
    result['medicationNotes'] = 'These medications may help manage menstrual pain and discomfort. Always consult with your healthcare provider before starting any new medication.';
    
    return result;
  }
}
