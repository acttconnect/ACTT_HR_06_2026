import 'package:employeeattendance/widgets/AttendanceMethodsSection/attendance_method_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// =====================================================
// TODO(Laravel): Uncomment after permission module ready
// =====================================================

// import '../../controllers/permission_controller.dart';
// import '../../controllers/permission_keys.dart';

import '../../core/colors.dart';

class QrAttendanceCard extends StatelessWidget {
  const QrAttendanceCard({super.key});

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
        icon: Icons.qr_code_scanner_rounded,
        title: "QR\nAttendance",
        color: AppColors.orange,
        enabled: hasPermission,
        onTap: !hasPermission
            ? null
            : () {
                Get.snackbar(
                  "Coming Soon",
                  "QR Code attendance will be available soon.",
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
      );
    });
    */

    // =====================================================
    // Temporary UI
    // =====================================================

    return AttendanceMethodTile(
      icon: Icons.qr_code_scanner_rounded,
      title: "QR\nAttendance",
      color: AppColors.orange,
      enabled: hasPermission,
      onTap: !hasPermission
          ? null
          : () {
              Get.snackbar(
                "Coming Soon",
                "QR Code attendance will be available soon.",
                snackPosition: SnackPosition.BOTTOM,
              );

              // TODO(Laravel):
              // Implement QR Attendance API
            },
    );
  }
}
