import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:larnity/src/core/error/failures.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/group/data/models/class_schedule_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final classScheduleDataSourceProvider = Provider<ClassScheduleDataSource>((
  ref,
) {
  return ClassScheduleDataSource(
    supabaseClient: ref.watch(supabaseClientProvider),
  );
});

class ClassScheduleDataSource {
  final SupabaseClient supabaseClient;

  ClassScheduleDataSource({required this.supabaseClient});

  Future<Either<Failure, ClassScheduleModel>> createClass({
    required ClassScheduleModel classSchedule,
  }) async {
    try {
      final response = await supabaseClient
          .from('ClassSchedule')
          .insert(classSchedule.toMap())
          .select()
          .single();

      return Right(ClassScheduleModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Create Class Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Create Class Error: $e");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<ClassScheduleModel>>> getClassesByGroup({
    required String groupId,
  }) async {
    try {
      final response = await supabaseClient
          .from('ClassSchedule')
          .select()
          .eq('groupId', groupId)
          .order('eventDate', ascending: true);

      final classes = response
          .map((data) => ClassScheduleModel.fromMap(data))
          .toList();

      return Right(classes);
    } on PostgrestException catch (e) {
      Log.error("Get Classes Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Classes Error: $e");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, void>> deleteClass({required String id}) async {
    try {
      await supabaseClient.from('ClassSchedule').delete().eq('id', id);
      return const Right(null);
    } on PostgrestException catch (e) {
      Log.error("Delete Class Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Delete Class Error: $e");
      return Left(Failure(e.toString()));
    }
  }
}
