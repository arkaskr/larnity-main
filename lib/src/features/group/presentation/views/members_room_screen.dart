import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/extensions/screen_size_extension.dart';
import 'package:larnity/src/core/router/router.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/auth/presentation/provider/auth_provider.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/group/data/models/group_model.dart';

class MembersRoomScreen extends ConsumerWidget {
  const MembersRoomScreen({Key? key}) : super(key: key);

  // ✅ Separate method for start chat
  void _handleStartChat(BuildContext context, WidgetRef ref, dynamic group) {
    // Check if context is still valid
    if (!context.mounted) return;

    try {
      ref.read(groupProvider.notifier).setSelectedGroup(group);

      // Small delay to ensure state is set
      Future.microtask(() {
        if (context.mounted) {
          context.pushNamed(Routes.chatting);
        }
      });
    } catch (e) {
      debugPrint('Error in start chat: $e');
    }
  }

  // ✅ Separate method for join group
  Future<void> _handleJoinGroup(
    BuildContext context,
    WidgetRef ref,
    dynamic group,
    String? userId,
  ) async {
    if (!context.mounted) return;

    if (userId == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if group is paid
    if (group.monthlyPrice != null ||
        group.yearlyPrice != null ||
        group.lifetimePrice != null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment feature coming soon'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Free group - join directly
      final success = await ref
          .read(groupProvider.notifier)
          .joinGroup(groupId: group.id!);

      if (!context.mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Successfully joined ${group.name}!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final error = ref.read(groupProvider).error ?? 'Failed to join';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupState = ref.watch(groupProvider);
    final authState = ref.watch(authProvider);

    // Get current user
    final currentUser = authState.user;

    return Scaffold(
      endDrawer: Drawer(
        child: Container(
          color: AppColors.darkBg,
          child: Column(
            children: [
              AppSizes.xxxlg.ph,
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: HugeIcon(
                    icon: HugeIconsStrokeRounded.cancel01,
                    color: AppColors.white,
                  ),
                ),
              ),
              AppSizes.xxxlg.ph,
              Text(
                AppStrings.eventDetails,
                style: AppTextStyles.headline2(color: AppColors.white),
              ),
              AppSizes.xs.ph,
              Text(
                AppStrings.eventDetailsDesc,
                style: AppTextStyles.overLine(),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.xs),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.groupMembers,
                        style: AppTextStyles.headline2(color: AppColors.white),
                      ),
                      Text(
                        AppStrings.membersInTheGroup,
                        style: AppTextStyles.overLine(),
                      ),
                    ],
                  ),
                  Spacer(),
                  IconButton(
                    icon: HugeIcon(
                      icon: HugeIconsStrokeRounded.settings01,
                      color: AppColors.white,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            backgroundColor: AppColors.darkBg,
                            title: Text(
                              'Options',
                              style: AppTextStyles.headline4(
                                color: AppColors.white,
                              ),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  title: Text(
                                    'Go to Settings',
                                    style: AppTextStyles.bodyText1(
                                      color: AppColors.white,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.of(dialogContext).pop();
                                    if (context.mounted) {
                                      context.pushNamed(Routes.profileSettings);
                                    }
                                  },
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(dialogContext).pop();
                                },
                                child: Text(
                                  'Cancel',
                                  style: AppTextStyles.button(
                                    color: AppColors.primaryOrange,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              AppSizes.xxxlg.ph,
              TextFormField(
                style: AppTextStyles.bodyText1(color: AppColors.white),
                cursorColor: AppColors.primaryOrange,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.darkBgContainer.withValues(alpha: 0.8),
                  hintText: AppStrings.searchMembers,
                  hintStyle: AppTextStyles.bodyText2(
                    color: AppColors.creamWhite.withValues(alpha: 0.6),
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: HugeIcon(
                      icon: HugeIconsStrokeRounded.search01,
                      color: AppColors.creamWhite.withValues(alpha: 0.7),
                      size: 20,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.primaryOrange,
                      width: 1.2,
                    ),
                  ),
                ),
              ),
              AppSizes.xxxlg.ph,
              // Display groups
              if (groupState.fetchState == AsyncState.loading)
                const Center(child: CircularProgressIndicator())
              else if (groupState.fetchState == AsyncState.failure)
                const Center(child: Text('Failed to load groups'))
              else if (groupState.groups != null &&
                  groupState.groups!.isNotEmpty)
                Column(
                  children: groupState.groups!
                      .where((group) => group.userId == currentUser?.id)
                      .map((group) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSizes.xs),
                          margin: const EdgeInsets.only(bottom: AppSizes.xs),
                          decoration: BoxDecoration(
                            color: AppColors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(AppSizes.xs),
                            border: Border.all(
                              color: AppColors.primaryOrange,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryOrange,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: group.icon != null
                                        ? Image.network(
                                            group.icon!,
                                            fit: BoxFit.contain,
                                          )
                                        : Icon(
                                            Icons.group,
                                            color: AppColors.white,
                                          ),
                                  ),
                                  AppSizes.xs.pw,
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          group.name,
                                          style: AppTextStyles.headline3(),
                                        ),
                                        if (group.category != null)
                                          Text(
                                            group.category!,
                                            style: AppTextStyles.overLine(
                                              color: AppColors.creamWhite,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: HugeIcon(
                                      icon: HugeIconsStrokeRounded.settings01,
                                      color: AppColors.white,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext dialogContext) {
                                          return AlertDialog(
                                            backgroundColor: AppColors.darkBg,
                                            title: Text(
                                              'Group Options',
                                              style: AppTextStyles.headline4(
                                                color: AppColors.white,
                                              ),
                                            ),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                ListTile(
                                                  title: Text(
                                                    'Go to Group Settings',
                                                    style:
                                                        AppTextStyles.bodyText1(
                                                          color:
                                                              AppColors.white,
                                                        ),
                                                  ),
                                                  onTap: () {
                                                    Navigator.of(
                                                      dialogContext,
                                                    ).pop();
                                                    if (context.mounted) {
                                                      context.pushNamed(
                                                        Routes.groupDetails,
                                                        extra: group,
                                                      );
                                                    }
                                                  },
                                                ),
                                                ListTile(
                                                  title: Text(
                                                    'View Members',
                                                    style:
                                                        AppTextStyles.bodyText1(
                                                          color:
                                                              AppColors.white,
                                                        ),
                                                  ),
                                                  onTap: () {
                                                    Navigator.of(
                                                      dialogContext,
                                                    ).pop();
                                                  },
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(
                                                    dialogContext,
                                                  ).pop();
                                                },
                                                child: Text(
                                                  'Cancel',
                                                  style: AppTextStyles.button(
                                                    color:
                                                        AppColors.primaryOrange,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                              AppSizes.xs.ph,
                              if (group.description != null)
                                Text(
                                  group.description!,
                                  style: AppTextStyles.bodyText2(
                                    color: AppColors.creamWhite,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              AppSizes.xs.ph,
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      HugeIcon(
                                        icon: HugeIconsStrokeRounded
                                            .userMultiple02,
                                        color: AppColors.white,
                                        size: 16,
                                      ),
                                      AppSizes.xxxs.pw,
                                      Text(
                                        "0 members",
                                        style: AppTextStyles.caption2(),
                                      ),
                                    ],
                                  ),
                                  if (group.createdAt != null)
                                    Text(
                                      "Created: ${group.createdAt!.toLocal().toString().split(' ')[0]}",
                                      style: AppTextStyles.caption2(
                                        color: AppColors.creamWhite,
                                      ),
                                    ),
                                ],
                              ),
                              AppSizes.xxxlg.ph,
                              Row(
                                children: [
                                  Expanded(
                                    child: AppButton(
                                      onPressed: () => _handleJoinGroup(
                                        context,
                                        ref,
                                        group,
                                        currentUser?.id,
                                      ),
                                      label: "Join Group",
                                      labelStyle: AppTextStyles.caption2(
                                        color: AppColors.black,
                                      ),
                                      bgColor: AppColors.primaryOrange,
                                    ),
                                  ),
                                  AppSizes.xs.pw,
                                  Expanded(
                                    child: AppButton(
                                      onPressed: () =>
                                          _handleStartChat(context, ref, group),
                                      label: AppStrings.startChat,
                                      prefix: HugeIcon(
                                        icon: HugeIconsStrokeRounded.message02,
                                        color: AppColors.black,
                                      ),
                                      labelStyle: AppTextStyles.caption2(
                                        color: AppColors.black,
                                      ),
                                      bgColor: AppColors.primaryOrange,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      })
                      .toList(),
                )
              else
                const Center(child: Text('No groups found')),
            ],
          ),
        ),
      ),
    );
  }
}
