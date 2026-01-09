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
import 'package:larnity/src/features/group/presentation/provider/class_schedule_provider.dart';
import 'package:larnity/src/features/group/presentation/widgets/add_class.dart';
import 'package:larnity/src/features/group/presentation/widgets/view_event.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class LiveClassRoomScreen extends ConsumerStatefulWidget {
  final String groupId; // ⭐ REQUIRED

  const LiveClassRoomScreen({Key? key, required this.groupId})
    : super(key: key);

  @override
  ConsumerState<LiveClassRoomScreen> createState() =>
      _LiveClassRoomScreenState();
}

class _LiveClassRoomScreenState extends ConsumerState<LiveClassRoomScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(classScheduleProvider).fetchClasses(widget.groupId);
    });
  }

  _AppointmentDataSource _getCalendarDataSource() {
    final classes = ref.watch(classScheduleProvider).classes;

    final List<Appointment> appointments = classes.map((classSchedule) {
      final dateTime = DateTime(
        classSchedule.eventDate.year,
        classSchedule.eventDate.month,
        classSchedule.eventDate.day,
        int.parse(classSchedule.eventTime.split(':')[0]),
        int.parse(classSchedule.eventTime.split(':')[1]),
      );

      return Appointment(
        startTime: dateTime,
        endTime: dateTime.add(const Duration(hours: 1)),
        subject: classSchedule.title,
        color: AppColors.primaryOrange,
        id: classSchedule.id,
      );
    }).toList();

    return _AppointmentDataSource(appointments);
  }

  Widget _buildSizedDialog(
    BuildContext context, {
    required Widget child,
    double heightFactor = 0.65,
  }) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      backgroundColor: AppColors.bgBlue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.xxxs),
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * heightFactor,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(classScheduleProvider).isLoading;

    return SingleChildScrollView(
      child: Column(
        children: [
          AppSizes.xs.ph,
          SizedBox(
            height: 1.sh,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.liveClass,
                      style: AppTextStyles.headline2(color: AppColors.white),
                    ),
                    AppButton(
                      isExpanded: false,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => _buildSizedDialog(
                            context,
                            child: AddClass(
                              groupId: widget.groupId,
                            ), // ⭐ PASS groupId
                            heightFactor: 0.65,
                          ),
                        );
                      },
                      prefix: HugeIcon(
                        icon: HugeIconsStrokeRounded.addCircle,
                        color: AppColors.black,
                      ),
                      label: AppStrings.addClass,
                      labelStyle: AppTextStyles.bodyText2(
                        color: AppColors.black,
                      ),
                      bgColor: AppColors.primaryOrange,
                      radius: AppSizes.xxxs,
                    ),
                  ],
                ),
                AppSizes.xs.ph,

                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  SizedBox(
                    height: 0.9.sh,
                    child: SfCalendar(
                      dataSource: _getCalendarDataSource(),
                      allowDragAndDrop: true,
                      view: CalendarView.month,
                      appointmentBuilder:
                          (context, calendarAppointmentDetails) {
                            final appointment =
                                calendarAppointmentDetails.appointments.first;
                            return GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => _buildSizedDialog(
                                    context,
                                    child: const ViewEvent(),
                                    heightFactor: 0.6,
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.skyBlue),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 20,
                                      width: 20,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primaryOrange,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    AppSizes.xxxs.pw,
                                    Expanded(
                                      child: Text(
                                        appointment.subject,
                                        overflow: TextOverflow.fade,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                      onTap: (calendarTapDetails) {
                        showDialog(
                          context: context,
                          builder: (_) => _buildSizedDialog(
                            context,
                            child: AddClass(
                              groupId: widget.groupId,
                            ), // ⭐ PASS groupId
                            heightFactor: 0.65,
                          ),
                        );
                      },
                      monthViewSettings: const MonthViewSettings(
                        appointmentDisplayMode:
                            MonthAppointmentDisplayMode.appointment,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
