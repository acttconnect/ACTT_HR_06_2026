// import 'package:face_recognition_attendance_system/controllers/attendance_controller.dart';
// import 'package:face_recognition_attendance_system/controllers/user_controller.dart';
// import 'package:face_recognition_attendance_system/controllers/permission_controller.dart';
// import 'package:face_recognition_attendance_system/screens/attendance/attendance_screen.dart';
// import 'package:face_recognition_attendance_system/screens/face_registration/register_face_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/hero_config.dart';
import '../models/hero_stat.dart';
// import 'package:face_recognition_attendance_system/controllers/permission_keys.dart';

class HeroFactory {
  static HeroConfig build() {
    // ======================================================
    // TODO: Uncomment when Laravel backend is integrated
    // ======================================================

    // final permission = Get.find<PermissionController>();
    // final userController = Get.find<UserController>();

    // final bool isFaceRegistered = userController.isFaceRegistered;
    // final String status = userController.attendanceState.value;

    // if (permission.can(PermissionKeys.fullAccess)) {
    //   return _superAdmin();
    // }

    // if (!permission.can(PermissionKeys.attendanceMark)) {
    //   return HeroConfig(
    //     title: "Attendance",
    //     buttonText: "No Permission",
    //     buttonIcon: Icons.lock_outline,
    //     onPressed: () {},
    //     stats: const [],
    //   );
    // }

    // return _employee(isFaceRegistered, status, userController);

    // ======================================================
    // TEMPORARY UI (Static Data)
    // ======================================================

    return _employeeDummy();
  }

  // =========================
  // SUPER ADMIN
  // =========================
  static HeroConfig _superAdmin() {
    return HeroConfig(
      title: "Enterprise Overview",
      buttonText: "Open Analytics",
      buttonIcon: Icons.bar_chart,
      onPressed: () {},
      stats: const [
        HeroStat(
          title: "Admins",
          value: "12",
          icon: Icons.admin_panel_settings,
        ),
        HeroStat(title: "Employees", value: "426", icon: Icons.people),
        HeroStat(title: "Branches", value: "8", icon: Icons.business),
        HeroStat(title: "Present", value: "401", icon: Icons.check_circle),
      ],
    );
  }

  // =========================
  // EMPLOYEE FLOW (FIXED)
  // =========================
  // static HeroConfig _employee(
  //   bool isFaceRegistered,
  //   String status,
  //   UserController userController,
  // ) {
  //   final attendance = userController.attendance.value ?? {};

  //   final checkIn = attendance["checkInTime"];
  //   final checkOut = attendance["checkOutTime"];
  //   final workedMinutes = attendance["workedMinutes"] ?? 0;

  //   final hours = (workedMinutes / 60).toStringAsFixed(2);
  //   // ❌ Face not registered
  //   if (!isFaceRegistered) {
  //     return HeroConfig(
  //       title: "Face Registration Required",
  //       buttonText: "Register Face",
  //       buttonIcon: Icons.face_retouching_natural,
  //       onPressed: () => Get.to(() => RegisterFaceScreen()),
  //       stats: const [],
  //     );
  //   }

  //   // 🔥 LIVE STATE CHECK (NO CACHE)
  //   final currentState = userController.attendanceState.value;

  //   // =========================
  //   // NOT CHECKED IN
  //   // =========================
  //   if (currentState == "not_checked_in") {
  //     return HeroConfig(
  //       title: "Ready to start your day?",
  //       buttonText: "Check In",
  //       buttonIcon: Icons.login,
  //       onPressed: () {
  //         Get.find<AttendanceController>().markFaceAttendance();
  //       },
  //       stats: const [],
  //     );
  //   }

  //   // =========================
  //   // CHECKED IN
  //   // =========================
  //   if (currentState == "checked_in") {
  //     return HeroConfig(
  //       title: "You're working now",
  //       buttonText: "Check Out",
  //       buttonIcon: Icons.logout,
  //       onPressed: () {
  //         Get.find<AttendanceController>().markFaceAttendance();
  //       },
  //       stats: [
  //         HeroStat(
  //           title: "Check In",
  //           value: checkIn != null
  //               ? DateTime.parse(
  //                   checkIn,
  //                 ).toLocal().toString().substring(11, 16)
  //               : "--:--",
  //           icon: Icons.login,
  //         ),
  //         HeroStat(title: "Worked", value: "$hours hrs", icon: Icons.timer),
  //       ],
  //     );
  //   }

  //   // =========================
  //   // CHECKED OUT (LOCK STATE)
  //   // =========================
  //   return HeroConfig(
  //     title: "Today's Attendance Completed",
  //     buttonText: "Completed",
  //     buttonIcon: Icons.check_circle,
  //     onPressed: () {},
  //     stats: [
  //       HeroStat(
  //         title: "Check In",
  //         value: checkIn != null
  //             ? DateTime.parse(
  //                 checkIn,
  //               ).toLocal().toString().substring(11, 16)
  //             : "--:--",
  //         icon: Icons.login,
  //       ),
  //       HeroStat(
  //         title: "Check Out",
  //         value: checkOut != null
  //             ? DateTime.parse(
  //                 checkOut,
  //               ).toLocal().toString().substring(11, 16)
  //             : "--:--",
  //         icon: Icons.logout,
  //       ),
  //       HeroStat(title: "Worked", value: "$hours hrs", icon: Icons.timer),
  //     ],
  //   );
  // }
  static HeroConfig _employeeDummy() {
    const bool isFaceRegistered = true;

    const String currentState = "not_checked_in";

    const String checkIn = "09:15";

    const String checkOut = "--:--";

    const String hours = "0.0";

    if (!isFaceRegistered) {
      return HeroConfig(
        title: "Face Registration Required",
        buttonText: "Register Face",
        buttonIcon: Icons.face_retouching_natural,
        onPressed: () {
          // TODO: Navigate to RegisterFaceScreen
        },
        stats: const [],
      );
    }

    if (currentState == "not_checked_in") {
      return HeroConfig(
        title: "Ready to start your day?",
        buttonText: "Check In",
        buttonIcon: Icons.login,
        onPressed: () {
          // TODO: AttendanceController.markFaceAttendance()
        },
        stats: const [],
      );
    }

    if (currentState == "checked_in") {
      return HeroConfig(
        title: "You're working now",
        buttonText: "Check Out",
        buttonIcon: Icons.logout,
        onPressed: () {
          // TODO: AttendanceController.markFaceAttendance()
        },
        stats: const [
          HeroStat(
            title: "Check In",
            value: checkIn,
            icon: Icons.login,
          ),
          HeroStat(
            title: "Worked",
            value: "$hours hrs",
            icon: Icons.timer,
          ),
        ],
      );
    }

    return HeroConfig(
      title: "Today's Attendance Completed",
      buttonText: "Completed",
      buttonIcon: Icons.check_circle,
      onPressed: () {},
      stats: const [
        HeroStat(
          title: "Check In",
          value: checkIn,
          icon: Icons.login,
        ),
        HeroStat(
          title: "Check Out",
          value: checkOut,
          icon: Icons.logout,
        ),
        HeroStat(
          title: "Worked",
          value: "$hours hrs",
          icon: Icons.timer,
        ),
      ],
    );
  }
}
