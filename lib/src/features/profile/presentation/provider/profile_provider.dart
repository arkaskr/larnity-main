import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/auth/data/models/user_model.dart';
import 'package:larnity/src/features/profile/data/datasource/profile_datasource.dart';

final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(
  ProfileNotifier.new,
);

class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    return const ProfileState(state: AsyncState.initial);
  }

  Future<void> createProfile({
    required UserModel user,
    void Function()? successCallBack,
    void Function()? failureCallBack,
  }) async {
    final dataSource = ref.read(profileDataSourceProvider);

    state = state.copyWith(state: AsyncState.loading);

    final response = await dataSource.createProfile(user: user);

    response.fold(
      (failure) {
        state = state.copyWith(
          state: AsyncState.failure,
          error: failure.message,
        );
        failureCallBack?.call();
      },
      (user) {
        state = state.copyWith(state: AsyncState.success, user: user);
        successCallBack?.call();
      },
    );
  }

  // profile_provider.dart - Add this method
  Future<void> updateProfile({
    required UserModel user,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final dataSource = ref.read(profileDataSourceProvider);

    state = state.copyWith(state: AsyncState.loading);

    final response = await dataSource.updateProfile(user: user);

    response.fold(
      (failure) {
        state = state.copyWith(
          state: AsyncState.failure,
          error: failure.message,
        );
        failureCallBack?.call(failure.message);
      },
      (user) {
        state = state.copyWith(state: AsyncState.success, user: user);
        successCallBack?.call();
      },
    );
  }
}

class ProfileState {
  final AsyncState state;
  final String? error;
  final UserModel? user;

  const ProfileState({required this.state, this.error, this.user});

  ProfileState copyWith({AsyncState? state, String? error, UserModel? user}) {
    return ProfileState(
      state: state ?? this.state,
      error: error ?? this.error,
      user: user ?? this.user,
    );
  }
}
