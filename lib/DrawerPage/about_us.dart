import 'dart:math';
import 'package:flutter/material.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({super.key});

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> with TickerProviderStateMixin {
  // Logo pop-in
  late AnimationController _logoController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  // Content slide-up
  late AnimationController _contentController;
  late Animation<double> _contentSlide;
  late Animation<double> _contentOpacity;

  // Pulsing rings behind logo
  late AnimationController _ringController;

  // Floating particles
  late AnimationController _particleController;
  final List<_Particle> _particles = [];

  // Features stagger
  late AnimationController _featuresController;

  @override
  void initState() {
    super.initState();
    _buildParticles();
    _initAnimations();
  }

  void _buildParticles() {
    final rng = Random();
    for (int i = 0; i < 18; i++) {
      _particles.add(_Particle(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        size: rng.nextDouble() * 5 + 2,
        speed: rng.nextDouble() * 0.3 + 0.15,
        delay: rng.nextDouble(),
        opacity: rng.nextDouble() * 0.12 + 0.04,
      ));
    }
  }

  void _initAnimations() {
    // Logo
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
      ),
    );

    // Content
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _contentSlide = Tween<double>(begin: 32.0, end: 0.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic),
    );
    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeIn),
    );

    // Rings
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    // Particles
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();

    // Features stagger
    _featuresController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Sequence
    _logoController.forward().then((_) {
      _contentController.forward();
      _featuresController.forward();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _contentController.dispose();
    _ringController.dispose();
    _particleController.dispose();
    _featuresController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const brandBlue = Color(0xFF2563EB);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: brandBlue,
        title: const Text(
          'About Us',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Floating particles background
          AnimatedBuilder(
            animation: _particleController,
            builder: (_, __) => CustomPaint(
              size: size,
              painter: _ParticlePainter(
                particles: _particles,
                progress: _particleController.value,
                color: brandBlue,
              ),
            ),
          ),

          // Decorative top blob
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: brandBlue.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: brandBlue.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: brandBlue.withOpacity(0.05),
              ),
            ),
          ),

          // Main scrollable content
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // ── Logo section ──────────────────────────────────────────
                AnimatedBuilder(
                  animation: _ringController,
                  builder: (_, child) {
                    final pulse = _ringController.value;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Ring 3 (outer)
                        Container(
                          width: 190 + (pulse * 10),
                          height: 190 + (pulse * 10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: brandBlue.withOpacity(0.06 - pulse * 0.02),
                              width: 1.5,
                            ),
                          ),
                        ),
                        // Ring 2
                        Container(
                          width: 160 + (pulse * 8),
                          height: 160 + (pulse * 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: brandBlue.withOpacity(0.09 - pulse * 0.02),
                              width: 1.5,
                            ),
                          ),
                        ),
                        // Ring 1 (inner)
                        Container(
                          width: 130 + (pulse * 5),
                          height: 130 + (pulse * 5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: brandBlue.withOpacity(0.04 + pulse * 0.02),
                            border: Border.all(
                              color: brandBlue.withOpacity(0.12),
                              width: 1,
                            ),
                          ),
                        ),
                        child!,
                      ],
                    );
                  },
                  child: AnimatedBuilder(
                    animation: _logoController,
                    builder: (_, child) => Opacity(
                      opacity: _logoOpacity.value.clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: _logoScale.value.clamp(0.0, 1.15),
                        child: child,
                      ),
                    ),
                    child: Container(
                      width: 115,
                      height: 115,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: brandBlue.withOpacity(0.18),
                            blurRadius: 30,
                            spreadRadius: 4,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(18),
                      child: Image.asset(
                        'assets/images/ACT-HR.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ── App name + version ────────────────────────────────────
                AnimatedBuilder(
                  animation: _contentController,
                  builder: (_, child) => Opacity(
                    opacity: _contentOpacity.value,
                    child: Transform.translate(
                      offset: Offset(0, _contentSlide.value),
                      child: child,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'ACT HR',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Employee Attendance Management',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Version badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFBFDBFE),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Color(0xFF22C55E),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Version 2.4.9  •  Latest',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── What's New card ───────────────────────────────────────
                _StaggeredCard(
                  controller: _featuresController,
                  delay: 0.0,
                  child: _WhatsNewCard(),
                ),

                const SizedBox(height: 16),

                // ── Feature highlights ────────────────────────────────────
                _StaggeredCard(
                  controller: _featuresController,
                  delay: 0.18,
                  child: _buildFeaturesCard(),
                ),

                const SizedBox(height: 16),

                // ── Company info card ─────────────────────────────────────
                _StaggeredCard(
                  controller: _featuresController,
                  delay: 0.36,
                  child: _buildCompanyCard(),
                ),

                const SizedBox(height: 16),

                // ── Contact card ──────────────────────────────────────────
                _StaggeredCard(
                  controller: _featuresController,
                  delay: 0.54,
                  child: _buildContactCard(),
                ),

                const SizedBox(height: 32),

                // Footer
                _StaggeredCard(
                  controller: _featuresController,
                  delay: 0.7,
                  child: Text(
                    '© 2025 ACT HR. All rights reserved.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── What's New Card ─────────────────────────────────────────────────────────
  Widget _WhatsNewCard() {
    const updates = [
      _UpdateItem(
        icon: Icons.speed_rounded,
        color: Color(0xFF7C3AED),
        title: 'Faster Performance',
        desc: 'App launch and screen transitions are 40% faster.',
      ),
      _UpdateItem(
        icon: Icons.location_on_rounded,
        color: Color(0xFF2563EB),
        title: 'Improved Location Tracking',
        desc: 'More accurate check-in/check-out with live GPS.',
      ),
      _UpdateItem(
        icon: Icons.bar_chart_rounded,
        color: Color(0xFF0891B2),
        title: 'New Attendance Reports',
        desc: 'View weekly and monthly summaries at a glance.',
      ),
      _UpdateItem(
        icon: Icons.palette_rounded,
        color: Color(0xFFD97706),
        title: 'UI Refresh',
        desc: 'Modern cards, animations, and cleaner layouts.',
      ),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.new_releases_rounded,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    "What's New in v2.4.9",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            // Update items
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: updates.map((u) => _buildUpdateRow(u)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateRow(_UpdateItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: item.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.desc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Features Card ───────────────────────────────────────────────────────────
  Widget _buildFeaturesCard() {
    final features = [
      {
        'icon': Icons.fingerprint_rounded,
        'color': const Color(0xFF7C3AED),
        'label': 'Biometric\nAttendance'
      },
      {
        'icon': Icons.map_rounded,
        'color': const Color(0xFF2563EB),
        'label': 'GPS\nTracking'
      },
      {
        'icon': Icons.receipt_long_rounded,
        'color': const Color(0xFF0891B2),
        'label': 'Expense\nManagement'
      },
      {
        'icon': Icons.notifications_rounded,
        'color': const Color(0xFFD97706),
        'label': 'Smart\nAlerts'
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Key Features',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: features.map((f) {
              return Column(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: (f['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(f['icon'] as IconData,
                        color: f['color'] as Color, size: 26),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    f['label'] as String,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Company Card ────────────────────────────────────────────────────────────
  Widget _buildCompanyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About the Company',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'ACT HR is a comprehensive Human Resource Management solution built to streamline employee attendance, leave, expense, and payroll management for modern businesses.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          _infoRow(Icons.business_rounded, 'ACT Solutions Pvt. Ltd.'),
          const SizedBox(height: 8),
          _infoRow(Icons.public_rounded, 'www.acthr.in'),
          const SizedBox(height: 8),
          _infoRow(Icons.location_on_rounded, 'Mumbai, Maharashtra, India'),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF2563EB)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF475569),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ── Contact Card ────────────────────────────────────────────────────────────
  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Get in Touch',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _contactRow(Icons.email_rounded, 'support@acthr.in'),
          const SizedBox(height: 8),
          _contactRow(Icons.phone_rounded, '+91 98765 43210'),
          const SizedBox(height: 8),
          _contactRow(Icons.schedule_rounded, 'Mon – Sat, 9 AM – 6 PM'),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Staggered card wrapper
// ═══════════════════════════════════════════════════════════════════════════════
class _StaggeredCard extends StatelessWidget {
  final AnimationController controller;
  final double delay;
  final Widget child;

  const _StaggeredCard({
    required this.controller,
    required this.delay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final end = (delay + 0.55).clamp(0.0, 1.0);

    final opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(delay, end, curve: Curves.easeOut),
      ),
    );
    final slide = Tween<double>(begin: 28.0, end: 0.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(delay, end, curve: Curves.easeOutCubic),
      ),
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => Opacity(
        opacity: opacity.value,
        child: Transform.translate(
          offset: Offset(0, slide.value),
          child: child,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Update item model
// ═══════════════════════════════════════════════════════════════════════════════
class _UpdateItem {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;
  const _UpdateItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.desc,
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
// Particle system
// ═══════════════════════════════════════════════════════════════════════════════
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
      final y = size.height - (t * size.height * 1.1);
      final opacity = (sin(t * pi) * p.opacity).clamp(0.0, 1.0);
      paint.color = color.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}
