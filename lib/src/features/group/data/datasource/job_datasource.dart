import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:larnity/src/core/error/failures.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/group/data/models/job_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final jobDataSourceProvider = Provider<JobDataSource>((ref) {
  return JobDataSource(supabaseClient: ref.watch(supabaseClientProvider));
});

class JobDataSource {
  final SupabaseClient supabaseClient;

  JobDataSource({required this.supabaseClient});

  Future<Either<Failure, JobModel>> createJob({required JobModel job}) async {
    try {
      final response = await supabaseClient
          .from('Job')
          .insert(job.toMap())
          .select()
          .single();

      Log.info("Create Job Response: ${response.toString()}");

      return Right(JobModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Create Job Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Create Job Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, JobModel>> getJob({required String id}) async {
    try {
      final response = await supabaseClient
          .from('Job')
          .select()
          .eq('id', id)
          .single();

      return Right(JobModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Get Job Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Job Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<JobModel>>> getJobsByGroup({
    required String groupId,
  }) async {
    try {
      final response = await supabaseClient
          .from('Job')
          .select()
          .eq('groupId', groupId)
          .order('created_at', ascending: false);

      final jobs = response.map((data) => JobModel.fromMap(data)).toList();

      return Right(jobs);
    } on PostgrestException catch (e) {
      Log.error("Get Jobs by Group Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Jobs by Group Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, JobModel>> updateJob({required JobModel job}) async {
    try {
      final response = await supabaseClient
          .from('Job')
          .update(job.toMap())
          .eq('id', job.id ?? "")
          .select()
          .single();

      Log.info("Update Job Response: ${response.toString()}");

      return Right(JobModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Update Job Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Update Job Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, void>> deleteJob({required String id}) async {
    try {
      await supabaseClient.from('Job').delete().eq('id', id);

      Log.info("Delete Job Success for ID: $id");

      return const Right(null);
    } on PostgrestException catch (e) {
      Log.error("Delete Job Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Delete Job Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }
}
