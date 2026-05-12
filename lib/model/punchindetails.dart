import 'package:employeeattendance/controller/globalvariable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthCheck {
  static checkIn(String checkinTime) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('time1', checkinTime);
  }

  static checkOut(String checkoutTime) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('time2', checkoutTime);
  }

  static autoCheck() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.containsKey('time1')) {
      GlobalVariable.checkIn = pref.getString('time1')!;
    }
    if (pref.containsKey('time2')) {
      GlobalVariable.checkOut = pref.getString('time2')!;
    }
  }
}
