import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/extensions/screen_size_extension.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/features/group/presentation/widgets/add_class.dart';
import 'package:larnity/src/features/group/presentation/widgets/add_event.dart';
import 'package:larnity/src/features/group/presentation/widgets/view_event.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class EventRoomScreen extends StatelessWidget {
  const EventRoomScreen({Key? key}) : super(key: key);

  _AppointmentDataSource _getCalendarDataSource() {
    List<Appointment> appointments = <Appointment>[];
    appointments.add(
      Appointment(
        startTime: DateTime.now(),
        endTime: DateTime.now().add(Duration(minutes: 10)),
        subject: 'Meeting',
        color: Colors.blue,
        // startTimeZone: '',
        // endTimeZone: '',
      ),
    );

    return _AppointmentDataSource(appointments);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          AppSizes.xs.ph,
          Container(
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
                          builder: (context) => Dialog(
                            backgroundColor: AppColors.bgBlue,
                            child: AddEvent(),
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
                            builder: (context) => Dialog(
                              backgroundColor: AppColors.bgBlue,
                              child: ViewEvent(),
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
                                decoration: BoxDecoration(
                                  color: AppColors.primaryOrange,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              AppSizes.xxxs.pw,
                              Expanded(
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
                        builder: (context) => Dialog(
                          backgroundColor: AppColors.bgBlue,
                          child: AddEvent(),
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
                    scheduleViewSettings: ScheduleViewSettings(
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
