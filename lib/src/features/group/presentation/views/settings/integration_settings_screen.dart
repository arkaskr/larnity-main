import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/presentation/widgets/settings/assign_paid_course.dart';
import 'package:larnity/src/features/group/presentation/widgets/settings/free_challenge_access.dart';
import 'package:larnity/src/features/group/presentation/widgets/settings/google_sheet_integration.dart';
import 'package:larnity/src/features/group/presentation/widgets/settings/group_tab_settings.dart';
import 'package:larnity/src/features/group/presentation/widgets/settings/integration_card.dart';
import 'package:larnity/src/features/group/presentation/widgets/settings/invitation_link.dart';
import 'package:larnity/src/features/group/presentation/widgets/settings/invite_members.dart';

class IntegrationSettingsScreen extends ConsumerStatefulWidget {
  const IntegrationSettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<IntegrationSettingsScreen> createState() => _IntegrationSettingsScreenState();
}

class _IntegrationSettingsScreenState extends ConsumerState<IntegrationSettingsScreen> {
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final groupId = ref.watch(groupProvider).group?.id ?? '';
    
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
          child: Column(
            children: [
              AppSizes.xs.ph,
              IntegrationCard(
                buttonLabel: AppStrings.inviteMembers,
                description: AppStrings.memberInvitationsDesc,
                icon: HugeIconsStrokeRounded.userMultiple02,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: AppColors.bgBlue,
                      child: InviteMembers(groupId: groupId),
                    ),
                  );
                },
                title: AppStrings.memberInvitations,
              ),
              AppSizes.xs.ph,
              IntegrationCard(
                buttonLabel: AppStrings.connectSheet,
                description: AppStrings.googleSheetIntegrationDesc,
                icon: HugeIconsStrokeRounded.googleSheet,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: AppColors.bgBlue,
                      child: GoogleSheetIntegration(groupId: groupId),
                    ),
                  );
                },
                title: AppStrings.googleSheetIntegration,
              ),
              AppSizes.xs.ph,
              IntegrationCard(
                buttonLabel: AppStrings.manageTabs,
                description: AppStrings.groupTabSettingsDesc,
                icon: HugeIconsStrokeRounded.settings01,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: AppColors.bgBlue,
                      child: GroupTabSettings(),
                    ),
                  );
                },
                title: AppStrings.groupTabSettings,
              ),
              AppSizes.xs.ph,
              IntegrationCard(
                buttonLabel: AppStrings.assignPaidCourse,
                description: AppStrings.paidCourseAssignmentDesc,
                icon: HugeIconsStrokeRounded.bookOpen01,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: AppColors.bgBlue,
                      child: AssignPaidCourse(),
                    ),
                  );
                },
                title: AppStrings.paidCourseAssignment,
              ),
              AppSizes.xs.ph,
              IntegrationCard(
                buttonLabel: AppStrings.grantAccess,
                description: AppStrings.grantFreeChallengeAccessDesc,
                icon: HugeIconsStrokeRounded.adventure,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: AppColors.bgBlue,
                      child: FreeChallengeAccess(),
                    ),
                  );
                },
                title: AppStrings.grantFreeChallengeAccess,
              ),
              AppSizes.xs.ph,
              IntegrationCard(
                buttonLabel: AppStrings.createInvitationLink,
                description: AppStrings.createInvitationLinkDesc,
                icon: HugeIconsStrokeRounded.userMultiple02,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: AppColors.bgBlue,
                      child: InvitationLink(groupId: groupId),
                    ),
                  );
                },
                title: AppStrings.createInvitationLink,
              ),
              AppSizes.xs.ph,
              IntegrationCard(
                buttonLabel: _isExporting ? "Exporting..." : AppStrings.export,
                description: AppStrings.exportUserDataDesc,
                icon: HugeIconsStrokeRounded.zeroCircle,
                onTap: _isExporting 
                    ? () {} 
                    : () {
                        setState(() => _isExporting = true);
                        ref.read(groupProvider.notifier).exportGroupMembers(
                          groupId: groupId,
                          successCallBack: () {
                            if (mounted) {
                              setState(() => _isExporting = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Export ready to share!')),
                              );
                            }
                          },
                          failureCallBack: (error) {
                            if (mounted) {
                              setState(() => _isExporting = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Export failed: $error')),
                              );
                            }
                          },
                        );
                      },
                title: AppStrings.exportUserData,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
