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
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/ui/widgets/app_dropdown.dart';
import 'package:larnity/src/core/ui/widgets/app_segmented_button.dart';
import 'package:larnity/src/core/ui/widgets/smart_image.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/auth/presentation/provider/auth_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/presentation/views/challenge_room_screen.dart';
import 'package:larnity/src/features/group/presentation/views/class_room_screen.dart';
import 'package:larnity/src/features/group/presentation/views/discussion_room_screen.dart';
import 'package:larnity/src/features/group/presentation/views/doubt_room_screen.dart';
import 'package:larnity/src/features/group/presentation/views/event_room_screen.dart';
import 'package:larnity/src/features/group/presentation/views/job_room_screen.dart';
import 'package:larnity/src/features/group/presentation/views/live_class_room_screen.dart';
import 'package:larnity/src/features/group/presentation/views/members_room_screen.dart';
import 'package:larnity/src/features/group/presentation/views/product_room_screen.dart';
import 'package:larnity/src/features/group/presentation/views/service_room_screen.dart';
import 'package:larnity/src/features/group/presentation/views/treasure_room_screen.dart';
import 'package:larnity/src/features/group/presentation/provider/event_provider.dart';

class GroupHomeScreen extends ConsumerStatefulWidget {
  final String? groupId;

  const GroupHomeScreen({super.key, this.groupId});

  @override
  ConsumerState<GroupHomeScreen> createState() => _GroupHomeScreenState();
}

class _GroupHomeScreenState extends ConsumerState<GroupHomeScreen> {
  final PageController groupPageController = PageController();
  bool _showOnboardingBanner = true;
  final AppDropdownController _groupDropdownController = AppDropdownController();

  @override
  void initState() {
    super.initState();

    // Fetch group data when screen loads
    if (widget.groupId != null) {
      Future.microtask(() {
        ref.read(groupProvider.notifier).fetchGroupById(widget.groupId!);
        ref.read(eventProvider).fetchEvents(widget.groupId!);
      });
    }
  }

  @override
  void dispose() {
    groupPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupState = ref.watch(groupProvider);
    final currentGroup = groupState.group;
    final groups = groupState.groups ?? [];

    // Get all groups where user has a role (ADMIN or MEMBER)
    final userGroups = groups
        .where((group) => group.userRole != null)
        .toList();

    // Calculate max overlay height (60% of screen height, but max 500)
    final screenHeight = MediaQuery.of(context).size.height;
    final maxOverlayHeight = (screenHeight * 0.6).clamp(200.0, 500.0);

    // Show loading while fetching
    if (groupState.fetchState == AsyncState.loading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Show error if fetch failed
    if (groupState.fetchState == AsyncState.failure) {
      return Scaffold(
        body: Center(child: Text('Failed to load group: ${groupState.error}')),
      );
    }

    // Show message if no group found
    if (currentGroup == null) {
      return Scaffold(body: Center(child: Text('Group not found')));
    }

    return Scaffold(
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
            child: HugeIcon(
              icon: HugeIconsStrokeRounded.notification01,
              color: Colors.grey,
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
                  controller: _groupDropdownController,
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
                            _groupDropdownController.close();
                            Navigator.of(context).pop(); // Close drawer
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
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: group.thumbnail != null
                                  ? NetworkImage(group.thumbnail!)
                                  : null,
                              child: group.thumbnail == null
                                  ? (group.icon != null
                                      ? SmartImage(group.icon, width: 20, height: 20)
                                      : HugeIcon(
                                          icon: group.userRole == 'ADMIN'
                                              ? HugeIconsStrokeRounded.crown
                                              : HugeIconsStrokeRounded.userGroup,
                                          color: group.userRole == 'ADMIN'
                                              ? AppColors.primaryOrange
                                              : AppColors.white,
                                          size: 20,
                                        ))
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
            // Rest of drawer content
            Padding(
              padding: const EdgeInsets.all(AppSizes.xs),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppSizes.xs.ph,
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
                  // General
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.of(context).pop();
                      if (currentGroup != null) {
                        ref
                            .read(groupProvider.notifier)
                            .setSelectedGroup(currentGroup);
                      }
                      context.goNamed(Routes.generalSettings);
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

                  // Announcements
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Row(
                      children: [
                        HugeIcon(
                          icon: HugeIconsStrokeRounded.notification01,
                          color: Colors.grey,
                        ),
                        8.pw,
                        Text(
                          "Announcements",
                          style: AppTextStyles.button(),
                        ),
                      ],
                    ),
                  ),
                  AppSizes.xs.ph,

                  // Settings Expansion Tile
                  if (currentGroup.userId == ref.watch(authProvider).user?.id)
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
                              Navigator.of(context).pop();
                              if (currentGroup != null) {
                                ref
                                    .read(groupProvider.notifier)
                                    .setSelectedGroup(currentGroup);
                              }
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
                              Navigator.of(context).pop();
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
                              Navigator.of(context).pop();
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
                              Navigator.of(context).pop();
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
                              Navigator.of(context).pop();
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
                              Navigator.of(context).pop();
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
                              Navigator.of(context).pop();
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
                              Navigator.of(context).pop();
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
                              Navigator.of(context).pop();
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
                              Navigator.of(context).pop();
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
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.xs),
          child: Column(
            children: [
              AppSizes.xs.ph,
              Text(
                currentGroup.name,
                style: AppTextStyles.headline2(color: AppColors.white),
              ),
              AnimatedSlide(
                offset: _showOnboardingBanner
                    ? Offset.zero
                    : const Offset(0, -0.3),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                child: AnimatedOpacity(
                  opacity: _showOnboardingBanner ? 1 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: _showOnboardingBanner
                      ? Container(
                          padding: EdgeInsets.all(AppSizes.xs),
                          decoration: BoxDecoration(
                            color: AppColors.infoCardColor,
                            border: Border.all(
                              color: AppColors.primaryOrange.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(AppSizes.xxxs),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  HugeIcon(
                                    icon: HugeIconsStrokeRounded
                                        .informationDiamond,
                                    color: AppColors.primaryOrange,
                                  ),
                                  AppSizes.xs.pw,
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Complete Group Onboarding",
                                          style: AppTextStyles.button(
                                            color: AppColors.primaryOrange,
                                          ),
                                        ),
                                        Text(
                                          "Your group is not public yet. Please finish onboarding and submit for approval.",
                                          style: AppTextStyles.overLine(
                                            color: AppColors.primaryOrange,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _showOnboardingBanner = false;
                                      });
                                    },
                                    icon: HugeIcon(
                                      icon: HugeIconsStrokeRounded.cancel01,
                                      color: AppColors.primaryOrange,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              AppSizes.xs.ph,
              AppSegmentedButton(
                height: 60,
                isScrollable: true,
                selectedBorderColor: AppColors.skyBlue,
                selectedButtonColor: Colors.transparent,
                selectedLabelStyle: AppTextStyles.overLine(
                  color: AppColors.white,
                ),
                unselectedLabelStyle: AppTextStyles.overLine(
                  color: AppColors.white,
                ),
                buttonItems: [
                  if (currentGroup.tabSettings?['discussion'] ?? true)
                    AppSegmentedButtonItem(
                      label: "Discussion Room",
                      prefixIcon: HugeIconsStrokeRounded.home03,
                    ),
                  if (currentGroup.tabSettings?['class'] ?? true)
                    AppSegmentedButtonItem(
                      label: "Class Room",
                      prefixIcon: HugeIconsStrokeRounded.geometricShapes01,
                    ),
                  if (currentGroup.tabSettings?['live_class'] ?? true)
                    AppSegmentedButtonItem(
                      label: "Live Class Room",
                      prefixIcon: HugeIconsStrokeRounded.computerVideo,
                    ),
                  if (currentGroup.tabSettings?['events'] ?? true)
                    AppSegmentedButtonItem(
                      label: "Events Room",
                      prefixIcon: HugeIconsStrokeRounded.calendar03,
                    ),
                  if (currentGroup.tabSettings?['members'] ?? true)
                    AppSegmentedButtonItem(
                      label: "Members Room",
                      prefixIcon: HugeIconsStrokeRounded.userMultiple,
                    ),
                  if (currentGroup.tabSettings?['doubt'] ?? true)
                    AppSegmentedButtonItem(
                      label: "Doubt Room",
                      prefixIcon: HugeIconsStrokeRounded.sourceCodeSquare,
                    ),
                  if (currentGroup.tabSettings?['challenges'] ?? true)
                    AppSegmentedButtonItem(
                      label: "Challenges Room",
                      prefixIcon: HugeIconsStrokeRounded.adventure,
                    ),
                  if (currentGroup.tabSettings?['treasure'] ?? true)
                    AppSegmentedButtonItem(
                      label: "Treasure Room",
                      prefixIcon: HugeIconsStrokeRounded.notebook02,
                    ),
                  if (currentGroup.tabSettings?['product'] ?? true)
                    AppSegmentedButtonItem(
                      label: "Product Room",
                      prefixIcon: HugeIconsStrokeRounded.shoppingBag01,
                    ),
                  if (currentGroup.tabSettings?['service'] ?? true)
                    AppSegmentedButtonItem(
                      label: "Service Room",
                      prefixIcon: HugeIconsStrokeRounded.documentValidation,
                    ),
                  if (currentGroup.tabSettings?['job'] ?? true)
                    AppSegmentedButtonItem(
                      label: "Job Room",
                      prefixIcon: HugeIconsStrokeRounded.id,
                    ),
                ],
                pageController: groupPageController,
              ),
              Expanded(
                child: PageView(
                  controller: groupPageController,
                  onPageChanged: (index) {
                    ref.read(groupProvider.notifier).setSelectedTab(index);
                  },
                  children: [
                    if (currentGroup.tabSettings?['discussion'] ?? true)
                      DiscussionRoomScreen(),
                    if (currentGroup.tabSettings?['class'] ?? true)
                      ClassRoomScreen(),
                    if (currentGroup.tabSettings?['live_class'] ?? true)
                      LiveClassRoomScreen(groupId: currentGroup.id!),
                    if (currentGroup.tabSettings?['events'] ?? true)
                      EventRoomScreen(),
                    if (currentGroup.tabSettings?['members'] ?? true)
                      MembersRoomScreen(),
                    if (currentGroup.tabSettings?['doubt'] ?? true)
                      DoubtRoomScreen(),
                    if (currentGroup.tabSettings?['challenges'] ?? true)
                      ChallengeRoomScreen(),
                    if (currentGroup.tabSettings?['treasure'] ?? true)
                      TreasureRoomScreen(),
                    if (currentGroup.tabSettings?['product'] ?? true)
                      ProductRoomScreen(),
                    if (currentGroup.tabSettings?['service'] ?? true)
                      ServiceRoomScreen(),
                    if (currentGroup.tabSettings?['job'] ?? true)
                      JobRoomScreen(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 60,
        color: Theme.of(context).colorScheme.surface,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BuildNavItem(
              onTap: () {
                if (currentGroup != null) {
                  ref
                      .read(groupProvider.notifier)
                      .setSelectedGroup(currentGroup);
                }
                context.goNamed(Routes.generalSettings);
              },
              icon: HugeIcon(
                icon: HugeIconsStrokeRounded.home03,
                color: Colors.grey,
              ),
              isSelected: false,
            ),
            _BuildNavItem(
              onTap: () {},
              icon: HugeIcon(
                icon: HugeIconsStrokeRounded.notification01,
                color: Colors.grey,
              ),
              isSelected: false,
            ),
            _BuildNavItem(
              onTap: () => context.goNamed(Routes.chatting),
              icon: HugeIcon(
                icon: HugeIconsStrokeRounded.message02,
                color: Colors.grey,
              ),
              isSelected: false,
            ),
            _BuildNavItem(
              onTap: () {},
              icon: AppDropdown(
                overlayWidth: 140,
                overlayHeight: 160,
                overlayAlignment: Alignment.centerRight,
                gapFromButton: 16,
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
                  child: Icon(Icons.person, color: Colors.white),
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
                        ref.read(authProvider.notifier).signOut();
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
