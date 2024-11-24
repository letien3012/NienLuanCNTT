import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; 
import '../../models/place.dart';
import '../../models/user.dart';
import '../auth/auth_manager.dart';
import '../chat/chat_detail_screen.dart';
import '../shared/dialog.dart';
import 'edit_room_screen.dart';
import 'room_manager.dart';
import 'user_room_screen.dart';

class RoomDetailScreen extends StatefulWidget {
  const RoomDetailScreen({super.key});
  static String routeName = 'place_detail_screen';

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  late Place place;
  late String placeId;
  bool isLoading = true;
  late User userLogin;
  late User userPost;
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      placeId = args?['placeId'] ?? '';
      _loadPlace(placeId);
    });
  }

  Future<void> _loadPlace(String placeId) async {
    place = await context.read<RoomManager>().getPlace(placeId);
    userLogin = await context.read<AuthManager>().getUserInfo();
    userPost = await context.read<AuthManager>().getUserInfoById(place.userId!);
    setState(() {
      isLoading = false; // Đánh dấu hoàn tất tải dữ liệu
    });
  }
  String formatPrice(double price) {
    if (price >= 1000000) {
      return NumberFormat().format(price / 1000000) + ' triệu';
    } else if (price >= 1000) {
      return NumberFormat().format(price / 1000) + ' nghìn';
    } else {
      return NumberFormat().format(price);
    }
  }
  Future<void> _delete() async{
    bool _isDelete = false;
    _isDelete = (await showConfirmDialog(context, "Bạn có chắc muốn xóa '${place.title}'"))!;
    if (_isDelete){
      context.read<RoomManager>().deletePlace(placeId);
      Navigator.of(context).pop();
      Navigator.of(context).popAndPushNamed(UserRoomScreen.routeName);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 400,
                        child: PageView.builder(
                          itemCount: place.imageUrls.length,
                          itemBuilder: (context, index) => ClipRRect(
                            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                            child: Image.network(
                              place.imageUrls[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    place.title,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                                Row(
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
                            const SizedBox(height: 8),
                            // Địa chỉ
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.location_on_rounded, color: Colors.grey),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${place.address}, ${place.district!}, ${place.city!}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Loại và chi tiết
                            Row(
                              children: [
                                Icon(Icons.home, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text('${place.type}'),
                                const SizedBox(width: 16),
                                if (place.type == 'Minihouse') ...[
                                  Icon(Icons.bed_rounded, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text('${place.roomCount} phòng'),
                                ] else ...[
                                  Icon(Icons.type_specimen, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(place.hasLoft! ? 'Có gác' : 'Không gác'),
                                ],
                                const SizedBox(width: 16),
                                Icon(Icons.square_foot, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text('${place.area}m²'),
                              ],
                            ),
                            const SizedBox(height: 16,),
                            Text('Số phòng còn lại: ${place.quantity}', style: TextStyle(fontSize: 20),),
                            const SizedBox(height: 16),
                            Text(
                              'Các quy định',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              place.description ?? '',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 20,
                  left: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(3, 0),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                if (userLogin.id != place.userId)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 80,
                    width: 400,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundImage:NetworkImage(userPost.imageUrl),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,   
                              mainAxisAlignment: MainAxisAlignment.center,                          
                              children: [
                                Text(
                                  userPost.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  '${userPost.gender}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(ChatDetailScreen.routeName, arguments: {'userId': userPost.id});
                          },
                          icon: const Icon(Icons.message, color: Colors.blue, size: 30,),
                        ),
                      ],
                    ),
                  ),
                ),
                if (userLogin.id == userPost.id)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 350,
                    height: 50,
                    margin: EdgeInsets.only(bottom: 10),
                    child: TextButton(
                      onPressed: _delete,
                      style: TextButton.styleFrom(backgroundColor: Colors.redAccent),
                      child: const Text( 'Xóa địa điểm', style: TextStyle(fontSize: 20, color: Colors.white),)
                    ),
                  ),
                ),
                if (userLogin.id == userPost.id)
                  Positioned(
                    right: 20,
                    top: 20,
                    child:Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle
                      ),
                      child: IconButton(
                        onPressed: () {
                            Navigator.of(context).pushNamed(EditRoomScreen.routeName, arguments: {'place': place});       
                        },
                        icon: const Icon(FontAwesomeIcons.pen, size: 18, color: Colors.black,)
                                        ),
                    ))
              ],
            ),
    );
  }
}