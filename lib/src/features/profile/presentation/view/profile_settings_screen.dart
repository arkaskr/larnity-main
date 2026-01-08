import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/ui/widgets/phone_number_input.dart';
import 'package:larnity/src/features/group/data/datasource/country_list_with_code.dart';
import 'package:larnity/src/features/group/data/models/country_model.dart';
import 'package:larnity/src/features/auth/presentation/provider/auth_provider.dart';
import 'package:larnity/src/features/profile/presentation/provider/profile_provider.dart';
import 'package:larnity/src/features/auth/data/models/user_model.dart';
import 'package:larnity/src/core/utils/async_states.dart';


class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  late TextEditingController firstNameCtrl;
  late TextEditingController lastNameCtrl;
  late TextEditingController phoneCtrl;

  @override
  void initState() {
    super.initState();

    final currentUser = ref.read(authProvider).user;

    firstNameCtrl = TextEditingController(text: currentUser?.firstName ?? "");
    lastNameCtrl = TextEditingController(text: currentUser?.lastName ?? "");
    phoneCtrl = TextEditingController(text: currentUser?.phoneNumber ?? "");
  }

  @override
  void dispose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider).user;
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Back',
          style: AppTextStyles.bodyText2().copyWith(color: Colors.grey, fontSize: 14),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSizes.xs.ph,

              Text(
                'Profile Settings',
                style: AppTextStyles.headline1().copyWith(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              AppSizes.lg.ph,

              // Profile icon with initials
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue,
                  child: Text(
                    "${currentUser?.firstName?.substring(0,1) ?? ''}${currentUser?.lastName?.substring(0,1) ?? ''}",
                    style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              AppSizes.lg.ph,

              // Name Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: firstNameCtrl,
                      decoration: _inputDecoration("First Name"),
                    ),
                  ),
                  AppSizes.xs.pw,
                  Expanded(
                    child: TextFormField(
                      controller: lastNameCtrl,
                      decoration: _inputDecoration("Last Name"),
                    ),
                  ),
                ],
              ),

              AppSizes.lg.ph,

              Text("Phone Number", style: AppTextStyles.bodyText2().copyWith(color: Colors.white)),
              AppSizes.xxxs.ph,

              PhoneNumberInput(
                countries: CountryListWithCode.countries,
                initialCountry: CountryModel(
                  name: "India",
                  code: "+91",
                  flag: "🇮🇳",
                  codeAbbreviation: "IN",
                  states: [],
                ),
                initialPhoneNumber: phoneCtrl.text,
                onPhoneNumberChanged: (phoneNumber, country) {
                  setState(() {
                    phoneCtrl.text = phoneNumber;
                  });
                },
              ),

              AppSizes.lg.ph,

              // Update Profile Button
              AppButton(
                onPressed: () {
                  final updatedUser = currentUser!.copyWith(
                    firstName: firstNameCtrl.text.trim(),
                    lastName: lastNameCtrl.text.trim(),
                    phoneNumber: phoneCtrl.text.trim(),
                  );

                  ref.read(profileProvider.notifier).createProfile(
                    user: updatedUser,
                    successCallBack: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Profile updated successfully")),
                      );
                    },
                  );
                },
                label: profileState.state == AsyncState.loading ? "Updating..." : "Update Profile",
                bgColor: Colors.grey[300]!,
                labelStyle: AppTextStyles.button().copyWith(color: Colors.black),
                radius: AppSizes.xs,
                isExpanded: true,
              ),

              AppSizes.xxxlg.ph,
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.darkBgContainer,
      hintText: hint,
      hintStyle: AppTextStyles.bodyText2().copyWith(color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.xxxs),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.xxxs),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.xxxs),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
      ),
    );
  }
}
