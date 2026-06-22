import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:employeeattendance/class/constants.dart';
import 'package:employeeattendance/controllers/location.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:slide_to_act/slide_to_act.dart';
import '../controllers/globalvariable.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({Key? key}) : super(key: key);

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen>
    with TickerProviderStateMixin {
  double screenHeight = 0;
  double screenWidth = 0;
  bool isDone = false;

  final LocationService _locationService = LocationService();
  Timer? _locationTimer;

  // ── Animation controllers ──────────────────────────────────────────────────
  late AnimationController _headerController; // top card slide-in
  late AnimationController _pulseController; // fingerprint pulse
  late AnimationController _ringController; // orbit rings
  late AnimationController _contentController; // bottom content fade
  late AnimationController _successController; // success burst
  late AnimationController _shimmerController; // shimmer on time card

  late Animation<double> _headerScale;
  late Animation<double> _headerOpacity;
  late Animation<Offset> _headerSlide;
  late Animation<double> _pulseScale;
  late Animation<double> _ring1;
  late Animation<double> _ring2;
  late Animation<double> _contentOpacity;
  late Animation<double> _contentSlide;
  late Animation<double> _successScale;
  late Animation<double> _successOpacity;
  late Animation<double> _shimmer;

  bool _showSuccess = false;
  bool _isApiLoading = false;

  static const brandBlue = Color(0xFF1E40AF);
  static const brandLight = Color(0xFF3B82F6);

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initializeLocation();
  }

  void _initAnimations() {
    // Header
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _headerScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOutBack),
    );
    _headerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _headerController,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.25),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic));

    // Pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Rings
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
    _ring1 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.linear),
    );
    _ring2 = Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.linear),
    );

    // Content
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );
    _contentSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic),
    );

    // Success burst
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _successScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );
    _successOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _successController,
          curve: const Interval(0.0, 0.4, curve: Curves.easeIn)),
    );

    // Shimmer
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _shimmer = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // Sequence
    _headerController.forward().then((_) => _contentController.forward());
  }

  Future<void> _initializeLocation() async {
    try {
      await _locationService.initialize();
      _locationTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (mounted) setState(() {});
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _headerController.dispose();
    _pulseController.dispose();
    _ringController.dispose();
    _contentController.dispose();
    _successController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  // ── API calls ────────────────────────────────────────────────────────────────
  Future<void> checkInTime(
      int id, String location, double lat, double lng) async {
    setState(() => _isApiLoading = true);
    try {
      final url =
          '${apiUrl}checkin?id=$id&location=$location&userLatitude=$lat&userLongitude=$lng';
      final response = await http.post(Uri.parse(url));
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == true) {
        setState(() {
          GlobalVariable.checkIn = data['data']['checkin'];
          GlobalVariable.checkInStatus = 1;
          isDone = true;
        });
        _triggerSuccess();
        Fluttertoast.showToast(msg: 'Check-In Successful ✓');
      } else {
        _showError(data['data'] ?? 'Check-In failed');
      }
    } catch (_) {
      _showError('Network error. Please try again.');
    } finally {
      if (mounted) setState(() => _isApiLoading = false);
    }
  }

  Future<void> checkOutTime(
      int id, String location, double lat, double lng) async {
    setState(() => _isApiLoading = true);
    try {
      final url =
          '${apiUrl}checkout?id=$id&location=$location&userLatitude=$lat&userLongitude=$lng';
      final response = await http.post(Uri.parse(url));
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == true) {
        setState(() {
          GlobalVariable.checkOut = data['data']['checkout'];
          GlobalVariable.checkOutStatus = 1;
          isDone = true;
        });
        _triggerSuccess();
        Fluttertoast.showToast(msg: 'Check-Out Successful ✓');
      } else {
        _showError(data['data'] ?? 'Check-Out failed');
      }
    } catch (_) {
      _showError('Network error. Please try again.');
    } finally {
      if (mounted) setState(() => _isApiLoading = false);
    }
  }

  void _triggerSuccess() {
    setState(() => _showSuccess = true);
    _successController.forward(from: 0).then((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _showSuccess = false);
          _successController.reset();
        }
      });
    });
  }

  void _showError(String msg) {
    Get.defaultDialog(
      backgroundColor: Colors.white,
      title: 'Error',
      titleStyle: const TextStyle(
          fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
      middleText: msg,
      middleTextStyle: const TextStyle(color: Color(0xFF64748B)),
      buttonColor: brandBlue,
      confirmTextColor: Colors.white,
      onConfirm: () => Get.back(),
    );
  }

  // ── BUILD ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    final isCheckedIn = GlobalVariable.checkInStatus != 0;
    final isCheckedOut = GlobalVariable.checkOutStatus != 0;
    final isDoneForDay = isCheckedIn && isCheckedOut;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // Background blobs
          _buildBackgroundBlobs(),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: Column(
                children: [
                  // ── Hero fingerprint card ─────────────────────────────────
                  _buildHeroCard(isCheckedIn, isCheckedOut, isDoneForDay),

                  const SizedBox(height: 18),

                  // ── Check-in / Check-out time card ────────────────────────
                  _StaggerCard(
                      controller: _contentController,
                      delay: 0.0,
                      child: _buildTimeCard()),

                  const SizedBox(height: 14),

                  // ── Live clock card ───────────────────────────────────────
                  _StaggerCard(
                      controller: _contentController,
                      delay: 0.12,
                      child: _buildClockCard()),

                  const SizedBox(height: 14),

                  // ── Slide action / Done state ─────────────────────────────
                  _StaggerCard(
                      controller: _contentController,
                      delay: 0.22,
                      child: isDoneForDay
                          ? _buildDoneCard()
                          : _buildSlideCard(isCheckedIn)),

                  const SizedBox(height: 14),

                  // ── Location card ─────────────────────────────────────────
                  _StaggerCard(
                      controller: _contentController,
                      delay: 0.32,
                      child: _buildLocationCard()),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // ── Success burst overlay ─────────────────────────────────────────
          if (_showSuccess) _buildSuccessOverlay(isCheckedIn),

          // ── API loading overlay ────────────────────────────────────────────
          if (_isApiLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: brandBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Check-In & Out',
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [brandBlue, brandLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(3),
        child: Container(
          height: 3,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF93C5FD), brandBlue],
            ),
          ),
        ),
      ),
    );
  }

  // ── Background blobs ────────────────────────────────────────────────────────
  Widget _buildBackgroundBlobs() {
    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -80,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: brandBlue.withOpacity(0.06),
            ),
          ),
        ),
        Positioned(
          bottom: -60,
          left: -60,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: brandLight.withOpacity(0.05),
            ),
          ),
        ),
      ],
    );
  }

  // ── Hero card with fingerprint ───────────────────────────────────────────────
  Widget _buildHeroCard(
      bool isCheckedIn, bool isCheckedOut, bool isDoneForDay) {
    final statusLabel = !isCheckedIn
        ? 'Ready to Check In'
        : !isCheckedOut
            ? 'Checked In — Ready to Check Out'
            : 'All Done for Today!';
    final statusColor = !isCheckedIn
        ? const Color(0xFF16A34A)
        : !isCheckedOut
            ? const Color(0xFFD97706)
            : const Color(0xFF6366F1);

    return FadeTransition(
      opacity: _headerOpacity,
      child: SlideTransition(
        position: _headerSlide,
        child: ScaleTransition(
          scale: _headerScale,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [brandBlue, brandLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: brandBlue.withOpacity(0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: statusColor.withOpacity(0.6),
                                blurRadius: 6)
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statusLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Animated fingerprint with rings
                AnimatedBuilder(
                  animation:
                      Listenable.merge([_pulseController, _ringController]),
                  builder: (_, __) {
                    return SizedBox(
                      width: 160,
                      height: 160,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Orbit ring 1
                          _buildOrbitRing(130, _ring1.value,
                              Colors.white.withOpacity(0.08)),
                          // Orbit ring 2
                          _buildOrbitRing(110, _ring2.value % 1.0,
                              Colors.white.withOpacity(0.06)),
                          // Static ring
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white24, width: 1.5),
                            ),
                          ),
                          // Pulsing fingerprint button
                          GestureDetector(
                            onTap: () {/* handled by slide */},
                            child: Transform.scale(
                              scale: isDoneForDay ? 1.0 : _pulseScale.value,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white38, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.2),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  isDoneForDay
                                      ? Icons.check_circle_outline_rounded
                                      : Icons.fingerprint_rounded,
                                  size: 44,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Date
                Text(
                  DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrbitRing(double diameter, double progress, Color color) {
    return SizedBox(
      width: diameter,
      height: diameter,
      child: CustomPaint(
        painter: _OrbitPainter(progress: progress, color: color),
      ),
    );
  }

  // ── Time card ───────────────────────────────────────────────────────────────
  Widget _buildTimeCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
              child: _buildTimeColumn(
                  'Check In', GlobalVariable.checkIn, const Color(0xFF16A34A))),
          Container(width: 1, height: 60, color: Colors.grey.withOpacity(0.15)),
          Expanded(
              child: _buildTimeColumn('Check Out', GlobalVariable.checkOut,
                  const Color(0xFFD97706))),
        ],
      ),
    );
  }

  Widget _buildTimeColumn(String label, String time, Color color) {
    final hasTime = time != '--:--' && time.isNotEmpty;
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            label == 'Check In' ? Icons.login_rounded : Icons.logout_rounded,
            color: color,
            size: 18,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          hasTime ? time : '--:--',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: hasTime ? color : const Color(0xFFCBD5E1),
          ),
        ),
      ],
    );
  }

  // ── Clock card ──────────────────────────────────────────────────────────────
  Widget _buildClockCard() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (_, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: child,
        );
      },
      child: StreamBuilder(
        stream: Stream.periodic(const Duration(seconds: 1)),
        builder: (_, __) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: brandBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.schedule_rounded,
                    color: brandBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Time',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                  Text(
                    DateFormat('hh:mm:ss a').format(DateTime.now()),
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Slide action card ────────────────────────────────────────────────────────
  Widget _buildSlideCard(bool isCheckedIn) {
    final label = isCheckedIn ? 'Slide to Check Out' : 'Slide to Check In';
    final color =
        isCheckedIn ? const Color(0xFFD97706) : const Color(0xFF16A34A);
    final bgColor =
        isCheckedIn ? const Color(0xFFFFFBEB) : const Color(0xFFF0FDF4);
    final icon = isCheckedIn ? Icons.logout_rounded : Icons.login_rounded;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCheckedIn ? 'Check Out' : 'Check In',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  Text(
                    isCheckedIn
                        ? 'Slide right to mark check-out'
                        : 'Slide right to mark check-in',
                    style:
                        const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // SlideToAct
          SlideAction(
            text: label,
            outerColor: bgColor,
            innerColor: color,
            elevation: 0,
            borderRadius: 14,
            height: 56,
            sliderButtonIconPadding: 12,
            textStyle: GoogleFonts.poppins(
              color: color.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            submittedIcon: Icon(Icons.check_rounded, color: color),
            onSubmit: () {
              if (GlobalVariable.uid == null) {
                Fluttertoast.showToast(
                    msg: 'User ID not available. Please login again.');
                return;
              }
              final id = GlobalVariable.uid!;
              if (GlobalVariable.location == '') {
                Fluttertoast.showToast(
                    msg: 'Please enable location to check-in or check-out');
                setState(() => isDone = false);
                return;
              }
              if (GlobalVariable.checkInStatus == 0) {
                checkInTime(id, GlobalVariable.location,
                    GlobalVariable.latitude, GlobalVariable.longitude);
              } else {
                checkOutTime(id, GlobalVariable.location,
                    GlobalVariable.latitude, GlobalVariable.longitude);
              }
            },
          ),
        ],
      ),
    );
  }

  // ── Done card ────────────────────────────────────────────────────────────────
  Widget _buildDoneCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4ADE80), Color(0xFF16A34A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF16A34A).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 52),
          const SizedBox(height: 12),
          Text(
            "You're All Done!",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Great work today. See you tomorrow 👋',
            style: TextStyle(fontSize: 13, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDoneStat(
                  'Check In', GlobalVariable.checkIn, Icons.login_rounded),
              const SizedBox(width: 24),
              _buildDoneStat(
                  'Check Out', GlobalVariable.checkOut, Icons.logout_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDoneStat(String label, String time, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.white60)),
        Text(
          time,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // ── Location card ────────────────────────────────────────────────────────────
  Widget _buildLocationCard() {
    final isAvailable = _locationService.isLocationAvailable;
    final statusColor =
        isAvailable ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    final statusText =
        isAvailable ? 'Location Available' : 'Location Unavailable';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.location_on_rounded,
                    color: statusColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Location',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(fontSize: 11, color: statusColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Refresh button
              GestureDetector(
                onTap: () async {
                  await _locationService.refreshLocation();
                  setState(() {});
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: brandBlue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.refresh_rounded,
                      color: brandBlue, size: 20),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(color: Colors.grey.withOpacity(0.1), height: 1),
          const SizedBox(height: 12),

          // Address
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.place_outlined, size: 15, color: Colors.grey.shade400),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _locationService.currentAddress.isNotEmpty
                      ? _locationService.currentAddress
                      : 'Fetching location...',
                  style: TextStyle(
                    fontSize: 13,
                    color: isAvailable
                        ? const Color(0xFF475569)
                        : const Color(0xFFDC2626),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),

          // Error
          if (_locationService.currentError != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    size: 13, color: Color(0xFFDC2626)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _locationService.currentError!,
                    style:
                        const TextStyle(fontSize: 11, color: Color(0xFFDC2626)),
                  ),
                ),
              ],
            ),
          ],

          // Not fetching indicator
          if (_locationService.locationStatus == 'Fetching') ...[
            const SizedBox(height: 10),
            const LinearProgressIndicator(
              backgroundColor: Color(0xFFE2E8F0),
              color: brandBlue,
              minHeight: 2,
            ),
          ],
        ],
      ),
    );
  }

  // ── Success overlay ──────────────────────────────────────────────────────────
  Widget _buildSuccessOverlay(bool isCheckedIn) {
    final color =
        isCheckedIn ? const Color(0xFF16A34A) : const Color(0xFFD97706);
    final label = isCheckedIn ? 'Checked In!' : 'Checked Out!';

    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          color: Colors.black.withOpacity(0.3),
          child: Center(
            child: AnimatedBuilder(
              animation: _successController,
              builder: (_, __) => Opacity(
                opacity: _successOpacity.value,
                child: Transform.scale(
                  scale: _successScale.value,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 40,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: color, size: 64),
                        const SizedBox(height: 8),
                        Text(
                          label,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                        Text(
                          DateFormat('hh:mm a').format(DateTime.now()),
                          style: TextStyle(
                              fontSize: 12, color: color.withOpacity(0.7)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── API loading overlay ──────────────────────────────────────────────────────
  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.2),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: brandBlue),
                const SizedBox(height: 16),
                Text(
                  GlobalVariable.checkInStatus == 0
                      ? 'Processing Check-In...'
                      : 'Processing Check-Out...',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Stagger card wrapper
// ═══════════════════════════════════════════════════════════════════════════════
class _StaggerCard extends StatelessWidget {
  final AnimationController controller;
  final double delay;
  final Widget child;

  const _StaggerCard({
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
          curve: Interval(delay, end, curve: Curves.easeOut)),
    );
    final slide = Tween<double>(begin: 25.0, end: 0.0).animate(
      CurvedAnimation(
          parent: controller,
          curve: Interval(delay, end, curve: Curves.easeOutCubic)),
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
// Orbit ring painter — rotating dashed arc
// ═══════════════════════════════════════════════════════════════════════════════
class _OrbitPainter extends CustomPainter {
  final double progress;
  final Color color;

  _OrbitPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // Draw arc sweeping with progress
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      progress * 2 * pi,
      pi * 1.2,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_OrbitPainter old) =>
      old.progress != progress || old.color != color;
}
