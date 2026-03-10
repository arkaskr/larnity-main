import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:larnity/src/core/error/failures.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/group/data/models/promotion_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final promotionDataSourceProvider = Provider<PromotionDataSource>((ref) {
  return PromotionDataSource(supabaseClient: ref.watch(supabaseClientProvider));
});

class PromotionDataSource {
  final SupabaseClient supabaseClient;

  PromotionDataSource({required this.supabaseClient});

  Future<Either<Failure, PromotionModel>> createPromotion({
    required PromotionModel promotion,
  }) async {
    try {
      final response = await supabaseClient
          .from('PromoCode')
          .insert(promotion.toMap())
          .select()
          .single();

      Log.info("Create Promotion Response: ${response.toString()}");

      return Right(PromotionModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Create Promotion Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Create Promotion Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, PromotionModel>> getPromotion({
    required String id,
  }) async {
    try {
      final response = await supabaseClient
          .from('PromoCode')
          .select()
          .eq('id', id)
          .single();

      return Right(PromotionModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Get Promotion Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Promotion Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<PromotionModel>>> getPromotionsByGroup({
    required String groupId,
  }) async {
    try {
      final response = await supabaseClient
          .from('PromoCode')
          .select()
          .eq('groupId', groupId)
          .order('created_at', ascending: false);

      final promotions = (response as List)
          .map((data) => PromotionModel.fromMap(data))
          .toList();

      return Right(promotions);
    } on PostgrestException catch (e) {
      Log.error("Get Promotions by Group Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Promotions by Group Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<PromotionModel>>> getActivePromotionsByGroup({
    required String groupId,
  }) async {
    try {
      final response = await supabaseClient
          .from('PromoCode')
          .select()
          .eq('groupId', groupId)
          .eq('isActive', true)
          .order('created_at', ascending: false);

      final promotions = (response as List)
          .map((data) => PromotionModel.fromMap(data))
          .toList();

      return Right(promotions);
    } on PostgrestException catch (e) {
      Log.error("Get Active Promotions by Group Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Active Promotions by Group Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<PromotionModel>>> getAllActivePromotions() async {
    try {
      final response = await supabaseClient
          .from('PromoCode')
          .select()
          .eq('isActive', true)
          .order('created_at', ascending: false);

      final promotions = (response as List)
          .map((data) => PromotionModel.fromMap(data))
          .toList();

      return Right(promotions);
    } on PostgrestException catch (e) {
      Log.error("Get All Active Promotions Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get All Active Promotions Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, PromotionModel>> updatePromotionStatus({
    required String id,
    required bool isActive,
  }) async {
    try {
      final response = await supabaseClient
          .from('PromoCode')
          .update({'isActive': isActive})
          .eq('id', id)
          .select()
          .single();

      Log.info("Update Promotion Status Response: ${response.toString()}");

      return Right(PromotionModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Update Promotion Status Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Update Promotion Status Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, void>> deletePromotion({required String id}) async {
    try {
      await supabaseClient.from('PromoCode').delete().eq('id', id);

      Log.info("Delete Promotion Success for ID: $id");

      return const Right(null);
    } on PostgrestException catch (e) {
      Log.error("Delete Promotion Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Delete Promotion Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }
}
