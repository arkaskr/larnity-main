import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';

class GoogleSheetIntegration extends ConsumerStatefulWidget {
  final String groupId;
  
  const GoogleSheetIntegration({Key? key, required this.groupId}) : super(key: key);

  @override
  ConsumerState<GoogleSheetIntegration> createState() => _GoogleSheetIntegrationState();
}

class _GoogleSheetIntegrationState extends ConsumerState<GoogleSheetIntegration> {
  bool _enableSync = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load current settings
    final group = ref.read(groupProvider).group;
    if (group != null) {
      _enableSync = group.enableGoogleSheetSync ?? false;
    }
  }

  void _saveSettings() {
    setState(() => _isLoading = true);

    ref.read(groupProvider.notifier).updateGoogleSheetSettings(
      groupId: widget.groupId,
      googleSheetId: null, // Can be added later with a text field
      enableSync: _enableSync,
      successCallBack: () {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved successfully!')),
        );
        context.pop();
      },
      failureCallBack: (error) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
          Text(
            AppStrings.googleSheetIntegration,
            style: AppTextStyles.headline4(),
          ),
          Text(
            AppStrings.googleSheetIntegrationDialogDesc,
            style: AppTextStyles.overLine(color: AppColors.skyBlue),
          ),
          AppSizes.lg.ph,
          Container(
            padding: EdgeInsets.all(AppSizes.xs),
            decoration: BoxDecoration(
              color: AppColors.borderBrown,
              borderRadius: BorderRadius.circular(AppSizes.xxxs),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSizes.xxxs),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: AppColors.white.withValues(alpha: 0.1),
                      ),
                      child: Center(
                        child: HugeIcon(
                          icon: HugeIconsStrokeRounded.googleSheet,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                    ),
                    AppSizes.xxxs.pw,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.notConnected,
                            style: AppTextStyles.headline4(),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  AppStrings.notConnectedDesc,
                                  style: AppTextStyles.overLine(
                                    color: AppColors.skyBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppSizes.xs.ph,
          Container(
            padding: EdgeInsets.all(AppSizes.xs),
            decoration: BoxDecoration(
              color: AppColors.borderBrown,
              borderRadius: BorderRadius.circular(AppSizes.xxxs),
            ),
            child: CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _enableSync,
              onChanged: (val) {
                setState(() {
                  _enableSync = val ?? false;
                });
              },
              title: Text(AppStrings.enableGoogleSheetSync),
              subtitle: Text(AppStrings.enableGoogleSheetSyncDesc),
            ),
          ),
          AppSizes.xs.ph,

          AppButton(
            onPressed: _isLoading ? null : _saveSettings,
            label: _isLoading ? 'Saving...' : AppStrings.saveSettings,
            labelStyle: AppTextStyles.bodyText2(color: AppColors.black),
            bgColor: AppColors.primaryOrange,
            radius: AppSizes.xxxs,
          ),
        ],
      ),
    );
  }
}
