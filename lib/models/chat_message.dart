class ChatMessage {
  String id; 
  String conservationId;
  String messageContent;
  String messageType;
  bool isDeletedForSender; 
  bool isDeletedForReceiver; 

  ChatMessage({
    required this.id, 
    required this.conservationId,
    required this.messageContent,
    required this.messageType,
    required this.isDeletedForSender, 
    required this.isDeletedForReceiver, 
  });

  
  Map<String, dynamic> toJson() {
    return {
      'id': id, 
      'conservationId': conservationId,
      'messageContent': messageContent,
      'messageType': messageType,
      'isDeletedForSender': isDeletedForSender, 
      'isDeletedForReceiver':isDeletedForReceiver, 
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '', 
      conservationId: json['conservationId'] ?? '',
      messageContent: json['messageContent'] ?? '',
      messageType: json['messageType'] ?? '',
      isDeletedForSender:
          json['isDeletedForSender'] ?? false, 
      isDeletedForReceiver: json['isDeletedForReceiver'] ??
          false, 
    );
  }
}
