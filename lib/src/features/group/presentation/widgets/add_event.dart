import 'package:flutter/material.dart';
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
import 'package:larnity/src/core/ui/widgets/app_dropdown_datepicker.dart';
import 'package:larnity/src/core/ui/widgets/app_dropdown_timepicker.dart';
import 'package:larnity/src/core/ui/widgets/dialog_header.dart';

class AddEvent extends StatelessWidget {
  const AddEvent({Key? key}) : super(key: key);

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
              title: AppStrings.addEvent,
              description: AppStrings.addEventDesc,
            ),

            Container(
              padding: EdgeInsets.all(AppSizes.xs),
              decoration: BoxDecoration(
                color: AppColors.iconColor,
                borderRadius: BorderRadius.circular(AppSizes.xxxs),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSizes.xs.ph,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSizes.xxxs),
                        ),
                        child: Center(
                          child: HugeIcon(
                            icon: HugeIconsStrokeRounded.calendar04,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                      ),
                      AppSizes.xs.pw,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.eventDetails,
                              style: AppTextStyles.headline2(
                                color: AppColors.white,
                              ),
                            ),

                            Text(
                              AppStrings.eventDetailsDesc,
                              style: AppTextStyles.overLine(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  AppSizes.xs.ph,
                  Text(AppStrings.title, style: AppTextStyles.overLine()),
                  AppSizes.xxxs.ph,
                  TextFormField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.darkBgContainer,
                      hintText: AppStrings.enterTitle,
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
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppSizes.xs.ph,
                            Text(
                              AppStrings.date,
                              style: AppTextStyles.overLine(),
                            ),
                            AppSizes.xxxs.ph,
                            Row(
                              children: [
                                Expanded(
                                  child: DatePickerDropdown(
                                    overlayHeight: 300,
                                    button: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          AppSizes.xxxs,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("mm/dd/yyyy"),
                                          HugeIcon(
                                            icon: HugeIconsStrokeRounded
                                                .calendar03,
                                            color: AppColors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      AppSizes.xs.pw,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppSizes.xs.ph,
                            Text(
                              AppStrings.time,
                              style: AppTextStyles.overLine(),
                            ),
                            AppSizes.xxxs.ph,
                            Row(
                              children: [
                                Expanded(
                                  child: TimePickerDropdown(
                                    overlayAlignment: Alignment.centerRight,
                                    onTimeSelected: (p0) {
                                      print("Time: ${p0}");
                                    },
                                    button: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          AppSizes.xxxs,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("--:--:--"),
                                          HugeIcon(
                                            icon:
                                                HugeIconsStrokeRounded.clock01,
                                            color: AppColors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                    selectedTimeDecoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.white,
                                      ),
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
                color: AppColors.iconColor,
                borderRadius: BorderRadius.circular(AppSizes.xxxs),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSizes.xxxs),
                        ),
                        child: Center(
                          child: HugeIcon(
                            icon: HugeIconsStrokeRounded.location06,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                      ),
                      AppSizes.xs.pw,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.locationAndLink,
                              style: AppTextStyles.headline2(
                                color: AppColors.white,
                              ),
                            ),

                            Text(
                              AppStrings.locationAndLinkDesc,
                              style: AppTextStyles.overLine(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  AppSizes.xs.ph,

                  AppSizes.xs.ph,
                  Text(
                    AppStrings.locationType,
                    style: AppTextStyles.overLine(),
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
                            "",
                            style: AppTextStyles.bodyText2(
                              color: AppColors.white,
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.white,
                          ),
                        ],
                      ),
                    ),
                    items: [
                      AppDropdownItem(value: "zoom", label: "Zoom"),
                      AppDropdownItem(value: "meet", label: "Meet"),
                      AppDropdownItem(value: "address", label: "Address"),
                      AppDropdownItem(value: "link", label: "Link"),
                    ],
                  ),
                  AppSizes.xs.ph,

                  AppSizes.xs.ph,
                  Text(AppStrings.eventLink, style: AppTextStyles.overLine()),
                  AppSizes.xxxs.ph,
                  TextFormField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.darkBgContainer,
                      hintText: AppStrings.enterLink,
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
                ],
              ),
            ),
            AppSizes.xs.ph,

            Container(
              padding: EdgeInsets.all(AppSizes.xs),

              decoration: BoxDecoration(
                color: AppColors.iconColor,
                borderRadius: BorderRadius.circular(AppSizes.xxxs),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSizes.xxxs),
                        ),
                        child: Center(
                          child: HugeIcon(
                            icon: HugeIconsStrokeRounded.file02,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                      ),
                      AppSizes.xs.pw,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.description,
                              style: AppTextStyles.headline2(
                                color: AppColors.white,
                              ),
                            ),

                            Text(
                              AppStrings.descriptionDesc,
                              style: AppTextStyles.overLine(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  AppSizes.xs.ph,
                  Text(AppStrings.description, style: AppTextStyles.overLine()),
                  AppSizes.xxxs.ph,

                  TextFormField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.darkBgContainer,
                      hintText: AppStrings.enterLink,
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
                    minLines: 2,
                    maxLines: 5,
                  ),
                ],
              ),
            ),
            AppSizes.xs.ph,

            Container(
              padding: EdgeInsets.all(AppSizes.xs),

              decoration: BoxDecoration(
                color: AppColors.iconColor,
                borderRadius: BorderRadius.circular(AppSizes.xxxs),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSizes.xxxs),
                        ),
                        child: Center(
                          child: HugeIcon(
                            icon: HugeIconsStrokeRounded.image01,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                      ),
                      AppSizes.xs.pw,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.eventCoverImage,
                              style: AppTextStyles.headline2(
                                color: AppColors.white,
                              ),
                            ),

                            Text(
                              AppStrings.eventCoverImageDesc,
                              style: AppTextStyles.overLine(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  AppSizes.xs.ph,

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
                          style: AppTextStyles.overLine(
                            color: AppColors.creamWhite,
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
                    label: AppStrings.addEvent,
                    labelStyle: AppTextStyles.bodyText2(color: AppColors.black),
                    bgColor: AppColors.primaryOrange,
                    radius: AppSizes.xxxs,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
