// lib/src/features/group/presentation/widgets/create_course.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:larnity/src/core/ui/widgets/dialog_header.dart';
import 'package:larnity/src/core/utils/show_snackbar.dart';
import 'package:larnity/src/features/group/data/models/course_model.dart';
import 'package:larnity/src/features/group/presentation/provider/course_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';

class CreateCourse extends ConsumerWidget {
  const CreateCourse({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseNotifier = ref.read(courseProvider.notifier);
    final courseState = ref.watch(courseProvider);
    final groupState = ref.watch(groupProvider);

    final currentGroup = groupState.group;

    return Padding(
      padding: const EdgeInsets.all(AppSizes.xs),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            DialogHeader(
              title: AppStrings.createNewCourse,
              description: AppStrings.createNewCourseDesc,
            ),

            Text(AppStrings.courseName, style: AppTextStyles.overLine()),
            AppSizes.xxxs.ph,
            TextFormField(
              controller: courseNotifier.nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.darkBgContainer,
                hintText: AppStrings.courseNameHint,
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
            Text(AppStrings.courseDescription, style: AppTextStyles.overLine()),
            AppSizes.xxxs.ph,
            TextFormField(
              controller: courseNotifier.descriptionController,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.darkBgContainer,
                hintText: AppStrings.courseDescriptionHint,
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
            Text(AppStrings.courseAccess, style: AppTextStyles.overLine()),
            AppSizes.xxxs.ph,
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    onPressed: () {
                      courseNotifier.setPrivacy(CoursePrivacy.public);
                    },
                    bgColor: courseState.selectedPrivacy == CoursePrivacy.public
                        ? AppColors.primaryOrange
                        : AppColors.white.withValues(alpha: 0.1),
                    label: AppStrings.public,
                  ),
                ),
                AppSizes.xs.pw,
                Expanded(
                  child: AppButton(
                    onPressed: () {
                      courseNotifier.setPrivacy(CoursePrivacy.paid);
                    },
                    bgColor: courseState.selectedPrivacy == CoursePrivacy.paid
                        ? AppColors.primaryOrange
                        : AppColors.white.withValues(alpha: 0.1),
                    label: AppStrings.paid,
                  ),
                ),
              ],
            ),

            if (courseState.selectedPrivacy == CoursePrivacy.paid) ...[
              AppSizes.xs.ph,
              Text(AppStrings.coursePrice, style: AppTextStyles.overLine()),
              AppSizes.xxxs.ph,
              TextFormField(
                controller: courseNotifier.priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.darkBgContainer,
                  hintText: AppStrings.coursePriceHint,
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
            ],

            AppSizes.xs.ph,
            Text(AppStrings.courseThumbnail, style: AppTextStyles.overLine()),
            AppSizes.xxxs.ph,
            GestureDetector(
              onTap: () => courseNotifier.pickThumbnail(),
              child: Container(
                height: 0.2.sh,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.skyBlue.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.xs),
                  image: courseState.thumbnailImage != null
                      ? DecorationImage(
                          image: FileImage(courseState.thumbnailImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: courseState.thumbnailImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          HugeIcon(
                            icon: HugeIconsStrokeRounded.image02,
                            color: AppColors.creamWhite,
                            size: 40,
                          ),
                          AppSizes.xs.ph,
                          Text(
                            AppStrings.clickToUpload,
                            style: AppTextStyles.overLine(
                              color: AppColors.creamWhite,
                            ),
                          ),
                          Text(
                            "${AppStrings.fileType} (Max 5MB)",
                            style: AppTextStyles.caption2(
                              color: AppColors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          Text(
                            AppStrings.max400x400,
                            style: AppTextStyles.caption2(
                              color: AppColors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      )
                    : Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                            onPressed: () => courseNotifier.removeThumbnail(),
                            icon: Icon(Icons.close, color: AppColors.white),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            AppSizes.xs.ph,

            AppButton(
              isLoading: courseState.isCreating,
              onPressed: () {
                // Validation
                if (courseNotifier.nameController.text.isEmpty) {
                  showErrorToast(content: "Please enter course name");
                  return;
                }

                if (courseState.selectedPrivacy == null) {
                  showErrorToast(content: "Please select course access");
                  return;
                }

                if (currentGroup?.id == null) {
                  showErrorToast(content: "Group not found");
                  return;
                }

                int? price;
                if (courseState.selectedPrivacy == CoursePrivacy.paid) {
                  if (courseNotifier.priceController.text.isEmpty) {
                    showErrorToast(content: "Please enter course price");
                    return;
                  }
                  price = int.tryParse(courseNotifier.priceController.text);
                  if (price == null) {
                    showErrorToast(content: "Invalid price");
                    return;
                  }
                }

                // Create course
                final course = CourseModel(
                  name: courseNotifier.nameController.text,
                  description: courseNotifier.descriptionController.text.isEmpty
                      ? null
                      : courseNotifier.descriptionController.text,
                  privacy: courseState.selectedPrivacy!,
                  groupId: currentGroup!.id!,
                  price: price,
                );

                courseNotifier.createCourse(
                  course: course,
                  successCallBack: () {
                    showSuccessToast(content: "Course created successfully");
                    context.pop();
                  },
                  failureCallBack: (error) {
                    showErrorToast(content: error);
                  },
                );
              },
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
