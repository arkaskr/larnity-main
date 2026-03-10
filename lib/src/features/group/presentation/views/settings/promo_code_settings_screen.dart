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
import 'package:larnity/src/core/ui/widgets/app_table.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/promotion_provider.dart';
import 'package:larnity/src/features/group/presentation/widgets/settings/create_promo_code.dart';
import 'package:flutter/services.dart';

class PromoCodeSettingsScreen extends ConsumerStatefulWidget {
  const PromoCodeSettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PromoCodeSettingsScreen> createState() =>
      _PromoCodeSettingsScreenState();
}

class _PromoCodeSettingsScreenState
    extends ConsumerState<PromoCodeSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final groupId = ref.read(groupProvider).group?.id;
      if (groupId != null) {
        ref
            .read(promotionProvider.notifier)
            .getPromotionsByGroup(groupId: groupId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final promotionState = ref.watch(promotionProvider);
    final promotions = promotionState.promotions ?? [];
    final isLoading = promotionState.isLoading;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.xs),
        child: Column(
          children: [
            AppSizes.xs.ph,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    AppStrings.promoCodes,
                    style: AppTextStyles.headline2(color: AppColors.white),
                  ),
                ),
                AppSizes.xs.pw,
                AppButton(
                  isExpanded: false,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          AlertDialog(content: CreatePromoCode()),
                    );
                  },
                  prefix: HugeIcon(
                    icon: HugeIconsStrokeRounded.addCircle,
                    color: AppColors.black,
                  ),
                  label: AppStrings.createPromoCode,
                  labelStyle: AppTextStyles.bodyText2(color: AppColors.black),
                  bgColor: AppColors.white,
                  radius: AppSizes.xxxs,
                ),
              ],
            ),
            AppSizes.xs.ph,
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : AppTable(
                      columns: [
                        TableColumn(
                          title: 'Promo Code',
                          width: 140,
                          cellBuilder: (index) {
                            final promo = promotions[index];
                            return Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    promo.code,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () async {
                                    await Clipboard.setData(
                                      ClipboardData(text: promo.code),
                                    );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Promo code copied to clipboard",
                                          ),
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Icon(
                                    Icons.copy,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        TableColumn(
                          title: 'Plan Type',
                          width: 120,
                          cellBuilder: (index) => Text(
                            promotions[index].planType,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                        TableColumn(
                          title: 'Discount',
                          width: 100,
                          cellBuilder: (index) => Text(
                            '${promotions[index].discountRate}%',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        TableColumn(
                          title: 'Usage',
                          width: 80,
                          cellBuilder: (index) {
                            final promo = promotions[index];
                            final max = promo.maxUses == 0
                                ? "∞"
                                : "${promo.maxUses}";
                            return Text(
                              "${promo.currentUses}/$max",
                              style: const TextStyle(color: Colors.grey),
                            );
                          },
                        ),
                        TableColumn(
                          title: 'Status',
                          width: 80,
                          cellBuilder: (index) => Switch(
                            value: promotions[index].isActive,
                            onChanged: (value) {
                              ref
                                  .read(promotionProvider.notifier)
                                  .updatePromotionStatus(
                                    id: promotions[index].id,
                                    isActive: value,
                                  );
                            },
                            activeColor: Colors.green,
                          ),
                        ),
                        TableColumn(
                          title: 'Actions',
                          width: 100,
                          cellBuilder: (index) => ElevatedButton(
                            onPressed: () {
                              final promoId = promotions[index].id;
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Delete Promo Code"),
                                  content: const Text(
                                    "Are you sure you want to delete this promo code?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        ref
                                            .read(promotionProvider.notifier)
                                            .deletePromotion(
                                              id: promoId,
                                              successCallBack: () {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "Promo code deleted successfully",
                                                    ),
                                                  ),
                                                );
                                              },
                                              failureCallBack: (error) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      "Failed to delete: $error",
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                      },
                                      child: const Text(
                                        "Delete",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              minimumSize: Size.zero,
                            ),
                            child: const Text(
                              'Delete',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                      rowCount: promotions.length,
                      emptyWidget: Text(AppStrings.noPromoCode),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
