import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pocketbase/pocketbase.dart';
import '../helpers/asset_helper.dart';
import '../models/user.dart';
import 'pocketbase_client.dart';

class AuthService {
  void Function(User? user)? onAuthChange;

  AuthService({this.onAuthChange}){
    if (onAuthChange != null){
      getPocketbaseInstance().then((pb){
        pb.authStore.onChange.listen((event){
          onAuthChange!(event.model == null
            ? null
            : User.fromJson(event.model!.toJson()));
        });
      });
    }
  }
  
  Future<File> loadDefaultAvatar(String gender) async {
    final String assetPath;
    if (gender == 'Nam') {
      assetPath = AssetHelper.male_avatar; 
    }
    else if(gender == 'Nữ'){
      assetPath = AssetHelper.female_avatar; 
    }
    else{
      assetPath = AssetHelper.otherAvatar; 
    }
    try {
      ByteData data = await rootBundle.load(assetPath);
      Uint8List bytes = data.buffer.asUint8List();

      Directory tempDir = await getTemporaryDirectory();
      String filePath = '${tempDir.path}/default_avatar.png';

      File avatarFile = File(filePath);
      await avatarFile.writeAsBytes(bytes);

      return avatarFile; 
    } catch (e) {
      print('Lỗi khi tải avatar mặc định: $e');
      throw Exception('Failed to load default avatar');
    }
  }
  Future<bool> isEmailExist(String email) async {
    var result = [];
    try {
      final pb = await getPocketbaseInstance();
      result = await pb.collection('users').getFullList(
        batch: 1,
        filter: 'email="$email"',
      );
      return result.isNotEmpty;
    } catch (e) {
      if (e is ClientException && e.statusCode == 404) {
        return false;
      }
      rethrow; 
    }
  }
  Future<void> updateAvatar(File avatar, User user) async {
    try {
      final pb = await getPocketbaseInstance();
      final userId = pb.authStore.model!.id;
      final productModel = await pb.collection('users').update(
        userId,
        files: [
          http.MultipartFile.fromBytes(
            'avatar',
            await avatar.readAsBytes(),
            filename: avatar.uri.pathSegments.last,
          ),
        ],
      );
    } catch (error){
      print(error);
    }
  } 
  Future<User> signup(Map<String, dynamic> authData) async {
    final pb = await getPocketbaseInstance();
    try {
      final avatarFile = await loadDefaultAvatar(authData['gender']);
      print(avatarFile);
      final record = await pb.collection('users').create(body: {
        'name': authData['name'],
        'email':  authData['email'],
        'password':  authData['password'],
        'passwordConfirm':  authData['password'],
        'gender': authData['gender'],
        'city': authData['city'],
        'district': authData['district'],
        'role': authData['role']
        },
        files: [
          http.MultipartFile.fromBytes(
            'avatar',
            await avatarFile.readAsBytes(), 
            filename: avatarFile.uri.pathSegments.last,
          ),
        ]
      );
      return User.fromJson(record.toJson());
    } catch (error) {
      print(error);
      if (error is ClientException){
        throw Exception(error.response['message']);
      }
      throw Exception('An error occurred');
    }
  }
  Future<User> login(String email, String password) async {
    final pb = await getPocketbaseInstance();
    try {
      final authRecord = 
        await pb.collection('users').authWithPassword(email, password);
      return User.fromJson(authRecord.record!.toJson());
    } catch (error) {
      print(error);
      if (error is ClientException){
        throw Exception(error.response['message']);
      }
      throw Exception('An error occurred');
    }
  }
  Future<void> logout() async {
    final pb = await getPocketbaseInstance();
    pb.authStore.clear();
  }
  Future<User?> getUserFromStore() async {
    final pb = await getPocketbaseInstance();
    final model = pb.authStore.model;

    if (model == null){
      return null;
    }

    return User.fromJson(model.toJson());
  }
  Future<User> getUserInfo() async {
    final emptyUser = User(id: "", email: "", phone: "", address: "", name: "");

    try {
      final pb = await getPocketbaseInstance();
      final userJson = await pb.collection('users').getOne(pb.authStore.model!.id);

      var userModel = User.fromJson(userJson.toJson());
      userModel.imageUrl = pb.files.getUrl(userJson, userJson.getStringValue('avatar')).toString(); 
      return userModel;

    } catch (error) {
      print('An error occurred: $error');
      return emptyUser;
    }
  }

  Future<User> getUserInfoById(String userId) async {
    final emptyUser = User(id: "", email: "", phone: "", address: "", name: "", city: '', district: '',);
    try {
      final pb = await getPocketbaseInstance();
      final user = await pb.collection('users').getOne(userId);
      final userModel = User(
        id: user.id,
        email: user.getStringValue('email'),
        name: user.getStringValue('name'),
        phone: user.getStringValue('phone'),
        address: user.getStringValue('address'),
        imageUrl: pb.files.getUrl(user, user.getStringValue('avatar')).toString(), 
        city: user.getStringValue('city'), 
        district: user.getStringValue('district'),
        gender: user.getStringValue('gender'),  
        role: user.getIntValue('role')
      );
      return userModel;

    } catch (error) {
      print('An error occurred: $error');
      return emptyUser;
    }
  }
  Future<User> updateUserInfo(Map<String, dynamic> authData) async {
    final pb = await getPocketbaseInstance();
    final userId = pb.authStore.model.id;
    try {
      final record = await pb.collection('users').update(
        userId,
        body: {
          // 'email': email,
          'name': authData['name'],
          'phone': authData['phone'],
          'address':authData['address'],
          'city': authData['city'],
          'district': authData['district'],
        },
      );
      return User.fromJson(record.toJson()); 
    } catch (error) {
      print(error);
      if (error is ClientException) {
        final errorMessage = error.response['message'] ?? 'Lỗi không xác định';
        throw Exception('Lỗi Pocketbase: $errorMessage');
      }
      throw Exception('Đã xảy ra lỗi không mong muốn');
    }
  }

}