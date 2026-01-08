import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:larnity/src/core/error/failures.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/group/data/models/resource_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final resourceDataSourceProvider = Provider<ResourceDataSource>((ref) {
  return ResourceDataSource(supabaseClient: ref.watch(supabaseClientProvider));
});

class ResourceDataSource {
  final SupabaseClient supabaseClient;

  ResourceDataSource({required this.supabaseClient});

  Future<Either<Failure, ResourceModel>> createResource({
    required ResourceModel resource,
  }) async {
    try {
      final response = await supabaseClient
          .from('Resource')
          .insert(resource.toMap())
          .select()
          .single();

      Log.info("Create Resource Response: ${response.toString()}");

      return Right(ResourceModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Create Resource Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Create Resource Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, ResourceModel>> getResource({
    required String id,
  }) async {
    try {
      final response = await supabaseClient
          .from('Resource')
          .select()
          .eq('id', id)
          .single();

      return Right(ResourceModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Get Resource Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Resource Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<ResourceModel>>> getResourcesByGroup({
    required String groupId,
  }) async {
    try {
      final response = await supabaseClient
          .from('Resource')
          .select()
          .eq('groupId', groupId)
          .order('created_at', ascending: false);

      final resources = response
          .map((data) => ResourceModel.fromMap(data))
          .toList();

      return Right(resources);
    } on PostgrestException catch (e) {
      Log.error("Get Resources by Group Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Resources by Group Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, ResourceModel>> updateResource({
    required ResourceModel resource,
  }) async {
    try {
      final response = await supabaseClient
          .from('Resource')
          .update(resource.toMap())
          .eq('id', resource.id ?? "")
          .select()
          .single();

      Log.info("Update Resource Response: ${response.toString()}");

      return Right(ResourceModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Update Resource Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Update Resource Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, void>> deleteResource({required String id}) async {
    try {
      await supabaseClient.from('Resource').delete().eq('id', id);

      Log.info("Delete Resource Success for ID: $id");

      return const Right(null);
    } on PostgrestException catch (e) {
      Log.error("Delete Resource Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Delete Resource Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }
}
