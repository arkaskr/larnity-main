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
  bool _isDisposed = false; // ✅ ADD THIS FLAG
  String? _currentGroupId; // ✅ Track current group

  @override
  ChatState build() {
    ref.onDispose(() {
      _isDisposed = true; // ✅ Mark as disposed
      unsubscribe();
    });
    return ChatState();
  }

  // ✅ FIXED: Safe state updates
  void _updateState(ChatState Function(ChatState) update) {
    if (!_isDisposed) {
      state = update(state);
    }
  }

  // Subscribe to real-time messages
  void subscribeToMessages({required String groupId}) {
    if (_isDisposed) return; // ✅ Safety check

    // ✅ Prevent duplicate subscriptions
    if (_currentGroupId == groupId && _messageSubscription != null) {
      Log.info("Already subscribed to group: $groupId");
      return;
    }

    final supabase = ref.read(supabaseClientProvider);

    unsubscribe();
    _currentGroupId = groupId; // ✅ Set current group
    _loadMessages(groupId);
    _loadMembers(groupId);

    _messageSubscription = supabase
        .from('Message')
        .stream(primaryKey: ['id'])
        .eq('recieverId', groupId)
        .order('created_at')
        .listen(
          (List<Map<String, dynamic>> data) {
            if (_isDisposed) return; // ✅ Check before update

            try {
              final messages = data
                  .map((m) => MessageModel.fromMap(m))
                  .toList();
              _updateState((s) => s.copyWith(messages: messages));
            } catch (e) {
              Log.error("Error processing message stream: $e");
            }
          },
          onError: (error) {
            Log.error("Stream error: $error");
          },
          cancelOnError: false,
        );

    Log.info("Subscribed to messages for group: $groupId");
  }

  Future<void> _loadMessages(String groupId) async {
    if (_isDisposed) return; // ✅ Safety check

    final supabase = ref.read(supabaseClientProvider);

    try {
      final response = await supabase
          .from('Message')
          .select()
          .eq('recieverId', groupId)
          .order('created_at', ascending: true);

      if (_isDisposed) return; // ✅ Check after async

      final messages = (response as List)
          .map((m) => MessageModel.fromMap(m))
          .toList();

      _updateState((s) => s.copyWith(messages: messages));
      Log.info("Loaded ${messages.length} messages");
    } catch (e) {
      Log.error("Error loading messages: $e");
    }
  }

  Future<void> _loadMembers(String groupId) async {
    if (_isDisposed) return; // ✅ Safety check

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

      if (_isDisposed) return; // ✅ Check after async

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

      _updateState((s) => s.copyWith(members: members));
      Log.info("Loaded ${members.length} members");
    } catch (e) {
      Log.error("Error loading members: $e");
    }
  }

  Future<bool> sendMessage({
    required String groupId,
    required String content,
  }) async {
    if (_isDisposed) return false; // ✅ Safety check

    final supabase = ref.read(supabaseClientProvider);
    final currentUser = ref.read(authProvider).user;

    if (currentUser == null) {
      Log.error("Cannot send message: User not authenticated");
      return false;
    }

    try {
      final messageId = Uuid().v4();

      await supabase.from('Message').insert({
        'id': messageId,
        'senderid': currentUser.id,
        'recieverId': groupId,
        'message': content,
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
    if (_isDisposed) return false; // ✅ Safety check

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
    _currentGroupId = null; // ✅ Clear group ID
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
