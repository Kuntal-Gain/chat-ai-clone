// ignore_for_file: empty_catches

import 'dart:convert';
import 'package:chat_app/data/models/chat_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatDb {
  final db = Supabase.instance.client.from("Chats");
  final userDb = Supabase.instance.client.from("Users");

  Future<void> createChat(ChatModel chat) async {
    try {
      final response = await db.insert(chat.toMap()).select("id").single();
      final newChatId = response['id'] as int; // Ensure `id` is an integer

      chat.id = newChatId;

      final userResponse =
          await userDb.select("chat_ids").eq("id", chat.userId).single();
      final currentChatIds =
          List<dynamic>.from(userResponse['chat_ids'] ?? []).cast<String>();

      currentChatIds.add(newChatId.toString());

      await userDb.update({"chat_ids": currentChatIds}).eq("id", chat.userId);
    } catch (e) {}
  }

  Future<void> sendMessage(String chatId, int userId, String message) async {
    try {
      final response = await db.select().eq("id", chatId).single();

      final conversation = List<Map<String, dynamic>>.from(
        response['conversations'] ?? [],
      );

      conversation.add({"user": userId, "message": message});

      await db.update({'conversations': conversation}).eq("id", chatId);
    } catch (e) {}
  }

  Future<void> botResponse(String chatId, String message) async {
    try {
      final response = await db.select().eq("id", chatId).single();

      final conversation = List<Map<String, dynamic>>.from(
        response['conversations'] ?? [],
      );

      conversation.add({"user": "bot", "message": message});

      await db.update({'conversations': conversation}).eq("id", chatId);
    } catch (e) {}
  }

  Future<void> updateChat(
      String chatId, List<Map<String, dynamic>> updatedConversation) async {
    try {
      await db.update({'conversations': jsonEncode(updatedConversation)}).eq(
          "id", chatId);
    } catch (e) {}
  }

  Future<List<ChatModel>> getChats(int userId) async {
    try {
      final response = await db.select().eq("uid", userId);
      return (response as List<dynamic>)
          .map((chat) => ChatModel.fromMap(chat as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<ChatModel?> getChatById(String chatId) async {
    try {
      final response = await db.select().eq("id", chatId).single();
      return ChatModel.fromMap(response);
    } catch (e) {
      return null;
    }
  }

  Future<int?> getLastChatId() async {
    try {
      final response = await db
          .select('id')
          .order('createdAt', ascending: false)
          .limit(1)
          .single();

      if (response['id'] != null) {
        return response['id'] as int;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Stream chats
  final stream = Supabase.instance.client.from('Chats').stream(
    primaryKey: ['id'],
  ).map((data) => data.map((chatMp) => ChatModel.fromMap(chatMp)).toList());
}
