import 'package:flutter/material.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/features/group/presentation/widgets/create_post.dart';

class DiscussionRoomScreen extends StatelessWidget {
  const DiscussionRoomScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
      child: Column(
        children: [
          AppSizes.xs.ph,
          AppButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  backgroundColor: AppColors.iconColor,
                  child: CreatePost(),
                ),
              );
            },
            bgColor: AppColors.iconColor,
            padding: EdgeInsets.symmetric(
              vertical: AppSizes.xs,
              horizontal: AppSizes.xs,
            ),
            child: Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryOrange,
                  ),
                ),
                AppSizes.xxxs.pw,
                Expanded(
                  child: Text(
                    AppStrings.postButtonText,
                    style: AppTextStyles.subtitle2(
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
