import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:employeeattendance/controller/globalvariable.dart';
import 'package:get/get.dart';
import '../class/constants.dart';

class CalController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<CalModel> attnData = <CalModel>[].obs;

  Future<void> fetchAttendance() async {
    if (GlobalVariable.empID.isEmpty) {
      Fluttertoast.showToast(msg: 'Employee ID not available. Please login again.');
      return;
    }
    
    final url = '${apiUrl}employee/attendance-calendar?employee_id=${GlobalVariable.empID}';
    
    // Print debugging information
    print('=== Attendance API Debug ===');
    print('Employee ID (uid): ${GlobalVariable.uid}');
    print('Employee ID (empID): ${GlobalVariable.empID}');
    print('Full API URL: $url');
    print('===========================');
    
    isLoading.value = true;
    try {
      var response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
        },
      );
      
      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Parsed Data: $data');
        
        List<CalModel> output = [];
        
        // Parse the new nested API response structure
        if (data['data'] is List) {
          for (var monthData in data['data']) {
            if (monthData['data'] is List) {
              for (var dayData in monthData['data']) {
                String status = dayData['status'] ?? 'absent';
                String workStatus = _mapStatusToWorkStatus(status);
                
                output.add(CalModel(
                  date: dayData['date'] ?? '',
                  checkIn: 'N/A',
                  checkOut: 'N/A',
                  inLocation: '-----',
                  outLocation: '-----',
                  workStatus: workStatus,
                  compareDate: dayData['date'] ?? '',
                  status: status,
                  day: dayData['day'] ?? '',
                ));
              }
            }
          }
        }
        
        print('Total records parsed: ${output.length}');
        attnData.assignAll(output);
      } else {
        Fluttertoast.showToast(msg: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching attendance: $e');
      Fluttertoast.showToast(msg: 'Error fetching data: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  String _mapStatusToWorkStatus(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return 'Present';
      case 'absent':
        return 'Absent';
      case 'incomplete':
        return 'Half Day / Incomplete';
      case 'weekly_off':
        return 'Weekly Off';
      case 'holiday':
        return 'Holiday';
      case 'half_day':
      case 'halfday':
        return 'Half Day / Incomplete';
      default:
        return 'Not Available';
    }
  }
}

class CalModel {
  final String date;
  final String checkIn;
  final String checkOut;
  final String inLocation;
  final String outLocation;
  final String workStatus;
  final String compareDate;
  final String? status;
  final String? day;

  CalModel({
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.inLocation,
    required this.outLocation,
    required this.workStatus,
    required this.compareDate,
    this.status,
    this.day,
  });
}
