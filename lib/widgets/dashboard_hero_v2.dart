import 'package:employeeattendance/widgets/hero_stat_card.dart';

// TODO(Laravel): Uncomment after backend integration
// import 'package:face_recognition_attendance_system/controllers/attendance_controller.dart';
// import '../../../controllers/user_controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/colors.dart';
import '/factories/hero_factory.dart';

// TODO(Laravel): Use GlobalVariable when integrating
// import 'package:employeeattendance/controller/globalvariable.dart';

class DashboardHeroV2 extends StatelessWidget {
  const DashboardHeroV2({super.key});

  String greeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) return "☀ Good Morning";
    if (hour < 17) return "🌤 Good Afternoon";
    return "🌙 Good Evening";
  }

  @override
  Widget build(BuildContext context) {
    //final user = Get.find<UserController>();

    // return Obx(() {
    //   // 🔥 NOW REACTIVE
    //   final config = HeroFactory.build();

    final config = HeroFactory.build();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting(),
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            // TODO(Laravel):
// GlobalVariable.name

            "Mahak Gupta",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            config.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: config.stats.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
            ),
            itemBuilder: (_, index) {
              return HeroStatCard(stat: config.stats[index]);
            },
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: config.onPressed,
              icon: Icon(config.buttonIcon),
              label: Text(config.buttonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
