import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:larnity/src/core/error/exceptions.dart';
import 'package:larnity/src/core/error/failures.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_table.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final profileDataSourceProvider = Provider<ProfileDataSource>((ref) {
  return ProfileDataSource(supabaseClient: ref.watch(supabaseClientProvider));
});

class ProfileDataSource {
  final SupabaseClient supabaseClient;
  ProfileDataSource({required this.supabaseClient});

  Future<Either<Failure, UserModel>> createProfile({
    required UserModel user,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.profiles)
          .insert(user.toMap())
          .select();

      Log.info("Create Profile Response: ${response.first.toString()}");

      return right(UserModel.fromMap(response.first));
    } on PostgrestException catch (e) {
      Log.info("Create Profile Error: ${e.message}");
      return left(Failure(e.message));
    } catch (e) {
      Log.info("Create Profile Error: ${e.toString()}");
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> getUser({required String id}) async {
    try {
      final userData = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', id);
      return right(UserModel.fromMap(userData.first));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
