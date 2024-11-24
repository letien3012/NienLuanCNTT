import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/chat_user.dart';
import '../auth/auth_manager.dart';
import '../shared/dialog.dart';
import '../widgets/conversation_list.dart';
import 'chat_manager.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  static String routeName = 'chat_screen';

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUserId =
        context.read<AuthManager>().currentUserId; 

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.redAccent,
        title: Text(
          'Tin nhắn',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<ChatUser>>(
        stream: context
            .read<ChatManager>()
            .fetchChatUserStream(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi khi tải tin nhắn'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Không có tin nhắn'));
          }

          // Lấy dữ liệu và sắp xếp
          final chatUsers = snapshot.data!;
          chatUsers.sort((a, b) => b.time.compareTo(a.time));

          return RefreshIndicator(
            onRefresh: () async {
              // Gọi lại fetch dữ liệu từ ChatManager
              await context
                  .read<ChatManager>()
                  .fetchChatUserStream(currentUserId);
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 16, left: 16, right: 16),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Tìm kiếm tin nhắn & hộp thoại",
                        hintStyle: TextStyle(color: Colors.grey.shade600),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: EdgeInsets.all(8),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(width: 1, color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(width: 1, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  ListView.builder(
                    itemCount: chatUsers.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.only(top: 16),
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return Dismissible(
                        key: ValueKey(chatUsers[index].conservationId),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          bool _isDelete = false;
                          _isDelete = (await showConfirmDialog(
                              context, "Bạn có chắc muốn xóa hội thoại này"))!;
                          if (_isDelete) {
                            await context
                                .read<ChatManager>()
                                .deleteConversation(
                                    chatUsers[index].conservationId,
                                    currentUserId);
                          }
                        },
                        // onDismissed: (direction) async {
                        //   await context
                        //       .read<ChatManager>()
                        //       .fetchChatUserStream(currentUserId);
                        // },
                        background: Container(
                          color: Colors.red,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                          ),
                        ),
                        child: ConversationList(
                          name: chatUsers[index].name,
                          messageText: chatUsers[index].messageContent,
                          imageUrl: chatUsers[index].imageReceiverUrl,
                          time: chatUsers[index].time,
                          isMessageRead: (index == 0 || index == 3),
                          userchatId: chatUsers[index].chatuserId,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
