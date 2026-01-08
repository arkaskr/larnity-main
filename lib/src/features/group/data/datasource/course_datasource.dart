import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:larnity/src/core/error/failures.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/group/data/models/course_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final courseDataSourceProvider = Provider<CourseDataSource>((ref) {
  return CourseDataSource(supabaseClient: ref.watch(supabaseClientProvider));
});

class CourseDataSource {
  final SupabaseClient supabaseClient;

  CourseDataSource({required this.supabaseClient});

  Future<Either<Failure, CourseModel>> createCourse({
    required CourseModel course,
  }) async {
    try {
      final response = await supabaseClient
          .from('Course')
          .insert(course.toMap())
          .select()
          .single();

      Log.info("Create Course Response: ${response.toString()}");

      return Right(CourseModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Create Course Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Create Course Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, CourseModel>> getCourse({required String id}) async {
    try {
      final response = await supabaseClient
          .from('Course')
          .select()
          .eq('id', id)
          .single();

      return Right(CourseModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Get Course Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Course Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<CourseModel>>> getCoursesByGroup({
    required String groupId,
  }) async {
    try {
      final response = await supabaseClient
          .from('Course')
          .select()
          .eq('groupId', groupId)
          .order('created_at', ascending: false);

      final courses = response
          .map((data) => CourseModel.fromMap(data))
          .toList();

      return Right(courses);
    } on PostgrestException catch (e) {
      Log.error("Get Courses by Group Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Courses by Group Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, CourseModel>> updateCourse({
    required CourseModel course,
  }) async {
    try {
      final response = await supabaseClient
          .from('Course')
          .update(course.toMap())
          .eq('id', course.id ?? "")
          .select()
          .single();

      Log.info("Update Course Response: ${response.toString()}");

      return Right(CourseModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Update Course Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Update Course Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, void>> deleteCourse({required String id}) async {
    try {
      await supabaseClient.from('Course').delete().eq('id', id);

      Log.info("Delete Course Success for ID: $id");

      return const Right(null);
    } on PostgrestException catch (e) {
      Log.error("Delete Course Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Delete Course Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }
}
