import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_assets.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/extensions/screen_size_extension.dart';
import 'package:larnity/src/core/router/router.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_dropdown.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';

class ExploreNestedRoute extends ConsumerStatefulWidget {
  const ExploreNestedRoute({Key? key, required this.navigationShell})
    : super(key: key ?? const ValueKey('exploreNestedRoute'));

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<ExploreNestedRoute> createState() => _ExploreNestedRouteState();
}

class _ExploreNestedRouteState extends ConsumerState<ExploreNestedRoute> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final AppDropdownController _larnityDropdownController =
      AppDropdownController();

  void _goBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupState = ref.watch(groupProvider);
    final userGroups =
        groupState.groups?.where((group) {
          // User is creator OR has userRole (means is member)
          return group.userRole != null;
        }).toList() ??
        [];
    print("🔍 Total groups: ${userGroups.length}");
    
    // Calculate max overlay height (60% of screen height, but max 500)
    final screenHeight = MediaQuery.of(context).size.height;
    final maxOverlayHeight = (screenHeight * 0.6).clamp(200.0, 500.0);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Image.asset(AppAssets.images.logoWhite, width: 100),
        centerTitle: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              context.pushNamed(Routes.notification);
            },
            child: AppDropdown(
              controller: _larnityDropdownController,
              button: HugeIcon(
                icon: HugeIconsStrokeRounded.notification01,
                color: Colors.grey,
              ),
              overlayWidth: 0.9.sw,
              overlayAlignment: Alignment.centerRight,
              overlayHeight: 260,
              top: Padding(
                padding: const EdgeInsets.all(AppSizes.xs),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Notifications",
                          style: AppTextStyles.button().copyWith(
                            fontWeight: AppFontWeights.bold,
                          ),
                        ),
                      ],
                    ),
                    AppSizes.xs.ph,
                    RichText(
                      text: TextSpan(
                        text: AppStrings.markAllAsRead,
                        style: AppTextStyles.subtitle2(
                          color: AppColors.primaryOrange,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {},
                      ),
                    ),
                    AppSizes.xs.ph,
                    AppDropdown(
                      button: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.xs,
                          vertical: AppSizes.xxs,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.borderBrown),
                          borderRadius: BorderRadius.circular(AppSizes.xxxs),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text("All groups"),
                            Icon(Icons.keyboard_arrow_down),
                          ],
                        ),
                      ),
                      items: [
                        AppDropdownItem(value: 'all', label: "All groups"),
                      ],
                    ),
                    Divider(color: AppColors.borderBrown),
                  ],
                ),
              ),
              bottom: Column(
                children: [
                  Divider(color: AppColors.borderBrown),
                  TextButton(
                    onPressed: () {
                      context.pushNamed(Routes.notification);
                    },
                    child: const Text("See all notifications(0)"),
                  ),
                ],
              ),
              items: [],
            ),
          ),
          AppSizes.xs.pw,
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.xlg),
                child: AppDropdown(
                  button: Row(
                    children: [
                      Expanded(child: Image.asset(AppAssets.images.logoWhite)),
                      AppSizes.xs.pw,
                      HugeIcon(
                        icon: HugeIconsStrokeRounded.unfoldMore,
                        color: AppColors.white,
                      ),
                    ],
                  ),
                  overlayHeight: maxOverlayHeight,
                  overlayRadius: AppSizes.xs,
                  top: Padding(
                    padding: const EdgeInsets.all(AppSizes.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'All Groups',
                          style: AppTextStyles.subtitle1(
                            color: AppColors.white,
                          ),
                        ),
                        Divider(color: AppColors.borderBrown),
                        AppSizes.xs.ph,
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            context.goNamed(Routes.explore);
                          },
                          child: Row(
                            children: const [
                              Icon(Icons.explore_outlined, color: Colors.grey),
                              SizedBox(width: 8),
                              Text("Explore Groups"),
                            ],
                          ),
                        ),
                        Divider(color: AppColors.borderBrown),
                      ],
                    ),
                  ),
                  items: userGroups.map((group) {
                    return AppDropdownItem(
                      value: group.id ?? '',
                      height: 60,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          _larnityDropdownController.close();
                          Navigator.of(context).pop(); // Close drawer

                          // Set selected group
                          ref
                              .read(groupProvider.notifier)
                              .setSelectedGroup(group);

                          // ✅ Navigate directly to GroupHomeScreen
                          context.pushNamed(
                            Routes.group,
                            pathParameters: {'groupId': group.id ?? ''},
                          );
                        },
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: group.thumbnail != null
                                  ? NetworkImage(group.thumbnail!)
                                  : null,
                              child: group.thumbnail == null
                                  ? HugeIcon(
                                      icon: HugeIconsStrokeRounded.userGroup,
                                      color: AppColors.white,
                                      size: 20,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                group.name,
                                style: AppTextStyles.button(),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            ListTile(
              leading: HugeIcon(
                icon: HugeIconsStrokeRounded.compass01,
                color: AppColors.white,
              ),
              title: Text(
                AppStrings.exploreGroups,
                style: AppTextStyles.button(),
              ),
              onTap: () {
                Navigator.of(context).pop();
                context.goNamed(Routes.explore);
              },
            ),
          ],
        ),
      ),
      body: widget.navigationShell,
    );
  }
}
