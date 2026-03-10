import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/extensions/screen_size_extension.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/presentation/widgets/settings/manage_group_tab_card.dart';

class GroupTabSettings extends ConsumerWidget {
  const GroupTabSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(groupProvider).group;
    final tabSettings = group?.tabSettings ?? {};

    void updateSetting(String key, bool value) {
      if (group == null) return;
      
      final newSettings = Map<String, bool>.from(tabSettings);
      newSettings[key] = value;

      ref.read(groupProvider.notifier).updateGroupTabSettings(
        groupId: group.id!,
        tabSettings: newSettings,
      );
    }
    return Padding(
      padding: const EdgeInsets.all(AppSizes.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  context.pop();
                },
                icon: Icon(Icons.close),
              ),
            ],
          ),
          Text(AppStrings.manageGroupTabs, style: AppTextStyles.headline4()),
          Text(
            AppStrings.manageGroupTabsDesc,
            style: AppTextStyles.overLine(color: AppColors.skyBlue),
          ),
          AppSizes.lg.ph,
          SizedBox(
            height: 0.5.sh,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ManageGroupTabCard(
                    icon: HugeIconsStrokeRounded.home03,
                    title: AppStrings.discussionRoom,
                    value: tabSettings['discussion'] ?? true,
                    onSwitch: (val) => updateSetting('discussion', val),
                  ),
                  AppSizes.xs.ph,
                  ManageGroupTabCard(
                    icon: HugeIconsStrokeRounded.geometricShapes01,
                    title: 'Class Room',
                    value: tabSettings['class'] ?? true,
                    onSwitch: (val) => updateSetting('class', val),
                  ),
                  AppSizes.xs.ph,
                  ManageGroupTabCard(
                    icon: HugeIconsStrokeRounded.computerVideo,
                    title: 'Live Class Room',
                    value: tabSettings['live_class'] ?? true,
                    onSwitch: (val) => updateSetting('live_class', val),
                  ),
                  AppSizes.xs.ph,
                  ManageGroupTabCard(
                    icon: HugeIconsStrokeRounded.calendar03,
                    title: 'Events Room',
                    value: tabSettings['events'] ?? true,
                    onSwitch: (val) => updateSetting('events', val),
                  ),
                  AppSizes.xs.ph,
                  ManageGroupTabCard(
                    icon: HugeIconsStrokeRounded.userMultiple,
                    title: 'Members Room',
                    value: tabSettings['members'] ?? true,
                    onSwitch: (val) => updateSetting('members', val),
                  ),
                  AppSizes.xs.ph,
                  ManageGroupTabCard(
                    icon: HugeIconsStrokeRounded.sourceCodeSquare,
                    title: 'Doubt Room',
                    value: tabSettings['doubt'] ?? true,
                    onSwitch: (val) => updateSetting('doubt', val),
                  ),
                  AppSizes.xs.ph,
                  ManageGroupTabCard(
                    icon: HugeIconsStrokeRounded.adventure,
                    title: 'Challenges Room',
                    value: tabSettings['challenges'] ?? true,
                    onSwitch: (val) => updateSetting('challenges', val),
                  ),
                  AppSizes.xs.ph,
                  ManageGroupTabCard(
                    icon: HugeIconsStrokeRounded.notebook02,
                    title: 'Treasure Room',
                    value: tabSettings['treasure'] ?? true,
                    onSwitch: (val) => updateSetting('treasure', val),
                  ),
                  AppSizes.xs.ph,
                  ManageGroupTabCard(
                    icon: HugeIconsStrokeRounded.shoppingBag01,
                    title: 'Product Room',
                    value: tabSettings['product'] ?? true,
                    onSwitch: (val) => updateSetting('product', val),
                  ),
                  AppSizes.xs.ph,
                  ManageGroupTabCard(
                    icon: HugeIconsStrokeRounded.documentValidation,
                    title: 'Service Room',
                    value: tabSettings['service'] ?? true,
                    onSwitch: (val) => updateSetting('service', val),
                  ),
                  AppSizes.xs.ph,
                  ManageGroupTabCard(
                    icon: HugeIconsStrokeRounded.id,
                    title: 'Job Room',
                    value: tabSettings['job'] ?? true,
                    onSwitch: (val) => updateSetting('job', val),
                  ),
                  AppSizes.xs.ph,

                  AppButton(
                    label: AppStrings.resetAllToDefault,
                    labelStyle: AppTextStyles.bodyText2(color: AppColors.white),
                    bgColor: AppColors.darkBrown,
                    radius: AppSizes.xxxs,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
