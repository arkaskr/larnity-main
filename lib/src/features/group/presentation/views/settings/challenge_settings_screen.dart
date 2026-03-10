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
import 'package:larnity/src/features/group/presentation/provider/challenge_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/presentation/widgets/settings/create_challenge.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';

class ChallengeSettingsScreen extends ConsumerStatefulWidget {
  const ChallengeSettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ChallengeSettingsScreen> createState() =>
      _ChallengeSettingsScreenState();
}

class _ChallengeSettingsScreenState
    extends ConsumerState<ChallengeSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final groupId = ref.read(groupProvider).group?.id;
      if (groupId != null) {
        ref.read(challengeProvider.notifier).fetchChallenges(groupId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final challengeState = ref.watch(challengeProvider);
    final challenges = challengeState.challenges;
    final isLoading = challengeState.isLoading;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
        child: Column(
          children: [
            AppSizes.xs.ph,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.challenges,
                      style: AppTextStyles.headline2(color: AppColors.white),
                    ),
                    Text(
                      AppStrings.challengesAvailable,
                      style: AppTextStyles.overLine(),
                    ),
                  ],
                ),
                AppButton(
                  isExpanded: false,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          AlertDialog(content: CreateChallenge()),
                    );
                  },
                  prefix: HugeIcon(
                    icon: HugeIconsStrokeRounded.addCircle,
                    color: AppColors.black,
                  ),
                  label: AppStrings.createChallenge,
                  labelStyle: AppTextStyles.bodyText2(color: AppColors.black),
                  bgColor: AppColors.primaryOrange,
                  radius: AppSizes.xxxs,
                ),
              ],
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : challenges.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            HugeIcon(
                              icon: HugeIconsStrokeRounded.champion,
                              color: AppColors.creamWhite,
                              size: 50,
                            ),
                            AppSizes.lg.ph,
                            Text(
                              AppStrings.noChallengeYet,
                              style: AppTextStyles.headline3(),
                            ),
                            Text(
                              AppStrings.noChallengeDesc,
                              style: AppTextStyles.overLine(),
                              textAlign: TextAlign.center,
                            ),
                            AppSizes.xs.ph,
                            AppButton(
                              isExpanded: false,
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      AlertDialog(content: CreateChallenge()),
                                );
                              },
                              prefix: HugeIcon(
                                icon: HugeIconsStrokeRounded.addCircle,
                                color: AppColors.black,
                              ),
                              label: AppStrings.createFirstChallenge,
                              labelStyle: AppTextStyles.bodyText2(
                                  color: AppColors.black),
                              bgColor: AppColors.primaryOrange,
                              radius: AppSizes.xxxs,
                            ),
                          ],
                        )
                      : ListView.separated(
                          itemCount: challenges.length,
                          separatorBuilder: (context, index) => AppSizes.sm.ph,
                          itemBuilder: (context, index) {
                            final challenge = challenges[index];
                            return Container(
                              padding: EdgeInsets.all(AppSizes.sm),
                              decoration: BoxDecoration(
                                color: AppColors.darkBgContainer,
                                borderRadius: BorderRadius.circular(AppSizes.sm),
                                border: Border.all(
                                    color: AppColors.skyBlue.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  if (challenge.thumbnail != null)
                                    Container(
                                      width: 60,
                                      height: 60,
                                      margin: EdgeInsets.only(right: AppSizes.sm),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(AppSizes.xs),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                              ref.read(supabaseClientProvider).storage.from('images').getPublicUrl(challenge.thumbnail!),
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                  else
                                    Container(
                                      width: 60,
                                      height: 60,
                                      margin: EdgeInsets.only(right: AppSizes.sm),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryOrange.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(AppSizes.xs),
                                      ),
                                      child: Icon(Icons.emoji_events, color: AppColors.primaryOrange),
                                    ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          challenge.title,
                                          style: AppTextStyles.headline4(),
                                        ),
                                        Text(
                                          "${challenge.startDate.toString().split(' ')[0]} - ${challenge.endDate.toString().split(' ')[0]}",
                                          style: AppTextStyles.caption2(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: AppSizes.xs, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: challenge.status == 'PUBLISHED' ? Colors.green.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(AppSizes.xxxs),
                                    ),
                                    child: Text(
                                      challenge.status,
                                      style: AppTextStyles.caption2(
                                        color: challenge.status == 'PUBLISHED' ? Colors.green : Colors.grey,
                                      ),
                                    ),
                                  )
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
