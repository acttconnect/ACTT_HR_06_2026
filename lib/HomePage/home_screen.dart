import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:employeeattendance/DrawerPage/about_us.dart';
import 'package:employeeattendance/DrawerPage/expense/expense.dart';
import 'package:employeeattendance/DrawerPage/expense/show_expense.dart';
import 'package:employeeattendance/DrawerPage/appliedleave.dart';
import 'package:employeeattendance/DrawerPage/learning_screen.dart';
import 'package:employeeattendance/DrawerPage/leaveapplication.dart';
import 'package:employeeattendance/DrawerPage/calender.dart';
import 'package:employeeattendance/HomePage/notification_screen.dart';
import 'package:employeeattendance/HomePage/today_screen.dart';
import 'package:employeeattendance/PayrollPage/payroll_screen.dart';
import 'package:employeeattendance/class/constants.dart';
import 'package:employeeattendance/controllers/globalvariable.dart';
import 'package:employeeattendance/controllers/location.dart';
import 'package:employeeattendance/model/birthday_model.dart';
import 'package:employeeattendance/model/events_data.dart';
import 'package:employeeattendance/model/rewardmodel.dart';
import 'package:employeeattendance/model/auth_controller.dart';
import 'package:employeeattendance/widgets/AttendanceMethodsSection/attendance_methods_section.dart';
import 'package:employeeattendance/widgets/dashboard_hero_v2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../DrawerPage/profile_screen.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  double screenHeight = 0;
  double screenWidth = 0;
  bool isLoaded = false;

  final LocationService _locationService = LocationService();
  Timer? _locationTimer;

  Future<EventsData>? _newsDataFuture;
  Future<BirthdayModel>? _birthdayDataFuture;
  Future<RewardModel>? _rewardDataFuture;

  // ── Animation controllers ────────────────────────────────────────────────
  late AnimationController _headerController;
  late AnimationController _cardsController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;

  late Animation<double> _headerOpacity;
  late Animation<Offset> _headerSlide;
  late Animation<double> _cardsFade;

  static const brandBlue = Color(0xFF1E40AF);
  static const brandLight = Color(0xFF3B82F6);

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initializeLocation();
  }

  void _initAnimations() {
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _cardsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _headerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic));

    _cardsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardsController, curve: Curves.easeOut),
    );

    _headerController.forward().then((_) => _cardsController.forward());
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _headerController.dispose();
    _cardsController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    try {
      await _locationService.initialize();
      _locationTimer = Timer.periodic(const Duration(seconds: 10), (_) {
        if (mounted) setState(() {});
      });
    } catch (_) {}
  }

  void _refreshNewsData() => setState(() {
        _newsDataFuture = _getEventsData();
      });
  void _refreshRewardData() => setState(() {
        _rewardDataFuture = _getRewardData();
      });
  void _refreshBirthdayData() => setState(() {
        _birthdayDataFuture = _getBirthdayData();
      });

  // ── BUILD ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      drawer: _buildDrawer(),
      appBar: _buildAppBar(),
      body: isLoaded ? _buildFullShimmer() : _buildBody(),
    );
  }

  // ── AppBar ───────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: brandBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'ACT HR',
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 1,
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
            gradient: LinearGradient(colors: [Color(0xFF93C5FD), brandBlue]),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => Get.to(() => const NotificationScreen()),
          icon: const Icon(Icons.notifications_outlined, size: 22),
        ),
        IconButton(
          tooltip: 'Logout',
          onPressed: () => Get.defaultDialog(
            backgroundColor: Colors.white,
            buttonColor: brandBlue,
            title: 'Logout?',
            middleText: 'Tap confirm to logout.',
            onCancel: () => Get.back(),
            onConfirm: () => AuthLogin.logout(),
            confirmTextColor: Colors.white,
          ),
          icon: const Icon(Icons.logout_rounded, size: 22),
        ),
      ],
    );
  }

  // ── Body ─────────────────────────────────────────────────────────────────
  Widget _buildBody() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
      children: [
        // Greeting header
        _buildGreetingHeader(),
        const SizedBox(height: 14),

        // Dashboard Hero
        _AnimatedSection(
          controller: _cardsController,
          delay: 0.0,
          child: const DashboardHeroV2(),
        ),
        const SizedBox(height: 16),

// Attendance Methods
        _AnimatedSection(
          controller: _cardsController,
          delay: 0.1,
          child: const AttendanceMethodsSection(),
        ),
        const SizedBox(height: 16),

        // News & Updates
        _AnimatedSection(
            controller: _cardsController,
            delay: 0.2,
            child: _buildSectionCard(
              title: 'News & Updates',
              icon: Icons.newspaper_rounded,
              child: _buildNews(),
            )),
        const SizedBox(height: 14),

        // Leave & Attendance
        _AnimatedSection(
            controller: _cardsController,
            delay: 0.3,
            child: _buildSectionCard(
              title: 'Leave & Attendance',
              icon: Icons.calendar_month_rounded,
              child: _buildLeaveSection(),
            )),
        const SizedBox(height: 14),

        // Birthdays
        _AnimatedSection(
            controller: _cardsController,
            delay: 0.4,
            child: _buildSectionCard(
              title: 'Birthdays & Anniversaries',
              icon: FontAwesomeIcons.cakeCandles,
              iconSize: 16,
              child: _buildBirthday(),
            )),
        const SizedBox(height: 14),

        // Rewards
        _AnimatedSection(
            controller: _cardsController,
            delay: 0.5,
            child: _buildSectionCard(
              title: 'Rewards & Recognition',
              icon: FontAwesomeIcons.handsClapping,
              iconSize: 16,
              child: _buildReward(),
            )),
      ],
    );
  }

  // ── Greeting ─────────────────────────────────────────────────────────────
  Widget _buildGreetingHeader() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';
    final greetIcon = hour < 12
        ? '🌤️'
        : hour < 17
            ? '☀️'
            : '🌙';

    return FadeTransition(
      opacity: _headerOpacity,
      child: SlideTransition(
        position: _headerSlide,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greetIcon $greeting,',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    GlobalVariable.name.isNotEmpty
                        ? GlobalVariable.name
                        : 'Employee',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    GlobalVariable.designation.isNotEmpty
                        ? GlobalVariable.designation
                        : '',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            // Avatar
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: brandBlue.withOpacity(0.3), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: brandBlue.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: const Color(0xFFEFF6FF),
                    child: const Icon(Icons.person, color: brandBlue),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: const Color(0xFFEFF6FF),
                    child: const Icon(Icons.person, color: brandBlue),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Punch In Card ────────────────────────────────────────────────────────
  Widget _buildPunchInCard() {
    final isCheckedIn = GlobalVariable.checkInStatus != 0;
    final isCheckedOut = GlobalVariable.checkOutStatus != 0;
    final isDone = isCheckedIn && isCheckedOut;

    final statusText = !isCheckedIn
        ? 'Check In'
        : !isCheckedOut
            ? 'Check Out'
            : 'Done';
    final statusColor = !isCheckedIn
        ? const Color(0xFF16A34A)
        : !isCheckedOut
            ? const Color(0xFFD97706)
            : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [brandBlue, brandLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: brandBlue.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Pulsing fingerprint
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, child) {
              final scale = 1.0 + (_pulseController.value * 0.08);
              return Transform.scale(scale: scale, child: child);
            },
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.fingerprint_rounded,
                size: 38,
                color: isDone ? Colors.white38 : Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${DateTime.now().day} ${_getMonthName(DateTime.now().month)} ${DateTime.now().year}',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: _getLocationStatusColor(),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        _getLocationStatusText(),
                        style: const TextStyle(
                            fontSize: 10, color: Colors.white60),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_locationService.locationStatus == 'Fetching')
                      const SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: Colors.white60,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Button
          GestureDetector(
            onTap: () {
              if (GlobalVariable.location != '') {
                Get.to(() => const TodayScreen());
              } else {
                setState(() => isLoaded = true);
                Future.delayed(const Duration(milliseconds: 200), () {
                  Get.to(() => const TodayScreen())!
                      .then((_) => setState(() => isLoaded = false));
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 11, color: statusColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick Actions ────────────────────────────────────────────────────────
  Widget _buildQuickActions() {
    final actions = [
      {
        'icon': FontAwesomeIcons.fileCirclePlus,
        'label': 'Apply\nLeave',
        'color': const Color(0xFF7C3AED),
        'route': () => Get.to(() => const LeaveApplication())
      },
      {
        'icon': FontAwesomeIcons.clockRotateLeft,
        'label': 'Leave\nHistory',
        'color': const Color(0xFF0891B2),
        'route': () => Get.to(() => const AppliedLeave())
      },
      {
        'icon': FontAwesomeIcons.calendarDay,
        'label': 'Attendance',
        'color': const Color(0xFF16A34A),
        'route': () => Get.to(() => const Calender())
      },
      {
        'icon': FontAwesomeIcons.sackDollar,
        'label': 'Payroll',
        'color': const Color(0xFFD97706),
        'route': () => Get.to(() => const PayrollScreen())
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(actions.length, (i) {
            final a = actions[i];
            return _AnimatedSection(
              controller: _cardsController,
              delay: 0.05 * i,
              child: GestureDetector(
                onTap: a['route'] as Function(),
                child: Container(
                  width: (screenWidth - 28 - 36) / 4,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: (a['color'] as Color).withOpacity(0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: (a['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          a['icon'] as IconData,
                          color: a['color'] as Color,
                          size: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        a['label'] as String,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ── Section Card wrapper ─────────────────────────────────────────────────
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    double iconSize = 18,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.withOpacity(0.1)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: brandBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: brandBlue, size: iconSize),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }

  // ── Leave Section ────────────────────────────────────────────────────────
  Widget _buildLeaveSection() {
    final buttons = [
      {
        'label': 'Apply Leave',
        'route': () => Get.to(() => const LeaveApplication())
      },
      {
        'label': 'Leave History',
        'route': () => Get.to(() => const AppliedLeave())
      },
      {'label': 'Attendance', 'route': () => Get.to(() => const Calender())},
    ];

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: brandBlue.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.calendar_month_rounded,
                color: brandBlue, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'No Leave This Month',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: buttons.map((b) {
                    return GestureDetector(
                      onTap: b['route'] as Function(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [brandBlue, brandLight],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          b['label'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── News ─────────────────────────────────────────────────────────────────
  Widget _buildNews() {
    _newsDataFuture ??= _getEventsData();
    return SizedBox(
      height: screenHeight / 5.5,
      child: FutureBuilder<EventsData>(
        future: _newsDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerRow(height: screenHeight / 5.5);
          }
          if (snapshot.hasError) {
            return _buildErrorState('Error loading news', _refreshNewsData);
          }
          if (snapshot.hasData && snapshot.data!.data!.isNotEmpty) {
            return CarouselSlider.builder(
              itemCount: snapshot.data!.data!.length,
              itemBuilder: (_, index, __) => _buildNewsCard(snapshot, index),
              options: CarouselOptions(
                height: screenHeight / 5.5,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 4),
                enlargeCenterPage: true,
                viewportFraction: 0.95,
              ),
            );
          }
          return _buildEmptyState('No news available', Icons.newspaper_rounded);
        },
      ),
    );
  }

  Widget _buildNewsCard(AsyncSnapshot<EventsData> snapshot, int index) {
    final item = snapshot.data!.data![index];
    return Container(
      margin: const EdgeInsets.fromLTRB(4, 10, 4, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [brandBlue, brandLight],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            child: const Icon(FontAwesomeIcons.newspaper,
                color: Colors.white, size: 24),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title.toString(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.des.toString(),
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF64748B), height: 1.4),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Birthday ─────────────────────────────────────────────────────────────
  Widget _buildBirthday() {
    _birthdayDataFuture ??= _getBirthdayData();
    return SizedBox(
      height: screenHeight / 6,
      child: FutureBuilder<BirthdayModel>(
        future: _birthdayDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerRow(height: screenHeight / 6);
          }
          if (snapshot.hasError) {
            return _buildErrorState(
                'Error loading birthdays', _refreshBirthdayData);
          }
          if (snapshot.hasData) {
            if (snapshot.data!.data!.isEmpty) {
              return _buildEmptyState(
                  'No Birthdays Today', FontAwesomeIcons.cakeCandles);
            }
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              itemCount: snapshot.data!.data!.length,
              itemBuilder: (_, index) => _buildBirthdayCard(snapshot, index),
            );
          }
          return _buildEmptyState('No data available', Icons.info_outline);
        },
      ),
    );
  }

  Widget _buildBirthdayCard(AsyncSnapshot<BirthdayModel> snapshot, int index) {
    final item = snapshot.data!.data![index];
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFED7AA), width: 1),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF97316), width: 2),
            ),
            child: CircleAvatar(
              radius: 26,
              backgroundImage: NetworkImage('$imgLink${item.image}'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Color(0xFF9A3412),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.dob.toString(),
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xFFC2410C)),
                ),
              ],
            ),
          ),
          const Icon(FontAwesomeIcons.cakeCandles,
              color: Color(0xFFF97316), size: 20),
        ],
      ),
    );
  }

  // ── Reward ───────────────────────────────────────────────────────────────
  Widget _buildReward() {
    _rewardDataFuture ??= _getRewardData();
    return SizedBox(
      height: screenHeight / 4.5,
      child: FutureBuilder<RewardModel>(
        future: _rewardDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerRow(height: screenHeight / 4.5);
          }
          if (snapshot.hasError) {
            return _buildErrorState(
                'Error loading rewards', _refreshRewardData);
          }
          if (snapshot.hasData) {
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              itemCount: snapshot.data!.data!.length,
              itemBuilder: (_, index) => _buildRewardCard(snapshot, index),
            );
          }
          return _buildEmptyState(
              'No rewards yet', FontAwesomeIcons.handsClapping);
        },
      ),
    );
  }

  Widget _buildRewardCard(AsyncSnapshot<RewardModel> snapshot, int index) {
    final item = snapshot.data!.data![index];
    return Container(
      width: screenWidth * 0.72,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBBF7D0), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(FontAwesomeIcons.handsClapping,
                color: Color(0xFF16A34A), size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            item.title.toString(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF14532D),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            item.des.toString(),
            style: const TextStyle(
                fontSize: 11, color: Color(0xFF166534), height: 1.4),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Shimmer Loading ──────────────────────────────────────────────────────
  Widget _buildShimmerRow({required double height}) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (_, __) {
        final shimmerValue = Tween<double>(begin: -1.5, end: 2.5)
            .animate(CurvedAnimation(
                parent: _shimmerController, curve: Curves.easeInOut))
            .value;
        return SizedBox(
          height: height,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            itemCount: 3,
            itemBuilder: (_, __) => Container(
              width: screenWidth * 0.65,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(14),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CustomPaint(
                  painter: _ShimmerPainter(progress: shimmerValue),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFullShimmer() {
    return const Center(child: CircularProgressIndicator(color: brandBlue));
  }

  // ── Error & Empty States ─────────────────────────────────────────────────
  Widget _buildErrorState(String msg, VoidCallback retry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Color(0xFFDC2626), size: 32),
          const SizedBox(height: 6),
          Text(msg,
              style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626))),
          const SizedBox(height: 8),
          TextButton(onPressed: retry, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String msg, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey.shade300, size: 32),
          const SizedBox(height: 6),
          Text(msg,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  // ── Drawer ───────────────────────────────────────────────────────────────
  Widget _buildDrawer() {
    return Drawer(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [brandBlue, Color(0xFF1E3A8A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SafeArea(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // Profile header
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white38, width: 2),
                            ),
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => const Icon(
                                    Icons.person,
                                    color: Colors.white),
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
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  GlobalVariable.email,
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.white60),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  GlobalVariable.designation,
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.white60),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Divider(
                        color: Colors.white.withOpacity(0.15),
                        height: 0,
                        indent: 16,
                        endIndent: 16),
                    const SizedBox(height: 8),

                    _drawerItem(
                        icon: FontAwesomeIcons.houseChimneyUser,
                        title: 'Home',
                        onTap: () => Navigator.pop(context)),
                    _drawerItem(
                        icon: FontAwesomeIcons.idCard,
                        title: 'Profile',
                        onTap: () => Get.to(() => const ProfileScreen())),
                    _drawerItem(
                        icon: FontAwesomeIcons.calendarDay,
                        title: 'Attendance',
                        onTap: () => Get.to(() => const Calender())),

                    // Leaves expansion
                    _drawerExpansion(
                      icon: FontAwesomeIcons.personWalkingArrowRight,
                      title: 'Leaves',
                      children: [
                        _drawerSubItem(
                            'Apply for Leave',
                            FontAwesomeIcons.fileCirclePlus,
                            () => Get.to(() => const LeaveApplication())),
                        _drawerSubItem(
                            'Leave Request History',
                            FontAwesomeIcons.clockRotateLeft,
                            () => Get.to(() => const AppliedLeave())),
                      ],
                    ),

                    // Expense expansion
                    _drawerExpansion(
                      icon: FontAwesomeIcons.sackDollar,
                      title: 'Expense',
                      children: [
                        _drawerSubItem(
                            'Add Expense',
                            FontAwesomeIcons.fileCirclePlus,
                            () => Get.to(() => const Expenses())),
                        _drawerSubItem(
                            'Expense History',
                            FontAwesomeIcons.clockRotateLeft,
                            () => Get.to(() => ShowExpense())),
                      ],
                    ),

                    _drawerItem(
                        icon: FontAwesomeIcons.moneyCheckDollar,
                        title: 'Payroll',
                        onTap: () => Get.to(() => const PayrollScreen())),
                    _drawerItem(
                        icon: FontAwesomeIcons.graduationCap,
                        title: 'Learning',
                        onTap: () => Get.to(() => LearningScreen())),
                    _drawerItem(
                        icon: FontAwesomeIcons.circleInfo,
                        title: 'About Us',
                        onTap: () => Get.to(() => const AboutUs())),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                'All rights reserved | Act T Connect Pvt. Ltd.',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.4),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70, size: 18),
      title: Text(title,
          style: const TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded,
          size: 12, color: Colors.white30),
      onTap: onTap,
      dense: true,
    );
  }

  Widget _drawerExpansion(
      {required IconData icon,
      required String title,
      required List<Widget> children}) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.white70, size: 18),
        title: Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500)),
        iconColor: Colors.white54,
        collapsedIconColor: Colors.white54,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.only(bottom: 4),
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        children: children,
      ),
    );
  }

  Widget _drawerSubItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 40),
      leading: Icon(icon, color: Colors.white38, size: 14),
      title: Text(title,
          style: const TextStyle(color: Colors.white60, fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded,
          size: 10, color: Colors.white24),
      onTap: onTap,
      dense: true,
    );
  }

  // ── API calls ─────────────────────────────────────────────────────────────
  Future<RewardModel> _getRewardData() async {
    final response = await http.post(Uri.parse('${apiUrl}rewards'));
    if (response.statusCode == 200)
      return RewardModel.fromJson(jsonDecode(response.body));
    throw Exception('Failed to load rewards');
  }

  Future<BirthdayModel> _getBirthdayData() async {
    final response = await http.post(Uri.parse('${apiUrl}dob'));
    if (response.statusCode == 200)
      return BirthdayModel.fromJson(jsonDecode(response.body));
    throw Exception('Failed to load birthdays');
  }

  Future<EventsData> _getEventsData() async {
    final urls = [
      '${apiUrl}newsevent',
      '${apiUrl}news-event',
      '${apiUrl}news',
      '${apiUrl}events'
    ];
    for (final url in urls) {
      try {
        final response = await http
            .post(Uri.parse(url), headers: {'Accept': 'application/json'});
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data is Map<String, dynamic> && data.containsKey('data')) {
            return EventsData.fromJson(data);
          }
        }
      } catch (_) {
        continue;
      }
    }
    throw Exception('Failed to load news');
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _getMonthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month];
  }

  String _getLocationStatusText() {
    switch (_locationService.locationStatus) {
      case 'Fetching':
        return 'Location: Fetching';
      case 'Permission Required':
        return 'Location: Permission Required';
      case 'Error':
        return 'Location: Error';
      default:
        return 'Location: Available';
    }
  }

  Color _getLocationStatusColor() {
    switch (_locationService.locationStatus) {
      case 'Fetching':
        return Colors.blue;
      case 'Permission Required':
        return Colors.orange;
      case 'Error':
        return Colors.red;
      default:
        return Colors.green;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Animated Section — staggered fade + slide
// ═══════════════════════════════════════════════════════════════════════════════
class _AnimatedSection extends StatelessWidget {
  final AnimationController controller;
  final double delay;
  final Widget child;

  const _AnimatedSection({
    required this.controller,
    required this.delay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final end = (delay + 0.6).clamp(0.0, 1.0);
    final opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: controller,
          curve: Interval(delay, end, curve: Curves.easeOut)),
    );
    final slide = Tween<double>(begin: 24.0, end: 0.0).animate(
      CurvedAnimation(
          parent: controller,
          curve: Interval(delay, end, curve: Curves.easeOutCubic)),
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => Opacity(
        opacity: opacity.value,
        child:
            Transform.translate(offset: Offset(0, slide.value), child: child),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Shimmer Painter
// ═══════════════════════════════════════════════════════════════════════════════
class _ShimmerPainter extends CustomPainter {
  final double progress;
  _ShimmerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final x = progress * size.width;
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withOpacity(0.0),
          Colors.white.withOpacity(0.5),
          Colors.white.withOpacity(0.0)
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(x - 80, 0, 160, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(_ShimmerPainter old) => old.progress != progress;
}
