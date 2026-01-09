import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/extensions/screen_size_extension.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/ui/widgets/app_dropdown.dart';
import 'package:larnity/src/core/ui/widgets/app_dropdown_datepicker.dart';
import 'package:larnity/src/core/ui/widgets/app_dropdown_timepicker.dart';
import 'package:larnity/src/core/ui/widgets/dialog_header.dart';
import 'package:larnity/src/features/group/data/models/class_schedule_model.dart';
import 'package:larnity/src/features/group/presentation/provider/class_schedule_provider.dart';

class AddClass extends ConsumerStatefulWidget {
  final String groupId;

  const AddClass({Key? key, required this.groupId}) : super(key: key);

  @override
  ConsumerState<AddClass> createState() => _AddClassState();
}

class _AddClassState extends ConsumerState<AddClass> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _linkController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedTime;
  String? _selectedLocationType;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _saveClass() async {
    if (_titleController.text.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null ||
        _selectedLocationType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final classSchedule = ClassScheduleModel(
      title: _titleController.text,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      eventDate: _selectedDate!,
      eventTime: _selectedTime!,
      locationType: _selectedLocationType!,
      eventLink: _linkController.text.isEmpty ? null : _linkController.text,
      groupId: widget.groupId,
    );

    final success = await ref
        .read(classScheduleProvider)
        .createClass(classSchedule);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Class added successfully')));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(classScheduleProvider).errorMessage ??
                'Failed to add class',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(classScheduleProvider).isLoading;

    return Padding(
      padding: const EdgeInsets.all(AppSizes.xs),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            DialogHeader(
              title: AppStrings.addClass,
              description: AppStrings.addEventDesc,
            ),

            Container(
              padding: EdgeInsets.all(AppSizes.xs),
              decoration: BoxDecoration(
                color: AppColors.iconColor,
                borderRadius: BorderRadius.circular(AppSizes.xxxs),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSizes.xs.ph,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSizes.xxxs),
                        ),
                        child: Center(
                          child: HugeIcon(
                            icon: HugeIconsStrokeRounded.calendar04,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                      ),
                      AppSizes.xs.pw,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.eventDetails,
                              style: AppTextStyles.headline2(
                                color: AppColors.white,
                              ),
                            ),
                            Text(
                              AppStrings.eventDetailsDesc,
                              style: AppTextStyles.overLine(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  AppSizes.xs.ph,
                  Text(AppStrings.title, style: AppTextStyles.overLine()),
                  AppSizes.xxxs.ph,
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.darkBgContainer,
                      hintText: AppStrings.enterTitle,
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
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppSizes.xs.ph,
                            Text(
                              AppStrings.date,
                              style: AppTextStyles.overLine(),
                            ),
                            AppSizes.xxxs.ph,
                            DatePickerDropdown(
                              overlayHeight: 300,
                              onDateSelected: (date) {
                                setState(() => _selectedDate = date);
                              },
                              button: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.xxxs,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _selectedDate != null
                                          ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
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
                          ],
                        ),
                      ),
                      AppSizes.xs.pw,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppSizes.xs.ph,
                            Text(
                              AppStrings.time,
                              style: AppTextStyles.overLine(),
                            ),
                            AppSizes.xxxs.ph,
                            // ⭐ YEH SIMPLE GESTURE DETECTOR USE KARO
                            GestureDetector(
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: _selectedTime != null
                                      ? TimeOfDay(
                                          hour: int.parse(
                                            _selectedTime!.split(':')[0],
                                          ),
                                          minute: int.parse(
                                            _selectedTime!.split(':')[1],
                                          ),
                                        )
                                      : TimeOfDay.now(),
                                );
                                if (time != null) {
                                  setState(() {
                                    _selectedTime =
                                        "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00";
                                  });
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(AppSizes.xs),
                                decoration: BoxDecoration(
                                  color: AppColors.darkBgContainer,
                                  border: Border.all(
                                    color: AppColors.skyBlue.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.xxxs,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _selectedTime != null
                                          ? _selectedTime!.substring(
                                              0,
                                              5,
                                            ) // HH:MM
                                          : "--:--",
                                      style: AppTextStyles.button(
                                        color: _selectedTime != null
                                            ? AppColors.white
                                            : AppColors.skyBlue,
                                      ),
                                    ),
                                    HugeIcon(
                                      icon: HugeIconsStrokeRounded.clock01,
                                      color: AppColors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AppSizes.xs.ph,
            Container(
              padding: EdgeInsets.all(AppSizes.xs),
              decoration: BoxDecoration(
                color: AppColors.iconColor,
                borderRadius: BorderRadius.circular(AppSizes.xxxs),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSizes.xxxs),
                        ),
                        child: Center(
                          child: HugeIcon(
                            icon: HugeIconsStrokeRounded.location06,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                      ),
                      AppSizes.xs.pw,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.locationAndLink,
                              style: AppTextStyles.headline2(
                                color: AppColors.white,
                              ),
                            ),
                            Text(
                              AppStrings.locationAndLinkDesc,
                              style: AppTextStyles.overLine(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  AppSizes.xs.ph,
                  Text(
                    AppStrings.locationType,
                    style: AppTextStyles.overLine(),
                  ),
                  AppSizes.xxxs.ph,
                  AppDropdown(
                    onItemSelected: (value) {
                      setState(() => _selectedLocationType = value);
                    },
                    button: Container(
                      padding: EdgeInsets.all(AppSizes.xs),
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
                            _selectedLocationType ?? "Select location type",
                            style: AppTextStyles.bodyText2(
                              color: AppColors.white,
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.white,
                          ),
                        ],
                      ),
                    ),
                    items: [
                      AppDropdownItem(value: "zoom", label: "Zoom"),
                      AppDropdownItem(value: "meet", label: "Meet"),
                      AppDropdownItem(value: "address", label: "Address"),
                      AppDropdownItem(value: "link", label: "Link"),
                    ],
                  ),
                  AppSizes.xs.ph,
                  Text(AppStrings.eventLink, style: AppTextStyles.overLine()),
                  AppSizes.xxxs.ph,
                  TextFormField(
                    controller: _linkController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.darkBgContainer,
                      hintText: AppStrings.enterLink,
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
              ),
            ),
            AppSizes.xs.ph,
            Container(
              padding: EdgeInsets.all(AppSizes.xs),
              decoration: BoxDecoration(
                color: AppColors.iconColor,
                borderRadius: BorderRadius.circular(AppSizes.xxxs),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSizes.xxxs),
                        ),
                        child: Center(
                          child: HugeIcon(
                            icon: HugeIconsStrokeRounded.file02,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                      ),
                      AppSizes.xs.pw,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.description,
                              style: AppTextStyles.headline2(
                                color: AppColors.white,
                              ),
                            ),
                            Text(
                              AppStrings.descriptionDesc,
                              style: AppTextStyles.overLine(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  AppSizes.xs.ph,
                  Text(AppStrings.description, style: AppTextStyles.overLine()),
                  AppSizes.xxxs.ph,
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.darkBgContainer,
                      hintText: AppStrings.enterLink,
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
                ],
              ),
            ),
            AppSizes.xs.ph,
            AppButton(
              onPressed: isLoading ? null : _saveClass,
              label: isLoading ? "Saving..." : AppStrings.addClass,
              labelStyle: AppTextStyles.bodyText2(color: AppColors.black),
              bgColor: AppColors.primaryOrange,
              radius: AppSizes.xxxs,
            ),
          ],
        ),
      ),
    );
  }
}
