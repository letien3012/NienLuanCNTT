class ChatUser {
  String conservationId;
  String chatuserId;
  String name;
  String imageReceiverUrl;
  String messageContent;
  String messageType;
  DateTime time;
  bool isDeletedForUser1;
  bool isDeletedForUser2;

  ChatUser({
    required this.conservationId,
    required this.chatuserId,
    required this.name,
    required this.imageReceiverUrl,
    required this.messageContent,
    required this.messageType,
    required this.time,
    this.isDeletedForUser1 = false,
    this.isDeletedForUser2 = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'conservationId': conservationId,
      'userId': chatuserId,
      'name': name,
      'imageReceiverUrl': imageReceiverUrl,
      'messageContent': messageContent,
      'messageType': messageType,
      'time': time.toIso8601String(),
      'isDeletedForUser1': isDeletedForUser1,
      'isDeletedForUser2': isDeletedForUser2,
    };
  }

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      conservationId: json['conservationId'] ?? '',
      chatuserId: json['userId'] ?? '',
      name: json['name'] ?? '',
      imageReceiverUrl: json['imageReceiverUrl'] ?? '',
      messageContent: json['messageContent'] ?? '',
      messageType: json['messageType'] ?? '',
      time: DateTime.parse(json['time']),
      isDeletedForUser1: json['isDeletedForUser1'] ?? false,
      isDeletedForUser2: json['isDeletedForUser2'] ?? false,
    );
  }
}
