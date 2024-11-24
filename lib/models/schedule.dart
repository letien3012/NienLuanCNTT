import 'dart:io';

class Schedule {
  String id;
  String? userId;
  String? name;
  String? startDate;
  String? endDate;
  double? budget;
  File? image;
  final String imageUrl;
  String? destination;

  Schedule({
    required this.id,
    required this.userId,
    required this.startDate,
    required this.endDate,
    this.image,
    required this.imageUrl,
    this.name,
    this.budget,
    this.destination,
  });

  Schedule copyWith({
    String? id,
    String? userId,
    String? name,
    String? startDate,
    String? endDate,
    double? budget,
    File? image,
    String? imageUrl,
    String? destination,
  }) {
    return Schedule(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      budget: budget ?? this.budget,
      image: image ?? this.image,
      imageUrl: imageUrl ?? this.imageUrl,
      destination: destination ?? this.destination,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'startDate': startDate,
      'endDate': endDate,
      'budget': budget,
      'imageUrl': imageUrl,  // Include imageUrl in the JSON if needed
      'destination': destination,
    };
  }

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      budget: json['budget']?.toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      destination: json['destination'],
    );
  }
}
