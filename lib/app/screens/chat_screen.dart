import 'package:chat_app/app/widgets/typing_bubble.dart';
import 'package:chat_app/data/models/chat_model.dart';
import 'package:chat_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/data/datasource/chat_db.dart';
import 'package:chat_app/data/models/user_model.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.user, required this.chatId});

  final UserModel user;
  final String chatId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // controllers
  final TextEditingController _messageController = TextEditingController();
  // services
  final chatDb = ChatDb();
  final service = ApiService();
  // local varibles
  String response = "";
  bool isTyping = false;
  int id = 0;

  @override
  void initState() {
    id = int.tryParse(widget.chatId)!;
    super.initState();
  }

  // methods
  void _sendMessage() async {
    final message = _messageController.text.trim();

    setState(() {
      isTyping = true;
    });

    if (message.isNotEmpty) {
      try {
        await chatDb.sendMessage(widget.chatId, widget.user.id!, message);

        response = await service.getResponse(message);

        await chatDb.botResponse(widget.chatId, response);

        setState(() {
          isTyping = false;
          _messageController.clear();
        });
      } catch (e) {
        setState(() {
          isTyping = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Chat #${widget.chatId}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: chatDb.stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Something went wrong: ${snapshot.error}",
                      style: const TextStyle(fontSize: 18, color: Colors.red),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(
                    child: Text(
                      "No chat data available.",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

                final chats = snapshot.data!;

                if (chats.isEmpty) {
                  return const Center(
                    child: Text(
                      "No chats found. Start a new conversation!",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

                final chatData = chats.firstWhere(
                  (chat) => chat.id == id,
                  orElse: () => ChatModel(
                    id: -1,
                    conversation: [],
                    userId: -1,
                    createdAt: DateTime.now(),
                  ),
                );

                // fetch conversations
                final List<Map<String, dynamic>> conversation =
                    List<Map<String, dynamic>>.from(chatData.conversation);

                if (conversation.isEmpty) {
                  return const Center(
                    child: Text(
                      "No messages yet. Start the conversation!",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: conversation.length,
                        itemBuilder: (context, index) {
                          final messageData = conversation[index];

                          final message = messageData["message"] as String? ??
                              "Unknown message";
                          final user = messageData["user"].toString();

                          final isMe = user == widget.user.id.toString();

                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Row(
                                mainAxisAlignment: isMe
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  if (!isMe)
                                    const CircleAvatar(
                                      child: Icon(
                                        Icons.smart_toy_outlined,
                                        color: Colors.black,
                                      ),
                                    ),
                                  Container(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.7,
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color:
                                          isMe ? Colors.blue : Colors.grey[300],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      message,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color:
                                            isMe ? Colors.white : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (isMe)
                                    CircleAvatar(
                                      backgroundColor: Colors.amber,
                                      child: Text(
                                        widget.user.avatarUrl!
                                            .substring(0, 1)
                                            .toUpperCase(),
                                      ),
                                    )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (isTyping) const TypingBubble(),
                  ],
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 60,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xffc2c2c2)),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: "Type a message...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                    onPressed: () => _sendMessage(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
