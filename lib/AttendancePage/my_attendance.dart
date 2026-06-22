import 'package:employeeattendance/DrawerPage/view_attendance.dart';
import 'package:employeeattendance/HomePage/main_screen.dart';
import 'package:employeeattendance/controllers/globalvariable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyAttendancePage extends StatefulWidget {
  @override
  _MyAttendancePageState createState() => _MyAttendancePageState();
}

class _MyAttendancePageState extends State<MyAttendancePage> {
  DateTime _currentMonth = DateTime.now();
  List<dynamic> _attendanceData = [];
  String? _Id;
  DateTime? _selectedDate;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadId();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentDate();
    });
  }

  void _scrollToCurrentDate() {
    if (_selectedDate != null) {
      int dayIndex = _selectedDate!.day - 1;
      _scrollController.animateTo(
        64.0 * (dayIndex), // 60 width + 4 margin
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _loadId() async {
    if (GlobalVariable.uid == null) {
      Fluttertoast.showToast(msg: 'User ID not available. Please login again.');
      return;
    }

    setState(() {
      _Id = GlobalVariable.uid.toString();
      print(_Id);
    });
    _fetchAttendanceData();
  }

  Future<void> _fetchAttendanceData() async {
    if (_Id == null) return;

    final response =
        await http.post(Uri.parse('https://pinghr.in/api/attendance?id=$_Id'));

    print(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      print(data);
      if (data['status'] == true) {
        setState(() {
          _attendanceData = data['data'];
          _selectedDate = DateTime.now();
        });
      }
    } else {
      // Handle error
      print('Failed to load attendance data');
    }
  }

  void _incrementMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  void _decrementMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  List<DateTime> _getMonthDates(DateTime month) {
    DateTime firstDayOfMonth = DateTime(month.year, month.month, 1);
    int daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    return List.generate(
        daysInMonth, (index) => DateTime(month.year, month.month, index + 1));
  }

  void _selectDateFromCalendar(DateTime date) {
    setState(() {
      _selectedDate = date;
      _currentMonth = DateTime(date.year, date.month);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue.shade900,
        title: Text('My Attendance',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18)),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
              icon: Icon(Icons.calendar_month_outlined,
                  color: Colors.white, size: 24),
              // onPressed: () => _selectDateFromCalendar(DateTime.now()),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ViewAttendance()));
              }),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCalendar(),
            _buildDetailsCard(),
            _buildSummaryRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    List<DateTime> monthDates = _getMonthDates(_currentMonth);
    DateTime today = DateTime.now();

    return Container(
      clipBehavior: Clip.none,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              clipBehavior: Clip.none,
              height: 50,
              initialPage: _currentMonth.month - 1,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentMonth = DateTime(_currentMonth.year, index + 1);
                  _selectedDate = _currentMonth.month == today.month &&
                          _currentMonth.year == today.year
                      ? today
                      : DateTime(_currentMonth.year, _currentMonth.month, 1);
                });
              },
              viewportFraction: 0.4,
            ),
            items: List.generate(12, (index) {
              DateTime month = DateTime(_currentMonth.year, index + 1, 1);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentMonth = DateTime(_currentMonth.year, month.month);
                    _selectedDate = _currentMonth.month == today.month &&
                            _currentMonth.year == today.year
                        ? today
                        : DateTime(_currentMonth.year, _currentMonth.month, 1);
                  });
                },
                child: Container(
                  clipBehavior: Clip.none,
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    color: _currentMonth.month == month.month
                        ? Colors.blue.shade900
                        : Colors.transparent,
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      DateFormat('MMMM yyyy').format(month),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _currentMonth.month == month.month
                            ? Colors.white
                            : Colors.blue.shade900,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          Container(
            height: 100,
            child: ListView.builder(
              clipBehavior: Clip.none,
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: monthDates.length,
              itemBuilder: (context, index) {
                DateTime date = monthDates[index];
                bool isToday = date.year == today.year &&
                    date.month == today.month &&
                    date.day == today.day;
                bool isSelected = _selectedDate != null &&
                    date.year == _selectedDate!.year &&
                    date.month == _selectedDate!.month &&
                    date.day == _selectedDate!.day;

                return GestureDetector(
                  onTap: () => _selectDateFromCalendar(date),
                  child: Container(
                    clipBehavior: Clip.none,
                    width: 60,
                    margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue.shade900
                          : isToday
                              ? Colors.blue.shade50
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.blue.shade900
                            : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('EEE').format(date).toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : isToday
                                    ? Colors.blue.shade900
                                    : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    if (_attendanceData.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade900),
        ),
      );
    }

    final selectedDateStr = _selectedDate != null
        ? DateFormat('dd MMMM yyyy').format(_selectedDate!)
        : null;
    final attendance = _attendanceData.firstWhere(
      (record) => record['date'] == selectedDateStr,
      orElse: () => null,
    );

    if (attendance == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.event_busy_outlined,
                  size: 48, color: Colors.grey.shade400),
              SizedBox(height: 16),
              Text(
                'No attendance data for selected date',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade900,
              ),
            ),
            SizedBox(height: 16),
            _buildDetailRow('Date', attendance['date']),
            _buildDetailRow('In Time', attendance['checkin']),
            _buildDetailRow('Out Time', attendance['checkout'] ?? '--:--'),
            _buildDetailRow('Status', attendance['work_status'] ?? 'Unknown'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    Color statusColor = Colors.black87;
    if (label == 'Status') {
      switch (value.toLowerCase()) {
        case 'present':
          statusColor = Colors.green.shade600;
          break;
        case 'absent':
          statusColor = Colors.red.shade600;
          break;
        case 'half day':
          statusColor = Colors.orange.shade600;
          break;
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: label == 'Status' ? statusColor : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow() {
    final summary = _getMonthlySummary();

    return Container(
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2,
            children: [
              _buildSummaryItem('${summary['workingDays']}', 'Working Days',
                  Icons.work_outline, Colors.green.shade600),
              _buildSummaryItem('${summary['halfDays']}', 'Half Days',
                  Icons.hourglass_bottom_outlined, Colors.orange.shade600),
              _buildSummaryItem('${summary['leaveDays']}', 'Leave Days',
                  Icons.event_busy_outlined, Colors.red.shade600),
              _buildSummaryItem('${summary['holidays']}', 'Holiday',
                  Icons.celebration_outlined, Colors.blue.shade600),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, int> _getMonthlySummary() {
    int workingDays = 0;
    int halfDays = 0;
    int leaveDays = 0;
    int holidays = 0;

    final parser = DateFormat('dd MMMM yyyy');

    for (final record in _attendanceData) {
      if (record is! Map<String, dynamic>) continue;

      final dateString = record['date']?.toString();
      if (dateString == null || dateString.isEmpty) continue;

      DateTime? recordDate;
      try {
        recordDate = parser.parse(dateString);
      } catch (_) {
        continue;
      }

      if (recordDate.year != _currentMonth.year ||
          recordDate.month != _currentMonth.month) {
        continue;
      }

      final status =
          (record['work_status']?.toString() ?? '').trim().toLowerCase();

      if (status == 'half day' || status == 'half-day' || status == 'halfday') {
        halfDays++;
      } else if (status.contains('leave') || status == 'absent') {
        leaveDays++;
      } else if (status.contains('holiday') ||
          status.contains('week off') ||
          status.contains('sunday')) {
        holidays++;
      } else if (status == 'present') {
        workingDays++;
      }
    }

    return {
      'workingDays': workingDays,
      'halfDays': halfDays,
      'leaveDays': leaveDays,
      'holidays': holidays,
    };
  }

  Widget _buildSummaryItem(
      String value, String label, IconData icon, Color iconColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 24),
          SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
