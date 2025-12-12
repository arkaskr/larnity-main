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
import 'package:larnity/src/core/ui/widgets/phone_number_input.dart';
import 'package:larnity/src/features/group/data/datasource/country_list_with_code.dart';
import 'package:larnity/src/features/group/data/models/country_model.dart';

class AddProduct extends StatelessWidget {
  const AddProduct({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.xs),
      child: SingleChildScrollView(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppStrings.createNewProduct,
                  style: AppTextStyles.headline4(),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    AppStrings.createNewProductDesc,
                    style: AppTextStyles.overLine(color: AppColors.skyBlue),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            AppSizes.lg.ph,

            Text(AppStrings.productName, style: AppTextStyles.overLine()),
            AppSizes.xxxs.ph,
            TextFormField(
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.darkBgContainer,
                hintText: AppStrings.productNameHint,
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
            Text(
              AppStrings.productDescription,
              style: AppTextStyles.overLine(),
            ),
            AppSizes.xxxs.ph,
            TextFormField(
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.darkBgContainer,
                hintText: AppStrings.productDescriptionHint,
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
            Text(AppStrings.productPrice, style: AppTextStyles.overLine()),
            AppSizes.xxxs.ph,
            TextFormField(
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.darkBgContainer,
                hintText: "0",
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
              maxLines: 1,
            ),
            AppSizes.xs.ph,
            Text(
              AppStrings.productDiscountPrice,
              style: AppTextStyles.overLine(),
            ),
            AppSizes.xxxs.ph,
            TextFormField(
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.darkBgContainer,
                hintText: "0",
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
              maxLines: 1,
            ),
            AppSizes.xs.ph,
            Text(AppStrings.whatsappNumber, style: AppTextStyles.overLine()),
            AppSizes.xxxs.ph,

            PhoneNumberInput(
              countries: CountryListWithCode.countries,
              initialCountry: CountryModel(
                name: "India",
                code: "+91",
                flag: '🇮🇳',
                codeAbbreviation: 'IN',
                states: [
                  'Andaman and Nicobar Islands',
                  'Andhra Pradesh',
                  'Arunachal Pradesh',
                  'Assam',
                  'Bihar',
                  'Chandigarh',
                  'Chhattisgarh',
                  'Dadra and Nagar Haveli and Daman and Diu',
                  'Delhi',
                  'Goa',
                  'Gujarat',
                  'Haryana',
                  'Himachal Pradesh',
                  'Jammu and Kashmir',
                  'Jharkhand',
                  'Karnataka',
                  'Kerala',
                  'Ladakh',
                  'Lakshadweep',
                  'Madhya Pradesh',
                  'Maharashtra',
                  'Manipur',
                  'Meghalaya',
                  'Mizoram',
                  'Nagaland',
                  'Odisha',
                  'Puducherry',
                  'Punjab',
                  'Rajasthan',
                  'Sikkim',
                  'Tamil Nadu',
                  'Telangana',
                  'Tripura',
                  'Uttar Pradesh',
                  'Uttarakhand',
                  'West Bengal',
                ],
              ),
              countryDropdownHint: "Country",
              hintText: "00000-00000",
              textStyle: AppTextStyles.overLine(color: AppColors.white),
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
              child: Center(
                child: Text(
                  AppStrings.uploadImage,
                  style: AppTextStyles.caption2(
                    color: AppColors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ),
            AppSizes.xs.ph,

            Text(AppStrings.productRating, style: AppTextStyles.overLine()),
            AppSizes.xs.ph,

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
              ],
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
