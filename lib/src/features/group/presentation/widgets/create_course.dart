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
import 'package:larnity/src/core/ui/widgets/dialog_header.dart';

class CreateCourse extends StatelessWidget {
  const CreateCourse({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.xs),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            DialogHeader(
              title: AppStrings.createNewCourse,
              description: AppStrings.createNewCourseDesc,
            ),
            Text(AppStrings.courseName, style: AppTextStyles.overLine()),
            AppSizes.xxxs.ph,
            TextFormField(
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.darkBgContainer,
                hintText: AppStrings.courseNameHint,
                hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
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

            AppSizes.xs.ph,
            Text(AppStrings.courseDescription, style: AppTextStyles.overLine()),
            AppSizes.xxxs.ph,
            TextFormField(
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.darkBgContainer,
                hintText: AppStrings.courseDescriptionHint,
                hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
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
              maxLines: 5,
              minLines: 2,
            ),
            AppSizes.xs.ph,
            Text(AppStrings.courseAccess, style: AppTextStyles.overLine()),
            AppSizes.xxxs.ph,
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    bgColor: AppColors.white.withValues(alpha: 0.1),
                    label: AppStrings.public,
                  ),
                ),
                AppSizes.xs.pw,
                Expanded(
                  child: AppButton(
                    bgColor: AppColors.white.withValues(alpha: 0.1),
                    label: AppStrings.paid,
                  ),
                ),
              ],
            ),
            AppSizes.xs.ph,
            Text(AppStrings.coursePrice, style: AppTextStyles.overLine()),
            AppSizes.xxxs.ph,
            TextFormField(
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.darkBgContainer,
                hintText: AppStrings.coursePriceHint,
                hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
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
            AppSizes.xs.ph,
            Text(AppStrings.courseThumbnail, style: AppTextStyles.overLine()),
            AppSizes.xxxs.ph,
            Container(
              height: 0.2.sh,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.skyBlue.withValues(alpha: 0.5),
                ),
                borderRadius: BorderRadius.circular(AppSizes.xs),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HugeIcon(
                    icon: HugeIconsStrokeRounded.image02,
                    color: AppColors.creamWhite,
                    size: 40,
                  ),
                  AppSizes.xs.ph,
                  Text(
                    AppStrings.clickToUpload,
                    style: AppTextStyles.overLine(color: AppColors.creamWhite),
                  ),
                  Text(
                    "${AppStrings.fileType} (Max 5MB)",
                    style: AppTextStyles.caption2(
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  Text(
                    AppStrings.max400x400,
                    style: AppTextStyles.caption2(
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            AppSizes.xs.ph,

            AppButton(
              onPressed: () {},
              label: AppStrings.create,
              labelStyle: AppTextStyles.bodyText2(color: AppColors.white),
              bgColor: Colors.transparent,
              borderColor: AppColors.skyBlue.withValues(alpha: 0.5),
              radius: AppSizes.xxxs,
            ),
          ],
        ),
      ),
    );
  }
}
