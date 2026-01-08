import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/screen_size_extension.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:go_router/go_router.dart';
import 'package:larnity/src/core/router/router.dart';
import 'package:larnity/src/features/explore/domain/category.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/package/presentation/provider/package_provider.dart';
import 'package:larnity/src/features/package_subscription/presentation/providers/package_subscription_provider.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/auth/presentation/provider/auth_provider.dart';

class ExploreGroupsWidget extends ConsumerStatefulWidget {
  final TextEditingController? searchController;

  const ExploreGroupsWidget({super.key, this.searchController});

  @override
  ConsumerState<ExploreGroupsWidget> createState() =>
      _ExploreGroupsWidgetState();
}

class _ExploreGroupsWidgetState extends ConsumerState<ExploreGroupsWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final packageState = ref.watch(packageProvider);
    final packageSubscriptionState = ref.watch(packageSubscriptionProvider);
    final groupState = ref.watch(groupProvider);
    final authState = ref.watch(authProvider);

    final hasActivePackage =
        packageState.state == AsyncState.success &&
        packageSubscriptionState.state == AsyncState.success &&
        packageSubscriptionState.activeSubscription != null;

    final hasCreatedGroups =
        groupState.fetchState == AsyncState.success &&
        groupState.groups != null &&
        groupState.groups!.any((g) => g.userId == authState.user?.id);

    final primaryCategories = categories.take(5).toList();
    final secondaryCategories = categories.skip(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: AppSizes.lg),
        Text(AppStrings.exploreGroups, style: AppTextStyles.headline1()),
        SizedBox(height: AppSizes.xxs),
        Text(
          AppStrings.exploreGroupsDesc,
          style: AppTextStyles.bodyText2(),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSizes.xs),

        AppButton(
          isExpanded: false,
          label: hasActivePackage && hasCreatedGroups
              ? "Manage your package"
              : "Create your own group",
          labelStyle: AppTextStyles.button(),
          bgColor: AppColors.white,
          suffix: const Icon(Icons.arrow_forward),
          onPressed: () {
            if (hasActivePackage && hasCreatedGroups) {
              context.pushNamed(Routes.packageSubscription);
            } else {
              context.pushNamed(Routes.package);
            }
          },
          radius: 32,
          padding: EdgeInsets.symmetric(horizontal: AppSizes.lg),
        ),

        SizedBox(height: AppSizes.lg),

        /// 🔍 SEARCH BAR (FULL WIDTH FIX)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.lg),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.lg,
              vertical: AppSizes.xxxs,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.lg),
              border: Border.all(color: AppColors.borderBrown.withOpacity(0.5)),
              color: AppColors.darkBg.withValues(alpha: 0.7),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey),
                SizedBox(width: AppSizes.xxs),
                Expanded(
                  child: TextFormField(
                    controller: widget.searchController,
                    decoration: const InputDecoration(
                      hintText: "Search for anything",
                      border: InputBorder.none,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: AppSizes.lg),

        Text(
          "Search by Categories",
          style: AppTextStyles.headline5(
            color: AppColors.white,
          ).copyWith(fontWeight: AppFontWeights.bold),
        ),

        SizedBox(height: AppSizes.md),

        Wrap(
          spacing: AppSizes.xs,
          runSpacing: AppSizes.xs,
          alignment: WrapAlignment.center,
          children: primaryCategories
              .map((c) => _buildCategoryButton(context, ref, c))
              .toList(),
        ),

        if (_isExpanded) ...[
          SizedBox(height: AppSizes.xs),
          Wrap(
            spacing: AppSizes.xs,
            runSpacing: AppSizes.xs,
            alignment: WrapAlignment.center,
            children: secondaryCategories
                .map((c) => _buildCategoryButton(context, ref, c))
                .toList(),
          ),
        ],

        SizedBox(height: AppSizes.xs),

        TextButton(
          onPressed: () => setState(() => _isExpanded = !_isExpanded),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isExpanded ? "Show Less" : "Show More",
                style: AppTextStyles.bodyText1(color: AppColors.white),
              ),
              Icon(
                _isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: AppColors.white,
                size: 16,
              ),
            ],
          ),
        ),

        /// ✅ VERY IMPORTANT GAP
        /// Groups list will start AFTER this safely
        SizedBox(height: AppSizes.lg),
      ],
    );
  }

  Widget _buildCategoryButton(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) {
    final notifier = ref.read(groupProvider.notifier);
    final state = ref.watch(groupProvider);

    final isSelected =
        state.selectedCategory == category ||
        (category.name == 'All' && state.selectedCategory == null);

    return AppButton(
      isExpanded: false,
      label: category.name,
      labelStyle:
          AppTextStyles.subtitle2(
            color: isSelected ? AppColors.primaryOrange : AppColors.white,
          ).copyWith(
            fontWeight: isSelected
                ? AppFontWeights.bold
                : AppFontWeights.regular,
          ),
      bgColor: isSelected
          ? AppColors.primaryOrange.withValues(alpha: 0.1)
          : AppColors.darkBgContainer.withValues(alpha: 0.3),
      borderColor: isSelected
          ? AppColors.primaryOrange
          : AppColors.borderBrown.withOpacity(0.3),
      prefix: HugeIcon(
        icon: category.icon,
        size: 18,
        color: isSelected ? AppColors.primaryOrange : AppColors.white,
      ),
      radius: AppSizes.xs,
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.xxxs,
      ),
      onPressed: () {
        if (category.name == 'All') {
          notifier.state = notifier.state.copyWith(selectedCategory: null);
        } else {
          notifier.selectCategory(category: category);
        }
      },
    );
  }
}
