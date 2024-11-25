import 'package:NienLuan/ui/room/room_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/place.dart';
import '../widgets/place_list.dart';
import 'room_manager.dart';

class UserRoomScreen extends StatefulWidget {
  const UserRoomScreen({super.key});
  static String routeName='user_place_screen';
  @override
  State<UserRoomScreen> createState() => _UserRoomScreenState();
}

class _UserRoomScreenState extends State<UserRoomScreen> {
  late Future<List<Place>> _fetchPlaces;
  @override
  void initState() {
    super.initState();
    _fetchPlaces = context.read<RoomManager>().fetchPlace(true);
  }
  Future<void> _refreshPlaces() async {
    setState() {
     _fetchPlaces = context.read<RoomManager>().fetchPlace(true);
    };
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        leading: IconButton(onPressed: (){ Navigator.of(context).pop();}, icon: const Icon(Icons.arrow_back_ios)),
        title: const Text('Các phòng đã đăng', style: TextStyle(fontWeight: FontWeight.bold),), 
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPlaces,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: FutureBuilder(
            future: _fetchPlaces,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Lỗi: ${snapshot.error}'));
              } else if (snapshot.hasData && snapshot.data!.length > 0) {
                final places = snapshot.data!;
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10,),
                      GridView.builder( 
                        physics: ScrollPhysics(),
                        scrollDirection: Axis.vertical, 
                        shrinkWrap: true,
                        padding: EdgeInsets.only(top: 10, left: 15, right: 15),
                        itemCount: places.length,
                        itemBuilder: (  BuildContext context, int index) {
                          return PlaceList(
                            imageUrl: places[index].imageUrls[0], address: places[index].address, 
                            title: places[index].title, price: places[index].price != null ? places[index].price! : 0.0,
                            ontap: (){
                              Navigator.of(context).pushNamed(
                                RoomDetailScreen.routeName, 
                                arguments: {'placeId': places[index].id,}
                              );
                            },);
                        }, 
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 5),
                      ),
                    ],
                  ),
                );
              } else {
                return Center(
                  child: Text('Không có dữ liệu người dùng.', style: TextStyle(fontSize: 20),),
                );
              }
            }
          ),
        ),
      )
    );
  }
}