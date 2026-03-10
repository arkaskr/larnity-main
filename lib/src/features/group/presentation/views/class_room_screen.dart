import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/features/group/presentation/provider/course_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/presentation/widgets/create_course.dart';
import 'package:larnity/src/core/extensions/extensions.dart';

class ClassRoomScreen extends ConsumerStatefulWidget {
  const ClassRoomScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ClassRoomScreen> createState() => _ClassRoomScreenState();
}

class _ClassRoomScreenState extends ConsumerState<ClassRoomScreen> {
  @override
  void initState() {
    super.initState();
    // Initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCourses();
    });
  }

  void _loadCourses() {
    final groupState = ref.read(groupProvider);
    final currentGroup = groupState.group;

    if (currentGroup?.id != null) {
      ref
          .read(courseProvider.notifier)
          .getCoursesByGroup(groupId: currentGroup!.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseState = ref.watch(courseProvider);
    final courses = courseState.courses ?? [];

    return Padding(
      padding: const EdgeInsets.all(AppSizes.xs),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.courses,
                    style: AppTextStyles.headline2(color: AppColors.white),
                  ),
                  Text(
                    "${courses.length} ${AppStrings.coursesAvailable}",
                    style: AppTextStyles.overLine(),
                  ),
                ],
              ),
              AppButton(
                isExpanded: false,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      insetPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 24,
                      ),
                      backgroundColor: AppColors.bgBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.xxxs),
                      ),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.95,
                        height: MediaQuery.of(context).size.height * 0.65,
                        child: const CreateCourse(),
                      ),
                    ),
                  );
                },
                prefix: HugeIcon(
                  icon: HugeIconsStrokeRounded.addCircle,
                  color: AppColors.black,
                ),
                label: AppStrings.createCourse,
                labelStyle: AppTextStyles.bodyText2(color: AppColors.black),
                bgColor: AppColors.primaryOrange,
                radius: AppSizes.xxxs,
              ),
            ],
          ),

          AppSizes.sm.ph,

          // Courses List
          Expanded(
            child: courseState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : courses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HugeIcon(
                          icon: HugeIconsStrokeRounded.book02,
                          color: AppColors.white.withValues(alpha: 0.3),
                          size: 80,
                        ),
                        AppSizes.sm.ph,
                        Text(
                          "No courses yet",
                          style: AppTextStyles.headline3(
                            color: AppColors.white.withValues(alpha: 0.5),
                          ),
                        ),
                        AppSizes.xs.ph,
                        Text(
                          "Create your first course to get started",
                          style: AppTextStyles.caption2(
                            color: AppColors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: AppSizes.md),
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSizes.sm),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppSizes.xs),
                          color: AppColors.darkBgContainer,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Thumbnail
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(AppSizes.xs),
                                topRight: Radius.circular(AppSizes.xs),
                              ),
                              child: course.thumbnail != null
                                  ? Image.network(
                                      course.thumbnail!,
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      height: 200,
                                      color: AppColors.skyBlue.withValues(
                                        alpha: 0.2,
                                      ),
                                      child: Center(
                                        child: HugeIcon(
                                          icon: HugeIconsStrokeRounded.image02,
                                          color: AppColors.skyBlue,
                                        ),
                                      ),
                                    ),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(AppSizes.sm),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          course.name,
                                          style: AppTextStyles.headline4(
                                            color: AppColors.white,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (course.isPaid)
                                        Container(
                                          margin: const EdgeInsets.only(left: 8),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppSizes.xs,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryOrange,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            'Premium',
                                            style: AppTextStyles.caption2(
                                              color: AppColors.white,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),

                                  if (course.description != null) ...[
                                    AppSizes.xs.ph,
                                    Text(
                                      course.description!,
                                      style: AppTextStyles.bodyText2(
                                        color: AppColors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],

                                  if (course.price != null) ...[
                                    AppSizes.xs.ph,
                                    Text(
                                      '₹${course.price}',
                                      style: AppTextStyles.headline3(
                                        color: AppColors.primaryOrange,
                                      ),
                                    ),
                                  ],
                                ],
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
    );
  }
}
