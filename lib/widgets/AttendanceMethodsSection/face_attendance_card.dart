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
// import '../../screens/face_registration/register_face_screen.dart';

import '../../core/colors.dart';

class FaceAttendanceCard extends StatelessWidget {
  const FaceAttendanceCard({super.key});

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

    // Change to false if you want to test Register Face UI
    const bool isFaceRegistered = true;

    // not_checked_in
    // checked_in
    // checked_out
    const String attendanceState = "not_checked_in";

    final bool completed = attendanceState == "checked_out";

    // =====================================================
    // Original Reactive Code (Keep for Future)
    // =====================================================

    /*
    return Obx(() {
      final bool hasPermission = permission.can(PermissionKeys.attendanceMark);

      final bool isFaceRegistered = userController.isFaceRegistered;

      final String attendanceState =
          userController.attendanceState.value.toLowerCase();

      final bool completed = attendanceState == "checked_out";

      return AttendanceMethodTile(
        icon: Icons.face_rounded,
        title: "Face\nRecognition",
        color: AppColors.primary,
        enabled: hasPermission,
        onTap: !hasPermission
            ? null
            : () {
                // Face registration first
                if (!isFaceRegistered) {
                  Get.to(() => RegisterFaceScreen());
                  return;
                }

                // Attendance already completed
                if (completed) {
                  Get.snackbar(
                    "Attendance Completed",
                    "You have already completed today's attendance.",
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  return;
                }

                // Existing logic
                Get.find<AttendanceController>().markFaceAttendance();
              },
      );
    });
    */

    // =====================================================
    // Temporary UI
    // =====================================================

    return AttendanceMethodTile(
      icon: Icons.face_rounded,
      title: "Face\nRecognition",
      color: AppColors.primary,
      enabled: hasPermission,
      onTap: !hasPermission
          ? null
          : () {
              // Face not registered
              if (!isFaceRegistered) {
                Get.snackbar(
                  "Register Face",
                  "Face registration screen will be integrated later.",
                  snackPosition: SnackPosition.BOTTOM,
                );

                // TODO(Laravel):
                // Get.to(() => RegisterFaceScreen());

                return;
              }

              // Attendance completed
              if (completed) {
                Get.snackbar(
                  "Attendance Completed",
                  "You have already completed today's attendance.",
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              // Temporary action
              Get.snackbar(
                "Coming Soon",
                "Face Recognition attendance will be integrated with Laravel backend.",
                snackPosition: SnackPosition.BOTTOM,
              );

              // TODO(Laravel):
              // Get.find<AttendanceController>().markFaceAttendance();
            },
    );
  }
}
