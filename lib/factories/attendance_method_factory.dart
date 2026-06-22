import 'package:employeeattendance/widgets/AttendanceMethodsSection/GPSAttendanceCard.dart';
import 'package:employeeattendance/widgets/AttendanceMethodsSection/WebPunchCard.dart';
import 'package:employeeattendance/widgets/AttendanceMethodsSection/face_attendance_card.dart';
import 'package:employeeattendance/widgets/AttendanceMethodsSection/qr_attendance_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AttendanceMethodFactory {
  AttendanceMethodFactory._();

  static List<Widget> build() {
    //final permission = Get.find<PermissionController>();

    final List<Widget> methods = [];

    // ==========================================
    // No Attendance Permission
    // ==========================================

    // if (!permission.can(PermissionKeys.attendanceMark)) {
    //   return methods;
    // }

    // ==========================================
    // Face Attendance
    // ==========================================

    methods.add(const FaceAttendanceCard());

    // ==========================================
    // GPS Attendance
    // Enable whenever backend is ready
    // ==========================================

    methods.add(const GpsAttendanceCard());

    // ==========================================
    // Web Punch
    // ==========================================

    methods.add(const WebPunchCard());

    // ==========================================
    // Future Methods
    // ==========================================

    methods.add(const QrAttendanceCard());

    // methods.add(const BluetoothAttendanceCard());
    // methods.add(const NfcAttendanceCard());
    // methods.add(const WifiAttendanceCard());

    return methods;
  }
}
