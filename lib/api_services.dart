import 'package:employeeattendance/models/holiday.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'model/learning_model.dart';  // Make sure this import matches where you put your model
import 'model/salary_structure_model.dart';

class ApiService {
  static const String apiUrl = 'https://pinghr.in/api/get-learning';

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  Future<SalaryStructureResponse> fetchPayrollHistory(String empId) async {
    final url = 'https://pinghr.in/api/employee/payroll-history?employee_id=$empId';

    debugPrint('=== Payroll History API Debug ===');
    debugPrint('Full API URL: $url');
    debugPrint('=================================');

    final response = await http.get(Uri.parse(url));

    debugPrint('API Response Status: ${response.statusCode}');
    debugPrint('API Response Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;

      final salaryOverview = (data['salary_overview'] ?? {}) as Map<String, dynamic>;
      final attendanceBreakdown = (data['attendance_breakdown'] ?? {}) as Map<String, dynamic>;
      final attendanceDates = (data['attendance_dates'] ?? {}) as Map<String, dynamic>;

      List<String> _listOfStrings(dynamic value) {
        if (value is List) return value.map((e) => e.toString()).toList();
        return const [];
      }

      return SalaryStructureResponse(
        employeeId: data['employee']?.toString() ?? '',
        month: data['month']?.toString() ?? '',
        calendarDays: _toInt(salaryOverview['calendar_days']),
        payableUnits: _toInt(salaryOverview['payable_units']),
        totalSalary: (salaryOverview['total_salary'] ?? 0).toDouble(),
        breakdown: Breakdown(
          // PingHR doesn't provide weekly-off / second-sat dates, only counts.
          sundays: DayType(
            count: _toInt(attendanceBreakdown['weekly_off']),
            dates: const [],
          ),
          secondSat: DayType(
            count: _toInt(attendanceBreakdown['second_saturday']),
            dates: const [],
          ),
          holidays: DayType(
            count: 0,
            dates: const [],
          ),
          present: DayType(
            count: _toInt(attendanceBreakdown['present']),
            dates: _listOfStrings(attendanceDates['present_dates']),
          ),
          halfDays: DayType(
            count: _toInt(attendanceBreakdown['half_day']),
            dates: _listOfStrings(attendanceDates['half_dates']),
          ),
          absent: DayType(
            count: _toInt(attendanceBreakdown['absent']),
            dates: _listOfStrings(attendanceDates['absent_dates']),
          ),
        ),
      );
    }

    throw Exception('Failed to load payroll history: ${response.statusCode}');
  }

  Future<List<LearningData>> fetchLearningData() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the data
      var jsonResponse = json.decode(response.body);
      return LearningResponse.fromJson(jsonResponse).data;
    } else {
      throw Exception('Failed to load learning data');
    }
  }

    Future<List<Holiday>> fetchHolidays(String empId) async {
    final url = 'https://pinghr.in/api/employee/holiday-calendar?employee_id=$empId';
    
    print('=== Holiday API Debug ===');
    print('Full API URL: $url');
    print('========================');
    
    final response = await http.get(Uri.parse(url));
    
    print('API Response Status: ${response.statusCode}');
    print('API Response Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = json.decode(response.body);
      print('Parsed JSON: $jsonData');
      
      List<Holiday> allHolidays = [];
      
      // Parse nested structure: data is a list of months
      final List<dynamic> monthsData = jsonData['data'] ?? [];
      
      for (var monthData in monthsData) {
        final List<dynamic> holidaysInMonth = monthData['data'] ?? [];
        
        for (var holiday in holidaysInMonth) {
          print('Processing holiday: $holiday');
          try {
            allHolidays.add(Holiday.fromJson(holiday));
          } catch (e) {
            print('Error parsing holiday: $e');
          }
        }
      }
      
      print('Total holidays: ${allHolidays.length}');
      return allHolidays;
    } else {
      throw Exception('Failed to load holidays: ${response.statusCode}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchLeaveData(String empId) async {
    final response = await http.post(Uri.parse('https://pinghr.in/api/leavedata?emp_id=$empId'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        return List<Map<String, dynamic>>.from(data['Employee Leave Data']);
      } else {
        throw Exception('Failed to load leave data');
      }
    } else {
      throw Exception('Failed to load leave data');
    }
  }

  Future<SalaryStructureResponse> fetchSalaryStructure(String empId, String salaryMonth) async {
    final response = await http.get(
      Uri.parse('https://pinghr.in/api/salary-structure-employee?emp_id=$empId&salary_month=$salaryMonth'),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return SalaryStructureResponse.fromJson(data);
    } else {
      throw Exception('Failed to load salary structure data');
    }
  }
}
