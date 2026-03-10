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
import 'package:larnity/src/features/group/presentation/provider/resource_provider.dart';
import 'package:larnity/src/features/group/presentation/widgets/add_resource.dart';
import 'package:larnity/src/features/group/presentation/widgets/resource_card.dart';
import 'package:url_launcher/url_launcher.dart';

class TreasureRoomScreen extends ConsumerStatefulWidget {
  const TreasureRoomScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TreasureRoomScreen> createState() => _TreasureRoomScreenState();
}

class _TreasureRoomScreenState extends ConsumerState<TreasureRoomScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final groupState = ref.read(groupProvider);
      final currentGroupId = groupState.group?.id;
      if (currentGroupId != null) {
        ref.read(resourceProvider).fetchResources(currentGroupId);
      }
    });
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open link')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupState = ref.watch(groupProvider);
    final currentGroupId = groupState.group?.id;
    final resourceState = ref.watch(resourceProvider);

    if (currentGroupId == null) {
      return const Center(child: Text('No group selected'));
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
          child: Column(
            children: [
              AppSizes.xs.ph,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.treasureRoom,
                          style: AppTextStyles.headline2(
                            color: AppColors.white,
                          ),
                        ),
                        Text(
                          "${resourceState.resources.length}${AppStrings.resourcesAvailable}",
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
                              borderRadius: BorderRadius.circular(
                                AppSizes.xxxs,
                              ),
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
                                child: AddResource(groupId: currentGroupId),
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
                    label: AppStrings.addResource,
                    labelStyle: AppTextStyles.bodyText2(color: AppColors.black),
                    bgColor: AppColors.primaryOrange,
                    radius: AppSizes.xxxs,
                  ),
                ],
              ),
              AppSizes.xs.ph,

              // Resources List
              resourceState.isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSizes.lg),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : resourceState.errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Error: ${resourceState.errorMessage}',
                            style: AppTextStyles.bodyText2(
                              //    color: AppColors.error
                            ),
                          ),
                          AppSizes.xs.ph,
                          AppButton(
                            onPressed: () {
                              ref
                                  .read(resourceProvider)
                                  .fetchResources(currentGroupId);
                            },
                            label: 'Retry',
                            bgColor: AppColors.primaryOrange,
                          ),
                        ],
                      ),
                    )
                  : resourceState.resources.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.lg),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            HugeIcon(
                              icon: HugeIconsStrokeRounded.folderAdd,
                              color: AppColors.skyBlue,
                              size: 64,
                            ),
                            AppSizes.xs.ph,
                            Text(
                              'No resources yet',
                              style: AppTextStyles.headline4(
                                color: AppColors.white,
                              ),
                            ),
                            AppSizes.xxxs.ph,
                            Text(
                              'Add your first resource to get started',
                              style: AppTextStyles.overLine(),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: resourceState.resources.length,
                      itemBuilder: (context, index) {
                        final resource = resourceState.resources[index];
                        return ResourceCard(
                          resource: resource,
                          groupId: currentGroupId,
                        );
                      },
                    ),
              AppSizes.xs.ph,
            ],
          ),
        ),
      ),
    );
  }
}
