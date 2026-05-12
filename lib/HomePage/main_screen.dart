import 'package:employeeattendance/AttendancePage/my_attendance.dart';
import 'package:employeeattendance/DrawerPage/profile_screen.dart';
import 'package:employeeattendance/LeavePage/leave_screen.dart';
import 'package:employeeattendance/PayrollPage/payroll_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:employeeattendance/HomePage/home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 2;

  // List of widgets for each tab page (excluding the placeholder)
  final List<Widget> _pages = [
    MyAttendancePage(),
    AutoLeaveScreen(),
    HomeScreen(),
    const PayrollScreen(),
    const ProfileScreen(),
  ];

  // Method to handle bottom navigation item selection
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: SafeArea(
        child: _buildBottomNavigationBar(context), // Bottom navigation builder
      ),
    );
  }

  // Build the bottom navigation bar with Material icons
  Widget _buildBottomNavigationBar(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          showSelectedLabels: true,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          showUnselectedLabels: true,
          selectedItemColor: Colors.blue.shade900,
          unselectedItemColor: Colors.grey.shade400,
          elevation: 10,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          items: const <BottomNavigationBarItem>[
           
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(Icons.timer_outlined, size: 24), // Clean timer icon for attendance
              ),
              label: 'Attendance',
            ),
                BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(Icons.event_available_outlined, size: 24), // Calendar with checkmark for leave
              ),
              label: 'Leave',
            ),
            // Middle placeholder for FAB
            BottomNavigationBarItem(
              icon: SizedBox(height: 24),
              label: '',
            ),
        
             BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(Icons.account_balance_wallet_outlined, size: 24), // Professional wallet icon
              ),
              label: 'Payroll',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(Icons.person_outline_rounded, size: 24), // Modern person icon
              ),
              label: 'Profile',
            ),
          ],
        ),
        // Floating Action Button (Add button in the middle)
        Positioned(
          bottom: 12, // Align the FAB with the bottom of the navigation bar
          left: (MediaQuery.of(context).size.width - 56) / 2, // Center the button based on its size
          child: FloatingActionButton(
            onPressed: () {
              _onItemTapped(2); // Update the index to show HomeScreen
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50), // Fully rounded button
            ),
            elevation: 10, // Higher elevation for more depth
            backgroundColor: Colors.blue.shade900,
            child: Icon(
              Icons.dashboard_outlined, // Professional dashboard icon
              size: 28, // Larger icon for the FAB
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
