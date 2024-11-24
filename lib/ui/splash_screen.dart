
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'main_screen.dart';
import 'onboard/intro_screen.dart';
import 'onboard/onboard_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  
  static String routeName='splash_screen';
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final OnboardManager onboardManager = OnboardManager();
  @override
  void initState() {
    super.initState();
    redirectIntroScreen();
  }
  void redirectIntroScreen() async{
    bool hasSeenOnboarding = await onboardManager.getHasSeenOnboarding();
    if (hasSeenOnboarding){
      await Future.delayed(const Duration(seconds: 2));
      Navigator.of(context).popAndPushNamed(MainScreen.routeName);
    } {
      await onboardManager.setHasSeenOnboarding();
      await Future.delayed(const Duration(seconds: 3));
      Navigator.of(context).popAndPushNamed(IntroScreen.routeName);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.redAccent,
      alignment: Alignment.center,
      child: const Text(
        style: TextStyle(
          color: Colors.white,
          decoration: TextDecoration.none,
        ),
        'Tìm trọ 247',
      ),
    );
  }
}

