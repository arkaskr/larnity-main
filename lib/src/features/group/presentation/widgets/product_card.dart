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

class ProductCard extends StatelessWidget {
  const ProductCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkBgContainer,
        borderRadius: BorderRadius.circular(AppSizes.xs),
      ),
      child: Column(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Product Name", style: AppTextStyles.headline4()),

                    AppDropdown(
                      button: Icon(Icons.more_vert, color: AppColors.white),
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
                Text("Description", style: AppTextStyles.overLine()),
                AppSizes.xs.ph,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "₹8 ",
                            style: AppTextStyles.bodyText1(
                              color: AppColors.primaryOrange,
                            ),
                          ),
                          TextSpan(
                            text: "₹10",
                            style:
                                AppTextStyles.bodyText1(
                                  color: AppColors.creamWhite,
                                ).copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: AppColors.creamWhite,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        HugeIcon(
                          icon: HugeIconsStrokeRounded.star,
                          color: AppColors.primaryOrange,
                        ),
                        HugeIcon(
                          icon: HugeIconsStrokeRounded.star,
                          color: AppColors.primaryOrange,
                        ),
                        HugeIcon(
                          icon: HugeIconsStrokeRounded.star,
                          color: AppColors.primaryOrange,
                        ),
                        HugeIcon(
                          icon: HugeIconsStrokeRounded.star,
                          color: AppColors.primaryOrange,
                        ),
                        HugeIcon(
                          icon: HugeIconsStrokeRounded.star,
                          color: AppColors.primaryOrange,
                        ),

                        AppSizes.xxxs.pw,
                        Text(
                          "(4)",
                          style: AppTextStyles.overLine(
                            color: AppColors.creamWhite,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                AppSizes.xs.ph,

                AppButton(
                  onPressed: () {},
                  label: AppStrings.buyNow,
                  prefix: HugeIcon(
                    icon: HugeIconsStrokeRounded.cloudDownload,
                    color: AppColors.black,
                  ),
                  labelStyle: AppTextStyles.button(color: AppColors.black),
                  bgColor: AppColors.primaryOrange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
