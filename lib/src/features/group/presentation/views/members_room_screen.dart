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
                  // Add a settings button that opens a dialog with "Go to Settings" option
                  IconButton(
                    icon: HugeIcon(
                      icon: HugeIconsStrokeRounded.settings01,
                      color: AppColors.white,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: AppColors.darkBg,
                            title: Text(
                              'Options',
                              style: AppTextStyles.headline4(color: AppColors.white),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  title: Text(
                                    'Go to Settings',
                                    style: AppTextStyles.bodyText1(color: AppColors.white),
                                  ),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    context.pushNamed(Routes.profileSettings);
                                  },
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  'Cancel',
                                  style: AppTextStyles.button(color: AppColors.primaryOrange),
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
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.darkBgContainer,
                  hintText: AppStrings.searchMembers,
                  hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
                  prefixIcon: HugeIcon(
                    icon: HugeIconsStrokeRounded.search01,
                    color: AppColors.white,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.xxxs),
                    borderSide: BorderSide(
                      color: AppColors.skyBlue.withValues(alpha: 0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.xxxs),
                    borderSide: BorderSide(color: AppColors.skyBlue),
                  ),
                ),
              ),
              AppSizes.xxxlg.ph,
              // Display groups instead of user profiles
              if (groupState.fetchState == AsyncState.loading)
                Center(child: CircularProgressIndicator())
              else if (groupState.fetchState == AsyncState.failure)
                Center(child: Text('Failed to load groups'))
              else if (groupState.groups != null && groupState.groups!.isNotEmpty)
                Column(
                  children: groupState.groups!.map((group) {
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(AppSizes.xs),
                      margin: EdgeInsets.only(bottom: AppSizes.xs),
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
                              // Group icon
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                              // Settings button for each group
                              IconButton(
                                icon: HugeIcon(
                                  icon: HugeIconsStrokeRounded.settings01,
                                  color: AppColors.white,
                                ),
                                onPressed: () {
                                  // Show group settings dialog
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        backgroundColor: AppColors.darkBg,
                                        title: Text(
                                          'Group Options',
                                          style: AppTextStyles.headline4(color: AppColors.white),
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              title: Text(
                                                'Go to Group Settings',
                                                style: AppTextStyles.bodyText1(color: AppColors.white),
                                              ),
                                              onTap: () {
                                                Navigator.of(context).pop();
                                                // Navigate to group settings page with group ID
                                                context.pushNamed(
                                                  Routes.groupDetails,
                                                  extra: group,
                                                );
                                              },
                                            ),
                                            ListTile(
                                              title: Text(
                                                'View Members',
                                                style: AppTextStyles.bodyText1(color: AppColors.white),
                                              ),
                                              onTap: () {
                                                Navigator.of(context).pop();
                                                // Could navigate to a members list page
                                              },
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text(
                                              'Cancel',
                                              style: AppTextStyles.button(color: AppColors.primaryOrange),
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
                          // Group stats
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  HugeIcon(
                                    icon: HugeIconsStrokeRounded.userMultiple02,
                                    color: AppColors.white,
                                    size: 16,
                                  ),
                                  AppSizes.xxxs.pw,
                                  Text(
                                    "0 members", // Would be actual member count in real implementation
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
                          // Action buttons
                          Row(
                            children: [
                              Expanded(
                                child: AppButton(
                                  onPressed: () {
                                    // Join group functionality
                                  },
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
                                  onPressed: () {
                                    context.pushNamed(Routes.chatting);
                                  },
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
                  }).toList(),
                )
              else
                Center(child: Text('No groups found')),
            ],
          ),
        ),
      ),
    );
  }
}