
import 'package:flutter/material.dart';

import '../../models/chat_message.dart';
import '../../models/chat_user.dart';
import '../../services/chat_service.dart';

class ChatManager with ChangeNotifier {
  final ChatService _chatService = ChatService();

  Future<void> sendMessage(String messageText, String userIdReceive) async {
    return _chatService.sendMessage(messageText, userIdReceive);
  }

  Future<List<ChatMessage>> fetchUserMessage(String userIdReceive) async {
    return _chatService.fetchUserMessage(userIdReceive);
  }

  // Stream để tự động cập nhật danh sách hội thoại
  Stream<List<ChatUser>> fetchChatUserStream(String currentUserId) async* {
    while (true) {
      List<ChatUser> chatUsers = await _chatService.fetchChatUser();

      // Lọc các cuộc hội thoại đã bị xóa bởi người dùng hiện tại
      chatUsers = chatUsers.where((chat) {
        if (chat.chatuserId == currentUserId) {
          return !chat.isDeletedForUser1;
        } else {
          return !chat.isDeletedForUser2;
        }
      }).toList();

      yield chatUsers;

      // Đợi trước khi cập nhật lại danh sách
      await Future.delayed(Duration(seconds: 3));
    }
  }

  // Thêm phương thức xóa hội thoại chỉ cho một người dùng
  Future<void> deleteConversation(
      String conversationId, String currentUserId) async {
    await _chatService.deleteConversationForUser(conversationId, currentUserId);
    notifyListeners();
  }

  Future<void> undeleteConversation(
      String conversationId, String currentUserId) async {
    // Gọi tới service để cập nhật trạng thái xóa
    await _chatService.undeleteConversation(conversationId, currentUserId);
    notifyListeners();
  }

  Future<String?> getConversationId(String user1Id, String user2Id) {
    return _chatService.getConversationId(user1Id, user2Id);
  }

  Future<void> deleteMessageForUser(
      String messageId, String messageType) async {
    await _chatService.deleteMessageForUser(messageId, messageType);
    notifyListeners(); // Cập nhật giao diện
  }
}
