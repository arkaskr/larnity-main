import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:larnity/src/core/error/failures.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/group/data/models/supporter_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supporterDataSourceProvider = Provider<SupporterDataSource>((ref) {
  return SupporterDataSource(supabaseClient: ref.watch(supabaseClientProvider));
});

class SupporterDataSource {
  final SupabaseClient supabaseClient;

  SupporterDataSource({required this.supabaseClient});

  Future<Either<Failure, SupporterModel>> createSupporter({
    required SupporterModel supporter,
  }) async {
    try {
      final response = await supabaseClient
          .from('Supporter')
          .insert(supporter.toMap())
          .select()
          .single();

      Log.info("Create Supporter Response: ${response.toString()}");

      return Right(SupporterModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Create Supporter Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Create Supporter Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, SupporterModel>> getSupporter({
    required String id,
  }) async {
    try {
      final response = await supabaseClient
          .from('Supporter')
          .select()
          .eq('id', id)
          .single();

      return Right(SupporterModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Get Supporter Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Supporter Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<SupporterModel>>> getSupportersByGroup({
    required String groupId,
  }) async {
    try {
      final response = await supabaseClient
          .from('Supporter')
          .select()
          .eq('groupId', groupId)
          .order('created_at', ascending: false);

      final supporters = response
          .map((data) => SupporterModel.fromMap(data))
          .toList();

      return Right(supporters);
    } on PostgrestException catch (e) {
      Log.error("Get Supporters by Group Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Supporters by Group Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, SupporterModel>> updateSupporter({
    required SupporterModel supporter,
  }) async {
    try {
      final response = await supabaseClient
          .from('Supporter')
          .update(supporter.toMap())
          .eq('id', supporter.id ?? "")
          .select()
          .single();

      Log.info("Update Supporter Response: ${response.toString()}");

      return Right(SupporterModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Update Supporter Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Update Supporter Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, void>> deleteSupporter({required String id}) async {
    try {
      await supabaseClient.from('Supporter').delete().eq('id', id);

      Log.info("Delete Supporter Success for ID: $id");

      return const Right(null);
    } on PostgrestException catch (e) {
      Log.error("Delete Supporter Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Delete Supporter Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }
}
