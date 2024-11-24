class ChatMessage {
  String id; // ID của tin nhắn
  String conservationId;
  String messageContent;
  String messageType;
  bool
      isDeletedForSender; // Trường kiểm tra tin nhắn đã bị xóa đối với người gửi
  bool
      isDeletedForReceiver; // Trường kiểm tra tin nhắn đã bị xóa đối với người nhận

  ChatMessage({
    required this.id, // Đảm bảo truyền id khi khởi tạo
    required this.conservationId,
    required this.messageContent,
    required this.messageType,
    required this.isDeletedForSender, // Truyền giá trị isDeletedForSender
    required this.isDeletedForReceiver, // Truyền giá trị isDeletedForReceiver
  });

  // Chuyển đối tượng thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id, // Bao gồm id trong JSON
      'conservationId': conservationId,
      'messageContent': messageContent,
      'messageType': messageType,
      'isDeletedForSender': isDeletedForSender, // Thêm trường xóa cho người gửi
      'isDeletedForReceiver':
          isDeletedForReceiver, // Thêm trường xóa cho người nhận
    };
  }

  // Tạo đối tượng ChatMessage từ JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '', // Lấy id từ response (nếu có)
      conservationId: json['conservationId'] ?? '',
      messageContent: json['messageContent'] ?? '',
      messageType: json['messageType'] ?? '',
      isDeletedForSender:
          json['isDeletedForSender'] ?? false, // Lấy giá trị xóa cho người gửi
      isDeletedForReceiver: json['isDeletedForReceiver'] ??
          false, // Lấy giá trị xóa cho người nhận
    );
  }
}
