import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/auth/presentation/provider/auth_provider.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/features/group/data/models/message_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

final chatProvider = NotifierProvider.autoDispose<ChatNotifier, ChatState>(
  ChatNotifier.new,
);

class ChatNotifier extends AutoDisposeNotifier<ChatState> {
  StreamSubscription? _messageSubscription;

  @override
  ChatState build() {
    ref.onDispose(() {
      unsubscribe();
    });
    return ChatState();
  }

  // Subscribe to real-time messages
  void subscribeToMessages({required String groupId}) {
    final supabase = ref.read(supabaseClientProvider);

    unsubscribe();
    _loadMessages(groupId);
    _loadMembers(groupId);

    // ✅ FIXED: Use lowercase column names
    _messageSubscription = supabase
        .from('Message')
        .stream(primaryKey: ['id'])
        .eq('recieverId', groupId) // ✅ lowercase
        .order('created_at')
        .listen((List<Map<String, dynamic>> data) {
          try {
            final messages = data.map((m) => MessageModel.fromMap(m)).toList();
            state = state.copyWith(messages: messages);
          } catch (e) {
            Log.error("Error processing message stream: $e");
          }
        });

    Log.info("Subscribed to messages for group: $groupId");
  }

  Future<void> _loadMessages(String groupId) async {
    final supabase = ref.read(supabaseClientProvider);

    try {
      // ✅ FIXED: Use lowercase column name
      final response = await supabase
          .from('Message')
          .select()
          .eq('recieverId', groupId) // ✅ lowercase
          .order('created_at', ascending: true);

      final messages = (response as List)
          .map((m) => MessageModel.fromMap(m))
          .toList();

      state = state.copyWith(messages: messages);
      Log.info("Loaded ${messages.length} messages");
    } catch (e) {
      Log.error("Error loading messages: $e");
    }
  }

  Future<void> _loadMembers(String groupId) async {
    final supabase = ref.read(supabaseClientProvider);

    try {
      final response = await supabase
          .from('Members')
          .select('''
            userId,
            role,
            User:userId (
              firstname,
              lastname,
              image
            )
          ''')
          .eq('groupId', groupId)
          .eq('isActive', true);

      final members = (response as List).map((m) {
        final userData = m['User'] as Map<String, dynamic>?;
        final firstName = userData?['firstname'] as String?;
        final lastName = userData?['lastname'] as String?;
        final fullName = [
          firstName,
          lastName,
        ].where((n) => n != null && n.isNotEmpty).join(' ');

        return MemberModel.fromChatMap(m);
      }).toList();

      state = state.copyWith(members: members);
      Log.info("Loaded ${members.length} members");
    } catch (e) {
      Log.error("Error loading members: $e");
    }
  }

  // ✅ FIXED: Send message with correct column names
  Future<bool> sendMessage({
    required String groupId,
    required String content,
  }) async {
    final supabase = ref.read(supabaseClientProvider);
    final currentUser = ref.read(authProvider).user;

    if (currentUser == null) {
      Log.error("Cannot send message: User not authenticated");
      return false;
    }

    try {
      final messageId = Uuid().v4();

      // ✅ FIXED: Use lowercase column names matching your DB
      await supabase.from('Message').insert({
        'id': messageId,
        'senderid': currentUser.id, // ✅ lowercase
        'recieverId': groupId, // ✅ lowercase
        'message': content, // ✅ 'message' not 'content'
        'created_at': DateTime.now().toIso8601String(),
      });

      Log.info("Message sent successfully");
      return true;
    } catch (e) {
      Log.error("Error sending message: $e");
      return false;
    }
  }

  Future<bool> deleteMessage({required String messageId}) async {
    final supabase = ref.read(supabaseClientProvider);

    try {
      await supabase.from('Message').delete().eq('id', messageId);
      Log.info("Message deleted: $messageId");
      return true;
    } catch (e) {
      Log.error("Error deleting message: $e");
      return false;
    }
  }

  void unsubscribe() {
    _messageSubscription?.cancel();
    _messageSubscription = null;
    Log.info("Unsubscribed from messages");
  }
}

class ChatState {
  final List<MessageModel> messages;
  final List<MemberModel> members;
  final bool isLoading;
  final String? error;

  ChatState({
    this.messages = const [],
    this.members = const [],
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<MessageModel>? messages,
    List<MemberModel>? members,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      members: members ?? this.members,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
