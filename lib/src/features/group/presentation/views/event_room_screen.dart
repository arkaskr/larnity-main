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
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/presentation/widgets/add_event.dart';
import 'package:larnity/src/features/group/presentation/widgets/view_event.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class EventRoomScreen extends ConsumerWidget {
  const EventRoomScreen({Key? key}) : super(key: key);

  _AppointmentDataSource _getCalendarDataSource() {
    final List<Appointment> appointments = <Appointment>[
      Appointment(
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(minutes: 10)),
        subject: 'Meeting',
        color: Colors.blue,
      ),
    ];
    return _AppointmentDataSource(appointments);
  }

  Widget _buildSizedDialog(
    BuildContext context, {
    required Widget child,
    double heightFactor = 0.65,
  }) {
    final size = MediaQuery.of(context).size;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      backgroundColor: AppColors.bgBlue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.xxxs),
      ),
      child: SizedBox(
        width: size.width * 0.95,
        height: size.height * heightFactor,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupState = ref.watch(groupProvider);
    final currentGroupId = groupState.group?.id;

    if (currentGroupId == null) {
      return Center(child: Text('No group selected'));
    }

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
                      AppStrings.myEvents,
                      style: AppTextStyles.headline2(color: AppColors.white),
                    ),
                    AppButton(
                      isExpanded: false,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => _buildSizedDialog(
                            context,
                            child: AddEvent(groupId: currentGroupId),
                            heightFactor: 0.65,
                          ),
                        );
                      },
                      prefix: HugeIcon(
                        icon: HugeIconsStrokeRounded.addCircle,
                        color: AppColors.black,
                      ),
                      label: AppStrings.addEvent,
                      labelStyle: AppTextStyles.bodyText2(
                        color: AppColors.black,
                      ),
                      bgColor: AppColors.primaryOrange,
                      radius: AppSizes.xxxs,
                    ),
                  ],
                ),
                AppSizes.xs.ph,
                SizedBox(
                  height: 0.9.sh,
                  child: SfCalendar(
                    dataSource: _getCalendarDataSource(),
                    allowDragAndDrop: true,
                    view: CalendarView.month,
                    appointmentBuilder: (context, calendarAppointmentDetails) {
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
                              const Expanded(
                                child: Text(
                                  "demogsdgsdbsbsg",
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
                          child: AddEvent(groupId: currentGroupId),
                          heightFactor: 0.65,
                        ),
                      );
                    },
                    monthViewSettings: const MonthViewSettings(
                      appointmentDisplayMode:
                          MonthAppointmentDisplayMode.appointment,
                    ),
                    timeSlotViewSettings: const TimeSlotViewSettings(
                      minimumAppointmentDuration: Duration(minutes: 60),
                    ),
                    scheduleViewSettings: const ScheduleViewSettings(
                      appointmentItemHeight: 20,
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
