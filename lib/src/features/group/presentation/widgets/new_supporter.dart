import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/ui/widgets/app_dropdown.dart';
import 'package:larnity/src/core/ui/widgets/phone_number_input.dart';
import 'package:larnity/src/features/group/data/datasource/country_list_with_code.dart';
import 'package:larnity/src/features/group/data/models/country_model.dart';

class NewSupporter extends StatelessWidget {
  const NewSupporter({Key? key}) : super(key: key);

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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppStrings.addNewSupporter,
                style: AppTextStyles.headline4(),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  AppStrings.addNewSupporterDesc,
                  style: AppTextStyles.overLine(color: AppColors.skyBlue),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          AppSizes.lg.ph,

          AppSizes.xs.ph,
          Text(AppStrings.selectMember, style: AppTextStyles.overLine()),
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
                    AppStrings.searchMemberByEmail,
                    style: AppTextStyles.bodyText2(color: AppColors.white),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: AppColors.white),
                ],
              ),
            ),
            items: [AppDropdownItem(value: "Member", label: "Member")],
          ),
          AppSizes.xs.ph,

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
          Text(AppStrings.whatsappNumber, style: AppTextStyles.overLine()),
          AppSizes.xxxs.ph,
          TextFormField(
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.darkBgContainer,
              hintText: AppStrings.whatsappNumberHint,
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
          Text(AppStrings.booking, style: AppTextStyles.overLine()),
          AppSizes.xxxs.ph,
          TextFormField(
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.darkBgContainer,
              hintText: AppStrings.enterAppointmentBooking,
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
          AppButton(
            onPressed: () {},
            label: AppStrings.create,
            labelStyle: AppTextStyles.button(color: AppColors.black),
            bgColor: AppColors.primaryOrange,
          ),
        ],
      ),
    );
  }
}
