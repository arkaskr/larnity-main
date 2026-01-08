import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/extensions/screen_size_extension.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/ui/widgets/app_dropdown.dart';
import 'package:larnity/src/features/group/data/models/product_model.dart';
import 'package:larnity/src/features/group/presentation/provider/product_provider.dart';

class AddProduct extends ConsumerStatefulWidget {
  final String groupId;

  const AddProduct({Key? key, required this.groupId}) : super(key: key);

  @override
  ConsumerState<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends ConsumerState<AddProduct> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountPriceController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _ratingController = TextEditingController();
  final _picker = ImagePicker();

  ProductType _selectedType = ProductType.product;
  File? _selectedImage;
  String? _uploadedImageUrl;
  bool _isUploading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    _whatsappController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;

    setState(() {
      _isUploading = true;
    });

    try {
      final supabase = ref.read(supabaseClientProvider);
      final bytes = await _selectedImage!.readAsBytes();
      final fileExt = _selectedImage!.path.split('.').last;
      final fileName =
          'product-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'products/$fileName';

      await supabase.storage.from('images').uploadBinary(filePath, bytes);

      final imageUrl = supabase.storage.from('images').getPublicUrl(filePath);

      setState(() {
        _uploadedImageUrl = imageUrl;
        _isUploading = false;
      });

      return imageUrl;
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Image upload failed: $e')));
      }
      return null;
    }
  }

  Future<void> _handleCreateProduct() async {
    if (_nameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _whatsappController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    // Upload image first if selected
    String imageUrl = _uploadedImageUrl ?? '';
    if (_selectedImage != null && _uploadedImageUrl == null) {
      final uploaded = await _uploadImage();
      if (uploaded == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Image upload required')));
        return;
      }
      imageUrl = uploaded;
    }

    final product = ProductModel(
      groupId: widget.groupId,
      name: _nameController.text,
      description: _descriptionController.text,
      price: double.tryParse(_priceController.text) ?? 0.0,
      discountPrice: _discountPriceController.text.isNotEmpty
          ? double.tryParse(_discountPriceController.text)
          : null,
      whatsappNumber: _whatsappController.text,
      imageUrl: imageUrl.isEmpty ? 'default-image-url' : imageUrl,
      type: _selectedType,
      rating: _ratingController.text.isNotEmpty
          ? int.tryParse(_ratingController.text)
          : 1,
    );

    final success = await ref.read(productProvider).createProduct(product);

    if (success && mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed: ${ref.read(productProvider).errorMessage}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(productProvider).isLoading;

    return Padding(
      padding: const EdgeInsets.all(AppSizes.xs),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppStrings.addNewProduct,
                  style: AppTextStyles.headline4(),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    AppStrings.addNewProductDesc ??
                        'Add a new product or service',
                    style: AppTextStyles.overLine(color: AppColors.skyBlue),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            AppSizes.lg.ph,

            // Type Selection
            Text('Type', style: AppTextStyles.overLine()),
            AppSizes.xxxs.ph,
            AppDropdown(
              button: Container(
                padding: const EdgeInsets.all(AppSizes.xs),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.skyBlue.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.xs),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedType == ProductType.product
                          ? 'Product'
                          : 'Service',
                      style: AppTextStyles.bodyText2(color: AppColors.white),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.white,
                    ),
                  ],
                ),
              ),
              onItemSelected: (value) {
                setState(() {
                  _selectedType = value == 'product'
                      ? ProductType.product
                      : ProductType.service;
                });
              },
              items: const [
                AppDropdownItem(value: 'product', label: 'Product'),
                AppDropdownItem(value: 'service', label: 'Service'),
              ],
            ),
            AppSizes.xs.ph,

            // Name
            Text(AppStrings.name ?? 'Name', style: AppTextStyles.overLine()),
            AppSizes.xxxs.ph,
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.darkBgContainer,
                hintText: 'Enter product name',
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
            ),
            AppSizes.xs.ph,

            // Description
            Text(AppStrings.description, style: AppTextStyles.overLine()),
            AppSizes.xxxs.ph,
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.darkBgContainer,
                hintText: 'Enter description',
              ),
            ),
            AppSizes.xs.ph,

            // Image Upload
            GestureDetector(
              onTap: _isUploading ? null : _pickImage,
              child: Container(
                height: 0.2.sh,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.skyBlue.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.xs),
                  image: _selectedImage != null
                      ? DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _selectedImage == null
                    ? Center(
                        child: _isUploading
                            ? const CircularProgressIndicator()
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_outlined,
                                    color: AppColors.white.withValues(
                                      alpha: 0.5,
                                    ),
                                    size: 48,
                                  ),
                                  AppSizes.xxxs.ph,
                                  Text(
                                    AppStrings.uploadImage,
                                    style: AppTextStyles.caption2(
                                      color: AppColors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      )
                    : Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            //  backgroundColor: AppColors.error,
                            child: IconButton(
                              icon: const Icon(Icons.close, size: 16),
                              onPressed: () {
                                setState(() {
                                  _selectedImage = null;
                                  _uploadedImageUrl = null;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            AppSizes.xs.ph,

            // Price & Discount
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Price', style: AppTextStyles.overLine()),
                      AppSizes.xxxs.ph,
                      TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.darkBgContainer,
                          hintText: '0.00',
                          prefixText: '₹',
                        ),
                      ),
                    ],
                  ),
                ),
                AppSizes.xs.pw,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Discount Price', style: AppTextStyles.overLine()),
                      AppSizes.xxxs.ph,
                      TextFormField(
                        controller: _discountPriceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.darkBgContainer,
                          hintText: '0.00',
                          prefixText: '₹',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            AppSizes.xs.ph,

            // WhatsApp Number
            Text('WhatsApp Number', style: AppTextStyles.overLine()),
            AppSizes.xxxs.ph,
            TextFormField(
              controller: _whatsappController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.darkBgContainer,
                hintText: '919999999999',
              ),
            ),
            AppSizes.xs.ph,

            // Rating
            Text('Rating (1-5)', style: AppTextStyles.overLine()),
            AppSizes.xxxs.ph,
            TextFormField(
              controller: _ratingController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.darkBgContainer,
                hintText: '1',
              ),
            ),
            AppSizes.xs.ph,

            AppButton(
              onPressed: isLoading || _isUploading
                  ? null
                  : _handleCreateProduct,
              label: isLoading ? "Creating..." : AppStrings.create,
              bgColor: AppColors.primaryOrange,
            ),
          ],
        ),
      ),
    );
  }
}
