import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:larnity/src/core/error/failures.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/group/data/models/post_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final postDataSourceProvider = Provider<PostDataSource>((ref) {
  return PostDataSource(supabaseClient: ref.watch(supabaseClientProvider));
});

class PostDataSource {
  final SupabaseClient supabaseClient;

  PostDataSource({required this.supabaseClient});

  /// Create Post
  Future<Either<Failure, PostModel>> createPost({
    required PostModel post,
  }) async {
    try {
      final response = await supabaseClient
          .from('Post')
          .insert(post.toMap())
          .select()
          .single();

      Log.info("Create Post Response: ${response.toString()}");
      return Right(PostModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Create Post Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Create Post Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  /// Get Posts by Channel (Group)
  Future<Either<Failure, List<PostModel>>> getPostsByChannel({
    required String channelId,
  }) async {
    try {
      final response = await supabaseClient
          .from('Post')
          .select()
          .eq('channelId', channelId)
          .order('created_at', ascending: false);

      final posts = (response as List)
          .map((data) => PostModel.fromMap(data as Map<String, dynamic>))
          .toList();

      Log.info("Fetched ${posts.length} posts for channel $channelId");
      return Right(posts);
    } on PostgrestException catch (e) {
      Log.error("Get Posts by Channel Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Posts by Channel Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  /// Get Single Post
  Future<Either<Failure, PostModel>> getPost({required String id}) async {
    try {
      final response = await supabaseClient
          .from('Post')
          .select()
          .eq('id', id)
          .single();

      return Right(PostModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Get Post Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Post Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  /// Update Post
  Future<Either<Failure, PostModel>> updatePost({
    required PostModel post,
  }) async {
    try {
      final response = await supabaseClient
          .from('Post')
          .update(post.toMap())
          .eq('id', post.id ?? "")
          .select()
          .single();

      Log.info("Update Post Response: ${response.toString()}");
      return Right(PostModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Update Post Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Update Post Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, void>> deletePost({required String id}) async {
    try {
      await supabaseClient.from('Post').delete().eq('id', id);
      Log.info("Delete Post Success for ID: $id");
      return const Right(null);
    } on PostgrestException catch (e) {
      Log.error("Delete Post Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Delete Post Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }
}
