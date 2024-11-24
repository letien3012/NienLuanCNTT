import 'package:flutter/material.dart';

import 'ui/auth/signin_screen.dart';
import 'ui/auth/signup_screen.dart';
import 'ui/chat/chat_detail_screen.dart';
import 'ui/chat/chat_screen.dart';
import 'ui/home/home_screen.dart';
import 'ui/main_screen.dart';
import 'ui/onboard/intro_screen.dart';
import 'ui/place/add_room_screen.dart';
import 'ui/place/edit_room_screen.dart';
import 'ui/place/list_room_screen.dart';
import 'ui/place/room_detail_screen.dart';
import 'ui/place/user_place_detail.dart';
import 'ui/place/user_room_screen.dart';
import 'ui/profile/profile_screen.dart';
import 'ui/profile/update_profile_screen.dart';
import 'ui/search/search_screen.dart';
import 'ui/splash_screen.dart';

final Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => const SplashScreen(),
  IntroScreen.routeName: (context) => const IntroScreen(),
  MainScreen.routeName: (context) => const MainScreen(),
  HomeScreens.routeName: (context) => const HomeScreens(),
  ProfileScreen.routeName: (context) => const ProfileScreen(),
  SearchScreen.routeName: (context) => const SearchScreen(),
  UpdateProfileScreen.routeName: (context) => const UpdateProfileScreen(),
  ListRoomScreen.routeName: (context) => const ListRoomScreen(),
  SignupScreen.routeName: (context) => const SignupScreen(),
  SigninScreen.routeName: (context) => const SigninScreen(),
  RoomDetailScreen.routeName: (context) => const RoomDetailScreen(),
  AddRoomScreen.routeName: (context) => const AddRoomScreen(),
  EditRoomScreen.routeName: (context) => const EditRoomScreen(),
  UserRoomScreen.routeName: (context) => const UserRoomScreen(),
  UserPlaceDetail.routeName: (context) => const UserPlaceDetail(),
  ChatScreen.routeName: (context) => const ChatScreen(),
  ChatDetailScreen.routeName: (context) => const ChatDetailScreen(),
};
