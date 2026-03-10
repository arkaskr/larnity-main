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
import 'package:larnity/src/core/ui/widgets/app_dropdown.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';

class InviteMembers extends ConsumerStatefulWidget {
  final String groupId;
  
  const InviteMembers({Key? key, required this.groupId}) : super(key: key);

  @override
  ConsumerState<InviteMembers> createState() => _InviteMembersState();
}

class _InviteMembersState extends ConsumerState<InviteMembers> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  String _selectedPlan = 'MONTHLY';
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _sendInvitation() {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email address')),
      );
      return;
    }

    setState(() => _isLoading = true);

    ref.read(groupProvider.notifier).createInvitation(
      groupId: widget.groupId,
      email: _emailController.text.trim(),
      name: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
      planType: _selectedPlan,
      successCallBack: (link) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invitation sent successfully!')),
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
      child: SingleChildScrollView(
        child: Column(
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
            Text(AppStrings.inviteMembers, style: AppTextStyles.headline4()),
            Text(
              AppStrings.inviteMembersDesc,
              style: AppTextStyles.overLine(color: AppColors.skyBlue),
              textAlign: TextAlign.center,
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
                              AppStrings.bulkImport,
                              style: AppTextStyles.headline4(),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    AppStrings.bulkImportDesc,
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
                  AppSizes.xs.ph,
                  AppButton(
                    onPressed: () {},
                    prefix: HugeIcon(
                      icon: HugeIconsStrokeRounded.download01,
                      color: AppColors.white,
                    ),
                    label: AppStrings.downloadExampleCsv,
                    labelStyle: AppTextStyles.button(color: AppColors.white),
                    bgColor: AppColors.white.withValues(alpha: 0.1),
                  ),
                  AppSizes.xs.ph,
                  AppButton(
                    onPressed: () {},
                    prefix: HugeIcon(
                      icon: HugeIconsStrokeRounded.upload01,
                      color: AppColors.white,
                    ),
                    label: AppStrings.importCsv,
                    labelStyle: AppTextStyles.button(color: AppColors.white),
                    bgColor: AppColors.white.withValues(alpha: 0.1),
                  ),
                  AppSizes.xs.ph,
                  Text(
                    AppStrings.csvContain,
                    style: AppTextStyles.overLine(color: AppColors.skyBlue),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                            icon: HugeIconsStrokeRounded.userMultiple02,
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
                              AppStrings.singleInvitation,
                              style: AppTextStyles.headline4(),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    AppStrings.singleInvitationDesc,
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
                  AppSizes.xs.ph,

                  AppSizes.xs.ph,
                  Text(
                    AppStrings.emailAddress,
                    style: AppTextStyles.overLine(),
                  ),
                  AppSizes.xxxs.ph,
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.darkBgContainer,
                      hintText: AppStrings.emailAddressHint,
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
                    AppStrings.nameOptional,
                    style: AppTextStyles.overLine(),
                  ),
                  AppSizes.xxxs.ph,
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.darkBgContainer,
                      hintText: AppStrings.nameHint,
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
                    AppStrings.subscriptionPlan,
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
                            _selectedPlan == 'MONTHLY' ? "Monthly Plan" : _selectedPlan == 'YEARLY' ? "Yearly Plan" : "Lifetime Plan",
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
                      AppDropdownItem(value: "MONTHLY", label: "Monthly Plan"),
                      AppDropdownItem(value: "YEARLY", label: "Yearly Plan"),
                      AppDropdownItem(value: "LIFETIME", label: "Lifetime Plan"),
                    ],
                    onItemSelected: (value) {
                      setState(() {
                        _selectedPlan = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            AppSizes.xs.ph,
            AppButton(
              onPressed: _isLoading ? null : _sendInvitation,
              label: _isLoading ? 'Sending...' : AppStrings.sendInvitation,
              labelStyle: AppTextStyles.button(color: AppColors.black),
              bgColor: AppColors.primaryOrange,
            ),
          ],
        ),
      ),
    );
  }
}
