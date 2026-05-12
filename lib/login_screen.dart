// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'dart:math';
import 'package:employeeattendance/HomePage/main_screen.dart';
import 'package:employeeattendance/class/constants.dart';
import 'package:employeeattendance/model/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'controller/globalvariable.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  bool isAccepted = false;
  bool _obscurePassword = true;

  double screenHeight = 0;
  double screenWidth = 0;

  Color primary = const Color(0xFF2563EB);
  Color secondary = const Color(0xFF64748B);

  TextEditingController empIdController = TextEditingController();
  TextEditingController passController = TextEditingController();

  // ── Button loading animations ──────────────────────────────────────────────
  late AnimationController _buttonController;
  late AnimationController _shimmerController;
  late AnimationController _dotController;

  late Animation<double> _buttonWidth; // expands → shrinks to circle
  late Animation<double> _buttonOpacity;
  late Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();

    // Button squeeze animation (text → circle)
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Shimmer sweep across button before loading
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Bouncing dots
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _buttonOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _buttonController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _shimmer = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _buttonController.dispose();
    _shimmerController.dispose();
    _dotController.dispose();
    empIdController.dispose();
    passController.dispose();
    super.dispose();
  }

  // ── Login API ──────────────────────────────────────────────────────────────
  Future<void> getLogin(String empId, String password) async {
    if (_isLoading) return;

    // 1. Shimmer sweep first
    await _shimmerController.forward();

    setState(() => _isLoading = true);

    // 2. Squeeze button into loader
    await _buttonController.forward();

    try {
      final loginUri = Uri.parse('${apiUrl}login').replace(
        queryParameters: {'id': empId, 'password': password},
      );

      final response = await http.post(
        loginUri,
        headers: {'Accept': 'application/json'},
      );

      final body = response.body.trim();

      if (response.statusCode != 200) {
        Fluttertoast.showToast(
            msg: 'Server error (${response.statusCode}). Please try again.');
        return;
      }

      if (body.isEmpty ||
          body.startsWith('<!DOCTYPE html') ||
          body.startsWith('<html')) {
        Fluttertoast.showToast(
            msg: 'Server returned invalid response. Please contact admin.');
        return;
      }

      final dynamic decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        Fluttertoast.showToast(msg: 'Unexpected server response format.');
        return;
      }

      final data = decoded;
      if (data['status'] == true && data['data'] is Map<String, dynamic>) {
        final userData = data['data'] as Map<String, dynamic>;

        GlobalVariable.uid = userData['id'];
        GlobalVariable.checkInStatus = userData['checkin_status'];
        GlobalVariable.checkOutStatus = userData['checkout_status'];
        GlobalVariable.checkIn =
            userData['checkin_time']?.toString() ?? "--:--";
        GlobalVariable.checkOut =
            userData['checkout_time']?.toString() ?? "--:--";
        GlobalVariable.lastUsage = userData['last_uses']?.toString() ?? "";
        GlobalVariable.name = userData['name']?.toString() ?? "";
        GlobalVariable.designation = userData['designation']?.toString() ?? "";
        GlobalVariable.number = userData['number']?.toString() ?? "";
        GlobalVariable.email = userData['email']?.toString() ?? "";
        GlobalVariable.image = userData['image']?.toString() ?? "";
        GlobalVariable.department = userData['department']?.toString() ?? "";
        GlobalVariable.empID = userData['empid']?.toString() ?? "";
        GlobalVariable.permanentAdd =
            userData['permanent_add']?.toString() ?? "";
        final branchDetails = userData['branch_details'] as Map<String, dynamic>?;
        GlobalVariable.branch = branchDetails?['name']?.toString() ??
            userData['branch_allocated']?.toString();
        GlobalVariable.joiningDate = userData['date_of_join']?.toString();
        GlobalVariable.salary = userData['salary']?.toString();

        AuthLogin.login(empId, password);
        Fluttertoast.showToast(msg: 'Login Successful')
            .then((_) => Get.offAll(() => const MainScreen()));
      } else {
        Fluttertoast.showToast(msg: 'Invalid Employee ID or Password');
      }
    } on FormatException {
      Fluttertoast.showToast(msg: 'Invalid server response. Please try again.');
    } catch (_) {
      Fluttertoast.showToast(
          msg: 'Unable to login right now. Please try again.');
    } finally {
      if (mounted) {
        // Reverse button back to normal
        await _buttonController.reverse();
        _shimmerController.reset();
        setState(() => _isLoading = false);
      }
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    final Uri url = Uri.parse('http://pinghr.in/privacy-policy');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenHeight -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.04),

                  // Logo
                  SizedBox(
                    width: double.infinity,
                    height: screenHeight * 0.22,
                    child: Image.asset(
                      'assets/images/ACT-HR.png',
                      fit: BoxFit.cover,
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  // Welcome text
                  Text(
                    "Welcome Back",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Sign in to your account to continue",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: secondary,
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  // Employee ID
                  _buildInputField(
                    label: "Employee ID",
                    hint: "Enter your Employee ID",
                    icon: Icons.person_outline,
                    controller: empIdController,
                    keyboardType: TextInputType.text,
                  ),

                  const SizedBox(height: 16),

                  // Password
                  _buildPasswordField(),

                  const SizedBox(height: 12),

                  // Terms
                  _buildTermsBox(url),

                  const SizedBox(height: 20),

                  // ── Animated Login Button ──────────────────────────────
                  _buildAnimatedLoginButton(),

                  SizedBox(height: screenHeight * 0.05),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Animated Login Button ──────────────────────────────────────────────────
  Widget _buildAnimatedLoginButton() {
    return AnimatedBuilder(
      animation: Listenable.merge(
          [_buttonController, _shimmerController, _dotController]),
      builder: (context, _) {
        // Interpolate button width: full → square (48px)
        final double fullWidth = screenWidth - 48;
        final double targetWidth = 48.0;
        final double currentWidth = _isLoading
            ? lerpDouble(fullWidth, targetWidth, _buttonController.value)!
            : fullWidth;

        final double radius =
            _isLoading ? lerpDouble(10, 24, _buttonController.value)! : 10.0;

        return Center(
          child: AnimatedContainer(
            duration: Duration.zero,
            width: currentWidth,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.35),
                  blurRadius: _isLoading ? 18 : 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: Stack(
                children: [
                  // Base gradient fill
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primary, const Color(0xFF1D4ED8)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ),

                  // Shimmer sweep (visible before loading starts)
                  if (!_isLoading || _buttonController.value < 0.5)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _ShimmerPainter(
                          progress: _shimmer.value,
                          color: Colors.white.withOpacity(0.25),
                        ),
                      ),
                    ),

                  // Content: text OR bouncing dots
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(radius),
                        onTap: _isLoading
                            ? null
                            : () {
                                final id = empIdController.text.trim();
                                final password = passController.text.trim();
                                if (id.isEmpty) {
                                  _showErrorSnackbar(
                                      "Employee ID cannot be empty");
                                } else if (password.isEmpty) {
                                  _showErrorSnackbar(
                                      "Password cannot be empty");
                                } else if (!isAccepted) {
                                  Fluttertoast.showToast(
                                    msg:
                                        'Please accept our terms and conditions before login',
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                  );
                                } else {
                                  getLogin(id, password);
                                }
                              },
                        child: Center(
                          child: _isLoading && _buttonController.value > 0.6
                              ? _BouncingDots(
                                  controller: _dotController,
                                  color: Colors.white,
                                )
                              : Opacity(
                                  opacity: _isLoading
                                      ? (1 - _buttonController.value * 2)
                                          .clamp(0.0, 1.0)
                                      : 1.0,
                                  child: Text(
                                    "Sign In",
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Input field ────────────────────────────────────────────────────────────
  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.poppins(
                fontSize: 15, color: const Color(0xFF1E293B)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(fontSize: 15, color: secondary),
              prefixIcon: Icon(icon, color: secondary, size: 18),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  // ── Password field ─────────────────────────────────────────────────────────
  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Password",
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: passController,
            obscureText: _obscurePassword,
            style: GoogleFonts.poppins(
                fontSize: 15, color: const Color(0xFF1E293B)),
            decoration: InputDecoration(
              hintText: "Enter your Password",
              hintStyle: GoogleFonts.poppins(fontSize: 15, color: secondary),
              prefixIcon: Icon(Icons.lock_outline, color: secondary, size: 18),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: secondary,
                  size: 18,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  // ── Terms box ──────────────────────────────────────────────────────────────
  Widget _buildTermsBox(Uri url) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isAccepted
              ? primary.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform.scale(
            scale: 0.8,
            child: Checkbox(
              value: isAccepted,
              activeColor: primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              onChanged: (value) => setState(() => isAccepted = value!),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: const Color(0xFF475569)),
                    children: [
                      const TextSpan(text: 'I agree to HR Hub '),
                      WidgetSpan(
                        child: InkWell(
                          onTap: () => launchUrl(url),
                          child: Text(
                            'Terms and Conditions',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'PingHR collects location data to enable check-in and check-out functionality even when the app is closed or not in use.',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: secondary, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      "Error",
      message,
      colorText: Colors.white,
      backgroundColor: Colors.red.shade500,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
    );
  }
}

// ── Helper: linear interpolation ──────────────────────────────────────────────
double? lerpDouble(double a, double b, double t) => a + (b - a) * t;

// ── Bouncing Dots ──────────────────────────────────────────────────────────────
class _BouncingDots extends StatelessWidget {
  final AnimationController controller;
  final Color color;

  const _BouncingDots({required this.controller, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i * 0.28;
            final t = ((controller.value - delay) % 1.0).clamp(0.0, 1.0);
            final bounce = sin(t * pi);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 7,
              height: 7,
              transform: Matrix4.translationValues(0, -7 * bounce, 0),
              decoration: BoxDecoration(
                color: color.withOpacity(0.5 + bounce * 0.5),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}

// ── Shimmer Painter ────────────────────────────────────────────────────────────
class _ShimmerPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ShimmerPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress < -0.5 || progress > 1.5) return;
    final x = progress * size.width;
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.transparent, color, Colors.transparent],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(
        Rect.fromLTWH(x - 60, 0, 120, size.height),
      );
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(_ShimmerPainter old) => old.progress != progress;
}
