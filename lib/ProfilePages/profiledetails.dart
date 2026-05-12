import 'dart:math' as math;

import 'package:employeeattendance/controller/globalvariable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileDetails extends StatefulWidget {
  const ProfileDetails({Key? key}) : super(key: key);

  @override
  State<ProfileDetails> createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends State<ProfileDetails>
    with TickerProviderStateMixin {
  late AnimationController _headerCtrl;
  late AnimationController _cardsCtrl;
  late AnimationController _shimmerCtrl;

  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _shimmer;

  final List<Animation<Offset>> _cardSlides = [];
  final List<Animation<double>> _cardFades = [];
  final int _cardCount = 6;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _headerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _headerFade = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerSlide =
        Tween<Offset>(begin: const Offset(0, -0.25), end: Offset.zero).animate(
            CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic));

    _cardsCtrl = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400 + (_cardCount * 110)));
    for (int i = 0; i < _cardCount; i++) {
      final start = (i * 0.11).clamp(0.0, 1.0);
      final end = (start + 0.42).clamp(0.0, 1.0);
      final interval = CurvedAnimation(
          parent: _cardsCtrl,
          curve: Interval(start, end, curve: Curves.easeOutCubic));
      _cardSlides.add(
          Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero)
              .animate(interval));
      _cardFades.add(interval);
    }

    _shimmerCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat();
    _shimmer = Tween<double>(begin: 0.0, end: 1.0).animate(_shimmerCtrl);
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 80));
    _headerCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 220));
    _cardsCtrl.forward();
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _cardsCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  // ─── detail items ───────────────────────────────────────────────────────
  List<_DetailItem> get _items => [
        _DetailItem(
          title: "Contact Number",
          value: GlobalVariable.number,
          icon: Icons.phone_rounded,
          iconColor: const Color(0xFF4CAF50),
          bgColor: const Color(0xFF4CAF50),
        ),
        _DetailItem(
          title: "Employee ID",
          value: GlobalVariable.empID,
          icon: Icons.badge_rounded,
          iconColor: Colors.blue.shade300,
          bgColor: Colors.blue.shade400,
        ),
        _DetailItem(
          title: "Branch",
          value: GlobalVariable.branch ?? 'Not Available',
          icon: Icons.apartment_rounded,
          iconColor: const Color(0xFFFF7043),
          bgColor: const Color(0xFFFF7043),
        ),
        _DetailItem(
          title: "Salary",
          value: GlobalVariable.salary ?? 'Not Available',
          icon: Icons.currency_rupee_rounded,
          iconColor: const Color(0xFF29B6F6),
          bgColor: const Color(0xFF29B6F6),
        ),
        _DetailItem(
          title: "E-mail",
          value: GlobalVariable.email,
          icon: Icons.mail_rounded,
          iconColor: const Color(0xFFFFA726),
          bgColor: const Color(0xFFFFA726),
        ),
        _DetailItem(
          title: "Joining Date",
          value: GlobalVariable.joiningDate ?? 'Not Available',
          icon: Icons.calendar_month_rounded,
          iconColor: Colors.blue.shade200,
          bgColor: Colors.blue.shade300,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFF071232),
      body: Stack(
        children: [
          // ── background blobs ──
          const _AnimatedBackground(),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── AppBar ──
                SlideTransition(
                  position: _headerSlide,
                  child: FadeTransition(
                    opacity: _headerFade,
                    child: _buildAppBar(context),
                  ),
                ),

                // ── Header card ──
                SlideTransition(
                  position: _headerSlide,
                  child: FadeTransition(
                    opacity: _headerFade,
                    child: _buildHeaderCard(),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Detail cards ──
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                    itemCount: _items.length,
                    itemBuilder: (context, i) {
                      if (i >= _cardSlides.length) return const SizedBox();
                      return SlideTransition(
                        position: _cardSlides[i],
                        child: FadeTransition(
                          opacity: _cardFades[i],
                          child: _DetailCard(item: _items[i]),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.blue.shade800.withOpacity(0.35),
                border:
                    Border.all(color: Colors.blue.shade500.withOpacity(0.30)),
              ),
              child: Center(
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.blue.shade100, size: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "Profile Details",
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 20,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (_, __) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade900,
                Colors.blue.shade800,
                Colors.blue.shade700,
              ],
              stops: [
                0.0,
                _shimmer.value.clamp(0.3, 0.7),
                1.0,
              ],
            ),
            border: Border.all(
                color: Colors.blue.shade400.withOpacity(0.35), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade900.withOpacity(0.6),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar circle
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.blue.shade300.withOpacity(0.5), width: 2),
                  color: Colors.blue.shade800,
                ),
                child: Center(
                  child: Text(
                    GlobalVariable.name.isNotEmpty
                        ? GlobalVariable.name[0].toUpperCase()
                        : 'E',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      GlobalVariable.name,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      GlobalVariable.designation,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: Colors.blue.shade200.withOpacity(0.75),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade400.withOpacity(0.20),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.blue.shade300.withOpacity(0.35)),
                      ),
                      child: Text(
                        "${GlobalVariable.department} Dept.",
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: Colors.blue.shade100,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DETAIL ITEM MODEL
// ═══════════════════════════════════════════════════════════════════════════

class _DetailItem {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const _DetailItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });
}

// ═══════════════════════════════════════════════════════════════════════════
// DETAIL CARD
// ═══════════════════════════════════════════════════════════════════════════

class _DetailCard extends StatefulWidget {
  final _DetailItem item;
  const _DetailCard({required this.item});

  @override
  State<_DetailCard> createState() => _DetailCardState();
}

class _DetailCardState extends State<_DetailCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        // Copy value to clipboard on tap
        Clipboard.setData(ClipboardData(text: widget.item.value));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${widget.item.title} copied!",
              style: GoogleFonts.dmSans(color: Colors.white),
            ),
            backgroundColor: Colors.blue.shade900,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.blue.shade900.withOpacity(0.35),
            border: Border.all(
              color: Colors.blue.shade700.withOpacity(0.28),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Icon box
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: widget.item.bgColor.withOpacity(0.15),
                ),
                child: Center(
                  child: Icon(widget.item.icon,
                      color: widget.item.iconColor, size: 20),
                ),
              ),
              const SizedBox(width: 14),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.title,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: Colors.blue.shade300.withOpacity(0.65),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.item.value,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        color: Colors.blue.shade50,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Copy hint
              Icon(
                Icons.copy_rounded,
                size: 14,
                color: Colors.blue.shade400.withOpacity(0.40),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ANIMATED BACKGROUND
// ═══════════════════════════════════════════════════════════════════════════

class _AnimatedBackground extends StatefulWidget {
  const _AnimatedBackground();

  @override
  State<_AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<_AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 8))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Stack(
        children: [
          Positioned(
            top: -60 + (_ctrl.value * 30),
            right: -80 + (_ctrl.value * 20),
            child:
                _Blob(size: 280, color: Colors.blue.shade900.withOpacity(0.55)),
          ),
          Positioned(
            top: 300 + (_ctrl.value * -25),
            left: -70,
            child:
                _Blob(size: 220, color: Colors.blue.shade700.withOpacity(0.25)),
          ),
          Positioned(
            bottom: 80 + (_ctrl.value * 15),
            right: 10,
            child:
                _Blob(size: 170, color: Colors.blue.shade400.withOpacity(0.12)),
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 80, spreadRadius: 15)],
      ),
    );
  }
}
