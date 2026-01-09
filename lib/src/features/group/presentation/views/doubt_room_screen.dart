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
import 'package:larnity/src/features/group/data/models/supporter_model.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/supporter_provider.dart';
import 'package:larnity/src/features/group/presentation/widgets/new_supporter.dart';
import 'package:url_launcher/url_launcher.dart';

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
                        return _buildSupporterCard(supporter);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupporterCard(SupporterModel supporter) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.xs),
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar Circular
              Container(
                width: 55,
                height: 55,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE7EEF7),
                ),
                child: const Center(
                  child: HugeIcon(icon: HugeIconsStrokeRounded.user, size: 26),
                ),
              ),
              AppSizes.sm.pw,

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Supporter',
                      style: AppTextStyles.headline4(color: Colors.white),
                    ),
                    Text(
                      "Phone: ${supporter.phoneNumber}",
                      style: AppTextStyles.caption2(color: Colors.white),
                    ),
                    if (supporter.whatsappNumber != null)
                      Text(
                        "WhatsApp: ${supporter.whatsappNumber}",
                        style: AppTextStyles.caption2(color: Colors.white),
                      ),
                  ],
                ),
              ),

              IconButton(
                icon: const HugeIcon(
                  icon: HugeIconsStrokeRounded.delete02,
                  size: 22,
                ),
                onPressed: () {
                  ref
                      .read(supporterProvider)
                      .deleteSupporter(supporter.id!, supporter.groupId);
                },
              ),
            ],
          ),

          AppSizes.sm.ph,

          // CALL BUTTON
          _actionButton(
            label: "Call",
            color: const Color(0xFF0D2440),
            icon: HugeIcon(
              icon: HugeIconsStrokeRounded.call,
              color: Colors.white,
              size: 20,
            ),
            onTap: () => launchUrl(Uri.parse("tel:${supporter.phoneNumber}")),
          ),

          if (supporter.whatsappNumber != null) ...[
            AppSizes.xs.ph,
            _actionButton(
              label: "WhatsApp",
              color: const Color(0xFF083D24),
              icon: HugeIcon(
                icon: HugeIconsStrokeRounded.whatsapp,
                color: Colors.white,
                size: 20,
              ),
              onTap: () => _openWhatsapp(supporter.whatsappNumber!),
            ),
          ],

          if (supporter.link != null) ...[
            AppSizes.xs.ph,
            _actionButton(
              label: "Book Now",
              color: const Color(0xFF463700),
              icon: const Icon(Icons.check, size: 20, color: Color(0xFFFFD700)),
              onTap: () => launchUrl(Uri.parse(supporter.link!)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required Color color,
    Color textColor = Colors.white,
    Widget? icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) icon,
            const SizedBox(width: 8),
            Text(label, style: AppTextStyles.bodyText2(color: textColor)),
          ],
        ),
      ),
    );
  }

  void _openWhatsapp(String number) async {
    final uri = Uri.parse("https://wa.me/$number");

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
