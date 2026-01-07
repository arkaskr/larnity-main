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
import 'package:larnity/src/core/ui/widgets/dialog_header.dart';
import 'package:larnity/src/features/group/data/models/event_model.dart';
import 'package:larnity/src/features/group/presentation/provider/event_provider.dart';

class AddEvent extends ConsumerStatefulWidget {
  final String groupId;

  const AddEvent({Key? key, required this.groupId}) : super(key: key);

  @override
  ConsumerState<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends ConsumerState<AddEvent> {
  final _titleController = TextEditingController();
  final _linkController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedTime;
  String _locationType = "";

  @override
  void dispose() {
    _titleController.dispose();
    _linkController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// ✅ FIXED TIME PICKER WITH DONE BUTTON
  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(data: ThemeData.dark(), child: child!);
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked.format(context); // e.g. 10:30 AM
      });
    }
  }

  Future<void> _handleAddEvent() async {
    if (_titleController.text.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null ||
        _locationType.isEmpty ||
        _linkController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final event = EventModel(
      title: _titleController.text,
      date: _selectedDate!,
      time: _selectedTime!,
      location: _locationType,
      link: _linkController.text,
      description: _descriptionController.text,
      type: CalendarEventType.groupevent,
      groupId: widget.groupId,
    );

    final success = await ref.read(eventProvider).createEvent(event);

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event created successfully')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed: ${ref.read(eventProvider).errorMessage}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(eventProvider).isLoading;

    return Padding(
      padding: const EdgeInsets.all(AppSizes.xs),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            DialogHeader(
              title: AppStrings.addEvent,
              description: AppStrings.addEventDesc,
            ),

            /// EVENT DETAILS
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

                  /// DATE + TIME
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
                              button: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedDate != null
                                        ? "${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}"
                                        : "mm/dd/yyyy",
                                  ),
                                  HugeIcon(
                                    icon: HugeIconsStrokeRounded.calendar03,
                                    color: AppColors.white,
                                  ),
                                ],
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
                            GestureDetector(
                              onTap: _pickTime,
                              child: Container(
                                padding: EdgeInsets.all(AppSizes.xs),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.xxxs,
                                  ),
                                  border: Border.all(color: AppColors.skyBlue),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(_selectedTime ?? "--:-- AM"),
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

            /// LOCATION + LINK
            Container(
              padding: EdgeInsets.all(AppSizes.xs),
              decoration: BoxDecoration(
                color: AppColors.iconColor,
                borderRadius: BorderRadius.circular(AppSizes.xxxs),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.locationType,
                    style: AppTextStyles.overLine(),
                  ),
                  AppSizes.xxxs.ph,
                  AppDropdown(
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
                            _locationType.isEmpty
                                ? "Select location type"
                                : _locationType,
                          ),
                          const Icon(Icons.keyboard_arrow_down),
                        ],
                      ),
                    ),
                    onItemSelected: (value) {
                      setState(() => _locationType = value);
                    },
                    items: const [
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
                    ),
                  ),
                ],
              ),
            ),

            AppSizes.xs.ph,

            /// DESCRIPTION + BUTTON
            Container(
              padding: EdgeInsets.all(AppSizes.xs),
              decoration: BoxDecoration(
                color: AppColors.iconColor,
                borderRadius: BorderRadius.circular(AppSizes.xxxs),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.description, style: AppTextStyles.overLine()),
                  AppSizes.xxxs.ph,
                  TextFormField(
                    controller: _descriptionController,
                    minLines: 2,
                    maxLines: 5,
                  ),
                  AppSizes.xs.ph,
                  AppButton(
                    onPressed: isLoading ? null : _handleAddEvent,
                    label: isLoading ? "Adding..." : AppStrings.addEvent,
                    bgColor: AppColors.primaryOrange,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
