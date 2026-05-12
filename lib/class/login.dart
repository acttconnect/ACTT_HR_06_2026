import 'dart:convert';
import 'package:employeeattendance/HomePage/main_screen.dart';
import 'package:employeeattendance/class/constants.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:employeeattendance/controller/globalvariable.dart';

class Login {
  static Future<bool> getLogin(
    String empId,
    String password, {
    bool navigateToMain = true,
  }) async {
    final url = '${apiUrl}login?id=$empId&password=$password';
    var response = await http.post(Uri.parse(url));
    var data = jsonDecode(response.body.toString());
    if (response.statusCode == 200) {
      if (data['status'] == true) {
        GlobalVariable.uid = data['data']['id'];
        GlobalVariable.checkInStatus = data['data']['checkin_status'];
        GlobalVariable.checkOutStatus = data['data']['checkout_status'];
        GlobalVariable.checkIn = data['data']['checkin_time']?.toString() ?? "--:--";
        GlobalVariable.checkOut = data['data']['checkout_time']?.toString() ?? "--:--";
        GlobalVariable.lastUsage = data['data']['last_uses']?.toString() ?? "";
        GlobalVariable.name = data["data"]["name"]?.toString() ?? "";
        GlobalVariable.designation = data['data']['designation']?.toString() ?? "";
        GlobalVariable.number = data['data']['number']?.toString() ?? "";
        GlobalVariable.email = data['data']['email']?.toString() ?? "";
        GlobalVariable.image = data['data']['image']?.toString() ?? "";
        GlobalVariable.department = data['data']['department']?.toString() ?? "";
        GlobalVariable.empID = data['data']['empid']?.toString() ?? "";
        GlobalVariable.permanentAdd = data['data']['permanent_add']?.toString() ?? "";
        final branchDetails = data['data']['branch_details'] as Map<String, dynamic>?;
        GlobalVariable.branch = branchDetails?['name']?.toString() ??
            data['data']['branch_allocated']?.toString();
        GlobalVariable.joiningDate = data['data']['date_of_join']?.toString();
        GlobalVariable.salary = data['data']['salary']?.toString();
        // GlobalVariable.currentAdd = data['data']['corres_add'];
        // GlobalVariable.emergencynumber = data['data']['parent_mobile'];
        // GlobalVariable.blood = data['data']['blood_group'];
        print(GlobalVariable.empID);
        print(GlobalVariable.name);
        print(GlobalVariable.designation);
        print(GlobalVariable.number);
        print(GlobalVariable.email);
        print(GlobalVariable.image);
        print(GlobalVariable.department);
        print(GlobalVariable.joiningDate);
        print(GlobalVariable.salary);
        Fluttertoast.showToast(msg: 'Login Successful');
        if (navigateToMain) {
          Get.offAll(() => const MainScreen());
        }
        return true;
      } else {
        Fluttertoast.showToast(msg: 'Invalid Employee ID or Password');
        return false;
      }
    }
    return false;
  }
}
