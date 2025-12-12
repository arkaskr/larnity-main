import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_segmented_button.dart';
import 'package:larnity/src/features/group/presentation/views/challenge_room_screen.dart';
import 'package:larnity/src/features/group/presentation/views/class_room_screen.dart';
import 'package:larnity/src/features/group/presentation/views/discussion_room_screen.dart';
import 'package:larnity/src/features/group/presentation/views/doubt_room_screen.dart';
import 'package:larnity/src/features/group/presentation/views/event_room_screen.dart';
import 'package:larnity/src/features/group/presentation/views/job_room_screen.dart';
import 'package:larnity/src/features/group/presentation/views/live_class_room_screen.dart';
import 'package:larnity/src/features/group/presentation/views/members_room_screen.dart';
import 'package:larnity/src/features/group/presentation/views/product_room_screen.dart';
import 'package:larnity/src/features/group/presentation/views/service_room_screen.dart';
import 'package:larnity/src/features/group/presentation/views/treasure_room_screen.dart';

class GroupHomeScreen extends StatelessWidget {
  GroupHomeScreen({Key? key}) : super(key: key);

  final PageController groupPageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.xs),
        child: Column(
          children: [
            AppSizes.xs.ph,
            Container(
              padding: EdgeInsets.all(AppSizes.xs),
              decoration: BoxDecoration(
                color: AppColors.infoCardColor,
                border: Border.all(
                  color: AppColors.primaryOrange.withValues(alpha: 0.5),
                ),
                borderRadius: BorderRadius.circular(AppSizes.xxxs),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HugeIcon(
                        icon: HugeIconsStrokeRounded.informationDiamond,
                        color: AppColors.primaryOrange,
                      ),
                      AppSizes.xs.pw,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Complete Group Onboarding",
                              style: AppTextStyles.button(
                                color: AppColors.primaryOrange,
                              ),
                            ),
                            Text(
                              "Your group is not public yet. Please finish onboarding and submit for approval.",
                              style: AppTextStyles.overLine(
                                color: AppColors.primaryOrange,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: HugeIcon(
                          icon: HugeIconsStrokeRounded.cancel01,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "Go to Settings",
                          style: AppTextStyles.button(
                            color: AppColors.primaryOrange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AppSizes.xs.ph,
            AppSegmentedButton(
              height: 60,
              isScrollable: true,
              selectedBorderColor: AppColors.skyBlue,
              selectedButtonColor: Colors.transparent,
              selectedLabelStyle: AppTextStyles.overLine(
                color: AppColors.white,
              ),
              unselectedLabelStyle: AppTextStyles.overLine(
                color: AppColors.white,
              ),
              buttonItems: [
                AppSegmentedButtonItem(
                  label: "Discussion Room",
                  prefixIcon: HugeIconsStrokeRounded.home03,
                ),
                AppSegmentedButtonItem(
                  label: "Class Room",
                  prefixIcon: HugeIconsStrokeRounded.geometricShapes01,
                ),
                AppSegmentedButtonItem(
                  label: "Live Class Room",
                  prefixIcon: HugeIconsStrokeRounded.computerVideo,
                ),
                AppSegmentedButtonItem(
                  label: "Events Room",
                  prefixIcon: HugeIconsStrokeRounded.calendar03,
                ),

                AppSegmentedButtonItem(
                  label: "Members Room",
                  prefixIcon: HugeIconsStrokeRounded.userMultiple,
                ),
                AppSegmentedButtonItem(
                  label: "Doubt Room",
                  prefixIcon: HugeIconsStrokeRounded.sourceCodeSquare,
                ),
                AppSegmentedButtonItem(
                  label: "Challenges Room",
                  prefixIcon: HugeIconsStrokeRounded.adventure,
                ),
                AppSegmentedButtonItem(
                  label: "Treasure Room",
                  prefixIcon: HugeIconsStrokeRounded.notebook02,
                ),
                AppSegmentedButtonItem(
                  label: "Product Room",
                  prefixIcon: HugeIconsStrokeRounded.shoppingBag01,
                ),
                AppSegmentedButtonItem(
                  label: "Service Room",
                  prefixIcon: HugeIconsStrokeRounded.documentValidation,
                ),
                AppSegmentedButtonItem(
                  label: "Job Room",
                  prefixIcon: HugeIconsStrokeRounded.id,
                ),
              ],
              pageController: groupPageController,
            ),
            Expanded(
              child: PageView(
                controller: groupPageController,
                children: [
                  DiscussionRoomScreen(),
                  ClassRoomScreen(),
                  LiveClassRoomScreen(),
                  EventRoomScreen(),
                  MembersRoomScreen(),
                  DoubtRoomScreen(),
                  ChallengeRoomScreen(),
                  TreasureRoomScreen(),
                  ProductRoomScreen(),
                  ServiceRoomScreen(),
                  JobRoomScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
