import 'package:flutter/material.dart';
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
import 'package:larnity/src/core/ui/widgets/app_dropdown.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/features/group/data/models/resource_model.dart';
import 'package:larnity/src/features/group/presentation/provider/resource_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourceCard extends ConsumerWidget {
  final ResourceModel resource;
  final String groupId;

  const ResourceCard({
    Key? key,
    required this.resource,
    required this.groupId,
  }) : super(key: key);

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.darkBgContainer,
        borderRadius: BorderRadius.circular(AppSizes.xs),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppSizes.xs),
              topRight: Radius.circular(AppSizes.xs),
            ),
            child: Image.network(
              resource.resourceImg,
              height: 0.2.sh,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 0.2.sh,
                  color: AppColors.skyBlue.withValues(alpha: 0.1),
                  child: Center(
                    child: HugeIcon(
                      icon: HugeIconsStrokeRounded.image02,
                      color: AppColors.skyBlue,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.sm),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        resource.resourceName,
                        style: AppTextStyles.headline4(color: AppColors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppDropdown(
                      button: const Icon(Icons.more_vert, color: AppColors.white),
                      overlayWidth: 160,
                      overlayAlignment: Alignment.centerRight,
                      onItemSelected: (value) async {
                        if (value == 'delete') {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Resource'),
                              content: const Text('Are you sure?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await ref.read(resourceProvider).deleteResource(
                                  resource.id!,
                                  groupId,
                                );
                          }
                        }
                      },
                      items: [
                        AppDropdownItem(
                          value: "edit",
                          child: Row(
                            children: [
                              HugeIcon(
                                icon: HugeIconsStrokeRounded.edit02,
                                color: AppColors.primaryOrange,
                              ),
                              AppSizes.xxxs.pw,
                              Text(
                                AppStrings.edit,
                                style: AppTextStyles.overLine(
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppDropdownItem(
                          value: "delete",
                          child: Row(
                            children: [
                              HugeIcon(
                                icon: HugeIconsStrokeRounded.delete01,
                                color: AppColors.red,
                              ),
                              AppSizes.xxxs.pw,
                              Text(
                                AppStrings.delete,
                                style: AppTextStyles.overLine(
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                AppSizes.xs.ph,
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    onPressed: () => _launchUrl(context, resource.resourceLink),
                    label: "Access",
                    prefix: HugeIcon(
                      icon: HugeIconsStrokeRounded.cloudDownload,
                      color: AppColors.black,
                    ),
                    labelStyle: AppTextStyles.button(color: AppColors.black),
                    bgColor: AppColors.primaryOrange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
