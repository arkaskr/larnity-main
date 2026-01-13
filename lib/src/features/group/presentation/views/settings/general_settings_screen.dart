import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/extensions/screen_size_extension.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/ui/widgets/app_dropdown.dart';
import 'package:larnity/src/core/ui/widgets/app_dropdown_slash_editor.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/core/utils/show_snackbar.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';

class GeneralSettingsScreen extends ConsumerStatefulWidget {
  const GeneralSettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<GeneralSettingsScreen> createState() =>
      _GeneralSettingsScreenState();
}

class _GeneralSettingsScreenState extends ConsumerState<GeneralSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final groupState = ref.read(groupProvider);
      print("🔍 DEBUG: Group in state = ${groupState.group?.id}"); // ✅ Add this
      if (groupState.group == null) {
        showErrorToast(
          content: "No group selected. Please select a group first.",
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final groupState = ref.watch(groupProvider);
    final groupNotifier = ref.read(groupProvider.notifier);
    final currentGroup = groupState.group;

    if (currentGroup == null) {
      return Scaffold(
        backgroundColor: AppColors.darkBg,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "No group selected",
                style: AppTextStyles.headline3(color: AppColors.white),
              ),
              AppSizes.xs.ph,
              Text(
                "Please select a group from the menu",
                style: AppTextStyles.bodyText1(
                  color: AppColors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSizes.xs.ph,
              Text(
                AppStrings.groupSettings,
                style: AppTextStyles.headline1(color: AppColors.white),
              ),
              AppSizes.xxxs.ph,
              Text(AppStrings.groupSettingsDesc),
              AppSizes.xxxlg.ph,

              // Group URL Share Section
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.xxs,
                  vertical: AppSizes.xxxs,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.skyBlue.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.xxxs),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "https://www.larnity.com/about/${currentGroup?.slug ?? 'group'}",
                        style: AppTextStyles.overLine(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppSizes.xs.pw,
                    AppButton(
                      height: 40,
                      isExpanded: false,
                      onPressed: () {},
                      label: "Share",
                      labelStyle: AppTextStyles.bodyText2(
                        color: AppColors.white,
                      ),
                      borderColor: AppColors.skyBlue.withValues(alpha: 0.5),
                      bgColor: Colors.transparent,
                      radius: AppSizes.xxxs,
                    ),
                  ],
                ),
              ),
              AppSizes.xxxlg.ph,

              // Thumbnail Section
              Text(
                AppStrings.groupThumbnail,
                style: AppTextStyles.headline4(color: AppColors.white),
              ),
              AppSizes.xxlg.ph,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      height: 0.2.sh,
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange,
                        borderRadius: BorderRadius.circular(AppSizes.xxxs),
                        image: _getThumbnailImage(groupState, currentGroup),
                      ),
                      child:
                          _getThumbnailImage(groupState, currentGroup) == null
                          ? Center(
                              child: Icon(
                                Icons.image,
                                size: 60,
                                color: AppColors.white.withValues(alpha: 0.5),
                              ),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
              AppSizes.xxlg.ph,
              AppButton(
                onPressed: () {
                  groupNotifier.pickThumbnail();
                },
                bgColor: AppColors.darkBgContainer,
                label: AppStrings.changeThumbnail,
                labelStyle: AppTextStyles.button(color: AppColors.white),
              ),
              AppSizes.xxxlg.ph,

              // Privacy Section
              Text(
                AppStrings.groupPrivacy,
                style: AppTextStyles.headline5(color: AppColors.white),
              ),
              AppSizes.xxxs.ph,
              AppDropdown(
                button: Container(
                  padding: EdgeInsets.all(AppSizes.xs),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.skyBlue.withValues(alpha: 0.5),
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.xs),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currentGroup?.privacy?.name ?? "PRIVATE",
                        style: AppTextStyles.bodyText2(color: AppColors.white),
                      ),
                      Icon(Icons.keyboard_arrow_down, color: AppColors.white),
                    ],
                  ),
                ),
                items: [
                  AppDropdownItem(value: "private", label: "PRIVATE"),
                  AppDropdownItem(value: "public", label: "PUBLIC"),
                ],
              ),
              AppSizes.lg.ph,

              // Group Icon Section
              Text(
                "Group Icon",
                style: AppTextStyles.headline5(color: AppColors.white),
              ),
              AppSizes.lg.ph,
              Container(
                height: 0.2.sh,
                width: 0.2.sh,
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange,
                  borderRadius: BorderRadius.circular(AppSizes.xs),
                  image: _getIconImage(groupState, currentGroup),
                ),
                child: _getIconImage(groupState, currentGroup) == null
                    ? Center(
                        child: Icon(
                          Icons.image,
                          size: 60,
                          color: AppColors.white.withValues(alpha: 0.5),
                        ),
                      )
                    : null,
              ),
              AppSizes.xs.ph,
              AppButton(
                isExpanded: false,
                onPressed: () {
                  groupNotifier.pickIcon();
                },
                bgColor: AppColors.darkBgContainer,
                label: "Change Icon",
                labelStyle: AppTextStyles.button(color: AppColors.white),
              ),
              AppSizes.xxlg.ph,

              // Group Name
              Text(
                AppStrings.groupName,
                style: AppTextStyles.headline5(color: AppColors.white),
              ),
              AppSizes.xxxs.ph,
              TextFormField(
                initialValue: currentGroup?.name,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.darkBgContainer,
                  hintText: "Group Name",
                  hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.xxxs),
                    borderSide: BorderSide(color: AppColors.skyBlue),
                  ),
                ),
              ),
              AppSizes.lg.ph,

              // Group Slug
              Text(
                AppStrings.groupSlug,
                style: AppTextStyles.headline5(color: AppColors.white),
              ),
              AppSizes.xxxs.ph,
              TextFormField(
                initialValue: currentGroup?.slug,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.darkBgContainer,
                  hintText: "group-slug",
                  hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.xxxs),
                    borderSide: BorderSide(color: AppColors.skyBlue),
                  ),
                ),
              ),
              AppSizes.xxlg.ph,

              // Group Description
              Text(
                AppStrings.groupDesc,
                style: AppTextStyles.headline5(color: AppColors.white),
              ),
              AppSizes.xxxs.ph,
              AppDropdownSlashEditor(),
              AppSizes.xxlg.ph,

              // Show Group Name Toggle
              SwitchListTile(
                controlAffinity: ListTileControlAffinity.leading,
                value: true,
                onChanged: (val) {},
                title: Text(AppStrings.groupNameShown),
              ),
              AppSizes.lg.ph,

              // Save Changes Button
              AppButton(
                isLoading: groupState.updateState == AsyncState.loading,
                onPressed: () async {
                  if (currentGroup?.id == null) {
                    showErrorToast(content: "No group selected");
                    return;
                  }
                  
                  bool hasChanges = false;
                  
                  // Update thumbnail if selected
                  if (groupState.selectedThumbnail != null) {
                    hasChanges = true;
                    await groupNotifier.fetchGroupById(currentGroup!.id!);
                    await groupNotifier.updateGroupThumbnail(
                      groupId: currentGroup!.id!,
                      successCallBack: () {
                        showSuccessToast(
                          content: "Thumbnail updated successfully",
                        );
                      },
                      failureCallBack: (error) {
                        showErrorToast(content: error);
                      },
                    );
                  }
                  
                  // Update icon if selected
                  if (groupState.selectedIcon != null) {
                    hasChanges = true;
                    await groupNotifier.fetchGroupById(currentGroup!.id!);
                    await groupNotifier.updateGroupIcon(
                      groupId: currentGroup!.id!,
                      successCallBack: () {
                        showSuccessToast(
                          content: "Icon updated successfully",
                        );
                      },
                      failureCallBack: (error) {
                        showErrorToast(content: error);
                      },
                    );
                  }
                  
                  if (!hasChanges) {
                    showErrorToast(content: "Please select a thumbnail or icon to update");
                  }
                },
                bgColor: AppColors.primaryOrange,
                label: AppStrings.saveChanges,
                labelStyle: AppTextStyles.button(color: AppColors.black),
              ),
              AppSizes.xxxlg.ph,
            ],
          ),
        ),
      ),
    );
  }

  DecorationImage? _getThumbnailImage(groupState, currentGroup) {
    // Priority: selectedThumbnail (local file) > existing thumbnail URL
    if (groupState.selectedThumbnail != null) {
      return DecorationImage(
        image: FileImage(File(groupState.selectedThumbnail!.path)),
        fit: BoxFit.cover,
      );
    } else if (currentGroup?.thumbnail != null) {
      return DecorationImage(
        image: NetworkImage(currentGroup!.thumbnail!),
        fit: BoxFit.cover,
      );
    }
    return null;
  }

  DecorationImage? _getIconImage(groupState, currentGroup) {
    // Priority: selectedIcon (local file) > existing icon URL
    if (groupState.selectedIcon != null) {
      return DecorationImage(
        image: FileImage(File(groupState.selectedIcon!.path)),
        fit: BoxFit.cover,
      );
    } else if (currentGroup?.icon != null) {
      return DecorationImage(
        image: NetworkImage(currentGroup!.icon!),
        fit: BoxFit.cover,
      );
    }
    return null;
  }
}
