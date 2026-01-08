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
import 'package:larnity/src/core/ui/widgets/app_dropdown.dart';
import 'package:larnity/src/features/group/data/models/product_model.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/product_provider.dart';
import 'package:larnity/src/features/group/presentation/widgets/add_product.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductRoomScreen extends ConsumerStatefulWidget {
  const ProductRoomScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProductRoomScreen> createState() => _ProductRoomScreenState();
}

class _ProductRoomScreenState extends ConsumerState<ProductRoomScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final groupState = ref.read(groupProvider);
      final currentGroupId = groupState.group?.id;
      if (currentGroupId != null) {
        ref.read(productProvider).fetchProducts(currentGroupId);
      }
    });
  }

  Future<void> _contactOnWhatsApp(String phoneNumber) async {
    final url = 'https://wa.me/$phoneNumber';
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp')),
        );
      }
    }
  }

  Widget _buildProductCard(ProductModel product, String currentGroupId) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkBgContainer,
        borderRadius: BorderRadius.circular(AppSizes.xs),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppSizes.xs),
              topRight: Radius.circular(AppSizes.xs),
            ),
            child: Image.network(
              product.imageUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 150,
                  color: AppColors.primaryOrange.withValues(alpha: 0.3),
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 48,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSizes.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: AppTextStyles.headline4(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppDropdown(
                      button: const Icon(
                        Icons.more_vert,
                        color: AppColors.white,
                      ),
                      overlayWidth: 160,
                      overlayAlignment: Alignment.centerRight,
                      onItemSelected: (value) async {
                        if (value == 'delete') {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Product'),
                              content: const Text('Are you sure?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true && mounted) {
                            await ref
                                .read(productProvider)
                                .deleteProduct(product.id!, currentGroupId);
                          }
                        }
                      },
                      items: [
                        AppDropdownItem(
                          value: "edit",
                          child: Row(
                            children: [
                              HugeIcon(
                                icon: HugeIconsStrokeRounded.edit03,
                                color: AppColors.primaryOrange,
                              ),
                              AppSizes.xxxs.pw,
                              Text(
                                AppStrings.edit,
                                style: AppTextStyles.overLine(
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppDropdownItem(
                          value: "delete",
                          child: Row(
                            children: [
                              HugeIcon(
                                icon: HugeIconsStrokeRounded.delete01,
                                color: AppColors.red,
                              ),
                              AppSizes.xxxs.pw,
                              Text(
                                AppStrings.delete,
                                style: AppTextStyles.overLine(
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                AppSizes.xs.ph,
                Text(
                  product.description,
                  style: AppTextStyles.overLine(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSizes.xs.ph,

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Price
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: product.discountPrice != null
                                ? "₹${product.discountPrice!.toStringAsFixed(0)} "
                                : "₹${product.price.toStringAsFixed(0)} ",
                            style: AppTextStyles.bodyText1(
                              color: AppColors.primaryOrange,
                            ),
                          ),
                          if (product.discountPrice != null)
                            TextSpan(
                              text: "₹${product.price.toStringAsFixed(0)}",
                              style:
                                  AppTextStyles.bodyText1(
                                    color: AppColors.creamWhite,
                                  ).copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: AppColors.creamWhite,
                                  ),
                            ),
                        ],
                      ),
                    ),

                    // Rating
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (index) => HugeIcon(
                            icon: HugeIconsStrokeRounded.star,
                            color: index < (product.rating ?? 1)
                                ? AppColors.primaryOrange
                                : AppColors.creamWhite.withValues(alpha: 0.3),
                            size: 16,
                          ),
                        ),
                        AppSizes.xxxs.pw,
                        Text(
                          "(${product.rating ?? 1})",
                          style: AppTextStyles.overLine(
                            color: AppColors.creamWhite,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                AppSizes.xs.ph,

                AppButton(
                  onPressed: () => _contactOnWhatsApp(product.whatsappNumber),
                  label: AppStrings.buyNow,
                  prefix: HugeIcon(
                    icon: HugeIconsStrokeRounded.whatsapp,
                    color: AppColors.black,
                  ),
                  labelStyle: AppTextStyles.button(color: AppColors.black),
                  bgColor: AppColors.primaryOrange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupState = ref.watch(groupProvider);
    final currentGroupId = groupState.group?.id;
    final productState = ref.watch(productProvider);

    if (currentGroupId == null) {
      return const Center(child: Text('No group selected'));
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
        child: SingleChildScrollView(
          child: Column(
            children: [
              AppSizes.xs.ph,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.productRoom,
                          style: AppTextStyles.headline2(
                            color: AppColors.white,
                          ),
                        ),
                        Text(
                          "${productState.products.length}${AppStrings.productsAvailable ?? ' products available'}",
                          style: AppTextStyles.overLine(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppButton(
                    isExpanded: false,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          final size = MediaQuery.of(context).size;
                          return Dialog(
                            insetPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 24,
                            ),
                            backgroundColor: AppColors.bgBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.xxxs,
                              ),
                            ),
                            child: SizedBox(
                              width: size.width * 0.95,
                              height: size.height * 0.7,
                              child: SingleChildScrollView(
                                padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(
                                    context,
                                  ).viewInsets.bottom,
                                ),
                                child: AddProduct(groupId: currentGroupId),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    prefix: HugeIcon(
                      icon: HugeIconsStrokeRounded.addCircle,
                      color: AppColors.black,
                    ),
                    label: AppStrings.addProduct,
                    labelStyle: AppTextStyles.bodyText2(color: AppColors.black),
                    bgColor: AppColors.primaryOrange,
                    radius: AppSizes.xxxs,
                  ),
                ],
              ),
              AppSizes.xs.ph,

              // Products List
              productState.isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSizes.lg),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : productState.errorMessage != null
                  ? Center(
                      child: Column(
                        children: [
                          Text(
                            'Error: ${productState.errorMessage}',
                            // style: AppTextStyles.bodyText2(color: AppColors.error),
                          ),
                          AppSizes.xs.ph,
                          AppButton(
                            onPressed: () {
                              ref
                                  .read(productProvider)
                                  .fetchProducts(currentGroupId);
                            },
                            label: 'Retry',
                            bgColor: AppColors.primaryOrange,
                          ),
                        ],
                      ),
                    )
                  : productState.products.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.lg),
                        child: Column(
                          children: [
                            HugeIcon(
                              icon: HugeIconsStrokeRounded.shoppingBag01,
                              color: AppColors.skyBlue,
                              size: 64,
                            ),
                            AppSizes.xs.ph,
                            Text(
                              'No products yet',
                              style: AppTextStyles.headline4(
                                color: AppColors.white,
                              ),
                            ),
                            AppSizes.xxxs.ph,
                            Text(
                              'Add your first product to get started',
                              style: AppTextStyles.overLine(),
                            ),
                          ],
                        ),
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: AppSizes.xs,
                            mainAxisSpacing: AppSizes.xs,
                            childAspectRatio: 0.65,
                          ),
                      itemCount: productState.products.length,
                      itemBuilder: (context, index) {
                        final product = productState.products[index];
                        return _buildProductCard(product, currentGroupId);
                      },
                    ),
              AppSizes.xs.ph,
            ],
          ),
        ),
      ),
    );
  }
}
