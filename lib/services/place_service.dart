import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';
import '../models/place.dart';
import 'pocketbase_client.dart';

class PlaceService {
  
  Future<void> addPlace(Map<String, dynamic> place) async {
    final pb = await getPocketbaseInstance();
    try {
      final userId = pb.authStore.model!.id;

      // Tạo danh sách để lưu trữ các MultipartFile
      List<http.MultipartFile> imageFiles = [];

      // Lặp qua danh sách hình ảnh và thêm vào danh sách MultipartFile
      for (var image in place['images']) {
        imageFiles.add(
          http.MultipartFile.fromBytes(
            'image', // Tên trường trong cơ sở dữ liệu
            await image.readAsBytes(), // Đọc dữ liệu hình ảnh
            filename: image.uri.pathSegments.last, // Lấy tên tệp
          ),
        );
      }
      // Gửi yêu cầu tạo bản ghi với các trường và hình ảnh
      final record = await pb.collection('rooms').create(
        body: {
          'title': place['title'],
          'address': place['address'],
          'description': place['description'],
          'price': place['price'],
          'userId': userId,
          'city': place['city'],
          'district': place['district'],
          'type': place['type'],
          'roomCount': place['roomCount'],
          'hasLoft': place['hasLoft'],
          'area': place['area'],
          'quantity': place['quantity']
        },
        files: imageFiles, // Gửi danh sách hình ảnh
      );
    } catch (error) {
      print(error);
      if (error is ClientException) {
        throw Exception(error.response['message']);
      }
      throw Exception('An error occurred');
    }
  }

  Future<List<Place>> fetchPlace(bool filteredByUser ) async {
    final List<Place> places = [];
    final pb = await getPocketbaseInstance();
    try {
      final userId = pb.authStore.model!.id;
      final placeModels = await pb
          .collection('rooms')
          .getFullList(filter: filteredByUser  ? "userId='$userId'" : null);
      
      for (final placeModel in placeModels) {
        // Lấy danh sách hình ảnh
        final List<String> imageUrls = [];
        // Giả sử bạn có nhiều hình ảnh lưu trữ với tên trường là 'images'
        final imagesField = placeModel.getListValue('image');
        if (imagesField != null) {
          for (final image in imagesField) {
            final imageUrl = pb.files.getUrl(placeModel, image).toString();
            imageUrls.add(imageUrl);
          }
        }

        places.add(
          Place.fromJson(
            placeModel.toJson()
              ..addAll({
                'imageUrls': imageUrls, // Thêm danh sách URL hình ảnh
              }),
          ),
        );
      }
      return places;  
    } catch (error) {
      if (error is ClientException) {
        throw Exception(error.response['message']);
      }
      throw Exception('An error occurred');
    }
  }
  Future<Place> getPlace(String placeId) async {
    final pb = await getPocketbaseInstance();
    try {
      final placeModel = await pb.collection('rooms').getOne(placeId);
      final List<String> imageUrls = [];
      final imagesField = placeModel.getListValue('image'); 

      if (imagesField != null) {
        for (final image in imagesField) {
          final imageUrl = pb.files.getUrl(placeModel, image).toString();
          imageUrls.add(imageUrl);
        }
      }

      return Place.fromJson(
        placeModel.toJson()
          ..addAll({
            'imageUrls': imageUrls, 
          }),
      );  
    } catch (error) {
      if (error is ClientException) {
        throw Exception(error.response['message']);
      }
      throw Exception('An error occurred');
    }
  }

  Future<void> updatePlace(Map<String, dynamic> place) async {
    final pb = await getPocketbaseInstance();
    try {
      final userId = pb.authStore.model!.id;

      await pb.collection('rooms').update(
        place['id'],
        body: {
          'image': [], 
        },
      );

      // Tạo danh sách MultipartFile cho các file mới
      List<http.MultipartFile> imageFiles = [];
      for (var image in place['images']) {
        imageFiles.add(
          http.MultipartFile.fromBytes(
            'image', // Tên trường lưu file trong database
            await image.readAsBytes(),
            filename: image.uri.pathSegments.last,
          ),
        );
      }

      // Cập nhật hình ảnh mới
      await pb.collection('rooms').update(
        place['id'],
        body: {
          'title': place['title'],
          'address': place['address'],
          'description': place['description'],
          'price': place['price'],
          'userId': userId,
          'city': place['city'],
          'district': place['district'],
          'type': place['type'],
          'roomCount': place['roomCount'],
          'hasLoft': place['hasLoft'],
          'area': place['area'],
          'quantity': place['quantity'],
        },
        files: imageFiles, // Gửi danh sách file mới
      );
    } catch (error) {
      if (error is ClientException) {
        throw Exception(error.response['message']);
      }
      throw Exception('An error occurred');
    }
  }

  Future<void> deletePlace(String placeId) async{
    final pb = await getPocketbaseInstance();
    try {
      await pb.collection('rooms').delete(placeId);
      return ;
    } catch (error) {
      if (error is ClientException){
        throw Exception(error.response['message']);
      }
      throw Exception('An error occurred');
    }
  }
  
}