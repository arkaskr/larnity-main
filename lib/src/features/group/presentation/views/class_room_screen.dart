import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/features/group/presentation/widgets/create_course.dart';

class ClassRoomScreen extends StatelessWidget {
  const ClassRoomScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                    "0${AppStrings.coursesAvailable}",
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
                        width:
                            MediaQuery.of(context).size.width *
                            0.95, // width badhi
                        height:
                            MediaQuery.of(context).size.height *
                            0.65, // height kam
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
        ],
      ),
    );
  }
}
