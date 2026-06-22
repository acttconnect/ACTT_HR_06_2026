import 'package:employeeattendance/widgets/AttendanceMethodsSection/attendance_method_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// =====================================================
// TODO(Laravel): Uncomment after permission module ready
// =====================================================

// import '../../controllers/permission_controller.dart';
// import '../../controllers/permission_keys.dart';

import '../../core/colors.dart';

class WebPunchCard extends StatelessWidget {
  const WebPunchCard({super.key});

  @override
  Widget build(BuildContext context) {
    // =====================================================
    // TODO(Laravel): Uncomment when PermissionController exists
    // =====================================================

    // final permission = Get.find<PermissionController>();

    // Temporary static permission
    const bool hasPermission = true;

    // =====================================================
    // Original Reactive Code (Keep for Future)
    // =====================================================

    /*
    return Obx(() {
      final bool hasPermission =
          permission.can(PermissionKeys.attendanceMark);

      return AttendanceMethodTile(
        icon: Icons.language_rounded,
        title: "Web\nPunch",
        color: AppColors.purple,
        enabled: hasPermission,
        onTap: !hasPermission
            ? null
            : () {
                Get.snackbar(
                  "Coming Soon",
                  "Web Punch attendance will be available soon.",
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                );

                // Future:
                // Get.find<AttendanceController>().markWebAttendance();
              },
      );
    });
    */

    // =====================================================
    // Temporary UI
    // =====================================================

    return AttendanceMethodTile(
      icon: Icons.language_rounded,
      title: "Web\nPunch",
      color: AppColors.purple,
      enabled: hasPermission,
      onTap: !hasPermission
          ? null
          : () {
              Get.snackbar(
                "Coming Soon",
                "Web Punch attendance will be available soon.",
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
              );

              // TODO(Laravel):
              // Get.find<AttendanceController>().markWebAttendance();
            },
    );
  }
}
