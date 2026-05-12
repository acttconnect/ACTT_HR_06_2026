import 'package:employeeattendance/HomePage/main_screen.dart';
import 'package:employeeattendance/controller/globalvariable.dart';
import 'package:employeeattendance/HomePage/home_screen.dart';
import 'package:employeeattendance/login_screen.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthLogin {
  static login(String empId, String pass) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('id', empId);
    pref.setString('pass', pass);
    Get.offAll(const MainScreen());
  }

  static Future<bool> tryAutoLogin() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.containsKey('id')) {
      GlobalVariable.empID = pref.getString('id')!;
      GlobalVariable.password = pref.getString('pass')!;
      return true;
    } else {
      return false;
    }
  }

  static logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Get.offAll(() => const LoginScreen());
  }
}
