import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/ui/widgets/app_dropdown_slash_editor.dart';

class CreatePost extends StatelessWidget {
  const CreatePost({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryOrange,
                ),
              ),
              AppSizes.xs.pw,
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: AppStrings.postingIn,
                      style: AppTextStyles.subtitle2(color: AppColors.white),
                    ),
                    TextSpan(
                      text: "General",
                      style: AppTextStyles.subtitle1(color: AppColors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSizes.lg.ph,
          TextFormField(
            decoration: InputDecoration(
              // filled: true,
              // fillColor: AppColors.darkBgContainer,
              hintText: AppStrings.postTitle,
              hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.xxxs),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.xxxs),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          AppSizes.xs.ph,
          AppDropdownSlashEditor(),
          AppSizes.lg.ph,
          Row(
            children: [
              TextButton(
                onPressed: () {},
                child: Text(
                  AppStrings.shareWithGroup,
                  style: AppTextStyles.subtitle2(),
                ),
              ),
              Spacer(),
              AppButton(
                onPressed: () {
                  context.pop();
                },
                isExpanded: false,
                bgColor: Colors.transparent,
                label: AppStrings.close,
                labelStyle: AppTextStyles.button(color: AppColors.white),
              ),
            ],
          ),
          AppSizes.xs.ph,
          AppButton(
            onPressed: () {},

            bgColor: AppColors.white,
            suffix: HugeIcon(
              icon: HugeIconsStrokeRounded.plane,
              color: AppColors.black,
            ),
            label: AppStrings.post,
            labelStyle: AppTextStyles.button(color: AppColors.black),
          ),
        ],
      ),
    );
  }
}
