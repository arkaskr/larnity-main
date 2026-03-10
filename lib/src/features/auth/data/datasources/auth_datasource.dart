import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:larnity/src/core/error/exceptions.dart';
import 'package:larnity/src/core/error/failures.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authDataSourceProvider = Provider<AuthDatasource>((ref) {
  return AuthDatasource(supabaseClient: ref.watch(supabaseClientProvider));
});

class AuthDatasource {
  final SupabaseClient supabaseClient;

  AuthDatasource({required this.supabaseClient});

  Session? get currentUserSession => supabaseClient.auth.currentSession;

  Future<Either<Failure, UserModel>> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        password: password,
        email: email,
      );
      if (response.user == null) {
        return left(Failure("User is null"));
      }
      return right(UserModel.fromMap(response.user!.toJson()));
    } on AuthException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, UserModel>> signUpWithEmailPassword({
    required UserModel user,
    required String password,
  }) async {
    Log.info("${user.firstName} || ${user.lastName}");
    try {
      final response = await supabaseClient.auth.signUp(
        password: password,
        email: user.email,
        data: {"firstname": user.firstName, "lastname": user.lastName},
      );
      if (response.user == null) {
        return left(Failure("User is null"));
      }
      return right(UserModel.fromMap(response.user!.toJson()));
    } on AuthException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // In your AuthDataSource class
  Future<Either<Failure, bool>> sendEmailConfirmation({
    required String email,
  }) async {
    Log.info("Email: $email");
    try {
      final response = await supabaseClient.auth.resend(
        type: OtpType.email,
        email: email,
      );

      Log.info("Send email response: ${response.toString()}");

      if (response != null) {
        return const Right(true);
      } else {
        return Left(Failure('Failed to send confirmation email'));
      }
    } on AuthException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Send email failure: ${e.toString()}");
      return Left(Failure('${e.toString()}'));
    }
  }

  Future<Either<Failure, UserModel?>> getCurrentUserData() async {
    try {
      if (currentUserSession != null) {
        final userData = await supabaseClient
            .from('profiles')
            .select()
            .eq('id', currentUserSession!.user.id);
        return right(
          UserModel.fromMap(
            userData.first,
          ).copyWith(email: currentUserSession!.user.email),
        );
      } else {
        return left(Failure("No user found"));
      }
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, bool>> loginWithGoogle() async {
    try {
      await supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.larnity://login-callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      // OAuth flow launched successfully
      // The actual session will be handled by auth state listener
      return right(true);
    } on AuthException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      Log.error("Google login failure: ${e.toString()}");
      return left(Failure(e.toString()));
    }
  }
}
