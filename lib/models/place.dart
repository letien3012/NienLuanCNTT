import 'dart:io';

class Place {
  final String? id;
  final String title;
  final String address;
  final String? description;
  final double? price;
  final List<File>? images;
  final List<String> imageUrls;
  final String? city;
  final String? district;
  final String? type;
  final int? roomCount;
  final bool? hasLoft;
  final int? area;
  final int? quantity;
  // String imageUrl;
  String? userId;
  // bool isFavorite;

  Place({
    this.id,
    required this.title,
    required this.address,
    this.description,
    this.price,
    this.images,
    this.type,
    this.area,
    required this.imageUrls,
    // required this.imageUrl,
    this.userId,
    this.city,
    this.district,
    this.roomCount,
    this.hasLoft,
    this.quantity

    // this.isFavorite = false,
  });
  Place copyWith({
    String? id,
    String? title,
    String? address,
    String? description,
    double? price,
    File? image,
    String? imageUrl,
    // bool? isFavorite,
  }) {
    return Place(
      id: id ?? this.id,
      title: title ?? this.title,
      address: address ?? this.address,
      description: description ?? this.description,
      price: price ?? this.price,
      images: images ?? this.images,
      // imageUrl: imageUrl ?? this.imageUrl,
      userId: userId ?? this.userId, 
      imageUrls: [],
      // isFavorite: isFavorite ?? this.isFavorite,
    );
  }
  Map<String ,dynamic> toJson(){
    return {
      'title': title,
      'address': address,
      'description': description,
      'price': price!.toDouble(),
    };
  }
  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'],
      title: json['title'],
      address: json['address'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] is int) 
        ? (json['price'] as int).toDouble() 
        : (json['price'] as double? ?? 0.0),
      imageUrls: List<String>.from(json['imageUrls'] ?? []), 
      // imageUrl: json['imageUrl'] ?? '', 
      userId: json['userId'] ?? '',
      type: json['type'] ?? '',
      hasLoft: json['hasLoft'] ?? '',
      roomCount: (json['roomCount'] is int) 
        ? (json['roomCount'] as int).toInt() 
        : (json['roomCount'] as int? ?? 0),
      city: json['city'] ?? '',
      district: json['district'] ?? '',
      area: (json['area'] is int) 
        ? (json['area'] as int).toInt() 
        : (json['area'] as int? ?? 0),
      quantity: (json['quantity'] is int) 
        ? (json['quantity'] as int).toInt() 
        : (json['quantity'] as int? ?? 0),
      // images: json['image']
    );
  }
}