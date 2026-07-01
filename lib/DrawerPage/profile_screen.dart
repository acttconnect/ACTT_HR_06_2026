import 'dart:convert';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:employeeattendance/DrawerPage/help.dart';
import 'package:employeeattendance/HomePage/main_screen.dart';
import 'package:employeeattendance/ProfilePages/downloads.dart';
import 'package:employeeattendance/ProfilePages/familydetails.dart';
import 'package:employeeattendance/ProfilePages/personaldetails.dart';
import 'package:employeeattendance/ProfilePages/profiledetails.dart';
import 'package:employeeattendance/ProfilePages/uploadsdocument.dart';
import 'package:employeeattendance/class/constants.dart';
import 'package:employeeattendance/model/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/globalvariable.dart';

// ─── Blue.shade900 palette reference ───────────────────────────────────────
// Colors.blue.shade900  = #0D47A1  ← primary brand
// Colors.blue.shade800  = #1565C0
// Colors.blue.shade700  = #1976D2
// Colors.blue.shade600  = #1E88E5
// Colors.blue.shade400  = #42A5F5
// Colors.blue.shade300  = #64B5F6
// Colors.blue.shade200  = #90CAF9
// Colors.blue.shade50   = #E3F2FD
// Background base       = #071232  (darker than shade900 for depth)
// ───────────────────────────────────────────────────────────────────────────

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _avatarController;
  late AnimationController _tilesController;
  late AnimationController _shimmerController;
  late AnimationController _floatingController;

  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _avatarScale;
  late Animation<double> _avatarFade;
  late Animation<double> _shimmer;
  late Animation<double> _floating;

  final List<Animation<Offset>> _tileSlides = [];
  final List<Animation<double>> _tileFades = [];
  final int _tileCount = 5;

  @override
  void initState() {
    super.initState();
    _printProfileApiDebug();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _headerController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _headerFade =
        CurvedAnimation(parent: _headerController, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _headerController, curve: Curves.easeOutCubic));

    _avatarController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _avatarScale = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _avatarController, curve: Curves.elasticOut));
    _avatarFade =
        CurvedAnimation(parent: _avatarController, curve: Curves.easeIn);

    _tilesController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400 + (_tileCount * 100)));
    for (int i = 0; i < _tileCount; i++) {
      final start = (i * 0.12).clamp(0.0, 1.0);
      final end = (start + 0.45).clamp(0.0, 1.0);
      final interval = CurvedAnimation(
          parent: _tilesController,
          curve: Interval(start, end, curve: Curves.easeOutCubic));
      _tileSlides.add(
          Tween<Offset>(begin: const Offset(0.4, 0), end: Offset.zero)
              .animate(interval));
      _tileFades.add(interval);
    }

    _shimmerController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
    _shimmer = Tween<double>(begin: 0.0, end: 1.0).animate(_shimmerController);

    _floatingController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);
    _floating = Tween<double>(begin: -6.0, end: 6.0).animate(
        CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut));
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _headerController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _avatarController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _tilesController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _avatarController.dispose();
    _tilesController.dispose();
    _shimmerController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  Future<void> _printProfileApiDebug() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final empId = prefs.getString('id') ?? GlobalVariable.empID;
      final password = prefs.getString('pass') ?? GlobalVariable.password;
      if (empId.trim().isEmpty || password.trim().isEmpty) return;
      final profileUri = Uri.parse('${apiUrl}login')
          .replace(queryParameters: {'id': empId, 'password': password});
      final response =
          await http.post(profileUri, headers: {'Accept': 'application/json'});
      try {
        final decoded = jsonDecode(response.body);
        debugPrint('Profile API Parsed Status: ${decoded['status']}');
      } catch (_) {}
    } catch (e) {
      debugPrint('Profile API Debug Error: $e');
    }
  }

  // ─── BUILD ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFF071232), // very dark navy
      body: Stack(
        children: [
          const _AnimatedBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    children: [
                      const SizedBox(height: 10),
                      _buildProfileCardOptions(),
                      const SizedBox(height: 28),
                      _buildAvatarSection(),
                      const SizedBox(height: 28),
                      _buildMenuTiles(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ── Bottom bar ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.blue.shade900.withOpacity(0.97),
                border: Border(
                    top: BorderSide(
                        color: Colors.blue.shade700.withOpacity(0.25))),
              ),
              child: Text(
                "All Rights Reserved  |  Act T Connect Pvt. Ltd.",
                style: TextStyle(
                  color: Colors.blue.shade200.withOpacity(0.45),
                  fontSize: 11,
                  fontFamily: GoogleFonts.dmSans().fontFamily,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── APP BAR ─────────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context) {
    return SlideTransition(
      position: _headerSlide,
      child: FadeTransition(
        opacity: _headerFade,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              _GlassButton(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const MainScreen())),
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.blue.shade100, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "My Profile",
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              _GlassButton(
                onTap: () {},
                child: Icon(Icons.notifications_none_rounded,
                    color: Colors.blue.shade100, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── PROFILE OPTION CARDS ────────────────────────────────────────────────

  Widget _buildProfileCardOptions() {
    final options = [
      _ProfileOption(
        title: "Profile",
        icon: Icons.person_rounded,
        color: Colors.blue.shade400,
        onTap: () => Get.to(() => const ProfileDetails()),
      ),
      _ProfileOption(
        title: "Personal",
        icon: Icons.badge_rounded,
        color: Colors.blue.shade200,
        onTap: () => Get.to(() => const PersonalDetails()),
      ),
      _ProfileOption(
        title: "Family",
        icon: Icons.people_alt_rounded,
        color: const Color(0xFF29B6F6), // light sky blue
        onTap: () => Get.to(() => const FamilyDetails()),
      ),
    ];

    return FadeTransition(
      opacity: _headerFade,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: options.asMap().entries.map((entry) {
          return _AnimatedProfileOptionCard(
            option: entry.value,
            delay: Duration(milliseconds: 100 * entry.key),
          );
        }).toList(),
      ),
    );
  }

  // ─── AVATAR SECTION ──────────────────────────────────────────────────────

  Widget _buildAvatarSection() {
    return ScaleTransition(
      scale: _avatarScale,
      child: FadeTransition(
        opacity: _avatarFade,
        child: AnimatedBuilder(
          animation: _floating,
          builder: (_, child) => Transform.translate(
              offset: Offset(0, _floating.value), child: child),
          child: Column(
            children: [
              // Rotating shimmer ring in blue shades
              AnimatedBuilder(
                animation: _shimmer,
                builder: (_, child) {
                  return Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          Colors.blue.shade900,
                          Colors.blue.shade700,
                          Colors.blue.shade400,
                          Colors.blue.shade200,
                          Colors.blue.shade400,
                          Colors.blue.shade900,
                        ],
                        stops: const [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
                        transform:
                            GradientRotation(_shimmer.value * 2 * math.pi),
                      ),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: child,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.shade900,
                  ),
                  padding: const EdgeInsets.all(3),
                  child: CircleAvatar(
                    radius: 58,
                    backgroundColor: Colors.blue.shade800,
                    backgroundImage: NetworkImage(imageUrl),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                GlobalVariable.name,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),

              const SizedBox(height: 6),

              // Designation chip — blue.shade900 → blue.shade600
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade900, Colors.blue.shade600],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.blue.shade400.withOpacity(0.5), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade700.withOpacity(0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  GlobalVariable.designation,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.apartment_rounded,
                      color: Colors.blue.shade300.withOpacity(0.5), size: 14),
                  const SizedBox(width: 5),
                  Text(
                    "${GlobalVariable.department} Department",
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: Colors.blue.shade100.withOpacity(0.5),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── MENU TILES ──────────────────────────────────────────────────────────

  Widget _buildMenuTiles() {
    final tiles = [
      _TileData("Upload Documents", FontAwesomeIcons.upload,
          Colors.blue.shade400, () => Get.to(() => const UploadDocuments())),
      _TileData("Downloads", FontAwesomeIcons.download, Colors.blue.shade300,
          () => Get.to(() => const Downloads())),
      _TileData("Help & Support", FontAwesomeIcons.circleQuestion,
          const Color(0xFF29B6F6), () => Get.to(() => const SupportScreen())),
      _TileData(
        "Privacy Policy",
        FontAwesomeIcons.shield,
        Colors.blue.shade200,
        () async {
          try {
            await launchUrl(Uri.parse('https://pinghr.in/privacy'));
          } catch (_) {
            Get.snackbar('Error', 'Could not open privacy policy',
                snackPosition: SnackPosition.BOTTOM);
          }
        },
      ),
      _TileData(
        "Logout",
        FontAwesomeIcons.powerOff,
        const Color(0xFFEF5350), // red kept for safety/UX clarity
        () => Get.defaultDialog(
          title: "Logout?",
          middleText: "Confirm to logout or cancel.",
          onCancel: () => Navigator.pop(Get.context!),
          onConfirm: () => AuthLogin.logout(),
          confirmTextColor: Colors.white,
        ),
      ),
    ];

    return Column(
      children: tiles.asMap().entries.map((entry) {
        final i = entry.key;
        if (i >= _tileSlides.length) return const SizedBox();
        return SlideTransition(
          position: _tileSlides[i],
          child: FadeTransition(
            opacity: _tileFades[i],
            child: _AnimatedMenuTile(tile: entry.value, index: i),
          ),
        );
      }).toList(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DATA MODELS
// ═══════════════════════════════════════════════════════════════════════════

class _ProfileOption {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ProfileOption(
      {required this.title,
      required this.icon,
      required this.color,
      required this.onTap});
}

class _TileData {
  final String title;
  final dynamic icon;
  final Color color;
  final VoidCallback onTap;
  const _TileData(this.title, this.icon, this.color, this.onTap);
}

// ═══════════════════════════════════════════════════════════════════════════
// ANIMATED BACKGROUND — blue.shade900 / 700 / 400 blobs
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
            top: -80 + (_ctrl.value * 40),
            left: -60 + (_ctrl.value * 30),
            child:
                _Blob(size: 300, color: Colors.blue.shade900.withOpacity(0.60)),
          ),
          Positioned(
            top: 200 + (_ctrl.value * -30),
            right: -80,
            child:
                _Blob(size: 250, color: Colors.blue.shade700.withOpacity(0.30)),
          ),
          Positioned(
            bottom: 150 + (_ctrl.value * 20),
            left: 20,
            child:
                _Blob(size: 200, color: Colors.blue.shade400.withOpacity(0.15)),
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
        boxShadow: [BoxShadow(color: color, blurRadius: 90, spreadRadius: 20)],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// GLASS BUTTON
// ═══════════════════════════════════════════════════════════════════════════

class _GlassButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _GlassButton({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.blue.shade800.withOpacity(0.35),
          border: Border.all(color: Colors.blue.shade500.withOpacity(0.30)),
        ),
        child: Center(child: child),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ANIMATED PROFILE OPTION CARD
// ═══════════════════════════════════════════════════════════════════════════

class _AnimatedProfileOptionCard extends StatefulWidget {
  final _ProfileOption option;
  final Duration delay;
  const _AnimatedProfileOptionCard({required this.option, required this.delay});

  @override
  State<_AnimatedProfileOptionCard> createState() =>
      _AnimatedProfileOptionCardState();
}

class _AnimatedProfileOptionCardState extends State<_AnimatedProfileOptionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _scale = Tween<double>(begin: 0.6, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: FadeTransition(
        opacity: _fade,
        child: GestureDetector(
          onTap: widget.option.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.93 : 1.0,
            duration: const Duration(milliseconds: 120),
            child: Container(
              width: 100,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.shade800.withOpacity(0.50),
                    Colors.blue.shade900.withOpacity(0.30),
                  ],
                ),
                border: Border.all(
                  color: widget.option.color.withOpacity(0.45),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.option.color.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.option.color.withOpacity(0.18),
                    ),
                    child: Icon(widget.option.icon,
                        color: widget.option.color, size: 22),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.option.title,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: Colors.blue.shade50,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ANIMATED MENU TILE
// ═══════════════════════════════════════════════════════════════════════════

class _AnimatedMenuTile extends StatefulWidget {
  final _TileData tile;
  final int index;
  const _AnimatedMenuTile({required this.tile, required this.index});

  @override
  State<_AnimatedMenuTile> createState() => _AnimatedMenuTileState();
}

class _AnimatedMenuTileState extends State<_AnimatedMenuTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.tile.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 130),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            // blue.shade900 glass tile
            color: Colors.blue.shade900.withOpacity(0.35),
            border: Border.all(
              color: Colors.blue.shade700.withOpacity(0.30),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: widget.tile.color.withOpacity(0.18),
                ),
                child: Center(
                  child: FaIcon(widget.tile.icon,
                      color: widget.tile.color, size: 16),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.tile.title,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    color: Colors.blue.shade50,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.shade800.withOpacity(0.30),
                ),
                child: Center(
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: Colors.blue.shade300.withOpacity(0.55),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
