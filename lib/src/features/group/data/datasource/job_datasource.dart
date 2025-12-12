import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:larnity/src/core/error/failures.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_table.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/group/data/models/job_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final postDataSourceProvider = Provider<PostDataSource>((ref) {
  return PostDataSource(supabaseClient: ref.watch(supabaseClientProvider));
});

class PostDataSource {
  final SupabaseClient supabaseClient;

  PostDataSource({required this.supabaseClient});

  Future<Either<Failure, JobModel>> createPost({required JobModel post}) async {
    try {
      final response = await supabaseClient
          .from('posts') // Adjust table name as needed
          .insert(post.toMap())
          .select()
          .single();

      Log.info("Create Post Response: ${response.toString()}");

      return Right(JobModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Create Post Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Create Post Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, JobModel>> getPost({required String postId}) async {
    try {
      final response = await supabaseClient
          .from('posts')
          .select()
          .eq('id', postId) // Assuming there's an id field
          .single();

      return Right(JobModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Get Post Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Post Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<JobModel>>> getPostsByGroup({
    required String groupId,
    int limit = 50,
    int offset = 0,
    bool activeOnly = true,
  }) async {
    try {
      var query = supabaseClient
          .from('posts')
          .select()
          .eq('groupId', groupId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      if (activeOnly) {
        final now = DateTime.now().toIso8601String();
        // query = query.or('postingEndDate.is.null,postingEndDate.gt.${now}');
      }

      final response = await query;

      final posts = response.map((data) => JobModel.fromMap(data)).toList();

      return Right(posts);
    } on PostgrestException catch (e) {
      Log.error("Get Posts by Group Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Posts by Group Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<JobModel>>> getActivePosts({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await supabaseClient
          .from('posts')
          .select()
          .or('postingEndDate.is.null,postingEndDate.gt.${now}')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final posts = response.map((data) => JobModel.fromMap(data)).toList();

      return Right(posts);
    } on PostgrestException catch (e) {
      Log.error("Get Active Posts Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Active Posts Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<JobModel>>> getExpiredPosts({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await supabaseClient
          .from('posts')
          .select()
          .lt('postingEndDate', now)
          .order('postingEndDate', ascending: false)
          .range(offset, offset + limit - 1);

      final posts = response.map((data) => JobModel.fromMap(data)).toList();

      return Right(posts);
    } on PostgrestException catch (e) {
      Log.error("Get Expired Posts Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Expired Posts Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<JobModel>>>
  getPostsWithGoogleSheetIntegration() async {
    try {
      final response = await supabaseClient
          .from('posts')
          .select()
          .not('googleSheetId', 'is', 'null')
          .order('created_at', ascending: false);

      final posts = response.map((data) => JobModel.fromMap(data)).toList();

      return Right(posts);
    } on PostgrestException catch (e) {
      Log.error("Get Posts with Google Sheet Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Posts with Google Sheet Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, JobModel>> updatePost({required JobModel post}) async {
    try {
      final response = await supabaseClient
          .from('posts')
          .update(post.toMap())
          // .eq('id', post.id) // Assuming there's an id field
          .select()
          .single();

      Log.info("Update Post Response: ${response.toString()}");

      return Right(JobModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Update Post Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Update Post Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, JobModel>> updatePostGoogleSheet({
    required String postId,
    required String googleSheetId,
  }) async {
    try {
      final response = await supabaseClient
          .from('posts')
          .update({
            'googleSheetId': googleSheetId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', postId)
          .select()
          .single();

      Log.info("Update Post Google Sheet Response: ${response.toString()}");

      return Right(JobModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Update Post Google Sheet Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Update Post Google Sheet Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, void>> deletePost({required String postId}) async {
    try {
      await supabaseClient.from('posts').delete().eq('id', postId);

      Log.info("Delete Post Success for ID: $postId");

      return const Right(null);
    } on PostgrestException catch (e) {
      Log.error("Delete Post Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Delete Post Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, void>> deletePostsByGroup({
    required String groupId,
  }) async {
    try {
      await supabaseClient.from('posts').delete().eq('groupId', groupId);

      Log.info("Delete Posts by Group Success for Group ID: $groupId");

      return const Right(null);
    } on PostgrestException catch (e) {
      Log.error("Delete Posts by Group Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Delete Posts by Group Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  // Real-time subscription for posts
  Stream<List<JobModel>> subscribeToGroupPosts(String groupId) {
    return supabaseClient
        .from('posts')
        .stream(primaryKey: ['id'])
        .eq('groupId', groupId)
        .order('created_at', ascending: false)
        .map((data) => data.map((item) => JobModel.fromMap(item)).toList());
  }
}
