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
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xs),
          child: Column(
            children: [
              AppSizes.xxxlg.ph,
              // Group Selector Dropdown
              AppDropdown(
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
                      Expanded(
                        child: Text(
                          currentGroup.name,
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
                overlayHeight: 1 * 70 + 120,
                overlayRadius: AppSizes.xs,
                top: Padding(
                  padding: const EdgeInsets.all(AppSizes.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Groups',
                        style: AppTextStyles.subtitle1(color: AppColors.white),
                      ),
                      Divider(color: AppColors.borderBrown),
                      AppSizes.xs.ph,
                      GestureDetector(
                        onTap: () {
                          context.goNamed(Routes.explore);
                        },
                        child: Row(
                          children: [
                            Icon(Icons.explore_outlined, color: Colors.grey),
                            8.pw,
                            Text("Explore Groups"),
                          ],
                        ),
                      ),
                      Divider(color: AppColors.borderBrown),
                    ],
                  ),
                ),
                items: groups.map((group) {
                  return AppDropdownItem(
                    value: group.id,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        ref
                            .read(groupProvider.notifier)
                            .setSelectedGroup(group);
                        if (group.id != null) {
                          context.go('/group/${group.id}');
                        }
                      },
                      child: Row(
                        children: [
                          group.icon != null
                              ? SmartImage(
                                  group.icon,
                                  width: 20,
                                  height: 20,
                                  fit: BoxFit.contain,
                                )
                              : HugeIcon(
                                  icon: HugeIconsStrokeRounded.user,
                                  color: AppColors.white,
                                  size: 20,
                                ),
                          8.pw,
                          Text(group.name),
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
              ),
            ],
          ),
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
                  AppSegmentedButtonItem(
                    label: "Discussion Room",
                    prefixIcon: HugeIconsStrokeRounded.home03,
                  ),
                  AppSegmentedButtonItem(
                    label: "Class Room",
                    prefixIcon: HugeIconsStrokeRounded.geometricShapes01,
                  ),
                  AppSegmentedButtonItem(
                    label: "Live Class Room",
                    prefixIcon: HugeIconsStrokeRounded.computerVideo,
                  ),
                  AppSegmentedButtonItem(
                    label: "Events Room",
                    prefixIcon: HugeIconsStrokeRounded.calendar03,
                  ),
                  AppSegmentedButtonItem(
                    label: "Members Room",
                    prefixIcon: HugeIconsStrokeRounded.userMultiple,
                  ),
                  AppSegmentedButtonItem(
                    label: "Doubt Room",
                    prefixIcon: HugeIconsStrokeRounded.sourceCodeSquare,
                  ),
                  AppSegmentedButtonItem(
                    label: "Challenges Room",
                    prefixIcon: HugeIconsStrokeRounded.adventure,
                  ),
                  AppSegmentedButtonItem(
                    label: "Treasure Room",
                    prefixIcon: HugeIconsStrokeRounded.notebook02,
                  ),
                  AppSegmentedButtonItem(
                    label: "Product Room",
                    prefixIcon: HugeIconsStrokeRounded.shoppingBag01,
                  ),
                  AppSegmentedButtonItem(
                    label: "Service Room",
                    prefixIcon: HugeIconsStrokeRounded.documentValidation,
                  ),
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
                    DiscussionRoomScreen(),
                    ClassRoomScreen(),
                    LiveClassRoomScreen(groupId: currentGroup.id!),
                    EventRoomScreen(),
                    MembersRoomScreen(),
                    DoubtRoomScreen(),
                    ChallengeRoomScreen(),
                    TreasureRoomScreen(),
                    ProductRoomScreen(),
                    ServiceRoomScreen(),
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
