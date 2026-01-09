import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:image_picker/image_picker.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/extensions/screen_size_extension.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/ui/widgets/phone_number_input.dart';
import 'package:larnity/src/features/group/data/datasource/country_list_with_code.dart';
import 'package:larnity/src/features/group/data/models/country_model.dart';
import 'package:larnity/src/features/group/data/models/product_model.dart';
import 'package:larnity/src/features/group/presentation/provider/service_provider.dart';

class AddService extends ConsumerStatefulWidget {
  final String groupId;

  const AddService({Key? key, required this.groupId}) : super(key: key);

  @override
  ConsumerState<AddService> createState() => _AddServiceState();
}

class _AddServiceState extends ConsumerState<AddService> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountPriceController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String _phoneNumber = '';
  int _selectedRating = 5;
  File? _selectedImage;
  bool _isUploadingImage = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to take photo: $e')));
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Replace the _createService method with this:

  Future<void> _createService() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter WhatsApp number')),
      );
      return;
    }

    if (_selectedImage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select an image')));
      return;
    }

    setState(() {
      _isUploadingImage = true;
    });

    String imageUrl;
    try {
      // Upload to Supabase Storage
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${_selectedImage!.path.split('/').last}';
      final bytes = await _selectedImage!.readAsBytes();

      await ref
          .read(supabaseClientProvider)
          .storage
          .from('images')
          .uploadBinary(fileName, bytes);

      imageUrl = ref
          .read(supabaseClientProvider)
          .storage
          .from('images')
          .getPublicUrl(fileName);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to upload image: $e')));
      }
      setState(() {
        _isUploadingImage = false;
      });
      return;
    }

    setState(() {
      _isUploadingImage = false;
    });

    final service = ProductModel(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      discountPrice: _discountPriceController.text.isNotEmpty
          ? double.parse(_discountPriceController.text.trim())
          : null,
      whatsappNumber: _phoneNumber,
      imageUrl: imageUrl,
      groupId: widget.groupId,
      type: ProductType.service,
      rating: _selectedRating,
    );

    final success = await ref.read(serviceProvider).createService(service);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service created successfully!')),
        );
        context.pop();
      } else {
        final error = ref.read(serviceProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create service: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final serviceState = ref.watch(serviceProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSizes.xs),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      context.pop();
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.createNewService,
                    style: AppTextStyles.headline4(),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      AppStrings.createNewServiceDesc,
                      style: AppTextStyles.overLine(color: AppColors.skyBlue),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              AppSizes.lg.ph,

              Text(AppStrings.serviceName, style: AppTextStyles.overLine()),
              AppSizes.xxxs.ph,
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.darkBgContainer,
                  hintText: AppStrings.serviceNameHint,
                  hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.xxxs),
                    borderSide: BorderSide(
                      color: AppColors.skyBlue.withValues(alpha: 0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.xxxs),
                    borderSide: const BorderSide(color: AppColors.skyBlue),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter service name';
                  }
                  return null;
                },
              ),
              AppSizes.xs.ph,
              Text(
                AppStrings.serviceDescription,
                style: AppTextStyles.overLine(),
              ),
              AppSizes.xxxs.ph,
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.darkBgContainer,
                  hintText: AppStrings.serviceDescriptionHint,
                  hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.xxxs),
                    borderSide: BorderSide(
                      color: AppColors.skyBlue.withValues(alpha: 0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.xxxs),
                    borderSide: const BorderSide(color: AppColors.skyBlue),
                  ),
                ),
                maxLines: 5,
                minLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter service description';
                  }
                  return null;
                },
              ),
              AppSizes.xs.ph,
              Text(AppStrings.servicePrice, style: AppTextStyles.overLine()),
              AppSizes.xxxs.ph,
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.darkBgContainer,
                  hintText: "0",
                  hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.xxxs),
                    borderSide: BorderSide(
                      color: AppColors.skyBlue.withValues(alpha: 0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.xxxs),
                    borderSide: const BorderSide(color: AppColors.skyBlue),
                  ),
                ),
                keyboardType: TextInputType.number,
                maxLines: 1,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter valid price';
                  }
                  return null;
                },
              ),
              AppSizes.xs.ph,
              Text(
                AppStrings.serviceDiscountPrice,
                style: AppTextStyles.overLine(),
              ),
              AppSizes.xxxs.ph,
              TextFormField(
                controller: _discountPriceController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.darkBgContainer,
                  hintText: "0",
                  hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.xxxs),
                    borderSide: BorderSide(
                      color: AppColors.skyBlue.withValues(alpha: 0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.xxxs),
                    borderSide: const BorderSide(color: AppColors.skyBlue),
                  ),
                ),
                keyboardType: TextInputType.number,
                maxLines: 1,
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      double.tryParse(value) == null) {
                    return 'Please enter valid discount price';
                  }
                  return null;
                },
              ),
              AppSizes.xs.ph,
              Text(AppStrings.whatsappNumber, style: AppTextStyles.overLine()),
              AppSizes.xxxs.ph,

              PhoneNumberInput(
                countries: CountryListWithCode.countries,
                initialCountry: CountryModel(
                  name: "India",
                  code: "+91",
                  flag: '🇮🇳',
                  codeAbbreviation: 'IN',
                  states: [
                    'Andaman and Nicobar Islands',
                    'Andhra Pradesh',
                    'Arunachal Pradesh',
                    'Assam',
                    'Bihar',
                    'Chandigarh',
                    'Chhattisgarh',
                    'Dadra and Nagar Haveli and Daman and Diu',
                    'Delhi',
                    'Goa',
                    'Gujarat',
                    'Haryana',
                    'Himachal Pradesh',
                    'Jammu and Kashmir',
                    'Jharkhand',
                    'Karnataka',
                    'Kerala',
                    'Ladakh',
                    'Lakshadweep',
                    'Madhya Pradesh',
                    'Maharashtra',
                    'Manipur',
                    'Meghalaya',
                    'Mizoram',
                    'Nagaland',
                    'Odisha',
                    'Puducherry',
                    'Punjab',
                    'Rajasthan',
                    'Sikkim',
                    'Tamil Nadu',
                    'Telangana',
                    'Tripura',
                    'Uttar Pradesh',
                    'Uttarakhand',
                    'West Bengal',
                  ],
                ),
                countryDropdownHint: "Country",
                hintText: "00000-00000",
                textStyle: AppTextStyles.overLine(color: AppColors.white),
                onPhoneNumberChanged: (phone, country) {
                  _phoneNumber = phone;
                },
              ),
              AppSizes.xs.ph,

              // Image Upload Section
              Text(AppStrings.uploadImage, style: AppTextStyles.overLine()),
              AppSizes.xxxs.ph,
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  height: 0.2.sh,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.skyBlue.withValues(alpha: 0.5),
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.xs),
                    color: AppColors.darkBgContainer,
                  ),
                  child: _selectedImage != null
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppSizes.xs),
                              child: Image.file(
                                _selectedImage!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedImage = null;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: AppColors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            HugeIcon(
                              icon: HugeIconsStrokeRounded.image02,
                              color: AppColors.skyBlue,
                              size: 48,
                            ),
                            AppSizes.xxxs.ph,
                            Text(
                              'Tap to upload image',
                              style: AppTextStyles.caption2(
                                color: AppColors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              AppSizes.xs.ph,

              Text(AppStrings.productRating, style: AppTextStyles.overLine()),
              AppSizes.xs.ph,

              Row(
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRating = index + 1;
                      });
                    },
                    child: HugeIcon(
                      icon: HugeIconsStrokeRounded.star,
                      color: index < _selectedRating
                          ? AppColors.primaryOrange
                          : AppColors.creamWhite.withValues(alpha: 0.3),
                    ),
                  );
                }),
              ),
              AppSizes.xs.ph,
              AppButton(
                onPressed: (serviceState.isLoading || _isUploadingImage)
                    ? null
                    : _createService,
                label: _isUploadingImage
                    ? 'Uploading image...'
                    : serviceState.isLoading
                    ? 'Creating...'
                    : AppStrings.create,
                labelStyle: AppTextStyles.bodyText2(color: AppColors.white),
                bgColor: Colors.transparent,
                borderColor: AppColors.skyBlue.withValues(alpha: 0.5),
                radius: AppSizes.xxxs,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
