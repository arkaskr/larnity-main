import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:larnity/src/core/error/failures.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/group/data/models/product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final productDataSourceProvider = Provider<ProductDataSource>((ref) {
  return ProductDataSource(supabaseClient: ref.watch(supabaseClientProvider));
});

class ProductDataSource {
  final SupabaseClient supabaseClient;

  ProductDataSource({required this.supabaseClient});

  Future<Either<Failure, ProductModel>> createProduct({
    required ProductModel product,
  }) async {
    try {
      final response = await supabaseClient
          .from('ProductAndService')
          .insert(product.toMap())
          .select()
          .single();

      Log.info("Create Product Response: ${response.toString()}");

      return Right(ProductModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Create Product Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Create Product Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, ProductModel>> getProduct({required String id}) async {
    try {
      final response = await supabaseClient
          .from('ProductAndService')
          .select()
          .eq('id', id)
          .single();

      return Right(ProductModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Get Product Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Product Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<ProductModel>>> getProductsByGroup({
    required String groupId,
  }) async {
    try {
      final response = await supabaseClient
          .from('ProductAndService')
          .select()
          .eq('groupId', groupId)
          .order('created_at', ascending: false);

      final products = response
          .map((data) => ProductModel.fromMap(data))
          .toList();

      return Right(products);
    } on PostgrestException catch (e) {
      Log.error("Get Products by Group Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Products by Group Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, ProductModel>> updateProduct({
    required ProductModel product,
  }) async {
    try {
      final response = await supabaseClient
          .from('ProductAndService')
          .update(product.toMap())
          .eq('id', product.id ?? "")
          .select()
          .single();

      Log.info("Update Product Response: ${response.toString()}");

      return Right(ProductModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Update Product Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Update Product Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, void>> deleteProduct({required String id}) async {
    try {
      await supabaseClient.from('ProductAndService').delete().eq('id', id);

      Log.info("Delete Product Success for ID: $id");

      return const Right(null);
    } on PostgrestException catch (e) {
      Log.error("Delete Product Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Delete Product Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }
}
