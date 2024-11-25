import '../models/chat_message.dart';
import '../models/chat_user.dart';
import 'pocketbase_client.dart';

class ChatService {
  Future<String> loadConservation(String userId1, String userId2) async {
    try {
      final pb = await getPocketbaseInstance();
      final conversation = await pb.collection('conversations').getFullList(
            filter: 'userId1="$userId1" && userId2="$userId2"',
          );
      final conversation1 = await pb.collection('conversations').getFullList(
            filter: 'userId1="$userId2" && userId2="$userId1"',
          );
      if (conversation.length == 0 && conversation1.length == 0) {
        final record = await pb.collection('conversations').create(
          body: {
            'userId1': userId1,
            'userId2': userId2,
          },
        );
        return record.id;
      }
      return conversation.length > 0 ? conversation[0].id : conversation1[0].id;
    } catch (error) {
      return '';
    }
  }

  Future<void> sendMessage(
    String messageContent,
    String userIdReceive,
  ) async {
    try {
      final pb = await getPocketbaseInstance();
      final userId = pb.authStore.model!.id;
      final conservationId = await loadConservation(userId, userIdReceive);
      final messageRecordSend = await pb.collection('messages').create(
        body: {
          'senderId': userId,
          'messageContent': messageContent,
          'conversationId': conservationId
        },
      );
    } catch (error) {
      return null;
    }
  }

  Future<List<ChatMessage>> fetchUserMessage(String userIdReceive) async {
    List<ChatMessage> listMessage = [];
    try {
      final pb = await getPocketbaseInstance();
      final userIdSender = pb.authStore.model!.id;
      final conversation = await pb.collection('conversations').getFullList(
            filter: 'userId1="$userIdSender" && userId2="$userIdReceive"',
          );
      final conversation1 = await pb.collection('conversations').getFullList(
            filter: 'userId1="$userIdReceive" && userId2="$userIdSender"',
          );
      final conservationId =
          conversation.length > 0 ? conversation[0].id : conversation1[0].id;
      final listMessageRecords = await pb
          .collection('messages')
          .getFullList(filter: 'conversationId="$conservationId"');
      for (final listMessageRecord in listMessageRecords) {
        listMessage.add(ChatMessage.fromJson(listMessageRecord.toJson()
          ..addAll({
            'messageType': listMessageRecord.data['senderId'] == userIdSender
                ? 'sender'
                : 'receiver'
          })));
      }
      return listMessage;
    } catch (error) {
      print(error);
      return listMessage;
    }
  }

  Future<void> deleteConversationForUser(
      String conversationId, String currentUserId) async {
    try {
      final pb = await getPocketbaseInstance();
      final listMessageRecords = await pb
          .collection('messages')
          .getFullList(filter: 'conversationId="$conversationId"');
      for (final listMessageRecord in listMessageRecords) {
        if (currentUserId == listMessageRecord.data['senderId'])
          await pb
              .collection('messages')
              .update(listMessageRecord.id, body: {'isDeletedForSender': true});
        else {
          await pb.collection('messages').update(listMessageRecord.id,
              body: {'isDeletedForReceiver': true});
        }
      }
      // Lấy thông tin cuộc hội thoại hiện tại
      final conversation =
          await pb.collection('conversations').getOne(conversationId);

      // Xác định cột cần cập nhật dựa trên người dùng hiện tại
      if (conversation.data['userId1'] == currentUserId) {
        await pb.collection('conversations').update(conversationId, body: {
          'isDeletedForUser1': true,
        });
      } else if (conversation.data['userId2'] == currentUserId) {
        await pb.collection('conversations').update(conversationId, body: {
          'isDeletedForUser2': true,
        });
      }
    } catch (error) {
      print("Error deleting conversation for user: $error");
    }
  }

  Future<void> undeleteConversation(
      String conversationId, String currentUserId) async {
    try {
      final pb = await getPocketbaseInstance();

      // Cập nhật trạng thái "đã xóa" về false
      final conversation =
          await pb.collection('conversations').getOne(conversationId);

      if (conversation.data['userId1'] == currentUserId) {
        await pb.collection('conversations').update(conversationId, body: {
          'isDeletedForUser1': false,
          'isDeletedForUser2': false,
        });
      } else if (conversation.data['userId2'] == currentUserId) {
        await pb.collection('conversations').update(conversationId, body: {
          'isDeletedForUser1': false,
          'isDeletedForUser2': false,
        });
      }
    } catch (e) {
      print("Error undeleting conversation: $e");
    }
  }

  Future<String?> getConversationId(String user1Id, String user2Id) async {
    try {
      final pb = await getPocketbaseInstance();
      final result = await pb.collection('conversations').getFullList(
            filter:
                '(userId1="$user1Id" && userId2="$user2Id") || (userId1="$user2Id" && userId2="$user1Id")',
          );

      if (result.isNotEmpty) {
        return result.first.id;
      }
      return null; // Không tìm thấy hội thoại
    } catch (e) {
      print("Error fetching conversationId: $e");
      return null;
    }
  }

  Future<void> deleteMessageForUser(
      String messageId, String messageType) async {
    try {
      final pb = await getPocketbaseInstance();

      // Lấy dữ liệu tin nhắn
      final message = await pb.collection('messages').getOne(messageId);
      final conversationId = message.data['conversationId'];

      // Truy vấn hội thoại để xác định userId1 và userId2
      final conversation =
          await pb.collection('conversations').getOne(conversationId);

      final userId1 = conversation.data['userId1'];
      final userId2 = conversation.data['userId2'];
      if (messageType == 'sender') {
        // Xóa tin nhắn cho userId1
        await pb.collection('messages').update(messageId, body: {
          'isDeletedForSender': true,
        });
      } else if (messageType == 'receiver') {
        // Xóa tin nhắn cho userId2
        await pb.collection('messages').update(messageId, body: {
          'isDeletedForReceiver': true,
        });
      }
    } catch (e) {
      print("Error deleting message: $e");
      throw Exception("Unable to delete message");
    }
  }

  // Cập nhật fetchChatUser để lọc các cuộc hội thoại đã xóa
  Future<List<ChatUser>> fetchChatUser() async {
    List<ChatUser> listChatUser = [];
    try {
      final pb = await getPocketbaseInstance();
      final userId = pb.authStore.model!.id;

      // Chỉ lấy các cuộc hội thoại chưa bị đánh dấu là đã xóa cho người dùng hiện tại
      final listconversation = await pb.collection('conversations').getFullList(
            filter:
                '(userId1="$userId" && isDeletedForUser1=false) || (userId2="$userId" && isDeletedForUser2=false)',
          );

      for (final conversation in listconversation) {
        final userchatId = userId == conversation.data['userId1']
            ? conversation.data['userId2']
            : conversation.data['userId1'];
        final userChatInfo = await pb.collection('users').getOne(userchatId);

        // Lấy tin nhắn gần nhất cho cuộc hội thoại
        final message = await pb.collection('messages').getList(
            page: 1,
            perPage: 1,
            filter:
                '(conversationId="${conversation.id}" && isDeletedForSender=false) || (conversationId="${conversation.id}" && isDeletedForReceiver=false && "$userId"!=senderId )',
            sort: '-created');

        listChatUser.add(ChatUser(
          conservationId: conversation.id,
          name: userChatInfo.data['name'],
          chatuserId: userChatInfo.id,
          messageContent: message.items.isNotEmpty
              ? message.items[0].data['messageContent']
              : '',
          messageType: message.items.isNotEmpty &&
                  message.items[0].data['senderId'] == userId
              ? 'sender'
              : 'receiver',
          imageReceiverUrl: pb.files
              .getUrl(userChatInfo, userChatInfo.getStringValue('avatar'))
              .toString(),
          time: message.items.isNotEmpty
              ? DateTime.parse(message.items[0].created)
              : DateTime.now(),
        ));
      }
      return listChatUser;
    } catch (error) {
      print(error);
      return listChatUser;
    }
  }
}
