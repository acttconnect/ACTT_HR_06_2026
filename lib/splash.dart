// ignore_for_file: use_build_context_synchronously
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:employeeattendance/class/login.dart';
import 'package:employeeattendance/controllers/globalvariable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import 'HomePage/main_screen.dart';
import 'login_screen.dart';
import 'model/auth_controller.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with TickerProviderStateMixin {
  // Logo animation
  late AnimationController _logoController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  // Title slide-up animation
  late AnimationController _titleController;
  late Animation<double> _titleSlide;
  late Animation<double> _titleOpacity;

  // Pulsing rings animation
  late AnimationController _ringController;
  late Animation<double> _ring1;
  late Animation<double> _ring2;
  late Animation<double> _ring3;

  // Loading dots animation
  late AnimationController _dotsController;

  // Floating particles
  late AnimationController _particleController;

  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _buildParticles();
    _initAnimations();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _start();
    });
  }

  void _buildParticles() {
    final rng = Random();
    for (int i = 0; i < 14; i++) {
      _particles.add(_Particle(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        size: rng.nextDouble() * 6 + 3,
        speed: rng.nextDouble() * 0.4 + 0.2,
        delay: rng.nextDouble(),
        opacity: rng.nextDouble() * 0.15 + 0.05,
      ));
    }
  }

  void _initAnimations() {
    // --- Logo pop-in ---
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // --- Title slide-up ---
    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _titleSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeOutCubic),
    );
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeIn),
    );

    // --- Pulsing rings ---
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _ring1 = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeInOut),
    );
    _ring2 = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _ringController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
      ),
    );
    _ring3 = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _ringController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
      ),
    );

    // --- Bouncing dots ---
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    // --- Floating particles ---
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    // Start logo first, then title
    _logoController.forward().then((_) {
      _titleController.forward();
    });
  }

  Future<void> _start() async {
    final startTime = DateTime.now();
    bool goToMain = false;
    try {
      final hasAutoLogin = await AuthLogin.tryAutoLogin();
      if (hasAutoLogin) {
        final ok = await Login.getLogin(
          GlobalVariable.empID,
          GlobalVariable.password,
          navigateToMain: false,
        );
        goToMain = ok;
      }
    } catch (_) {
      goToMain = false;
    }

    final elapsed = DateTime.now().difference(startTime);
    const minSplash = Duration(seconds: 3);
    if (elapsed < minSplash) {
      await Future.delayed(minSplash - elapsed);
    }

    if (mounted) {
      Get.offAll(() => goToMain ? const MainScreen() : const LoginScreen());
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _titleController.dispose();
    _ringController.dispose();
    _dotsController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const brandColor = Color(0xFF0767B6);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // --- Floating Particles ---
          AnimatedBuilder(
            animation: _particleController,
            builder: (_, __) {
              return CustomPaint(
                size: size,
                painter: _ParticlePainter(
                  particles: _particles,
                  progress: _particleController.value,
                  color: brandColor,
                ),
              );
            },
          ),

          // --- Pulsing Rings ---
          AnimatedBuilder(
            animation: _ringController,
            builder: (_, __) {
              return Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildRing(
                        160 * _ring3.value, brandColor.withOpacity(0.06)),
                    _buildRing(
                        230 * _ring2.value, brandColor.withOpacity(0.04)),
                    _buildRing(
                        310 * _ring1.value, brandColor.withOpacity(0.025)),
                  ],
                ),
              );
            },
          ),

          // --- Main Content ---
          SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo with pop-in
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (_, child) => Opacity(
                      opacity: _logoOpacity.value.clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: _logoScale.value.clamp(0.0, 1.2),
                        child: child,
                      ),
                    ),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: brandColor.withOpacity(0.2),
                            blurRadius: 30,
                            spreadRadius: 4,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Image.asset(
                          'assets/images/ACT-HR.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Title slide-up
                  AnimatedBuilder(
                    animation: _titleController,
                    builder: (_, child) => Opacity(
                      opacity: _titleOpacity.value,
                      child: Transform.translate(
                        offset: Offset(0, _titleSlide.value),
                        child: child,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Employee Attendance",
                          style: TextStyle(
                            color: brandColor,
                            fontSize: 26,
                            fontFamily: GoogleFonts.ubuntu().fontFamily,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "App",
                          style: TextStyle(
                            color: brandColor.withOpacity(0.75),
                            fontSize: 18,
                            fontFamily: GoogleFonts.ubuntu().fontFamily,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Splash image (if exists)
                  AnimatedBuilder(
                    animation: _titleController,
                    builder: (_, child) => Opacity(
                      opacity: _titleOpacity.value,
                      child: child,
                    ),
                    child: Image.asset(
                      'assets/images/splash.png',
                      height: 28,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Bouncing loading dots
                  _LoadingDots(controller: _dotsController, color: brandColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRing(double diameter, Color color) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.5),
      ),
    );
  }
}

// ─── Bouncing Dots Widget ─────────────────────────────────────────────────────

class _LoadingDots extends StatelessWidget {
  final AnimationController controller;
  final Color color;

  const _LoadingDots({required this.controller, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i * 0.25;
            final t = ((controller.value - delay) % 1.0).clamp(0.0, 1.0);
            final bounce = sin(t * pi);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: color.withOpacity(0.4 + bounce * 0.6),
                shape: BoxShape.circle,
              ),
              transform: Matrix4.translationValues(0, -10 * bounce, 0),
            );
          }),
        );
      },
    );
  }
}

// ─── Particle Data ────────────────────────────────────────────────────────────

class _Particle {
  final double x, y, size, speed, delay, opacity;
  const _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.delay,
    required this.opacity,
  });
}

// ─── Particle Painter ─────────────────────────────────────────────────────────

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Color color;

  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in particles) {
      final t = ((progress * p.speed + p.delay) % 1.0);
      final x = p.x * size.width;
      final y = size.height - (t * size.height * 1.2);
      final opacity = (sin(t * pi) * p.opacity).clamp(0.0, 1.0);
      paint.color = color.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) => true;
}
