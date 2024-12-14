import 'package:chat_app/app/screens/chat_screen.dart';
import 'package:chat_app/data/datasource/chat_db.dart';
import 'package:chat_app/data/datasource/user_db.dart';
import 'package:chat_app/data/models/chat_model.dart';
import 'package:chat_app/services/auth_services.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final db = UserDb();
  final chatDb = ChatDb();
  final _auth = AuthServices();

  int userId = 0;
  int lastChat = 0;

  @override
  void initState() {
    getLastNo();
    super.initState();
  }

  void getLastNo() async {
    int? idx = await chatDb.getLastChatId();

    setState(() {
      lastChat = idx ?? 0;
    });
  }

  // final List<String> chats = [
  //   "Chat 1",
  //   "Chat 2",
  //   "Chat 3",
  //   "Chat 4",
  //   "Chat 5",
  // ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Chat App"),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
              onPressed: () => AuthServices().signOut(),
              icon: const Icon(Icons.exit_to_app))
        ],
      ),
      drawer: Drawer(
        child: StreamBuilder(
          stream: db.stream,
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snap.hasData || snap.data == null) {
              return const Center(
                child: Text(
                  "No data available",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              );
            }

            if (snap.hasError) {
              return const Center(
                child: Text(
                  "An error occurred",
                  style: TextStyle(color: Colors.red),
                ),
              );
            }

            final email = _auth.getCurrentEmail();
            final userList =
                snap.data!.where((val) => val.email == email).toList();

            if (userList.isEmpty) {
              return const Center(
                child: Text(
                  "User not found",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              );
            }

            final user = userList[0];

            if (user.chatIds.isEmpty) {
              return const Center(
                child: Text(
                  "No chats available",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              );
            }

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 30),
                ...user.chatIds.map((chat) => ListTile(
                      leading: const Icon(Icons.chat),
                      title: Text("Chat #$chat"),
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.of(ctx).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ChatScreen(user: user, chatId: chat),
                          ),
                        );
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text("Switched to chat #$chat")),
                        );
                      },
                    )),
              ],
            );
          },
        ),
      ),
      body: StreamBuilder(
        stream: db.stream,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snap.hasData || snap.data == null) {
            return const Center(
              child: Text(
                "No data available",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          if (snap.hasError) {
            return const Center(
              child: Text(
                "An error occurred",
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          final email = _auth.getCurrentEmail();
          final userList =
              snap.data!.where((val) => val.email == email).toList();

          if (userList.isEmpty) {
            return const Center(
              child: Text(
                "User not found",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          final user = userList[0];

          userId = user.id!;

          lastChat = user.chatIds.isNotEmpty
              ? int.tryParse(user.chatIds.last) ?? 0
              : lastChat;

          return Column(
            children: [
              Column(
                children: [
                  Image.asset("assets/7118857_3394897.jpg"),
                  const Center(
                    child: Text(
                      "Welcome to Chat App",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const Center(
                    child: Text(
                      "Ask Anything to Chat AI it will respond to user all requests\nClick the `New Chat` down below to start chatting",
                    ),
                  )
                ],
              ),
              const SizedBox(height: 50),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      final newChatId = (lastChat + 1).toString();

                      chatDb.createChat(
                        ChatModel(
                          userId: userId,
                          conversation: [],
                          createdAt: DateTime.now(),
                        ),
                      );

                      Navigator.of(ctx).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ChatScreen(user: user, chatId: newChatId),
                        ),
                      );
                    },
                    child: Container(
                      height: 60,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xffc2c2c2),
                            blurRadius: 2,
                            spreadRadius: 2,
                            offset: Offset(0, 2),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text(
                          "New Chat",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
