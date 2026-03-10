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
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/ui/widgets/toast.dart';
import 'package:larnity/src/features/group/data/models/challenge_model.dart';
import 'package:larnity/src/features/group/presentation/provider/challenge_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class CreateChallenge extends ConsumerStatefulWidget {
  const CreateChallenge({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateChallenge> createState() => _CreateChallengeState();
}

class _CreateChallengeState extends ConsumerState<CreateChallenge> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController maxParticipantsController =
      TextEditingController();
  final TextEditingController firstPrizeController = TextEditingController();
  final TextEditingController secondPrizeController = TextEditingController();
  final TextEditingController thirdPrizeController = TextEditingController();
  final TextEditingController registrationFeeController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;
  bool isPaid = false;
  File? selectedThumbnail;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    maxParticipantsController.dispose();
    firstPrizeController.dispose();
    secondPrizeController.dispose();
    thirdPrizeController.dispose();
    registrationFeeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedThumbnail = File(image.path);
      });
    }
  }

  void _createChallenge() async {
    final groupState = ref.read(groupProvider);
    final groupId = groupState.group?.id;

    if (groupId == null) {
      AppToast.show("Group not found");
      return;
    }

    if (titleController.text.isEmpty) {
      AppToast.show("Please enter a title");
      return;
    }
    if (startDate == null || endDate == null) {
      AppToast.show("Please select a date range");
      return;
    }

    final challenge = ChallengeModel(
      title: titleController.text,
      startDate: startDate!,
      endDate: endDate!,
      maxParticipants: double.tryParse(maxParticipantsController.text) ?? 0,
      firstPlacePrize: int.tryParse(firstPrizeController.text) ?? 0,
      secondPlacePrize: int.tryParse(secondPrizeController.text) ?? 0,
      thirdPlacePrize: int.tryParse(thirdPrizeController.text) ?? 0,
      registrationFee: int.tryParse(registrationFeeController.text) ?? 0,
      isPaid: isPaid,
      groupId: groupId,
      description: descriptionController.text,
      status: 'PUBLISHED',
    );

    final success = await ref
        .read(challengeProvider.notifier)
        .createChallenge(challenge, selectedThumbnail);

    if (success && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(challengeProvider).isLoading;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  context.pop();
                },
                icon: Icon(Icons.close),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    AppStrings.createNewChallenge,
                    style: AppTextStyles.headline4(),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    AppStrings.createNewChallengeDesc,
                    style: AppTextStyles.overLine(color: AppColors.creamWhite),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),

          AppSizes.xlg.ph,
          Text(AppStrings.challengeTitle, style: AppTextStyles.overLine()),
          AppSizes.xxxs.ph,
          TextFormField(
            controller: titleController,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.darkBgContainer,
              hintText: AppStrings.addYourChallengeTitle,
              hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
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
          Text(AppStrings.challengeDesc, style: AppTextStyles.overLine()),
          AppSizes.xxxs.ph,
          TextFormField(
            controller: descriptionController,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.darkBgContainer,
              hintText: AppStrings.addDesc,
              hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
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
            minLines: 2,
            maxLines: 5,
          ),
          AppSizes.xs.ph,
          Text(AppStrings.chooseDateRange, style: AppTextStyles.overLine()),
          AppSizes.xxxs.ph,
          SizedBox(
            height: 0.3.sh,
            width: 0.8.sw,
            child: SfDateRangePicker(
              selectionMode: DateRangePickerSelectionMode.range,
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                if (args.value is PickerDateRange) {
                  setState(() {
                    startDate = args.value.startDate;
                    endDate = args.value.endDate;
                  });
                }
              },
            ),
          ),
          AppSizes.xs.ph,
          Text(AppStrings.maxParticipants, style: AppTextStyles.overLine()),
          AppSizes.xxxs.ph,
          TextFormField(
            controller: maxParticipantsController,
            keyboardType: TextInputType.number,
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
                borderSide: BorderSide(color: AppColors.skyBlue),
              ),
            ),
          ),
          AppSizes.xs.ph,
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.firstPrize,
                      style: AppTextStyles.overLine(),
                    ),
                    AppSizes.xxxs.ph,
                    TextFormField(
                      controller: firstPrizeController,
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
                  ],
                ),
              ),
              AppSizes.xxxs.pw,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.secondPrize,
                      style: AppTextStyles.overLine(),
                    ),
                    AppSizes.xxxs.ph,
                    TextFormField(
                      controller: secondPrizeController,
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
                  ],
                ),
              ),
              AppSizes.xxxs.pw,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.thirdPrize,
                      style: AppTextStyles.overLine(),
                    ),
                    AppSizes.xxxs.ph,
                    TextFormField(
                      controller: thirdPrizeController,
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
                  ],
                ),
              ),
            ],
          ),
          AppSizes.xs.ph,
          CheckboxListTile(
            value: isPaid,
            onChanged: (val) {
              setState(() {
                isPaid = val ?? false;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              AppStrings.paidChallenge,
              style: AppTextStyles.overLine().copyWith(
                fontWeight: AppFontWeights.bold,
              ),
            ),
          ),
          if (isPaid) ...[
            AppSizes.xs.ph,
            Text("Registration Fee", style: AppTextStyles.overLine()),
            AppSizes.xxxs.ph,
            TextFormField(
              controller: registrationFeeController,
              keyboardType: TextInputType.number,
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
                  borderSide: BorderSide(color: AppColors.skyBlue),
                ),
              ),
            ),
          ],

          AppSizes.xs.ph,
          Text(AppStrings.challengeThumbnail, style: AppTextStyles.overLine()),
          AppSizes.xxxs.ph,
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 0.2.sh,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.skyBlue.withValues(alpha: 0.5),
                ),
                borderRadius: BorderRadius.circular(AppSizes.xs),
                image: selectedThumbnail != null
                    ? DecorationImage(
                        image: FileImage(selectedThumbnail!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: selectedThumbnail == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HugeIcon(
                          icon: HugeIconsStrokeRounded.image02,
                          color: AppColors.creamWhite,
                          size: 40,
                        ),
                        AppSizes.xs.ph,
                        Text(
                          AppStrings.clickToUpload,
                          style:
                              AppTextStyles.overLine(color: AppColors.creamWhite),
                        ),
                        Text(
                          "${AppStrings.fileType} (Max 5MB)",
                          style: AppTextStyles.caption2(
                            color: AppColors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
          ),
          AppSizes.xs.ph,

          AppButton(
            onPressed: isLoading ? null : _createChallenge,
            label: AppStrings.create,
            labelStyle: AppTextStyles.bodyText2(color: AppColors.white),
            bgColor: Colors.transparent,
            borderColor: AppColors.skyBlue.withValues(alpha: 0.5),
            radius: AppSizes.xxxs,
            prefix: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
