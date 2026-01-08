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
import 'package:larnity/src/core/ui/widgets/app_dropdown_datepicker.dart';
import 'package:larnity/src/features/group/data/models/job_model.dart';
import 'package:larnity/src/features/group/presentation/provider/job_provider.dart';

class AddJob extends ConsumerStatefulWidget {
  final String groupId;

  const AddJob({Key? key, required this.groupId}) : super(key: key);

  @override
  ConsumerState<AddJob> createState() => _AddJobState();
}

class _AddJobState extends ConsumerState<AddJob> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _googleSheetIdController = TextEditingController();
  final _picker = ImagePicker();

  DateTime? _selectedEndDate;
  File? _selectedImage;
  String? _uploadedImageUrl;
  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _googleSheetIdController.dispose();
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
      final fileName = 'job-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'jobs/$fileName';

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

  Future<void> _handleCreateJob() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _googleSheetIdController.text.isEmpty ||
        _selectedEndDate == null) {
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

    final job = JobModel(
      groupId: widget.groupId,
      title: _titleController.text,
      description: _descriptionController.text,
      googleSheetId: _googleSheetIdController.text,
      postingEndDate: _selectedEndDate!,
      image: imageUrl.isEmpty ? 'default-image-url' : imageUrl,
    );

    final success = await ref.read(jobProvider).createJob(job);

    if (success && mounted) {
      context.pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Job posted successfully')));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed: ${ref.read(jobProvider).errorMessage}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(jobProvider).isLoading;

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
                Text(AppStrings.createNewJob, style: AppTextStyles.headline4()),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    AppStrings.createNewJobDesc,
                    style: AppTextStyles.overLine(color: AppColors.skyBlue),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            AppSizes.lg.ph,

            Text(AppStrings.jobTitle, style: AppTextStyles.overLine()),
            AppSizes.xxxs.ph,
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.darkBgContainer,
                hintText: AppStrings.jobTitle,
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
            ),
            AppSizes.xs.ph,

            Text(AppStrings.jobDescription, style: AppTextStyles.overLine()),
            AppSizes.xxxs.ph,
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.darkBgContainer,
                hintText: AppStrings.jobDescription,
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
            ),
            AppSizes.xs.ph,

            Text(AppStrings.postingEndDate, style: AppTextStyles.overLine()),
            AppSizes.xxxs.ph,
            DatePickerDropdown(
              overlayHeight: 0.3.sh,
              onDateSelected: (date) {
                setState(() => _selectedEndDate = date);
              },
              button: Container(
                padding: const EdgeInsets.all(AppSizes.xxxs),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.skyBlue),
                  color: AppColors.darkBgContainer,
                  borderRadius: BorderRadius.circular(AppSizes.xxxs),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedEndDate != null
                          ? "${_selectedEndDate!.month}/${_selectedEndDate!.day}/${_selectedEndDate!.year}"
                          : "mm/dd/yyyy",
                    ),
                    HugeIcon(
                      icon: HugeIconsStrokeRounded.calendar03,
                      color: AppColors.white,
                    ),
                  ],
                ),
              ),
            ),
            AppSizes.xs.ph,

            Text(AppStrings.googleSheetId, style: AppTextStyles.overLine()),
            AppSizes.xxxs.ph,
            TextFormField(
              controller: _googleSheetIdController,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.darkBgContainer,
                hintText: AppStrings.googleSheetId,
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
                            //   backgroundColor: AppColors.error,
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

            AppButton(
              onPressed: isLoading || _isUploading ? null : _handleCreateJob,
              label: isLoading ? "Posting..." : AppStrings.create,
              labelStyle: AppTextStyles.bodyText2(color: AppColors.white),
              bgColor: Colors.transparent,
              borderColor: AppColors.skyBlue.withValues(alpha: 0.5),
              radius: AppSizes.xxxs,
            ),
          ],
        ),
      ),
    );
  }
}
