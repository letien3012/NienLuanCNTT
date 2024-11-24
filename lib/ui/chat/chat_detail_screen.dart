import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/chat_message.dart';
import '../../models/user.dart';
import '../auth/auth_manager.dart';
import 'chat_manager.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key});
  static String routeName = 'chat_detai_screen';
  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  User userReceive = User(id: '', email: '', name: '', phone: '', address: '', city: '', district: '');
  late String userReceiveId;
  late List<ChatMessage> messages = [];

  late bool isLoading = true;
  late String? conversationId;

  Future<void> _loadData(String userReceiveId) async {
    final currentUserId = context.read<AuthManager>().currentUserId;

    // Lấy conversationId
    conversationId = await context
        .read<ChatManager>()
        .getConversationId(currentUserId, userReceiveId);

    userReceive =
        await context.read<AuthManager>().getUserInfoById(userReceiveId);

    // Lấy tất cả tin nhắn
    List<ChatMessage> allMessages =
        await context.read<ChatManager>().fetchUserMessage(userReceiveId);

    // Lọc các tin nhắn chưa bị xóa cho người dùng hiện tại
    messages = allMessages.where((msg) {
      if (msg.messageType == "sender") {
        return msg.isDeletedForSender ==
            false; // Chỉ hiển thị tin nhắn chưa bị xóa đối với người gửi
      } else {
        return msg.isDeletedForReceiver ==
            false; // Chỉ hiển thị tin nhắn chưa bị xóa đối với người nhận
      }
    }).toList();

    setState(() {
      isLoading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      userReceiveId = args?['userId'] ?? '';
      _loadData(userReceiveId);
    });
  }

  final _isSubmitting = ValueNotifier<bool>(false);
  String messageText = '';
  final _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Future<void> _submit() async {
    if (messageText.trim().isEmpty) return;

    _isSubmitting.value = true;
    try {
      final currentUserId = context.read<AuthManager>().currentUserId;

      // Bật lại hội thoại nếu đã bị xóa
      if (conversationId != null) {
        await context
            .read<ChatManager>()
            .undeleteConversation(conversationId!, currentUserId);
      }

      // Gửi tin nhắn
      await context.read<ChatManager>().sendMessage(messageText, userReceiveId);

      _messageController.clear();
      await _loadData(userReceiveId);
    } catch (error) {
      if (mounted) {
        print("Error sending message: $error");
      }
    }
    _isSubmitting.value = false;
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _deleteMessage(String messageId, String messageType) async {
    try {
      // Xóa tin nhắn cho người dùng hiện tại
      await context
          .read<ChatManager>()
          .deleteMessageForUser(messageId, messageType);

      // Cập nhật danh sách tin nhắn
      setState(() {
        messages.removeWhere((msg) => msg.id == messageId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tin nhắn đã được xóa")),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không thể xóa tin nhắn: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSubmitting.value) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.redAccent,
          flexibleSpace: SafeArea(
            child: Container(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    backgroundImage: userReceive.imageUrl == ''
                        ? null
                        : NetworkImage(userReceive.imageUrl),
                    maxRadius: 20,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        userReceive.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Online",
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Stack(
          children: <Widget>[
            SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 50),
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: messages.length,
                shrinkWrap: true,
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onLongPress: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => ListTile(
                          leading: const Icon(Icons.delete),
                          title: const Text('Xóa tin nhắn'),
                          onTap: () {
                            Navigator.of(context).pop();
                            _deleteMessage(
                              messages[index].id,
                              messages[index].messageType,
                            );
                          },
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.only(
                          left: 14, right: 14, top: 10, bottom: 10),
                      child: Align(
                        alignment: (messages[index].messageType == "receiver"
                            ? Alignment.topLeft
                            : Alignment.topRight),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: (messages[index].messageType == "receiver"
                                ? Colors.grey.shade200
                                : Colors.blue[200]),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            messages[index].messageContent,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                padding: const EdgeInsets.only(left: 10, bottom: 10, top: 10),
                height: 60,
                width: double.infinity,
                color: Colors.white,
                child: Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          color: Colors.lightBlue,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        onSubmitted: (value) {
                          messageText = value;
                          _submit();
                        },
                        decoration: const InputDecoration(
                            hintText: "Nhập tin nhắn",
                            hintStyle: TextStyle(color: Colors.black54),
                            border: InputBorder.none),
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    const SizedBox(width: 15),
                    FloatingActionButton(
                      onPressed: () {
                        messageText = _messageController.text;
                        _submit();
                      },
                      backgroundColor: Colors.blue,
                      elevation: 0,
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
