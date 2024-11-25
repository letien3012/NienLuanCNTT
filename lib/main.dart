import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'routes.dart';
import 'ui/auth/auth_manager.dart';
import 'ui/chat/chat_manager.dart';
import 'ui/room/room_manager.dart';
import 'ui/splash_screen.dart';


Future <void> main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TravelApp());
}

class OnboardingManager {
}

class TravelApp extends StatefulWidget {
  const TravelApp({super.key});

  @override
  State<TravelApp> createState() => _TravelAppState();
}

class _TravelAppState extends State<TravelApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => AuthManager() 
        ),
        ChangeNotifierProvider(
          create: (ctx) => ChatManager() 
        ),
        ChangeNotifierProvider(
          create: (ctx) => RoomManager() 
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: routes,
        home: SplashScreen(),
      ),
    );
  }
}


