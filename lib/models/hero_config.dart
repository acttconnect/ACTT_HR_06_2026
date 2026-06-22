import 'package:flutter/material.dart';

import 'hero_stat.dart';

class HeroConfig {
  final String title;

  final String buttonText;

  final IconData buttonIcon;

  final VoidCallback onPressed;

  final List<HeroStat> stats;

  const HeroConfig({
    required this.title,
    required this.buttonText,
    required this.buttonIcon,
    required this.onPressed,
    required this.stats,
  });
}
