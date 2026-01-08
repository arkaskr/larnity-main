part of 'router.dart';

class Routes {
  static const String explore = 'explore';
  static const String auth = 'auth';
  static const String notification = 'notification';
  static const String packageSubscription = 'package-subscription';
  static const String package = 'package';
  static const String packageDetails = 'package-details';
  static const String groupDetails = 'group-details';
  static const String group = 'group';
  static const String generalSettings = 'general-settings';
  static const String subscriptionSettings = 'subscription-settings';
  static const String paymentSettings = 'payment-settings';
  static const String offerSettings = 'offer-settings';
  static const String challengeSettings = 'challenge-settings';
  static const String integrationSettings = 'integration-settings';
  static const String promoCodeSettings = 'promo-code-settings';
  static const String memberManagementSettings = 'member-management-settings';
  static const String leaveReasonsSettings = 'leave-reasons-settings';
  static const String managerSettings = 'manager-settings';
  static const String profileSettings = 'profile-settings';
  static const String chatting = 'chatting';
  static const String choosePlan = 'choose-plan';
  static const String payment = 'payment';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final authNotifier = ref.read(authProvider.notifier);
  return GoRouter(
    refreshListenable: GoRouterRefreshStream(
      ref.watch(supabaseClientProvider).auth.onAuthStateChange,
    ),
    redirect: (context, state) {
      // We'll handle redirection logic here based on auth state
      // final appUserCubit = context.read<AppUserCubit>();

      // final isLoggedIn = appUserCubit.state is AppUserLoggedIn;
      final isLoggedIn = authState.isAuthenticated;
      final isAuthRoute = state.matchedLocation == Routes.auth.p;
      final isExploreRoute = state.matchedLocation == Routes.explore.p;

      Log.info("Is Logged in: ${isLoggedIn}");
      // Log.info("Is Login: ${state.matchedLocation}");

      // if (authState.loginState == AsyncState.initial ||
      //     authState.loginState == AsyncState.loading ||
      //     authState.signupState == AsyncState.initial ||
      //     authState.signupState == AsyncState.loading) {
      //   return null;
      // }

      // If user is logged in and trying to access login page, redirect to home
      if (isLoggedIn && isExploreRoute) {
        return Routes.explore.p;
      }

      // If user is not logged in and trying to access protected routes, redirect to login
      if (!isLoggedIn && isExploreRoute) {
        return Routes.auth.p;
      }

      // No redirect needed
      return null;
    },
    initialLocation: Routes.explore.p,
    routes: [
      _buildExploreShellRoutes(),
      _buildGroupShellRoutes(),
      _buildNotificationScreenRoute(),
      _buildProfileSettingsScreenRoute(),
      _buildAuthScreenRoute(),
      _buildGroupScreenRoute(),
      // MOVED: All settings routes are now top-level routes
      _buildSubscriptionSettingsScreenRoute(),
      _buildPaymentSettingsScreenRoute(),
      _buildOfferSettingsScreenRoute(),
      _buildChallengeSettingsScreenRoute(),
      _buildIntegrationSettingsScreenRoute(),
      _buildPromoCodeSettingsScreenRoute(),
      _buildMemberManagementSettingsScreenRoute(),
      _buildLeaveReasonsSettingsScreenRoute(),
      _buildManagerSettingsScreenRoute(),
    ],
  );
});

// Helper class to convert Stream to ChangeNotifier for GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

StatefulShellRoute _buildGroupShellRoutes() {
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) {
      return GroupNavBar(navigationShell: navigationShell);
    },
    branches: [
      // ❌ REMOVE THIS - don't include group route here
      // StatefulShellBranch(routes: [_buildGroupScreenRoute()]),

      // Branch 0 → General Settings
      StatefulShellBranch(routes: [_buildGeneralSettingsScreenRoute()]),

      // Branch 1 → Chat
      StatefulShellBranch(routes: [_buildChattingScreenRoute()]),
    ],
  );
}

StatefulShellRoute _buildExploreShellRoutes() {
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) {
      return ExploreNestedRoute(navigationShell: navigationShell);
    },
    branches: [
      StatefulShellBranch(routes: [_buildExploreScreenRoute()]),
      StatefulShellBranch(routes: [_buildPackageSubscriptionScreenRoute()]),
      StatefulShellBranch(routes: [_buildPackageScreenRoute()]),
      StatefulShellBranch(routes: [_buildPackageDetailsScreenRoute()]),
      StatefulShellBranch(routes: [_buildGroupDetailsScreenRoute()]),
      StatefulShellBranch(routes: [_buildChoosePlanScreenRoute()]),
      StatefulShellBranch(routes: [_buildPaymentScreenRoute()]),
      // ❌ REMOVE THIS LINE - This is causing the error
      // StatefulShellBranch(routes: [_buildGroupScreenRoute()]),
    ],
  );
}

// StatefulShellRoute _buildGroupShellRoutes() {
//   return StatefulShellRoute.indexedStack(
//     builder: (context, state, navigationShell) {
//       return GroupNavBar(navigationShell: navigationShell);
//     },
//     branches: [
//       // Branch 0 → Group Home
//       StatefulShellBranch(routes: [_buildGroupScreenRoute()]),

//       // Branch 1 → General Settings (keep one in branch for tab navigation)
//       StatefulShellBranch(routes: [_buildGeneralSettingsScreenRoute()]),

//       // Branch 2 → Chat
//       StatefulShellBranch(routes: [_buildChattingScreenRoute()]),
//     ],
//   );
// }

// StatefulShellRoute _buildExploreShellRoutes() {
//   return StatefulShellRoute.indexedStack(
//     builder: (context, state, navigationShell) {
//       return ExploreNestedRoute(navigationShell: navigationShell);
//     },
//     branches: [
//       StatefulShellBranch(routes: [_buildExploreScreenRoute()]),
//       StatefulShellBranch(routes: [_buildPackageSubscriptionScreenRoute()]),
//       StatefulShellBranch(routes: [_buildPackageScreenRoute()]),
//       StatefulShellBranch(routes: [_buildPackageDetailsScreenRoute()]),
//       StatefulShellBranch(routes: [_buildGroupDetailsScreenRoute()]),
//       StatefulShellBranch(routes: [_buildChoosePlanScreenRoute()]),
//       StatefulShellBranch(routes: [_buildPaymentScreenRoute()]),
//     ],
//   );
// }

GoRoute _buildExploreScreenRoute() => GoRoute(
  name: Routes.explore,
  path: Routes.explore.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => ExploreScreen(),
  ),
);

GoRoute _buildNotificationScreenRoute() => GoRoute(
  name: Routes.notification,
  path: Routes.notification.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => NotificationScreen(),
  ),
);

GoRoute _buildPackageSubscriptionScreenRoute() => GoRoute(
  name: Routes.packageSubscription,
  path: Routes.packageSubscription.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => PackageSubscriptionScreen(),
  ),
);

GoRoute _buildPackageScreenRoute() => GoRoute(
  name: Routes.package,
  path: Routes.package.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => PackageScreen(),
  ),
);

GoRoute _buildPackageDetailsScreenRoute() => GoRoute(
  name: Routes.packageDetails,
  path: Routes.packageDetails.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) =>
        PackageDetailsScreen(package: state.extra as PackageModel),
  ),
);

GoRoute _buildGroupDetailsScreenRoute() => GoRoute(
  name: Routes.groupDetails,
  path: Routes.groupDetails.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => GroupDetailsScreen(),
  ),
);

// GoRoute _buildGroupScreenRoute() => GoRoute(
//   name: Routes.group,
//   path: Routes.group.p,
//   pageBuilder: _getDefaultPageBuilderByPlatform(
//     childBuilder: (_, state) => GroupHomeScreen(),
//   ),
// );
GoRoute _buildGroupScreenRoute() => GoRoute(
  name: Routes.group,
  path: '/group/:groupId', // ✅ Leading slash hatao - relative path
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) {
      final groupId = state.pathParameters['groupId'];
      return GroupHomeScreen(groupId: groupId);
    },
  ),
);
GoRoute _buildGeneralSettingsScreenRoute() => GoRoute(
  name: Routes.generalSettings,
  path: Routes.generalSettings.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => GeneralSettingsScreen(),
  ),
);

GoRoute _buildSubscriptionSettingsScreenRoute() => GoRoute(
  name: Routes.subscriptionSettings,
  path: Routes.subscriptionSettings.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => SubscriptionSettingsScreen(),
  ),
);

GoRoute _buildPaymentSettingsScreenRoute() => GoRoute(
  name: Routes.paymentSettings,
  path: Routes.paymentSettings.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => PaymentSettingsScreen(),
  ),
);

GoRoute _buildOfferSettingsScreenRoute() => GoRoute(
  name: Routes.offerSettings,
  path: Routes.offerSettings.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => OfferSettingsScreen(),
  ),
);

GoRoute _buildChallengeSettingsScreenRoute() => GoRoute(
  name: Routes.challengeSettings,
  path: Routes.challengeSettings.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => ChallengeSettingsScreen(),
  ),
);

GoRoute _buildIntegrationSettingsScreenRoute() => GoRoute(
  name: Routes.integrationSettings,
  path: Routes.integrationSettings.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => IntegrationSettingsScreen(),
  ),
);

GoRoute _buildPromoCodeSettingsScreenRoute() => GoRoute(
  name: Routes.promoCodeSettings,
  path: Routes.promoCodeSettings.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => PromoCodeSettingsScreen(),
  ),
);

GoRoute _buildMemberManagementSettingsScreenRoute() => GoRoute(
  name: Routes.memberManagementSettings,
  path: Routes.memberManagementSettings.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => MemberManagementScreen(),
  ),
);

GoRoute _buildLeaveReasonsSettingsScreenRoute() => GoRoute(
  name: Routes.leaveReasonsSettings,
  path: Routes.leaveReasonsSettings.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => LeaveReasonScreen(),
  ),
);

GoRoute _buildManagerSettingsScreenRoute() => GoRoute(
  name: Routes.managerSettings,
  path: Routes.managerSettings.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => ManagerSettingsScreen(),
  ),
);

GoRoute _buildProfileSettingsScreenRoute() => GoRoute(
  name: Routes.profileSettings,
  path: Routes.profileSettings.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => ProfileSettingsScreen(),
  ),
);

GoRoute _buildChattingScreenRoute() => GoRoute(
  name: Routes.chatting,
  path: Routes.chatting.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => ChattingScreen(),
  ),
);
GoRoute _buildAuthScreenRoute() => GoRoute(
  name: Routes.auth,
  path: Routes.auth.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => AuthScreen(),
  ),
);

GoRoute _buildChoosePlanScreenRoute() => GoRoute(
  name: Routes.choosePlan,
  path: Routes.choosePlan.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => const ChoosePlanScreen(),
  ),
);

GoRoute _buildPaymentScreenRoute() => GoRoute(
  name: Routes.payment,
  path: Routes.payment.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => const PaymentScreen(),
  ),
);

//-------- Platform Wrapper-----------//

GoRouterPageBuilder _getDefaultPageBuilderByPlatform({
  required Widget Function(BuildContext context, GoRouterState goRouterState)
  childBuilder,
}) =>
    (context, goRouterState) =>
        _getPageByPlatform(child: childBuilder(context, goRouterState));

Page<T> _getPageByPlatform<T>({required Widget child}) {
  if (kIsWeb) {
    return MaterialPage(child: child);
  } else {
    if (Platform.isAndroid) {
      return MaterialPage(child: child);
    }
    if (Platform.isIOS) {
      return CupertinoPage(child: child);
    }
    return MaterialPage(child: child);
  }
}
