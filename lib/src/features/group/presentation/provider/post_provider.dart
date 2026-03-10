import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/group/data/datasource/post_datasource.dart';
import 'package:larnity/src/features/group/data/models/post_model.dart';
import 'package:larnity/src/features/explore/data/datasource/notification_datasource.dart';
import 'package:larnity/src/features/explore/data/models/notification_model.dart';
import 'package:larnity/src/features/group/data/datasource/group_datasource.dart';
import 'package:larnity/src/features/auth/presentation/provider/auth_provider.dart';
import 'package:uuid/uuid.dart';

final postProvider = ChangeNotifierProvider<PostProvider>((ref) {
  return PostProvider(
    ref.watch(postDataSourceProvider),
    ref.watch(notificationDataSourceProvider),
    ref.watch(groupDataSourceProvider),
    ref,
  );
});

class PostProvider extends ChangeNotifier {
  final PostDataSource _postDataSource;
  final NotificationDataSource _notificationDataSource;
  final GroupDataSource _groupDataSource;
  final Ref _ref;

  PostProvider(
    this._postDataSource,
    this._notificationDataSource,
    this._groupDataSource,
    this._ref,
  );

  List<PostModel> _posts = [];
  List<PostModel> get posts => _posts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Create Post
  Future<bool> createPost(PostModel post) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _postDataSource.createPost(post: post);

      return result.fold(
        (failure) {
          Log.error("Create Post Failed: ${failure.message}");
          _isLoading = false;
          _errorMessage = failure.message;
          notifyListeners();
          return false;
        },
        (createdPost) async {
          Log.info("Post created successfully: ${createdPost.id}");
          
          // Create notifications for group members
          await _createPostNotifications(createdPost);
          
          await fetchPosts(post.channelId);
          _isLoading = false;
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Fetch Posts by Channel
  Future<void> fetchPosts(String channelId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _postDataSource.getPostsByChannel(
        channelId: channelId,
      );

      result.fold(
        (failure) {
          Log.error("Fetch Posts Failed: ${failure.message}");
          _isLoading = false;
          _errorMessage = failure.message;
          notifyListeners();
        },
        (posts) {
          _posts = posts;
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Update Post
  Future<bool> updatePost(PostModel post) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _postDataSource.updatePost(post: post);

      return result.fold(
        (failure) {
          Log.error("Update Post Failed: ${failure.message}");
          _isLoading = false;
          _errorMessage = failure.message;
          notifyListeners();
          return false;
        },
        (updatedPost) async {
          Log.info("Post updated successfully: ${updatedPost.id}");
          await fetchPosts(post.channelId);
          _isLoading = false;
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete Post
  Future<bool> deletePost(String postId, String channelId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _postDataSource.deletePost(id: postId);

      return result.fold(
        (failure) {
          Log.error("Delete Post Failed: ${failure.message}");
          _isLoading = false;
          _errorMessage = failure.message;
          notifyListeners();
          return false;
        },
        (_) async {
          Log.info("Post deleted successfully");
          await fetchPosts(channelId);
          _isLoading = false;
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Create notifications for all group members when post is created
  Future<void> _createPostNotifications(PostModel post) async {
    try {
      final currentUserId = _ref.read(authProvider).user?.id;
      if (currentUserId == null) {
        Log.error("❌ Cannot create notifications: User not authenticated");
        return;
      }

      // Step 1: Get groupId from channelId
      final channelResponse = await _groupDataSource.supabaseClient
          .from('Channel')
          .select('groupId')
          .eq('id', post.channelId)
          .single();
      
      final groupId = channelResponse['groupId'] as String?;
      if (groupId == null) {
        Log.error("❌ Cannot create notifications: No groupId found for channel");
        return;
      }

      // Step 2: Get all group members
      final membersResult = await _groupDataSource.getGroupMembers(groupId: groupId);
      
      await membersResult.fold(
        (failure) async {
          Log.error("❌ Failed to fetch group members: ${failure.message}");
        },
        (members) async {
          Log.info("👥 Creating notifications for ${members.length} members");
          
          // Step 3: Create NotificationBatch entry
          final batchId = const Uuid().v4();
          await _groupDataSource.supabaseClient
              .from('NotificationBatches')
              .insert({
            'id': batchId,
            'groupId': groupId,
            'type': 'post_created',
            'content': {
              'title': '📝 New Post',
              'description': 'New post: "${post.title}"',
            },
            'status': 'pending',
            'actionItemId': post.id,
          });

          // Step 4: Create individual notifications for each member (including author for testing)
          int notificationCount = 0;
          int failedCount = 0;
          for (final member in members) {
            Log.info("🔍 Member: userId=${member.userId}, current user=$currentUserId");

            final notification = NotificationModel(
              id: const Uuid().v4(),
              createdAt: DateTime.now(),
              recipientId: member.userId,
              content: {
                'title': '📝 New Post',
                'body': member.userId == currentUserId 
                    ? 'You created a new post: "${post.title}"'
                    : 'New post in your group: "${post.title}"',
              },
              isRead: false,
              type: NotificationType.group_update,
              actorId: currentUserId,
              groupId: groupId,
              actionItemId: post.id,
            );

            Log.info("📤 Creating notification for recipient: ${member.userId}");

            final result = await _notificationDataSource.createNotificationViaRPC(
              notification: notification,
            );
            
            result.fold(
              (failure) {
                // Silently handle RLS errors - this is expected
                failedCount++;
                Log.error("❌ Failed to create notification: ${failure.message}");
              },
              (_) {
                notificationCount++;
              },
            );
          }

          // Step 5: Update batch status to completed
          await _groupDataSource.supabaseClient
              .from('NotificationBatches')
              .update({'status': 'completed'})
              .eq('id', batchId);

          Log.info("✅ Created $notificationCount notifications for post: ${post.id}");
        },
      );
    } catch (e) {
      Log.error("❌ Failed to create post notifications: $e");
    }
  }

  /// TEST: Create a test notification for current user
  Future<void> createTestNotification() async {
    try {
      final currentUserId = _ref.read(authProvider).user?.id;
      if (currentUserId == null) {
        Log.error("❌ Cannot create test notification: User not authenticated");
        return;
      }

      final notification = NotificationModel(
        id: const Uuid().v4(),
        createdAt: DateTime.now(),
        recipientId: currentUserId, // Send to yourself for testing
        content: {
          'title': '🧪 Test Notification',
          'body': 'This is a test notification to verify the system is working!',
        },
        isRead: false,
        type: NotificationType.system_alert,
        actorId: currentUserId,
      );

      final result = await _notificationDataSource.createNotificationViaRPC(
        notification: notification,
      );

      result.fold(
        (failure) => Log.error("❌ Failed to create test notification: ${failure.message}"),
        (_) => Log.info("✅ Test notification created successfully!"),
      );
    } catch (e) {
      Log.error("❌ Failed to create test notification: $e");
    }
  }
}
