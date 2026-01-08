import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/group/data/datasource/post_datasource.dart';
import 'package:larnity/src/features/group/data/models/post_model.dart';

final postProvider = ChangeNotifierProvider<PostProvider>((ref) {
  return PostProvider(ref.watch(postDataSourceProvider));
});

class PostProvider extends ChangeNotifier {
  final PostDataSource _postDataSource;

  PostProvider(this._postDataSource);

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
}
