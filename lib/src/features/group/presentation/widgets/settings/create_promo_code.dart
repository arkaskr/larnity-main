import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/ui/widgets/app_dropdown.dart';
import 'package:larnity/src/features/group/data/models/promotion_model.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/promotion_provider.dart';
import 'package:uuid/uuid.dart';

class CreatePromoCode extends ConsumerStatefulWidget {
  const CreatePromoCode({Key? key}) : super(key: key);

  @override
  ConsumerState<CreatePromoCode> createState() => _CreatePromoCodeState();
}

class _CreatePromoCodeState extends ConsumerState<CreatePromoCode> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _maxUsesController = TextEditingController();

  String _selectedPlanType = 'MONTHLY';
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    _discountController.dispose();
    _maxUsesController.dispose();
    super.dispose();
  }

  void _autoGenerateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final code = List.generate(
      8,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
    _codeController.text = code;
  }

  Future<void> _createPromoCode() async {
    final group = ref.read(groupProvider).group;
    if (group == null || group.id == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Group not found")));
      return;
    }

    if (_codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a promo code")),
      );
      return;
    }

    if (_discountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a discount percentage")),
      );
      return;
    }

    try {
      final discount = int.parse(_discountController.text);
      final maxUses = _maxUsesController.text.isEmpty
          ? 0
          : int.parse(_maxUsesController.text);

      if (discount <= 0 || discount > 100) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Discount must be between 1 and 100")),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final promotion = PromotionModel(
        id: const Uuid().v4(),
        createdAt: DateTime.now(),
        code: _codeController.text.toUpperCase(),
        discountRate: discount,
        planType: _selectedPlanType,
        maxUses: maxUses,
        currentUses: 0,
        isActive: true,
        groupId: group.id!,
      );

      await ref
          .read(promotionProvider.notifier)
          .createPromotion(
            promotion: promotion,
            successCallBack: () {
              if (mounted) {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Promo code created successfully"),
                  ),
                );
              }
            },
            failureCallBack: (error) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to create: $error")),
                );
              }
            },
          );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid input format")));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(onPressed: () => context.pop(), icon: Icon(Icons.close)),
          ],
        ),
        Text(AppStrings.createNewPromoCode, style: AppTextStyles.headline4()),
        Text(
          AppStrings.createNewPromoCodeDesc,
          style: AppTextStyles.overLine(color: AppColors.skyBlue),
        ),
        AppSizes.lg.ph,
        Text(AppStrings.promoCode, style: AppTextStyles.overLine()),
        AppSizes.xxxs.ph,
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.darkBgContainer,
                  hintText: AppStrings.promoCodeHint,
                  hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.xxxs),
                    borderSide: BorderSide(
                      color: AppColors.skyBlue.withOpacity(0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.xxxs),
                    borderSide: BorderSide(color: AppColors.skyBlue),
                  ),
                ),
              ),
            ),
            AppSizes.xs.pw,
            AppButton(
              isExpanded: false,
              height: 52,
              onPressed: _autoGenerateCode,
              label: AppStrings.autoGenerate,
              labelStyle: AppTextStyles.button(color: AppColors.white),
              bgColor: Colors.transparent,
              borderColor: AppColors.skyBlue.withOpacity(0.5),
            ),
          ],
        ),
        AppSizes.xs.ph,
        Text(AppStrings.planType, style: AppTextStyles.overLine()),
        AppSizes.xxxs.ph,
        AppDropdown<String>(
          button: Container(
            padding: EdgeInsets.all(AppSizes.xs),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.skyBlue.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(AppSizes.xs),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedPlanType == 'MONTHLY'
                      ? "Monthly Plan"
                      : "Yearly Plan",
                  style: AppTextStyles.bodyText2(color: AppColors.white),
                ),
                Icon(Icons.keyboard_arrow_down, color: AppColors.white),
              ],
            ),
          ),
          items: [
            AppDropdownItem(value: "MONTHLY", label: "Monthly Plan"),
            AppDropdownItem(value: "YEARLY", label: "Yearly Plan"),
          ],
          onItemSelected: (value) {
            setState(() {
              _selectedPlanType = value;
            });
          },
        ),
        AppSizes.xs.ph,
        Text(AppStrings.discountPercentage, style: AppTextStyles.overLine()),
        AppSizes.xxxs.ph,
        TextFormField(
          controller: _discountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.darkBgContainer,
            hintText: "10",
            hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.xxxs),
              borderSide: BorderSide(color: AppColors.skyBlue.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.xxxs),
              borderSide: BorderSide(color: AppColors.skyBlue),
            ),
          ),
        ),
        AppSizes.xs.ph,
        Text(AppStrings.maxUses, style: AppTextStyles.overLine()),
        AppSizes.xxxs.ph,
        TextFormField(
          controller: _maxUsesController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.darkBgContainer,
            hintText: AppStrings.maxUsesUnlimitedHint,
            hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.xxxs),
              borderSide: BorderSide(color: AppColors.skyBlue.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.xxxs),
              borderSide: BorderSide(color: AppColors.skyBlue),
            ),
          ),
        ),
        AppSizes.xs.ph,
        AppButton(
          onPressed: _isLoading ? null : _createPromoCode,
          label: _isLoading ? "Generating..." : AppStrings.generatePromoCode,
          labelStyle: AppTextStyles.button(color: AppColors.black),
          bgColor: AppColors.primaryOrange,
        ),
      ],
    );
  }
}
