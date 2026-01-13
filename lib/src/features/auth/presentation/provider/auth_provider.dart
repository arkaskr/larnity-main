import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/auth/data/datasources/auth_datasource.dart';
import 'package:larnity/src/features/auth/data/models/user_model.dart';
import 'package:larnity/src/features/profile/presentation/provider/profile_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AuthState> {
  bool isLogin = true;
  String? signUpSuccessMessage;
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();

  @override
  AuthState build() {
    Log.info("AuthNotifier initialized");

    // Don't read providers in build - just return initial state
    // The actual auth check will happen after initialization
    Future.microtask(() {
      listenToAuthChanges();
      getCurrentUser();
    });
    // listenToAuthChanges();

    return AuthState(loginState: AsyncState.initial);
  }

  void toggleLogin() {
    isLogin = !isLogin;
    state = state.copyWith(isLogIn: isLogin);
  }

  // Future<void> checkAuthState() async {
  //   final supabaseClient = ref.read(supabaseClientProvider);

  //   state = state.copyWith(state: AsyncState.loading);

  //   try {
  //     final currentUser = supabaseClient.currentUser;
  //     final currentSession = supabaseClient.currentSession;

  //     if (currentUser != null && currentSession != null) {
  //       state = state.copyWith(
  //         state: AsyncState.success,
  //         user: currentUser,
  //         session: currentSession,
  //         isAuthenticated: true,
  //       );
  //       Log.info("User authenticated: ${currentUser.email}");
  //     } else {
  //       state = state.copyWith(
  //         state: AsyncState.success,
  //         user: null,
  //         session: null,
  //         isAuthenticated: false,
  //       );
  //       Log.info("No authenticated user found");
  //     }
  //   } catch (e) {
  //     state = state.copyWith(
  //       state: AsyncState.failure,
  //       error: 'Failed to check auth state: ${e.toString()}',
  //       isAuthenticated: false,
  //     );
  //     Log.error("Auth check failed: ${e.toString()}");
  //   }
  // }

  Future<void> getCurrentUser() async {
    Log.info("Get Current User");
    final datasource = ref.read(authDataSourceProvider);
    final res = await datasource.getCurrentUserData();

    res.fold(
      (failure) => state = state.copyWith(
        currentUserState: AsyncState.failure,
        isAuthenticated: false,
      ),
      (user) => state = state.copyWith(
        currentUserState: AsyncState.success,
        isAuthenticated: true,
        user: user,
      ),
    );
  }

  Future<void> signInWithEmail({
    void Function()? successCallBack,
    void Function()? failureCallBack,
  }) async {
    final datasource = ref.read(authDataSourceProvider);

    state = state.copyWith(loginState: AsyncState.loading);

    final response = await datasource.loginWithEmailPassword(
      email: emailController.text.trim(),
      password: passController.text.trim(),
    );

    response.fold(
      (failure) {
        Log.error(failure.message);

        state = state.copyWith(
          loginState: AsyncState.failure,
          error: failure.message,
        );
        if (failure.message == "Email not confirmed") {
          sendEmailConfirmation();
        }
        failureCallBack?.call();
      },
      (user) {
        state = state.copyWith(
          loginState: AsyncState.success,
          isAuthenticated: true,
          user: user,
        );
        successCallBack?.call();
      },
    );
  }

  // Add this method in AuthNotifier class (around line 235, after listenToAuthChanges)
  void updateUser(UserModel user) {
    state = state.copyWith(user: user);
    Log.info(
      "✅ User updated in auth state: ${user.firstName} ${user.lastName}",
    );
  }

  Future<void> signUpWithEmail({
    void Function()? failureCallBack,
    void Function()? successCallBack,
  }) async {
    final datasource = ref.read(authDataSourceProvider);

    state = state.copyWith(signupState: AsyncState.loading);

    final response = await datasource.signUpWithEmailPassword(
      user: UserModel(
        email: emailController.text.trim(),
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
      ),
      password: passController.text.trim(),
    );

    response.fold(
      (failure) {
        Log.error("Sign up error: ${failure.message}");
        state = state.copyWith(
          signupState: AsyncState.failure,
          error: failure.message,
          isAuthenticated: false,
        );
        failureCallBack?.call();
      },
      (user) async {
        // await ref.read(profileProvider.notifier).createProfile(user: user);
        successCallBack?.call();
        state = state.copyWith(
          signupState: AsyncState.success,
          isLogIn: true,
          signUpSuccessMessage:
              "Email is sent. Please confirm your email then log in with your credentials",
          user: user,
        );
        Log.info("Sign up user; ${user.toString()}");
      },
    );
  }

  Future<void> signOut({
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final supabaseClient = ref.read(supabaseClientProvider);

    state = state.copyWith(logoutState: AsyncState.loading);

    try {
      await supabaseClient.auth.signOut();

      state = state.copyWith(
        logoutState: AsyncState.success,
        user: null,
        session: null,
        isAuthenticated: false,
      );

      successCallBack?.call();
      Log.info("User signed out successfully");
    } catch (e) {
      final errorMessage = 'Sign out failed: ${e.toString()}';
      state = state.copyWith(
        logoutState: AsyncState.failure,
        error: errorMessage,
      );
      failureCallBack?.call(errorMessage);
      Log.error("Sign out failed: $errorMessage");
    }
  }

  Future<void> sendEmailConfirmation({
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final datasource = ref.read(authDataSourceProvider);

    state = state.copyWith(loginState: AsyncState.loading);

    try {
      final response = await datasource.sendEmailConfirmation(
        email: emailController.text.trim(),
      );

      response.fold(
        (failure) {
          state = state.copyWith(
            loginState: AsyncState.failure,
            error: failure.message,
          );
          failureCallBack?.call(failure.message);
          Log.error("Email confirmation send failed: ${failure.message}");
        },
        (success) {
          state = state.copyWith(
            loginState: AsyncState.success,
            signUpSuccessMessage:
                "Confirmation email sent successfully. Please check your inbox.",
          );
          successCallBack?.call();
          Log.info("Email confirmation sent successfully");
        },
      );
    } catch (e) {
      final errorMessage = 'Failed to send confirmation email: ${e.toString()}';
      state = state.copyWith(
        loginState: AsyncState.failure,
        error: errorMessage,
      );
      failureCallBack?.call(errorMessage);
      Log.error("Email confirmation send error: $errorMessage");
    }
  }

  // Future<void> resetPassword({
  //   required String email,
  //   void Function()? successCallBack,
  //   void Function(String error)? failureCallBack,
  // }) async {
  //   final supabaseClient = ref.read(supabaseClientProvider);

  //   state = state.copyWith(state: AsyncState.loading);

  //   try {
  //     await supabaseClient.auth.resetPasswordForEmail(email);

  //     state = state.copyWith(state: AsyncState.success);
  //     successCallBack?.call();
  //     Log.info("Password reset email sent to: $email");
  //   } catch (e) {
  //     final errorMessage = 'Password reset failed: ${e.toString()}';
  //     state = state.copyWith(state: AsyncState.failure, error: errorMessage);
  //     failureCallBack?.call(errorMessage);
  //     Log.error("Password reset failed: $errorMessage");
  //   }
  // }

  // Future<void> updateUserProfile({
  //   required Map<String, dynamic> updates,
  //   void Function()? successCallBack,
  //   void Function(String error)? failureCallBack,
  // }) async {
  //   final supabaseClient = ref.read(supabaseClientProvider);

  //   state = state.copyWith(state: AsyncState.loading);

  //   try {
  //     final response = await supabaseClient.auth.updateUser(
  //       UserAttributes(data: updates),
  //     );

  //     if (response.user != null) {
  //       state = state.copyWith(state: AsyncState.success, user: response.user);

  //       successCallBack?.call();
  //       Log.info("User profile updated successfully");
  //     } else {
  //       state = state.copyWith(
  //         state: AsyncState.failure,
  //         error: 'Profile update failed',
  //       );
  //       failureCallBack?.call('Profile update failed');
  //     }
  //   } catch (e) {
  //     final errorMessage = 'Profile update failed: ${e.toString()}';
  //     state = state.copyWith(state: AsyncState.failure, error: errorMessage);
  //     failureCallBack?.call(errorMessage);
  //     Log.error("Profile update failed: $errorMessage");
  //   }
  // }

  Future<void> signInWithGoogle({
    void Function()? successCallBack,
    void Function()? failureCallBack,
  }) async {
    final datasource = ref.read(authDataSourceProvider);

    state = state.copyWith(loginState: AsyncState.loading);

    final response = await datasource.loginWithGoogle();

    response.fold(
      (failure) {
        Log.error("Google login error: ${failure.message}");
        state = state.copyWith(
          loginState: AsyncState.failure,
          error: failure.message,
        );
        failureCallBack?.call();
      },
      (success) {
        // OAuth flow launched successfully
        // The actual session will be handled by listenToAuthChanges()
        // which will update the state when the user completes OAuth
        state = state.copyWith(loginState: AsyncState.loading);
        successCallBack?.call();
      },
    );
  }

  // Listen to auth state changes
  void listenToAuthChanges() {
    final supabaseClient = ref.read(supabaseClientProvider);

    supabaseClient.auth.onAuthStateChange.listen((authState) {
      Log.info("Auth state changed: ${authState.event}");

      switch (authState.event) {
        case AuthChangeEvent.signedIn:
          // Fetch full user data when signed in
          getCurrentUser();
          state = state.copyWith(
            loginState: AsyncState.success,
            session: authState.session,
            isAuthenticated: true,
          );
          break;
        case AuthChangeEvent.signedOut:
          state = state.copyWith(
            loginState: AsyncState.failure,
            user: null,
            session: null,
            isAuthenticated: false,
          );
          break;
        case AuthChangeEvent.userUpdated:
          // Refresh user data when updated
          getCurrentUser();
          state = state.copyWith(session: authState.session);
          break;
        case AuthChangeEvent.userDeleted:
          state = state.copyWith(
            // state: AsyncState.success,
            user: null,
            session: null,
            isAuthenticated: false,
          );
          break;
        case AuthChangeEvent.tokenRefreshed:
          state = state.copyWith(
            session: authState.session,
            isAuthenticated: true,
            loginState: AsyncState.success,
          );
          getCurrentUser(); // optional but recommended
          break;

        default:
          break;
      }
    });
  }

  String _getAuthErrorMessage(dynamic error) {
    if (error is AuthException) {
      return error.message;
    }
    return error.toString();
  }
}

class AuthState {
  AuthState({
    this.loginState,
    this.logoutState,
    this.signupState,
    this.currentUserState,
    this.error,
    this.user,
    this.session,
    this.isAuthenticated = false,
    this.isLogIn = true,
    this.signUpSuccessMessage,
  });

  AsyncState? loginState;
  AsyncState? logoutState;
  AsyncState? signupState;
  AsyncState? currentUserState;
  String? error;
  String? signUpSuccessMessage;
  UserModel? user;
  Session? session;
  bool isAuthenticated;
  bool isLogIn;

  AuthState copyWith({
    AsyncState? loginState,
    AsyncState? logoutState,
    AsyncState? signupState,
    AsyncState? currentUserState,
    String? error,
    String? signUpSuccessMessage,
    UserModel? user,
    Session? session,
    bool? isAuthenticated,
    bool? isLogIn,
  }) {
    return AuthState(
      loginState: loginState ?? this.loginState,
      logoutState: logoutState ?? this.logoutState,
      signupState: signupState ?? this.signupState,
      currentUserState: currentUserState ?? this.currentUserState,
      error: error ?? this.error,
      user: user ?? this.user,
      session: session ?? this.session,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLogIn: isLogIn ?? this.isLogIn,
      signUpSuccessMessage: signUpSuccessMessage ?? this.signUpSuccessMessage,
    );
  }
}
