// import 'package:flutter/material.dart';
// import 'package:menstrual_health_ai/providers/theme_provider.dart';
// import 'package:menstrual_health_ai/providers/user_data_provider.dart';
// import 'package:menstrual_health_ai/screens/onboarding/splash_screens.dart';
// import 'package:provider/provider.dart';

// void main() {
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => ThemeProvider()),
//         ChangeNotifierProvider(create: (_) => UserDataProvider()),
//       ],
//       child: const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ThemeProvider>(
//       builder: (context, themeProvider, child) {
//         return MaterialApp(
//           title: 'Mimos - Menstrual Health AI',
//           theme: themeProvider.themeData,
//           debugShowCheckedModeBanner: false,
//           home: const SplashScreens(),
//         );
//       },
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:menstrual_health_ai/providers/theme_provider.dart';
import 'package:menstrual_health_ai/providers/user_data_provider.dart';
import 'package:menstrual_health_ai/screens/dashboard/bottom_nav.dart';
import 'package:menstrual_health_ai/screens/onboarding/onboarding_screens.dart';
import 'package:menstrual_health_ai/screens/onboarding/splash_screens.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Check if user has completed onboarding
  final prefs = await SharedPreferences.getInstance();
  final hasCompletedOnboarding = prefs.getBool('hasCompletedOnboarding') ?? false;
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserDataProvider()),
      ],
      child: MyApp(hasCompletedOnboarding: hasCompletedOnboarding),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool hasCompletedOnboarding;
  
  const MyApp({super.key, required this.hasCompletedOnboarding});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Menstrual Health AI',
          theme: themeProvider.getTheme(),
          debugShowCheckedModeBanner: false,
          home: const SplashScreens(),
        );
      },
    );
  }
}
