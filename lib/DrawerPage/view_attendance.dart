import 'package:employeeattendance/DrawerPage/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/services.dart';

import '../HomePage/main_screen.dart';

class ViewAttendance extends StatefulWidget {
  const ViewAttendance({super.key});

  @override
  State<ViewAttendance> createState() => _ViewAttendanceState();
}

class _ViewAttendanceState extends State<ViewAttendance> {
  DateTime selectedDay = DateTime.now();
  String tappedDay = '';
  final c = Get.put(CalController());

  // This function will update the tappedDay when a day is selected
  void onDaySelected(DateTime selected, DateTime focused) {
    selectedDay = selected;
    tappedDay = DateFormat('yyyy-MM-dd').format(selectedDay);
    // We don't need setState anymore as GetX will handle it reactively
  }

  final mediumWhiteText = const TextStyle(
    fontSize: 18,
    color: Colors.white,
  );
  final mediumText = const TextStyle(
    fontSize: 18,
    color: Colors.black,
  );

  @override
  void initState() {
    super.initState();
    c.fetchAttendance();  // Fetch attendance data on screen load
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.blue.shade900,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () {
            Get.back();
          },
        ),
        centerTitle: true,
        title: const Text('Attendance', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: Obx(
        () {
          return c.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      TableCalendar(
                        firstDay: DateTime(2023),
                        focusedDay: DateTime.now(),
                        lastDay: DateTime.now(),
                        onDaySelected: onDaySelected,
                        availableCalendarFormats: const {
                          CalendarFormat.month: 'Month',
                        },
                        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                        calendarBuilders: CalendarBuilders(
                          prioritizedBuilder: (context, day, focusedDay) {
                            final date = DateFormat('yyyy-MM-dd')
                                .format(DateTime(day.year, day.month, day.day));
                            final days = day.day;
                            final attnEvents = c.attnData
                                .where((event) => event.compareDate == date)
                                .toList();
                            bool hasEvents = attnEvents.isNotEmpty;
                            Color cellColor;
                            TextStyle style;
                            if (hasEvents) {
                              final events = attnEvents.first;
                              final status = events.status?.toLowerCase() ?? '';
                              if (status == 'present') {
                                cellColor = Colors.green;
                                style = mediumWhiteText;
                              } else if (status == 'half_day' || status == 'halfday' || status == 'incomplete') {
                                cellColor = Colors.yellow.shade700;
                                style = mediumWhiteText;
                              } else if (status == 'absent') {
                                cellColor = Colors.red;
                                style = mediumWhiteText;
                              } else if (status == 'weekly_off') {
                                cellColor = Colors.purple;
                                style = mediumWhiteText;
                              } else if (status == 'holiday') {
                                cellColor = Colors.blue;
                                style = mediumWhiteText;
                              } else {
                                cellColor = Colors.indigo;
                                style = mediumWhiteText;
                              }
                            } else if (DateTime.now().day < days) {
                              cellColor = Colors.white;
                              style = mediumText;
                            } else {
                              cellColor = Colors.red;
                              style = mediumWhiteText;
                            }
                            return Container(
                              height: 35,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: cellColor,
                              ),
                              child: Text(day.day.toString(),
                                  style: style),
                            );
                          },
                        ),
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: Colors.blue.shade300,
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: Colors.blue.shade700,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        margin: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            buildRow('Present', Colors.green),
                            buildRow('Absent', Colors.red),
                            buildRow('Half Day / Incomplete', Colors.yellow.shade700),
                            buildRow('Weekly Off', Colors.purple),
                            buildRow('Holiday', Colors.blue),
                          ],
                        ),
                      ),
                      // Show detailed information for tapped day
                      Obx(() {
                        RxList<CalModel> tappedEvents = c.attnData
                            .where((event) => event.compareDate == tappedDay)
                            .toList()
                            .obs;
                        return tappedEvents.isEmpty
                            ? Container()
                            : ShowDetail(tappedDay: tappedDay);
                      }),
                    ],
                  ),
                );
        },
      ),
    );
  }

  Row buildRow(String text, Color color) {
    return Row(
      children: [
        Container(
          height: 14,
          width: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class ShowDetail extends StatelessWidget {
  final String tappedDay;
  const ShowDetail({super.key, required this.tappedDay});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<CalController>();
    RxList<CalModel> tappedEvents =
        c.attnData.where((event) => event.compareDate == tappedDay).toList().obs;

    return Obx(
          () => Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              tappedEvents[0].date,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  tappedEvents[0].checkIn,
                  style: const TextStyle(fontSize: 16, color: Colors.green),
                ),
                const Text("---"),
                Text(
                  tappedEvents[0].checkOut,
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Check-In Location', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              tappedEvents[0].inLocation,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.indigoAccent),
            ),
            const SizedBox(height: 8),
            const Text('Check-Out Location', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              tappedEvents[0].outLocation,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.indigoAccent),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Status : ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    )),
                Text(
                  tappedEvents[0].workStatus,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
