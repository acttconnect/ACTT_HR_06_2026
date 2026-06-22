import 'package:employeeattendance/factories/attendance_method_factory.dart';
import 'package:flutter/material.dart';

class AttendanceMethodsSection extends StatelessWidget {
  const AttendanceMethodsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final methods = AttendanceMethodFactory.build();

    // Nothing to show
    if (methods.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Attendance Methods",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          "Choose any available method to mark your attendance.",
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: methods.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            mainAxisExtent: 145,
          ),
          itemBuilder: (_, index) => methods[index],
        ),
      ],
    );
  }
}
