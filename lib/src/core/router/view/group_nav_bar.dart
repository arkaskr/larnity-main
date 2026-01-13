import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
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
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/ui/widgets/app_dropdown.dart';
import 'package:larnity/src/core/ui/widgets/smart_image.dart';
import 'package:larnity/src/features/auth/presentation/provider/auth_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/data/models/group_model.dart';

class GroupNavBar extends ConsumerStatefulWidget {
  GroupNavBar({Key? key, required this.navigationShell})
    : super(key: key ?? const ValueKey('ScaffoldWithNestedNavigation'));

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<GroupNavBar> createState() => _GroupNavBarState();
}

class _GroupNavBarState extends ConsumerState<GroupNavBar> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final AppDropdownController _groupDropdownController = AppDropdownController();

  void _goBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch the group provider to get the list of groups
    final groupState = ref.watch(groupProvider);

    final allGroups = groupState.groups ?? [];

    // Get all groups where user has a role (ADMIN or MEMBER)
    final userGroups = allGroups
        .where((group) => group.userRole != null)
        .toList();

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
        actions: [SizedBox.shrink()],
      ),
      endDrawer: Drawer(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xs),
          child: Column(
            children: [
              AppSizes.xxxlg.ph,

              // Group selector dropdown
              AppDropdown(
                controller: _groupDropdownController,
                button: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.xxxs,
                    vertical: AppSizes.xxxs,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.skyBlue.withValues(alpha: 0.5),
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.xs),
                  ),
                  child: Row(
                    children: [
                      AppSizes.xs.pw,
                      // Group icon/thumbnail
                      if (groupState.group != null)
                        groupState.group!.thumbnail != null
                            ? CircleAvatar(
                                radius: 12,
                                backgroundImage: NetworkImage(groupState.group!.thumbnail!),
                              )
                            : CircleAvatar(
                                radius: 12,
                                child: groupState.group!.icon != null
                                    ? SmartImage(groupState.group!.icon, width: 16, height: 16)
                                    : HugeIcon(
                                        icon: groupState.group!.userRole == 'ADMIN'
                                            ? HugeIconsStrokeRounded.crown
                                            : HugeIconsStrokeRounded.userGroup,
                                        color: groupState.group!.userRole == 'ADMIN'
                                            ? AppColors.primaryOrange
                                            : AppColors.white,
                                        size: 16,
                                      ),
                              )
                        else
                          CircleAvatar(
                            radius: 12,
                            child: HugeIcon(
                              icon: HugeIconsStrokeRounded.userGroup,
                              color: AppColors.white,
                              size: 16,
                            ),
                          ),
                      AppSizes.xs.pw,
                      Expanded(
                        child: Text(
                          groupState.group?.name ?? "Select Group",
                          style: AppTextStyles.overLine(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Spacer(),
                      HugeIcon(
                        icon: HugeIconsStrokeRounded.arrowUpDown,
                        color: AppColors.white,
                      ),
                    ],
                  ),
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
                          _groupDropdownController.close();
                          Navigator.of(context).pop(); // Close drawer
                          context.pushNamed(Routes.explore);
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
                        _groupDropdownController.close();
                        Navigator.of(context).pop(); // Close drawer

                        // Set selected group
                        ref
                            .read(groupProvider.notifier)
                            .setSelectedGroup(group);

                        // Navigate to group
                        context.pushNamed(
                          Routes.group,
                          pathParameters: {'groupId': group.id ?? ''},
                        );
                      },
                      child: Row(
                        children: [
                          group.thumbnail != null
                              ? CircleAvatar(
                                  radius: 16,
                                  backgroundImage: NetworkImage(group.thumbnail!),
                                )
                              : CircleAvatar(
                                  radius: 16,
                                  child: group.icon != null
                                      ? SmartImage(group.icon, width: 20, height: 20)
                                      : HugeIcon(
                                          icon: group.userRole == 'ADMIN'
                                              ? HugeIconsStrokeRounded.crown
                                              : HugeIconsStrokeRounded.userGroup,
                                          color: group.userRole == 'ADMIN'
                                              ? AppColors.primaryOrange
                                              : AppColors.white,
                                          size: 20,
                                        ),
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

              AppSizes.xxxlg.ph,
              AppButton(
                onPressed: () {},
                padding: EdgeInsets.zero,
                bgColor: Colors.transparent,
                child: Row(
                  children: [
                    Text(
                      "CHANNELS",
                      style: AppTextStyles.overLine(color: AppColors.white),
                    ),
                    Spacer(),
                    Icon(Icons.add, color: AppColors.white),
                  ],
                ),
              ),
              AppSizes.lg.ph,

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          context.goNamed(Routes.explore);
                        },
                        child: Row(
                          children: [
                            HugeIcon(
                              icon: HugeIconsStrokeRounded.home03,
                              color: Colors.grey,
                            ),
                            8.pw,
                            Text("General", style: AppTextStyles.button()),
                          ],
                        ),
                      ),
                      AppSizes.xs.ph,
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          context.goNamed(Routes.explore);
                        },
                        child: Row(
                          children: [
                            HugeIcon(
                              icon: HugeIconsStrokeRounded.notification01,
                              color: Colors.grey,
                            ),
                            8.pw,
                            Text("Annoucements", style: AppTextStyles.button()),
                          ],
                        ),
                      ),
                      AppSizes.xs.ph,
                      Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          title: Text(
                            "Settings",
                            style: AppTextStyles.button(),
                          ),
                          tilePadding: EdgeInsets.zero,
                          leading: HugeIcon(
                            icon: HugeIconsStrokeRounded.settings01,
                            color: Colors.grey,
                          ),
                          children: [
                            ListTile(
                              onTap: () {
                                context.pushNamed(Routes.generalSettings);
                              },
                              leading: HugeIcon(
                                icon: HugeIconsStrokeRounded.settings01,
                                color: Colors.grey,
                              ),
                              title: Text("General"),
                            ),
                            ListTile(
                              onTap: () {
                                context.pushNamed(Routes.subscriptionSettings);
                              },
                              leading: HugeIcon(
                                icon: HugeIconsStrokeRounded.wallet01,
                                color: Colors.grey,
                              ),
                              title: Text("Subscriptions"),
                            ),
                            ListTile(
                              onTap: () {
                                context.pushNamed(Routes.paymentSettings);
                              },
                              leading: HugeIcon(
                                icon: HugeIconsStrokeRounded.building01,
                                color: Colors.grey,
                              ),
                              title: Text("Payment Method"),
                            ),
                            ListTile(
                              onTap: () {
                                context.pushNamed(Routes.offerSettings);
                              },
                              leading: HugeIcon(
                                icon: HugeIconsStrokeRounded.package,
                                color: Colors.grey,
                              ),
                              title: Text("Offer"),
                            ),
                            ListTile(
                              onTap: () {
                                context.pushNamed(Routes.challengeSettings);
                              },
                              leading: HugeIcon(
                                icon: HugeIconsStrokeRounded.award02,
                                color: Colors.grey,
                              ),
                              title: Text("Challenge"),
                            ),
                            ListTile(
                              onTap: () {
                                context.pushNamed(Routes.integrationSettings);
                              },
                              leading: HugeIcon(
                                icon: HugeIconsStrokeRounded.link01,
                                color: Colors.grey,
                              ),
                              title: Text("Integration"),
                            ),
                            ListTile(
                              onTap: () {
                                context.pushNamed(Routes.promoCodeSettings);
                              },
                              leading: HugeIcon(
                                icon: HugeIconsStrokeRounded.ticket03,
                                color: Colors.grey,
                              ),
                              title: Text("Promo Code"),
                            ),
                            ListTile(
                              onTap: () {
                                context.pushNamed(
                                  Routes.memberManagementSettings,
                                );
                              },
                              leading: HugeIcon(
                                icon: HugeIconsStrokeRounded.man,
                                color: Colors.grey,
                              ),
                              title: Text("Member Management"),
                            ),
                            ListTile(
                              onTap: () {
                                context.pushNamed(Routes.leaveReasonsSettings);
                              },
                              leading: HugeIcon(
                                icon: HugeIconsStrokeRounded.userBlock02,
                                color: Colors.grey,
                              ),
                              title: Text("Leave Reason"),
                            ),
                            ListTile(
                              onTap: () {
                                context.pushNamed(Routes.managerSettings);
                              },
                              leading: HugeIcon(
                                icon: HugeIconsStrokeRounded.userShield02,
                                color: Colors.grey,
                              ),
                              title: Text("Manager"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: widget.navigationShell,
      bottomNavigationBar: BottomAppBar(
        height: 60,
        color: Theme.of(context).colorScheme.surface,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BuildNavItem(
              onTap: () {
                // Get current group
                final currentGroup = ref.read(groupProvider).group;

                if (currentGroup?.id != null) {
                  // Navigate to group home and reset to discussion room (index 0)
                  ref.read(groupProvider.notifier).setSelectedTab(0);
                  context.go('/group/${currentGroup!.id}');
                }
              },
              icon: HugeIcon(
                icon: HugeIconsStrokeRounded.home03,
                color: Colors.grey,
              ),
              isSelected: widget.navigationShell.currentIndex == 0,
            ),
            _BuildNavItem(
              onTap: () {},
              icon: AppDropdown(
                button: HugeIcon(
                  icon: HugeIconsStrokeRounded.notification01,
                  color: Colors.grey,
                ),
                gapFromButton: 16,
                alignWithDevice: true,
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
                            children: [
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
                      child: Text("See all notifications(0)"),
                    ),
                  ],
                ),
                items: [],
              ),
              isSelected: widget.navigationShell.currentIndex == 1,
            ),
            _BuildNavItem(
              onTap: () => _goBranch(1),
              icon: HugeIcon(
                icon: HugeIconsStrokeRounded.message02,
                color: Colors.grey,
              ),
              isSelected: widget.navigationShell.currentIndex == 1,
            ),
            _BuildNavItem(
              onTap: () {},
              icon: AppDropdown(
                overlayWidth: 140,
                overlayHeight: 160,
                overlayAlignment: Alignment.centerRight,
                top: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: AppSizes.xxxs,
                        left: AppSizes.xs,
                      ),
                      child: Text(AppStrings.account),
                    ),
                    Divider(color: AppColors.creamWhite, thickness: 1),
                  ],
                ),
                button: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange,
                    shape: BoxShape.circle,
                  ),
                ),
                items: [
                  AppDropdownItem(
                    value: "settings",
                    child: GestureDetector(
                      onTap: () {
                        context.pushNamed(Routes.profileSettings);
                      },
                      child: Row(
                        children: [
                          HugeIcon(
                            icon: HugeIconsStrokeRounded.settings01,
                            color: Colors.grey,
                          ),
                          AppSizes.xxxs.pw,
                          Text("Settings"),
                        ],
                      ),
                    ),
                  ),
                  AppDropdownItem(
                    value: "logout",
                    child: GestureDetector(
                      onTap: () {
                        // Call the logout function from auth provider
                        ref.read(authProvider.notifier).signOut();
                        // Navigate to auth screen after logout
                        context.goNamed(Routes.auth);
                      },
                      child: Row(
                        children: [
                          HugeIcon(
                            icon: HugeIconsStrokeRounded.logout01,
                            color: Colors.grey,
                          ),
                          AppSizes.xxxs.pw,
                          Text("Logout"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              isSelected: false,
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Bottom Nav Bar Item

class _BuildNavItem extends StatelessWidget {
  const _BuildNavItem({
    required this.onTap,
    required this.icon,
    required this.isSelected,
  });

  final Widget icon;
  final void Function() onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: InkWell(onTap: onTap, child: icon),
    );
  }
}
