import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';
import '../auth/auth_manager.dart';
import '../main_screen.dart';
import '../place/add_room_screen.dart';
import '../place/user_place_screen.dart';
import '../shared/custom_page_route.dart';
import '../shared/dialog.dart';
import '../widgets/profile_menu_widget.dart';
import 'update_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  static String routeName='profile_screen';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<User> _fetchUser;
  @override
  void initState() {
    super.initState();
    _fetchUser = context.read<AuthManager>().getUserInfo();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Text('Thông tin', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<User>(
        future: _fetchUser,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (snapshot.hasData){
            return SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    /// Hình ảnh
                    Stack(
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(100), 
                              child:  Image.network(
                                snapshot.data!.imageUrl,
                                fit: BoxFit.cover,
                              )
                            ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.blue),
                            child: IconButton(
                              icon: const Icon(FontAwesomeIcons.pen),
                              color: Colors.white,
                              iconSize: 15,
                              onPressed: () async{
                                final imagePicker = ImagePicker();
                                try {
                                  final imageFile = 
                                    await imagePicker.pickImage(source: ImageSource.gallery);
                                  if (imageFile ==  null){
                                    return;
                                  }
                                  var newAvatar=File(imageFile.path);
                                  var user = snapshot.data;
                                  await context.read<AuthManager>().updateAvatar(newAvatar,user!);
                                  setState(() {
                                     _fetchUser = context.read<AuthManager>().getUserInfo();
                                     Navigator.of(context).pop();
                                     Navigator.of(context).push(CustomPageRoute(page: MainScreen(),arguments: {'index':3} ));
                                    //  Navigator.of(context).popAndPushNamed(MainScreen.routeName, arguments: {'index':4});
                                  });
                                } catch (error) {
                                  if (mounted){
                                    showErrorDialog(context, 'Something went wrong.');
                                  }
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(snapshot.data!.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                    Text(snapshot.data!.email, style: TextStyle(fontSize: 14),),
                    const SizedBox(height: 40),      
                    /// -- MENU
                    const Divider(),
                    ProfileMenuWidget(title: "Thông tin người dùng", 
                      icon: FontAwesomeIcons.user, 
                      onPress: () {
                        Navigator.of(context).push(CustomPageRoute(page: UpdateProfileScreen()));
                        // Navigator.pushNamed(context, UpdateProfileScreen.routeName);
                      }
                    ),
                    // const Divider(),
                    // ProfileMenuWidget(title: "BookMarked", icon: Icons.bookmark, onPress: () {}),
                    const Divider(),
                    if (snapshot.data!.role == 1)
                    ProfileMenuWidget(title: "Thêm phòng thuê", icon: Icons.add_location_outlined, onPress: () {
                      Navigator.of(context).push(CustomPageRoute(page: AddRoomScreen()));
                      // Navigator.of(context).pushNamed(AddPlaceScreen.routeName);
                    }),
                    if (snapshot.data!.role == 1)
                    const Divider(),
                    // const Divider(),
                    // const SizedBox(height: 10),
                    if (snapshot.data!.role == 1)
                    ProfileMenuWidget(title: "Địa điểm đã đăng", icon: Icons.list_alt, onPress: () {
                      Navigator.of(context).push(CustomPageRoute(page: UserPlaceScreen()));
                      // Navigator.of(context).pushNamed(UserPlaceScreen.routeName);
                    }),
                    if (snapshot.data!.role == 1)
                    const Divider(),
                    ProfileMenuWidget(
                        title: "Đăng Xuất",
                        icon: FontAwesomeIcons.rightFromBracket,
                        textColor: Colors.red,
                        endIcon: false,
                        onPress: () {
                          context.read<AuthManager>().logout();
                          Navigator.of(context).pushReplacementNamed(MainScreen.routeName,);
                        }
                    ),
                    const Divider(),
                    ],
                  ),
                ),
              );
            } else {
              return const Center(child: Text('Không có dữ liệu người dùng'));
            }  
        }
      )
    );
  }
}



