import 'dart:io';

class User {
  final String id;
  final String? username;
  final String email;
  final String name;
  late File? avatar;
  String imageUrl;
  final String? phone;
  final String? address;
  final String? city;
  final String? district;
  final String? gender;
  final int? role;
  User({
    required this.id,
    this.username,
    required this.email,
    required this.name,
    this.avatar,
    this.imageUrl = '',
    required this.phone,
    this.address,
    this.city,
    this.district,
    this.gender,
    this.role
  });

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? name,
    File? avatar,
    String? imageUrl,
    String? phone,
    String? address,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      imageUrl: imageUrl ?? this.imageUrl,
      phone: "" ?? this.phone,
      address: "" ?? this.address, 
    );
  }
  Map<String , dynamic> toJson(){
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'address': address,
    };
  }
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      city: json['city'] ?? '', 
      district: json['district'] ?? '', 
      imageUrl: json['imageUrl'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '', 
      gender: json['gender'] ?? '',
      role: (json['role'] is int) 
        ? (json['role'] as int).toInt() 
        : (json['role'] as int? ?? 0),
    );
  }
}
