import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:intl/intl.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/extensions/screen_size_extension.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/ui/widgets/app_dropdown.dart';
import 'package:larnity/src/features/group/data/models/job_model.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/job_provider.dart';
import 'package:larnity/src/features/group/presentation/widgets/add_job.dart';
import 'package:url_launcher/url_launcher.dart';

class JobRoomScreen extends ConsumerStatefulWidget {
  const JobRoomScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<JobRoomScreen> createState() => _JobRoomScreenState();
}

class _JobRoomScreenState extends ConsumerState<JobRoomScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final groupState = ref.read(groupProvider);
      final currentGroupId = groupState.group?.id;
      if (currentGroupId != null) {
        ref.read(jobProvider).fetchJobs(currentGroupId);
      }
    });
  }

  Future<void> _applyToJob(String googleSheetId) async {
    // Open Google Sheet for application
    final url = 'https://docs.google.com/spreadsheets/d/$googleSheetId/edit';
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open application form')),
        );
      }
    }
  }

  Widget _buildJobCard(JobModel job, String currentGroupId) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final formattedDate = dateFormat.format(job.postingEndDate);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkBgContainer,
        borderRadius: BorderRadius.circular(AppSizes.xs),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppSizes.xs),
              topRight: Radius.circular(AppSizes.xs),
            ),
            child: Image.network(
              job.image,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 150,
                  color: AppColors.primaryOrange.withValues(alpha: 0.3),
                  child: const Center(
                    child: Icon(
                      Icons.work_outline,
                      size: 48,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                );
              },
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
                    Expanded(
                      child: Text(
                        job.title,
                        style: AppTextStyles.headline4(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppDropdown(
                      button: const Icon(
                        Icons.more_vert,
                        color: AppColors.white,
                      ),
                      overlayWidth: 160,
                      overlayAlignment: Alignment.centerRight,
                      onItemSelected: (value) async {
                        if (value == 'delete') {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Job'),
                              content: const Text('Are you sure?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true && mounted) {
                            await ref
                                .read(jobProvider)
                                .deleteJob(job.id!, currentGroupId);
                          }
                        }
                      },
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

                Text(
                  job.description,
                  style: AppTextStyles.overLine(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSizes.xs.ph,

                Row(
                  children: [
                    HugeIcon(
                      icon: HugeIconsStrokeRounded.calendar03,
                      color: AppColors.white,
                      size: 16,
                    ),
                    AppSizes.xxxs.pw,
                    Text(
                      "Closes: $formattedDate",
                      style: AppTextStyles.overLine(
                        color: AppColors.creamWhite,
                      ),
                    ),
                  ],
                ),
                AppSizes.xs.ph,

                AppButton(
                  onPressed: () => _applyToJob(job.googleSheetId),
                  label: AppStrings.applyNow,
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

  @override
  Widget build(BuildContext context) {
    final groupState = ref.watch(groupProvider);
    final currentGroupId = groupState.group?.id;
    final jobState = ref.watch(jobProvider);

    if (currentGroupId == null) {
      return const Center(child: Text('No group selected'));
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
        child: SingleChildScrollView(
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
                          AppStrings.jobRoom,
                          style: AppTextStyles.headline2(
                            color: AppColors.white,
                          ),
                        ),
                        Text(
                          "${jobState.jobs.length}${AppStrings.jobsAvailable}",
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
                              height: size.height * 0.7,
                              child: SingleChildScrollView(
                                padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(
                                    context,
                                  ).viewInsets.bottom,
                                ),
                                child: AddJob(groupId: currentGroupId),
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
                    label: AppStrings.postJob,
                    labelStyle: AppTextStyles.bodyText2(color: AppColors.black),
                    bgColor: AppColors.primaryOrange,
                    radius: AppSizes.xxxs,
                  ),
                ],
              ),
              AppSizes.xs.ph,

              // Jobs List
              jobState.isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSizes.lg),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : jobState.errorMessage != null
                  ? Center(
                      child: Column(
                        children: [
                          Text(
                            'Error: ${jobState.errorMessage}',
                            style: AppTextStyles.bodyText2(
                              color: AppColors.red,
                            ),
                          ),
                          AppSizes.xs.ph,
                          AppButton(
                            onPressed: () {
                              ref.read(jobProvider).fetchJobs(currentGroupId);
                            },
                            label: 'Retry',
                            bgColor: AppColors.primaryOrange,
                          ),
                        ],
                      ),
                    )
                  : jobState.jobs.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.lg),
                        child: Column(
                          children: [
                            HugeIcon(
                              icon: HugeIconsStrokeRounded.briefcase01,
                              color: AppColors.skyBlue,
                              size: 64,
                            ),
                            AppSizes.xs.ph,
                            Text(
                              'No jobs yet',
                              style: AppTextStyles.headline4(
                                color: AppColors.white,
                              ),
                            ),
                            AppSizes.xxxs.ph,
                            Text(
                              'Post your first job to get started',
                              style: AppTextStyles.overLine(),
                            ),
                          ],
                        ),
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: AppSizes.xs,
                            mainAxisSpacing: AppSizes.xs,
                            childAspectRatio: 0.75,
                          ),
                      itemCount: jobState.jobs.length,
                      itemBuilder: (context, index) {
                        final job = jobState.jobs[index];
                        return _buildJobCard(job, currentGroupId);
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
