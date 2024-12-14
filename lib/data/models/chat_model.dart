class ChatModel {
  int? id;
  final int userId;
  final List<Map<String, dynamic>> conversation;
  final DateTime createdAt;

  ChatModel({
    this.id,
    required this.userId,
    required this.conversation,
    required this.createdAt,
  });

  // Chat -> Map
  Map<String, dynamic> toMap() {
    return {
      'uid': userId,
      'conversations': conversation, // No need to encode, already a list
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Map -> Chat
  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      id: map['id'],
      userId: map['uid'],
      conversation: List<Map<String, dynamic>>.from(
          map['conversations'] ?? []), // Handle it as a list directly
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
