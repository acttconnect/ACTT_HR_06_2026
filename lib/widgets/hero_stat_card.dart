import 'package:employeeattendance/models/hero_stat.dart';
import 'package:flutter/material.dart';

class HeroStatCard extends StatelessWidget {
  final HeroStat stat;

  const HeroStatCard({super.key, required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.15),
        borderRadius: BorderRadius.circular(18),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown, // 🔥 forces whole card to shrink if needed
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(stat.icon, color: Colors.white, size: 26),
            const SizedBox(height: 8),
            Text(
              stat.value,
              maxLines: 1,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 80, // 🔥 prevents horizontal overflow
              child: Text(
                stat.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
