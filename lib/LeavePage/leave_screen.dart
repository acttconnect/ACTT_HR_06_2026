import 'package:employeeattendance/DrawerPage/appliedleave.dart';
import 'package:employeeattendance/DrawerPage/leaveapplication.dart';
import 'package:employeeattendance/HomePage/main_screen.dart';
import 'package:employeeattendance/api_services.dart';
import 'package:employeeattendance/controller/globalvariable.dart';
import 'package:flutter/material.dart';
import 'package:employeeattendance/LeavePage/leave_history_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:employeeattendance/models/holiday.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AutoLeaveScreen extends StatefulWidget {
  @override
  State<AutoLeaveScreen> createState() => _AutoLeaveScreenState();
}

class _AutoLeaveScreenState extends State<AutoLeaveScreen> {
  List<bool> _isSelected = [true, false];
  Map<DateTime, Map<String, dynamic>> _holidays = {}; // Changed to store type info
  final ApiService _holidayService = ApiService();
  List<Map<String, dynamic>> _leaveData = [];
  String _employeeId = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmployeeId();
  }

  Future<void> _loadEmployeeId() async {
    setState(() {
      _employeeId = GlobalVariable.empID;
    });
    await _fetchHolidays();
    await _fetchLeaveData();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchHolidays() async {
    try {
      List<Holiday> holidays = await _holidayService.fetchHolidays(_employeeId);
      print('=== Holidays Fetched Successfully ===');
      print('Total holidays received: ${holidays.length}');
      for (var holiday in holidays) {
        print('Holiday - Date: ${holiday.date}, Name: ${holiday.name}, Type: ${holiday.type}');
      }
      print('=====================================');
      
      setState(() {
        // Normalize dates to midnight (00:00:00) for proper comparison
        _holidays = {
          for (var holiday in holidays) 
            DateTime(holiday.date.year, holiday.date.month, holiday.date.day): {
              'name': holiday.name,
              'type': holiday.type ?? 'holiday'
            }
        };
        print('Holidays map created with ${_holidays.length} entries');
      });
    } catch (e) {
      print('Error fetching holidays: $e');
    }
  }

  Future<void> _fetchLeaveData() async {
    try {
      List<Map<String, dynamic>> leaveData = await _holidayService.fetchLeaveData(_employeeId);
      setState(() {
        _leaveData = leaveData;
      });
    } catch (e) {
      print('Error fetching leave data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen()));
          },
        ),
        centerTitle: true,
        title: Text('Leaves', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Leave Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ToggleButtons(
                borderRadius: BorderRadius.circular(8),
                fillColor: Colors.blue.shade900.withOpacity(0.1),
                selectedColor: Colors.blue.shade900,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22.0),
                    child: Text('Leave Balance'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22.0),
                    child: Text('Holiday Calendar'),
                  ),
                ],
                isSelected: _isSelected,
                onPressed: (int index) {
                  setState(() {
                    for (int i = 0; i < _isSelected.length; i++) {
                      _isSelected[i] = i == index;
                    }
                  });
                },
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: _isSelected[0]
                  ? _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _buildLeaveDataTable()
                  : _buildHolidayCalendar(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AppliedLeave()),
                    );
                  },
                  icon: Icon(Icons.history, color: Colors.white),
                  label: Text('Leave History', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LeaveApplication()),
                    );
                  },
                  icon: Icon(Icons.add, color: Colors.white),
                  label: Text('Apply Leave', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveDataTable() {
    return ListView.builder(
      itemCount: _leaveData.length,
      itemBuilder: (context, index) {
        try {
          final leave = _leaveData[index];
          
          // Safely parse dates with fallback
          DateTime startDate;
          DateTime endDate;
          try {
            startDate = parseCustomDate(leave['start_date']?.toString() ?? '');
            endDate = parseCustomDate(leave['end_date']?.toString() ?? '');
          } catch (e) {
            print('Error parsing leave dates at index $index: $e');
            startDate = DateTime.now();
            endDate = DateTime.now();
          }
          
          final leaveCount = endDate.difference(startDate).inDays + 1;
          final status = leave['status'] == '2' ? 'Rejected' : 'Approved on ${leave['approved_date'] ?? 'N/A'}';

          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            elevation: 6.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.blue.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Leave Type: ${leave['type'] ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                        Icon(Icons.beach_access, color: Colors.blue.shade900),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Reason: ${leave['region'] ?? 'N/A'}',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    SizedBox(height: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start Date: ${leave['start_date'] ?? 'N/A'}',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        Text(
                          'End Date: ${leave['end_date'] ?? 'N/A'}',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Leave Count: ${leaveCount > 0 ? leaveCount : 0}',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Status: $status',
                      style: TextStyle(
                        fontSize: 14,
                        color: status.contains('Rejected') ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } catch (e) {
          print('Error building leave card at index $index: $e');
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error displaying leave data: ${e.toString()}'),
            ),
          );
        }
      },
    );
  }

  Widget _buildHolidayCalendar() {
    DateTime now = DateTime.now();
    
    // Calculate date range from holidays
    DateTime firstDay = DateTime.utc(2023, 1, 1);
    DateTime lastDay = DateTime.utc(2025, 12, 31);
    
    if (_holidays.isNotEmpty) {
      final dates = _holidays.keys.toList();
      dates.sort();
      firstDay = DateTime(dates.first.year, dates.first.month, 1);
      lastDay = DateTime(dates.last.year, dates.last.month + 1, 0);
    }
    
    DateTime focusedDay = now.isBefore(firstDay) ? firstDay : (now.isAfter(lastDay) ? lastDay : now);

    print('=== Holiday Calendar Debug ===');
    print('First day: $firstDay');
    print('Last day: $lastDay');
    print('Focused day: $focusedDay');
    print('Total holidays in map: ${_holidays.length}');
    print('Holidays: $_holidays');
    print('===============================');

    return SingleChildScrollView(
      child: Column(
        children: [
          TableCalendar(
            firstDay: firstDay,
            lastDay: lastDay,
            focusedDay: focusedDay,
            calendarFormat: CalendarFormat.month,
            eventLoader: (day) {
              // Normalize day to midnight for comparison
              final normalizedDay = DateTime(day.year, day.month, day.day);
              if (_holidays.containsKey(normalizedDay)) {
                print('Holiday found on $normalizedDay: ${_holidays[normalizedDay]}');
                return [_holidays[normalizedDay]!['name']];
              }
              return [];
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                // Normalize day to midnight for comparison
                final normalizedDay = DateTime(day.year, day.month, day.day);
                
                if (_holidays.containsKey(normalizedDay)) {
                  final holiday = _holidays[normalizedDay]!;
                  final type = holiday['type']?.toString().toLowerCase() ?? 'holiday';
                  
                  // Determine color based on type
                  Color cellColor;
                  Color textColor;
                  
                  if (type.contains('weekly_off')) {
                    cellColor = Colors.yellow.shade600;
                    textColor = Colors.black;
                  } else if (type.contains('holiday') || type.contains('official')) {
                    cellColor = Colors.blue.shade600;
                    textColor = Colors.white;
                  } else {
                    // casual, sick, etc.
                    cellColor = Colors.red.shade600;
                    textColor = Colors.white;
                  }
                  
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: cellColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                }
                return null;
              },
              todayBuilder: (context, day, focusedDay) {
                final normalizedDay = DateTime(day.year, day.month, day.day);
                
                if (_holidays.containsKey(normalizedDay)) {
                  final holiday = _holidays[normalizedDay]!;
                  final type = holiday['type']?.toString().toLowerCase() ?? 'holiday';
                  
                  // Determine color based on type
                  Color cellColor;
                  Color textColor;
                  
                  if (type.contains('weekly_off')) {
                    cellColor = Colors.yellow.shade600;
                    textColor = Colors.black;
                  } else if (type.contains('holiday') || type.contains('official')) {
                    cellColor = Colors.blue.shade600;
                    textColor = Colors.white;
                  } else {
                    // casual, sick, etc.
                    cellColor = Colors.red.shade600;
                    textColor = Colors.white;
                  }
                  
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: cellColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                }
                // Today but not holiday
                return Container(
                  margin: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Colors.green.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
            calendarStyle: CalendarStyle(
              outsideTextStyle: TextStyle(color: Colors.grey.shade400),
              weekendTextStyle: TextStyle(color: Colors.grey.shade700),
              defaultTextStyle: const TextStyle(color: Colors.black),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Holiday Legend
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Legend:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.yellow.shade600,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text('Weekly Off / Weekends'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade600,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text('Official Holiday'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text('Casual / Sick / Other Leave'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.green.shade300,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text('Today'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DateTime parseCustomDate(String dateString) {
    try {
      // Try multiple date formats
      dateString = dateString.trim();
      
      // Format 1: Try numeric format (dd-mm-yyyy or yyyy-mm-dd)
      if (dateString.contains('-')) {
        final parts = dateString.split('-');
        
        if (parts.length == 3) {
          // Check if it's numeric (dd-mm-yyyy or similar)
          if (RegExp(r'^\d+$').hasMatch(parts[0]) && RegExp(r'^\d+$').hasMatch(parts[1]) && RegExp(r'^\d+$').hasMatch(parts[2])) {
            int day = int.parse(parts[0]);
            int month = int.parse(parts[1]);
            int year = int.parse(parts[2]);
            
            // Handle if year is 2-digit or 4-digit
            if (year < 100) {
              year = year < 50 ? 2000 + year : 1900 + year;
            }
            
            return DateTime(year, month, day);
          }
          
          // Format 2: Try text month format (dd-Jan-yyyy)
          if (RegExp(r'^\d+$').hasMatch(parts[0]) && RegExp(r'^[a-zA-Z]+$').hasMatch(parts[1]) && RegExp(r'^\d+$').hasMatch(parts[2])) {
            int day = int.parse(parts[0]);
            int month = _monthStringToNumber(parts[1]);
            int year = int.parse(parts[2]);
            return DateTime(year, month, day);
          }
        }
      }
      
      // Format 3: Try ISO format (yyyy-mm-dd)
      try {
        return DateTime.parse(dateString);
      } catch (e) {
        // Continue to next format
      }
      
      // If all parsing fails, return today's date as fallback
      print('Unable to parse date: $dateString, using today\'s date');
      return DateTime.now();
    } catch (e) {
      print('Error parsing date $dateString: $e');
      return DateTime.now();
    }
  }

  int _monthStringToNumber(String month) {
    switch (month.toLowerCase()) {
      case 'jan': return 1;
      case 'feb': return 2;
      case 'mar': return 3;
      case 'apr': return 4;
      case 'may': return 5;
      case 'jun': return 6;
      case 'jul': return 7;
      case 'aug': return 8;
      case 'sep': return 9;
      case 'oct': return 10;
      case 'nov': return 11;
      case 'dec': return 12;
      case 'january': return 1;
      case 'february': return 2;
      case 'march': return 3;
      case 'april': return 4;
      case 'may': return 5;
      case 'june': return 6;
      case 'july': return 7;
      case 'august': return 8;
      case 'september': return 9;
      case 'october': return 10;
      case 'november': return 11;
      case 'december': return 12;
      default: throw FormatException('Invalid month format: $month');
    }
  }
} 