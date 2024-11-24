import 'package:flutter/material.dart';

import 'ui/auth/signin_screen.dart';
import 'ui/auth/signup_screen.dart';
import 'ui/chat/chat_detail_screen.dart';
import 'ui/chat/chat_screen.dart';
import 'ui/home/home_screen.dart';
import 'ui/main_screen.dart';
import 'ui/onboard/intro_screen.dart';
import 'ui/place/add_room_screen.dart';
import 'ui/place/edit_place_screen.dart';
import 'ui/place/list_places_screen.dart';
import 'ui/place/place_detail_screen.dart';
import 'ui/place/user_place_detail.dart';
import 'ui/place/user_place_screen.dart';
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
  ListPlacesScreen.routeName: (context) => const ListPlacesScreen(),
  SignupScreen.routeName: (context) => const SignupScreen(),
  SigninScreen.routeName: (context) => const SigninScreen(),
  PlaceDetailScreen.routeName: (context) => const PlaceDetailScreen(),
  AddRoomScreen.routeName: (context) => const AddRoomScreen(),
  EditPlaceScreen.routeName: (context) => const EditPlaceScreen(),
  UserPlaceScreen.routeName: (context) => const UserPlaceScreen(),
  UserPlaceDetail.routeName: (context) => const UserPlaceDetail(),
  ChatScreen.routeName: (context) => const ChatScreen(),
  ChatDetailScreen.routeName: (context) => const ChatDetailScreen(),
};
