import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';

class SubscriptionSettingsScreen extends ConsumerStatefulWidget {
  const SubscriptionSettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SubscriptionSettingsScreen> createState() =>
      _SubscriptionSettingsScreenState();
}

class _SubscriptionSettingsScreenState
    extends ConsumerState<SubscriptionSettingsScreen> {
  final TextEditingController monthlyPriceController = TextEditingController();
  final TextEditingController yearlyPriceController = TextEditingController();
  final TextEditingController lifetimePriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load current prices when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentPrices();
    });
  }

  void _loadCurrentPrices() {
    final group = ref.read(groupProvider).group;
    if (group != null) {
      monthlyPriceController.text = group.monthlyPrice?.toString() ?? '';
      yearlyPriceController.text = group.yearlyPrice?.toString() ?? '';
      lifetimePriceController.text = group.lifetimePrice?.toString() ?? '';
    }
  }

  void _updatePrices() {
    final group = ref.read(groupProvider).group;

    if (group == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No group selected')));
      return;
    }

    // Parse prices (null if empty)
    final monthlyPrice = monthlyPriceController.text.trim().isEmpty
        ? null
        : int.tryParse(monthlyPriceController.text.trim());
    final yearlyPrice = yearlyPriceController.text.trim().isEmpty
        ? null
        : int.tryParse(yearlyPriceController.text.trim());
    final lifetimePrice = lifetimePriceController.text.trim().isEmpty
        ? null
        : int.tryParse(lifetimePriceController.text.trim());

    // Validate
    if (monthlyPriceController.text.trim().isNotEmpty && monthlyPrice == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Invalid monthly price')));
      return;
    }
    if (yearlyPriceController.text.trim().isNotEmpty && yearlyPrice == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Invalid yearly price')));
      return;
    }
    if (lifetimePriceController.text.trim().isNotEmpty &&
        lifetimePrice == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Invalid lifetime price')));
      return;
    }

    // Update group with new prices
    final updatedGroup = group.copyWith(
      monthlyPrice: monthlyPrice,
      yearlyPrice: yearlyPrice,
      lifetimePrice: lifetimePrice,
    );

    ref
        .read(groupProvider.notifier)
        .updateGroupPrices(
          group: updatedGroup,
          successCallBack: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ Prices updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          },
          failureCallBack: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('❌ $error'), backgroundColor: Colors.red),
            );
          },
        );
  }

  @override
  void dispose() {
    monthlyPriceController.dispose();
    yearlyPriceController.dispose();
    lifetimePriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupState = ref.watch(groupProvider);
    final group = groupState.group;
    final isLoading = groupState.updateState == AsyncState.loading;

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        title: Text('Subscription Settings'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
        child: SingleChildScrollView(
          child: Column(
            children: [
              AppSizes.xs.ph,
              Text(
                AppStrings.groupSubscriptions,
                style: AppTextStyles.headline1(color: AppColors.white),
              ),
              AppSizes.xxxs.ph,

              // Price input form
              Container(
                padding: EdgeInsets.all(AppSizes.xs),
                decoration: BoxDecoration(
                  color: AppColors.bgBlue,
                  border: Border.all(
                    color: AppColors.skyBlue.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.xxxs),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.setSubscriptionPrices,
                      style: AppTextStyles.headline4().copyWith(
                        fontWeight: AppFontWeights.bold,
                      ),
                    ),
                    AppSizes.lg.ph,

                    // Monthly Price
                    Text(
                      AppStrings.monthlyPrice,
                      style: AppTextStyles.overLine(),
                    ),
                    TextFormField(
                      controller: monthlyPriceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.darkBgContainer,
                        hintText: "0",
                        hintStyle: AppTextStyles.button(
                          color: AppColors.skyBlue,
                        ),
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

                    // Yearly Price
                    Text(
                      AppStrings.yearlyPrice,
                      style: AppTextStyles.overLine(),
                    ),
                    TextFormField(
                      controller: yearlyPriceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.darkBgContainer,
                        hintText: "0",
                        hintStyle: AppTextStyles.button(
                          color: AppColors.skyBlue,
                        ),
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

                    // Lifetime Price
                    Text(
                      AppStrings.lifetimePrice,
                      style: AppTextStyles.overLine(),
                    ),
                    TextFormField(
                      controller: lifetimePriceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.darkBgContainer,
                        hintText: "0",
                        hintStyle: AppTextStyles.button(
                          color: AppColors.skyBlue,
                        ),
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

                    // Update Button
                    AppButton(
                      onPressed: isLoading ? null : _updatePrices,
                      label: isLoading
                          ? 'Updating...'
                          : AppStrings.updatePrices,
                      labelStyle: AppTextStyles.bodyText2(),
                      bgColor: isLoading ? Colors.grey : AppColors.white,
                      radius: AppSizes.xxxs,
                    ),
                  ],
                ),
              ),
              AppSizes.lg.ph,

              // Monthly Plan Display
              Container(
                padding: EdgeInsets.all(AppSizes.xs),
                decoration: BoxDecoration(
                  color: AppColors.bgBlue,
                  border: Border.all(
                    color: AppColors.skyBlue.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.xxxs),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.monthly, style: AppTextStyles.headline4()),
                    Text(
                      AppStrings.billedEveryMonth,
                      style: AppTextStyles.overLine(
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    AppSizes.xs.ph,
                    Text(
                      "₹${group?.monthlyPrice ?? '--'}",
                      style: AppTextStyles.headline1(),
                    ),
                    AppSizes.xs.ph,
                    Row(
                      children: [
                        HugeIcon(
                          icon: HugeIconsStrokeRounded.user,
                          color: AppColors.white,
                        ),
                        AppSizes.xxxs.pw,
                        Text("0 members", style: AppTextStyles.overLine()),
                      ],
                    ),
                  ],
                ),
              ),
              AppSizes.lg.ph,

              // Yearly Plan Display
              Container(
                padding: EdgeInsets.all(AppSizes.xs),
                decoration: BoxDecoration(
                  color: AppColors.bgBlue,
                  border: Border.all(
                    color: AppColors.skyBlue.withValues(alpha: 0.8),
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.xxxs),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.yearly, style: AppTextStyles.headline4()),
                    Text(
                      AppStrings.billedEveryYear,
                      style: AppTextStyles.overLine(
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    AppSizes.xs.ph,
                    Text(
                      "₹${group?.yearlyPrice ?? '--'}",
                      style: AppTextStyles.headline1(),
                    ),
                    if (group?.yearlyPrice != null)
                      Text(
                        "₹${(group!.yearlyPrice! / 12).toStringAsFixed(2)}/mo",
                        style: AppTextStyles.overLine(
                          color: AppColors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    AppSizes.xs.ph,
                    Row(
                      children: [
                        HugeIcon(
                          icon: HugeIconsStrokeRounded.user,
                          color: AppColors.white,
                        ),
                        AppSizes.xxxs.pw,
                        Text("0 members", style: AppTextStyles.overLine()),
                      ],
                    ),
                  ],
                ),
              ),
              AppSizes.lg.ph,

              // Lifetime Plan Display
              Container(
                padding: EdgeInsets.all(AppSizes.xs),
                decoration: BoxDecoration(
                  color: AppColors.bgBlue,
                  border: Border.all(
                    color: AppColors.skyBlue.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.xxxs),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.lifetime, style: AppTextStyles.headline4()),
                    Text(
                      AppStrings.oneTimePayment,
                      style: AppTextStyles.overLine(
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    AppSizes.xs.ph,
                    Text(
                      "₹${group?.lifetimePrice ?? '--'}",
                      style: AppTextStyles.headline1(),
                    ),
                    AppSizes.xs.ph,
                    Row(
                      children: [
                        HugeIcon(
                          icon: HugeIconsStrokeRounded.user,
                          color: AppColors.white,
                        ),
                        AppSizes.xxxs.pw,
                        Text("0 members", style: AppTextStyles.overLine()),
                      ],
                    ),
                  ],
                ),
              ),
              AppSizes.lg.ph,
            ],
          ),
        ),
      ),
    );
  }
}
