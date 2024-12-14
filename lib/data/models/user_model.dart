class UserModel {
  final int? id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final List<String> chatIds;
  final DateTime createdAt;

  UserModel({
    this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    required this.chatIds,
    required this.createdAt,
  });

  // User -> map
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'full_name': fullName,
      'avatar': avatarUrl,
      'chat_ids': chatIds,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// map -> User
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int,
      email: map['email'] as String,
      fullName: map['full_name'] as String?,
      avatarUrl: map['avatar'] as String?,
      chatIds: List<String>.from(map['chat_ids'] ?? []),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
