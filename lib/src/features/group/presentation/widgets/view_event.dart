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

class ViewEvent extends StatelessWidget {
  const ViewEvent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 0.2.sh,
          decoration: BoxDecoration(
            color: AppColors.primaryOrange,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppSizes.xs),
              topRight: Radius.circular(AppSizes.xs),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSizes.xs),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Event Name", style: AppTextStyles.overLine()),

                  AppDropdown(
                    button: Icon(Icons.more_horiz, color: AppColors.white),
                    overlayWidth: 160,
                    overlayAlignment: Alignment.centerRight,
                    items: [
                      AppDropdownItem(
                        value: "edit",
                        child: Row(
                          children: [
                            HugeIcon(
                              icon: HugeIconsStrokeRounded.edit03,
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
              Row(
                children: [
                  HugeIcon(
                    icon: HugeIconsStrokeRounded.calendar04,
                    color: AppColors.white,
                  ),
                  AppSizes.xs.pw,
                  Text(
                    "Friday, September 19, 2025",
                    style: AppTextStyles.overLine(),
                  ),
                ],
              ),
              AppSizes.xs.ph,
              Row(
                children: [
                  HugeIcon(
                    icon: HugeIconsStrokeRounded.clock01,
                    color: AppColors.white,
                  ),
                  AppSizes.xs.pw,
                  Text(
                    "Friday, September 19, 2025",
                    style: AppTextStyles.overLine(),
                  ),
                ],
              ),
              AppSizes.xs.ph,
              Row(
                children: [
                  HugeIcon(
                    icon: HugeIconsStrokeRounded.link05,
                    color: AppColors.white,
                  ),
                  AppSizes.xs.pw,
                  Text(
                    "https://bento.me/srksifat",
                    style: AppTextStyles.overLine(),
                  ),
                ],
              ),
              AppSizes.xs.ph,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    isExpanded: false,
                    onPressed: () {
                      context.pop();
                    },
                    label: AppStrings.close,
                    labelStyle: AppTextStyles.button(color: AppColors.white),
                    bgColor: Colors.transparent,
                    borderColor: AppColors.skyBlue.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
