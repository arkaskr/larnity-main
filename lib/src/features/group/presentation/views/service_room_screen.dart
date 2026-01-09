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
import 'package:larnity/src/features/group/presentation/provider/service_provider.dart';
import 'package:larnity/src/features/group/presentation/widgets/add_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceRoomScreen extends ConsumerStatefulWidget {
  const ServiceRoomScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ServiceRoomScreen> createState() => _ServiceRoomScreenState();
}

class _ServiceRoomScreenState extends ConsumerState<ServiceRoomScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final groupState = ref.read(groupProvider);
      final currentGroupId = groupState.group?.id;
      if (currentGroupId != null) {
        ref.read(serviceProvider).fetchServices(currentGroupId);
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

  Widget _buildServiceCard(ProductModel service, String currentGroupId) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.xs),
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
              service.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
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
                        service.name,
                        style: AppTextStyles.headline4(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
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
                              title: const Text('Delete Service'),
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
                                .read(serviceProvider)
                                .deleteService(service.id!, currentGroupId);
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
                  service.description,
                  style: AppTextStyles.overLine(),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSizes.xs.ph,

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Price
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: service.discountPrice != null
                                  ? "₹${service.discountPrice!.toStringAsFixed(0)} "
                                  : "₹${service.price.toStringAsFixed(0)} ",
                              style: AppTextStyles.bodyText1(
                                color: AppColors.primaryOrange,
                              ),
                            ),
                            if (service.discountPrice != null)
                              TextSpan(
                                text: "₹${service.price.toStringAsFixed(0)}",
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
                    ),

                    // Rating
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...List.generate(
                          5,
                          (index) => HugeIcon(
                            icon: HugeIconsStrokeRounded.star,
                            color: index < (service.rating ?? 1)
                                ? AppColors.primaryOrange
                                : AppColors.creamWhite.withValues(alpha: 0.3),
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "(${service.rating ?? 1})",
                          style: AppTextStyles.overLine(
                            color: AppColors.creamWhite,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                AppSizes.xs.ph,

                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    onPressed: () => _contactOnWhatsApp(service.whatsappNumber),
                    label: 'Book Now',
                    prefix: HugeIcon(
                      icon: HugeIconsStrokeRounded.whatsapp,
                      color: AppColors.black,
                    ),
                    labelStyle: AppTextStyles.button(color: AppColors.black),
                    bgColor: AppColors.primaryOrange,
                  ),
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
    final serviceState = ref.watch(serviceProvider);

    if (currentGroupId == null) {
      return const Center(child: Text('No group selected'));
    }

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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.serviceRoom,
                        style: AppTextStyles.headline2(color: AppColors.white),
                      ),
                      Text(
                        "${serviceState.services.length}${AppStrings.servicesAvailable ?? ' services available'}",
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
                            borderRadius: BorderRadius.circular(AppSizes.xxxs),
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
                              child: AddService(groupId: currentGroupId),
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
                  label: AppStrings.addService,
                  labelStyle: AppTextStyles.bodyText2(color: AppColors.black),
                  bgColor: AppColors.primaryOrange,
                  radius: AppSizes.xxxs,
                ),
              ],
            ),
            AppSizes.xs.ph,

            // Services List
            Expanded(
              child: serviceState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : serviceState.errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error: ${serviceState.errorMessage}'),
                          AppSizes.xs.ph,
                          AppButton(
                            onPressed: () {
                              ref
                                  .read(serviceProvider)
                                  .fetchServices(currentGroupId);
                            },
                            label: 'Retry',
                            bgColor: AppColors.primaryOrange,
                          ),
                        ],
                      ),
                    )
                  : serviceState.services.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          HugeIcon(
                            icon: HugeIconsStrokeRounded.customerService,
                            color: AppColors.skyBlue,
                            size: 64,
                          ),
                          AppSizes.xs.ph,
                          Text(
                            'No services yet',
                            style: AppTextStyles.headline4(
                              color: AppColors.white,
                            ),
                          ),
                          AppSizes.xxxs.ph,
                          Text(
                            'Add your first service to get started',
                            style: AppTextStyles.overLine(),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: serviceState.services.length,
                      itemBuilder: (context, index) {
                        final service = serviceState.services[index];
                        return _buildServiceCard(service, currentGroupId);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
