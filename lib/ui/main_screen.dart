import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'auth/auth_manager.dart';
import 'auth/signin_screen.dart';
import 'chat/chat_screen.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import 'search/search_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  static String routeName='main_screen';
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      if (args?['index'] != null){
      setState(() {
        _currentIndex = args?['index'];
      });
    }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthManager>(
      builder: (ctx, authManager, child) {
        if (!authManager.isAuth) {
          return SigninScreen(); 
        } else {       
        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 243, 242, 242),
          body: IndexedStack(
            index: _currentIndex,
            children: const [
              HomeScreens(),
              SearchScreen(),
              ChatScreen(),
              ProfileScreen(),
            ],
          ),
          bottomNavigationBar: SalomonBottomBar(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeIn,
            margin: EdgeInsets.all(20),
            unselectedItemColor: Colors.black,
            selectedItemColor: Colors.redAccent,
            backgroundColor: Colors.white,
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              SalomonBottomBarItem(
                icon: Icon(Icons.home_outlined),
                title: Text("Home"),
              ),
              SalomonBottomBarItem(
                icon: Icon(Icons.search_outlined),
                title: Text("Search"),
              ),
              SalomonBottomBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                title: Text("Message"),
              ),
              SalomonBottomBarItem(
                icon: Icon(Icons.person_2_outlined),
                title: Text("Profile"),
              ),
            ],
          ),
        );
        }
      },
    );
  }
}
