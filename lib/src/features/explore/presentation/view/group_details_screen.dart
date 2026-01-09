import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/extensions/screen_size_extension.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:go_router/go_router.dart';
import 'package:larnity/src/core/router/router.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/data/models/group_model.dart';
import 'dart:io';

import 'package:share_plus/share_plus.dart';

class GroupDetailsScreen extends ConsumerWidget {
  const GroupDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupState = ref.watch(groupProvider);
    final selectedGroup = groupState.group;

    // If no group is selected, show loading or error state
    if (selectedGroup == null) {
      if (groupState.isLoading) {
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      } else if (groupState.isFailure) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Failed to load group details'),
                AppSizes.xs.ph,
                AppButton(
                  onPressed: () {
                    // Try to reload the group
                    ref
                        .read(groupProvider.notifier)
                        .refreshGroupsForCurrentUser();
                  },
                  label: "Retry",
                  labelStyle: AppTextStyles.bodyText2(),
                  bgColor: AppColors.white,
                  radius: AppSizes.xxxs,
                ),
              ],
            ),
          ),
        );
      } else {
        return Scaffold(body: Center(child: Text('No group selected')));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(selectedGroup.name),
        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: () {
            // Navigate back to the explore screen (home)
            context.goNamed(Routes.explore);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppSizes.xs.ph,
              Container(
                height: 0.2.sh,
                width: 0.8.sw,
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange,
                  borderRadius: BorderRadius.circular(AppSizes.xxxs),
                ),
                child: smartImage(selectedGroup.thumbnail, fit: BoxFit.cover),
              ),
              AppSizes.lg.ph,
              Text(
                selectedGroup.name,
                style: AppTextStyles.headline2().copyWith(
                  fontWeight: AppFontWeights.extraBold,
                ),
              ),
              AppSizes.xxlg.ph,
              Container(
                padding: EdgeInsets.all(AppSizes.xs),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderBrown),
                  borderRadius: BorderRadius.circular(AppSizes.xxxs),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: smartImage(
                            selectedGroup.icon,
                            fit: BoxFit.contain,
                          ),
                        ),
                        AppSizes.xs.pw,
                        Expanded(
                          child: Text(
                            selectedGroup.name,
                            style: AppTextStyles.headline2(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    AppSizes.lg.ph,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            children: [
                              HugeIcon(
                                icon: selectedGroup.isPublic
                                    ? HugeIconsStrokeRounded.globe02
                                    : HugeIconsStrokeRounded.squareLock01,
                                color: AppColors.creamWhite,
                                size: 16, // icon size reduce karo
                              ),
                              SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  selectedGroup.isPublic ? "Public" : "Private",
                                  style: AppTextStyles.overLine(),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          child: Row(
                            children: [
                              HugeIcon(
                                icon: HugeIconsStrokeRounded.userMultiple02,
                                color: AppColors.creamWhite,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  "1 Members",
                                  style: AppTextStyles.overLine(),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          child: Row(
                            children: [
                              HugeIcon(
                                icon: HugeIconsStrokeRounded.tag01,
                                color: AppColors.creamWhite,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  selectedGroup.monthlyPrice != null
                                      ? "₹${selectedGroup.monthlyPrice}"
                                      : "Free",
                                  style: AppTextStyles.overLine(),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    AppSizes.xs.ph,
                    Row(
                      children: [
                        HugeIcon(
                          icon: HugeIconsStrokeRounded.star,
                          color: AppColors.primaryOrange,
                          size: 16, // size reduce karo
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          // Yaha Expanded add karo
                          child: Text(
                            selectedGroup.userId ?? "Unknown Creator",
                            style: AppTextStyles.overLine(),
                            overflow: TextOverflow
                                .ellipsis, // text cut ho jayega agar bada hai
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    AppSizes.lg.ph,
                    //if (selectedGroup.monthlyPrice != null)
                    AppButton(
                      onPressed: () async {
                        if (selectedGroup.monthlyPrice != null) {
                          _showPlanSelectionSheet(context, ref, selectedGroup);
                        } else {
                          // Free join logic
                          final success = await ref
                              .read(groupProvider.notifier)
                              .joinGroup(groupId: selectedGroup.id!);

                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Successfully joined ${selectedGroup.name}!',
                                ),
                              ),
                            );
                          } else if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  ref.read(groupProvider).error ??
                                      'Failed to join',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      label: selectedGroup.monthlyPrice != null
                          ? "Join from ₹${selectedGroup.monthlyPrice}"
                          : "Join Free",
                      labelStyle: AppTextStyles.bodyText2(
                        color: AppColors.black,
                      ),
                      bgColor: AppColors.white,
                      radius: AppSizes.xxxs,
                    ),
                    AppSizes.xs.ph,
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.xxs,
                        vertical: AppSizes.xxxs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.darkBgContainer,
                        borderRadius: BorderRadius.circular(AppSizes.xxxs),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedGroup.slug != null
                                  ? "https://www.larnity.com/group/${selectedGroup.slug}"
                                  : "https://www.larnity.com",
                              style: AppTextStyles.overLine(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          AppSizes.xs.pw,
                          AppButton(
                            height: 40,
                            isExpanded: false,
                            onPressed: () async {
                              final shareUrl = selectedGroup.slug != null
                                  ? "https://www.larnity.com/group/${selectedGroup.slug}"
                                  : "https://www.larnity.com";

                              final shareText =
                                  '''
Check out ${selectedGroup.name} on Larnity!

${selectedGroup.description ?? 'Join this amazing community'}

Join here: $shareUrl
''';

                              await Share.share(
                                shareText,
                                subject:
                                    'Join ${selectedGroup.name} on Larnity',
                              );
                            },
                            label: "Share",
                            labelStyle: AppTextStyles.bodyText2(
                              color: AppColors.white,
                            ),
                            borderColor: AppColors.white,
                            bgColor: AppColors.black,
                            radius: AppSizes.xxxs,
                          ),
                        ],
                      ),
                    ),
                    AppSizes.xxlg.ph,
                    Text(selectedGroup.name, style: AppTextStyles.headline5()),
                    if (selectedGroup.description != null)
                      Text(
                        selectedGroup.description!,
                        style: AppTextStyles.overLine(),
                      ),
                  ],
                ),
              ),
              AppSizes.xxxlg.ph,
              AppSizes.xxxlg.ph,
            ],
          ),
        ),
      ),
    );
  }
}

void _showPlanSelectionSheet(
  BuildContext context,
  WidgetRef ref,
  GroupModel group,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.darkBgContainer,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.xs)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          AppSizes.xs,
          AppSizes.sm,
          AppSizes.xs,
          AppSizes.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Choose a plan', style: AppTextStyles.headline4()),
                IconButton(
                  icon: const Icon(Icons.close),
                  color: AppColors.creamWhite,
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            AppSizes.xs.ph,
            Text(
              'Select a plan to join this community',
              style: AppTextStyles.overLine(),
            ),
            AppSizes.sm.ph,
            InkWell(
              onTap: () {
                Navigator.of(ctx).pop();
                _showPaymentSheet(
                  context,
                  ref,
                  group,
                  planName: 'Lifetime',
                  amountINR: 999,
                );
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSizes.xs),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.xxxs),
                  border: Border.all(color: AppColors.borderBrown),
                  color: AppColors.black,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Lifetime', style: AppTextStyles.headline5()),
                    AppSizes.xxxs.ph,
                    Text('₹999', style: AppTextStyles.headline4()),
                    AppSizes.xxxs.ph,
                    Text(
                      'One-time payment, access forever',
                      style: AppTextStyles.overLine(),
                    ),
                  ],
                ),
              ),
            ),
            AppSizes.sm.ph,
          ],
        ),
      );
    },
  );
}

void _showPaymentSheet(
  BuildContext context,
  WidgetRef ref,
  GroupModel group, {
  required String planName,
  required int amountINR,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.darkBgContainer,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.xs)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          String method = 'Paymintro';
          return Padding(
            padding: EdgeInsets.fromLTRB(
              AppSizes.xs,
              AppSizes.sm,
              AppSizes.xs,
              AppSizes.sm,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Payment', style: AppTextStyles.headline4()),
                    IconButton(
                      icon: const Icon(Icons.close),
                      color: AppColors.creamWhite,
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                AppSizes.xs.ph,
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(AppSizes.xs),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSizes.xxxs),
                    border: Border.all(color: AppColors.borderBrown),
                    color: AppColors.black,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$planName Plan', style: AppTextStyles.headline5()),
                      AppSizes.xxxs.ph,
                      Text(
                        '₹$amountINR for $planName',
                        style: AppTextStyles.bodyText2(),
                      ),
                    ],
                  ),
                ),
                AppSizes.sm.ph,
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Enter promo code',
                          filled: true,
                          fillColor: AppColors.black,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.xxxs),
                            borderSide: BorderSide(
                              color: AppColors.borderBrown,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.xxxs),
                            borderSide: BorderSide(
                              color: AppColors.borderBrown,
                            ),
                          ),
                        ),
                        style: AppTextStyles.bodyText2(),
                      ),
                    ),
                    AppSizes.xxxs.pw,
                    AppButton(
                      isExpanded: false,
                      height: 48,
                      onPressed: () {},
                      label: 'Apply',
                      labelStyle: AppTextStyles.bodyText2(
                        color: AppColors.white,
                      ),
                      bgColor: AppColors.black,
                      borderColor: AppColors.white,
                      radius: AppSizes.xxxs,
                    ),
                  ],
                ),
                AppSizes.sm.ph,
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        isExpanded: true,
                        onPressed: () {
                          setState(() => method = 'Paymintro');
                        },
                        label: 'Paymintro',
                        labelStyle: AppTextStyles.bodyText2(
                          color: AppColors.white,
                        ),
                        bgColor: method == 'Paymintro'
                            ? AppColors.purple
                            : AppColors.black,
                        borderColor: AppColors.white,
                        radius: AppSizes.xxxs,
                      ),
                    ),
                    AppSizes.xxxs.pw,
                    Expanded(
                      child: AppButton(
                        isExpanded: true,
                        onPressed: () {
                          setState(() => method = 'Cashfree');
                        },
                        label: 'Cashfree',
                        labelStyle: AppTextStyles.bodyText2(
                          color: AppColors.white,
                        ),
                        bgColor: method == 'Cashfree'
                            ? AppColors.purple
                            : AppColors.black,
                        borderColor: AppColors.white,
                        radius: AppSizes.xxxs,
                      ),
                    ),
                  ],
                ),
                AppSizes.sm.ph,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Amount:', style: AppTextStyles.bodyText2()),
                    Text(
                      '₹${amountINR.toStringAsFixed(0)}',
                      style: AppTextStyles.headline5(),
                    ),
                  ],
                ),
                AppSizes.xs.ph,
                AppButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Redirecting to $method secure payment...',
                        ),
                      ),
                    );
                  },
                  label: 'Pay Securely with $method',
                  labelStyle: AppTextStyles.bodyText2(color: AppColors.white),
                  bgColor: AppColors.purple,
                  radius: AppSizes.xxxs,
                ),
                AppSizes.xxxs.ph,
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text('Back', style: AppTextStyles.bodyText2()),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget smartImage(
  String? path, {
  BoxFit fit = BoxFit.cover,
  double? width,
  double? height,
}) {
  if (path == null || path.isEmpty) {
    return const SizedBox.shrink();
  }

  // If it's a network URL
  if (path.startsWith('http://') || path.startsWith('https://')) {
    return Image.network(
      path,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.broken_image, color: Colors.grey),
    );
  }

  // Otherwise treat it as a local file
  return Image.file(
    File(path),
    fit: fit,
    width: width,
    height: height,
    errorBuilder: (_, __, ___) =>
        const Icon(Icons.broken_image, color: Colors.grey),
  );
}
