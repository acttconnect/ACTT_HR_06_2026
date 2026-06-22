import 'package:employeeattendance/widgets/AttendanceMethodsSection/attendance_method_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// =====================================================
// TODO(Laravel): Uncomment after backend integration
// =====================================================

// import '../../controllers/attendance_controller.dart';
// import '../../controllers/permission_controller.dart';
// import '../../controllers/permission_keys.dart';
// import '../../controllers/user_controller.dart';

import '../../core/colors.dart';

class GpsAttendanceCard extends StatelessWidget {
  const GpsAttendanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    // =====================================================
    // TODO(Laravel): Uncomment when controllers are available
    // =====================================================

    // final permission = Get.find<PermissionController>();
    // final userController = Get.find<UserController>();

    // =====================================================
    // Temporary Dummy Data
    // =====================================================

    const bool hasPermission = true;

    // Change this to true if you want to test completed state
    const bool completed = false;

    // =====================================================
    // Original Reactive Code (Keep for Future)
    // =====================================================

    /*
    return Obx(() {
      final bool hasPermission =
          permission.can(PermissionKeys.attendanceMark);

      final bool completed =
          userController.attendanceState.value.toLowerCase() == "checked_out";

      return AttendanceMethodTile(
        icon: Icons.location_on_rounded,
        title: "GPS\nAttendance",
        color: AppColors.teal,
        enabled: hasPermission,
        onTap: !hasPermission
            ? null
            : () {
                if (completed) {
                  Get.snackbar(
                    "Attendance Completed",
                    "You have already completed today's attendance.",
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  return;
                }

                Get.find<AttendanceController>().markGpsAttendance();
              },
      );
    });
    */

    // =====================================================
    // Temporary UI
    // =====================================================

    return AttendanceMethodTile(
      icon: Icons.location_on_rounded,
      title: "GPS\nAttendance",
      color: AppColors.teal,
      enabled: hasPermission,
      onTap: !hasPermission
          ? null
          : () {
              if (completed) {
                Get.snackbar(
                  "Attendance Completed",
                  "You have already completed today's attendance.",
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              Get.snackbar(
                "Coming Soon",
                "GPS Attendance will be integrated with Laravel backend.",
                snackPosition: SnackPosition.BOTTOM,
              );

              // TODO(Laravel):
              // Get.find<AttendanceController>().markGpsAttendance();
            },
    );
  }
}
