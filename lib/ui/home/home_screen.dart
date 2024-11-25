
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/place.dart';
import '../../models/user.dart';
import '../auth/auth_manager.dart';
import '../room/list_room_screen.dart';
import '../room/room_detail_screen.dart';
import '../room/room_manager.dart';
import '../shared/custom_page_route.dart';

class HomeScreens extends StatefulWidget {
  const HomeScreens({Key? key}) : super(key: key);

  static String routeName = 'home_screen';

  @override
  State<HomeScreens> createState() => _HomeScreensState();
}

class _HomeScreensState extends State<HomeScreens> {
  late Future<User> _fetchUser;
  late Future<List<Place>> _fetchPlaces;
  late User user;
  @override
  void initState() {
    super.initState();
    _fetchUser = context.read<AuthManager>().getUserInfo();
    _fetchPlaces = context.read<RoomManager>().fetchPlace(false);
  }

  Future<void> _refreshPlaces() async {
    setState(() {
      _fetchPlaces = context.read<RoomManager>().fetchPlace(false);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Place>>(
        future: _fetchPlaces,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final placeList = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _refreshPlaces,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    Column(
                      children: [
                        SizedBox(height: 25,),
                        FutureBuilder<User>(
                          future: _fetchUser ,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(child: Text('Lỗi: ${snapshot.error}'));
                            } else if (snapshot.hasData) {
                              user = snapshot.data!;
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Vị trí của bạn',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis, 
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Icon(Icons.location_on_rounded, color: Colors.redAccent),
                                            SizedBox(width: 5),
                                            Flexible(
                                              child: Text(
                                                '${user.district}, ${user.city}',
                                                style: TextStyle(fontSize: 14),
                                                overflow: TextOverflow.ellipsis, 
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 10), // Khoảng cách giữa chữ và avatar
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: CircleAvatar(
                                      radius: 30,
                                      backgroundImage: NetworkImage(user.imageUrl),
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return const Center(
                                child: Text(
                                  'Không có dữ liệu người dùng',
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Các phòng gần bạn',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          child: const Text(
                            'Xem tất cả',
                            style: TextStyle(color: Colors.blueAccent),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(CustomPageRoute(page: ListRoomScreen()));
                          },
                        ),
                      ],
                    ),
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: placeList.length,
                      itemBuilder: (context, index) {
                        final place = placeList[index];                     
                        return FutureBuilder<User>(
                          future: context.read<AuthManager>().getUserInfoById(place.userId!),
                          builder: (context, userSnapshot) {
                            if (userSnapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (userSnapshot.hasError) {
                              return Center(child: Text('Lỗi: ${userSnapshot.error}'));
                            } else if (userSnapshot.hasData) {
                              final userPost = userSnapshot.data!;
                              return buildHomeScreen(
                                place: place,
                                userAvatarUrl: userPost.imageUrl,
                                userName: userPost.name,
                              );
                            } else {
                              return const Center(child: Text('Không có thông tin người dùng'));
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text('Không có dữ liệu địa điểm.'));
          }
        },
      ),
    );
  }
}

class buildHomeScreen extends StatelessWidget {
  const buildHomeScreen({
    super.key,
    required this.place,
    required this.userAvatarUrl,
    required this.userName,
  });

  final Place place;
  final dynamic userAvatarUrl;
  final dynamic userName;
   String formatPrice(double price) {
    if (price >= 1000000) {
      return NumberFormat().format(price / 1000000) + ' triệu';
    } else if (price >= 1000) {
      return NumberFormat().format(price / 1000) + ' nghìn';
    } else {
      return NumberFormat().format(price);
    }
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          RoomDetailScreen.routeName,
          arguments: {'placeId': place.id},
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 230,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(place.imageUrls[0]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Positioned(
                //   right: 15,
                //   top: 15,
                //   child: ClipOval(
                //     child: Container(
                //       height: 40,
                //       width: 40,
                //       color: Colors.black.withOpacity(0.6),
                //       child: IconButton(
                //         icon: const Icon(
                //           FontAwesomeIcons.bookmark,
                //           color: Colors.white,
                //           size: 18,
                //         ),
                //         onPressed: () {},
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.redAccent,
                              size: 18,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                place.address,
                                style: const TextStyle(
                                  fontSize: 14,                           
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(userAvatarUrl),
                              radius: 15,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              userName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        "${formatPrice(place.price!)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "/tháng",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
