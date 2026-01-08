import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/supporter_provider.dart';
import 'package:larnity/src/features/group/presentation/widgets/new_supporter.dart';

class DoubtRoomScreen extends ConsumerStatefulWidget {
  const DoubtRoomScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DoubtRoomScreen> createState() => _DoubtRoomScreenState();
}

class _DoubtRoomScreenState extends ConsumerState<DoubtRoomScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final groupState = ref.read(groupProvider);
      final currentGroupId = groupState.group?.id;
      if (currentGroupId != null) {
        ref.read(supporterProvider).fetchSupporters(currentGroupId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final groupState = ref.watch(groupProvider);
    final currentGroupId = groupState.group?.id;
    final supporterState = ref.watch(supporterProvider);

    if (currentGroupId == null) {
      return const Center(child: Text('No group selected'));
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.xs),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.supporterPage,
                        style: AppTextStyles.headline4(color: AppColors.white),
                      ),
                      Text(
                        "${supporterState.supporters.length} ${AppStrings.supportersAvailable}",
                        style: AppTextStyles.overLine(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AppButton(
                  isExpanded: false,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        final size = MediaQuery.of(context).size;

                        return Dialog(
                          insetPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 24,
                          ),
                          backgroundColor: AppColors.bgBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.xxxs),
                          ),
                          child: SizedBox(
                            width: size.width * 0.95,
                            height: size.height * 0.6,
                            child: SingleChildScrollView(
                              padding: EdgeInsets.only(
                                bottom: MediaQuery.of(
                                  context,
                                ).viewInsets.bottom,
                              ),
                              child: NewSupporter(groupId: currentGroupId),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  prefix: HugeIcon(
                    icon: HugeIconsStrokeRounded.addCircle,
                    color: AppColors.black,
                  ),
                  label: AppStrings.newSupporter,
                  labelStyle: AppTextStyles.bodyText2(color: AppColors.black),
                  bgColor: AppColors.primaryOrange,
                  radius: AppSizes.xxxs,
                ),
              ],
            ),
            AppSizes.xs.ph,

            // Supporters List
            Expanded(
              child: supporterState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : supporterState.errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Error: ${supporterState.errorMessage}',
                            style: AppTextStyles.bodyText2(
                              // color: AppColors.error
                            ),
                          ),
                          AppSizes.xs.ph,
                          AppButton(
                            onPressed: () {
                              ref
                                  .read(supporterProvider)
                                  .fetchSupporters(currentGroupId);
                            },
                            label: 'Retry',
                            bgColor: AppColors.primaryOrange,
                          ),
                        ],
                      ),
                    )
                  : supporterState.supporters.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          HugeIcon(
                            icon: HugeIconsStrokeRounded.userAdd01,
                            color: AppColors.skyBlue,
                            size: 48,
                          ),
                          AppSizes.xs.ph,
                          Text(
                            'No supporters yet',
                            style: AppTextStyles.headline4(
                              color: AppColors.white,
                            ),
                          ),
                          AppSizes.xxxs.ph,
                          Text(
                            'Add your first supporter to get started',
                            style: AppTextStyles.overLine(),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: supporterState.supporters.length,
                      itemBuilder: (context, index) {
                        final supporter = supporterState.supporters[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: AppSizes.xs),
                          padding: const EdgeInsets.all(AppSizes.xs),
                          decoration: BoxDecoration(
                            color: AppColors.iconColor,
                            borderRadius: BorderRadius.circular(AppSizes.xxxs),
                            border: Border.all(
                              color: AppColors.skyBlue.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryOrange.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.xxxs,
                                  ),
                                ),
                                child: Center(
                                  child: HugeIcon(
                                    icon: HugeIconsStrokeRounded.user,
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
                                      'Supporter',
                                      style: AppTextStyles.headline4(
                                        color: AppColors.white,
                                      ),
                                    ),
                                    AppSizes.xxxs.ph,
                                    Text(
                                      'Phone: ${supporter.phoneNumber}',
                                      style: AppTextStyles.overLine(),
                                    ),
                                    if (supporter.whatsappNumber != null)
                                      Text(
                                        'WhatsApp: ${supporter.whatsappNumber}',
                                        style: AppTextStyles.overLine(),
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Supporter'),
                                      content: const Text(
                                        'Are you sure you want to delete this supporter?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true && mounted) {
                                    await ref
                                        .read(supporterProvider)
                                        .deleteSupporter(
                                          supporter.id!,
                                          currentGroupId,
                                        );
                                  }
                                },
                                icon: HugeIcon(
                                  icon: HugeIconsStrokeRounded.delete02,
                                  // color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
