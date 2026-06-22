import 'package:employeeattendance/HomePage/main_screen.dart';
import 'package:employeeattendance/api_services.dart';
import 'package:employeeattendance/controllers/globalvariable.dart';
import 'package:employeeattendance/model/salary_structure_model.dart';
import 'package:flutter/material.dart';

class PayrollScreen extends StatefulWidget {
  const PayrollScreen({super.key});

  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
  final ApiService _apiService = ApiService();
  SalaryStructureResponse? _salaryData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSalaryData();
  }

  Future<void> _loadSalaryData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final empId = GlobalVariable.empID.trim();
      if (empId.isEmpty) {
        throw Exception('Employee ID is not available. Please login again.');
      }

      final salaryData = await _apiService.fetchPayrollHistory(empId);

      setState(() {
        _salaryData = salaryData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.blue.shade900,
          foregroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MainScreen()));
            },
            icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          ),
          actions: [
            IconButton(
              onPressed: _loadSalaryData,
              icon: Icon(Icons.refresh, color: Colors.white, size: 18),
            ),
          ],
          elevation: 0,
          centerTitle: true,
          title: Text('Payroll',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          bottom: TabBar(
            dividerHeight: 0,
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            tabs: [
              Tab(text: 'Payroll Structure'),
              Tab(text: 'Download Payslip'),
            ],
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(width: 2.0, color: Colors.white),
              insets: EdgeInsets.symmetric(horizontal: 20.0),
            ),
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.6),
            labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            unselectedLabelStyle: TextStyle(fontSize: 14),
            labelPadding: EdgeInsets.symmetric(horizontal: 20.0),
            indicatorPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          ),
        ),
        body: TabBarView(
          children: [
            _buildPayrollStructure(),
            _buildDownloadPayslip(),
          ],
        ),
      ),
    );
  }

  Widget _buildPayrollStructure() {
    if (_isLoading) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      color: Colors.blue.shade900,
                      strokeWidth: 2.5,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading Salary Data',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Please wait while we fetch your information...',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red.shade50, Colors.white],
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.error_outline,
                          size: 32,
                          color: Colors.red.shade700,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Oops! Something went wrong',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _error!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _loadSalaryData,
                        icon: Icon(Icons.refresh, size: 18),
                        label:
                            Text('Try Again', style: TextStyle(fontSize: 14)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade900,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_salaryData == null) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey.shade50, Colors.white],
          ),
        ),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16),
                Text(
                  'No Salary Data Available',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade50, Colors.white],
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Salary Overview Card
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade900, Colors.blue.shade700],
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Salary Overview',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              Text(
                                '${_salaryData!.month}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            'Total Salary',
                            '₹${_salaryData!.totalSalary.toInt()}',
                            Icons.currency_rupee,
                            Colors.green.shade400,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: _buildMetricCard(
                            'Payable Units',
                            '${_salaryData!.payableUnits}',
                            Icons.calendar_today,
                            Colors.orange.shade400,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: _buildMetricCard(
                            'Calendar Days',
                            '${_salaryData!.calendarDays}',
                            Icons.date_range,
                            Colors.purple.shade400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Attendance Breakdown
            _buildProfessionalSection(
              'Attendance Breakdown',
              Icons.analytics,
              [
                _buildAttendanceRow(
                    'Present Days',
                    '${_salaryData!.breakdown.present.count}',
                    Colors.green,
                    Icons.check_circle),
                _buildAttendanceRow(
                    'Absent Days',
                    '${_salaryData!.breakdown.absent.count}',
                    Colors.red,
                    Icons.cancel),
                _buildAttendanceRow(
                    'Half Day / Incomplete',
                    '${_salaryData!.breakdown.halfDays.count}',
                    Colors.orange,
                    Icons.schedule),
                _buildAttendanceRow(
                    'Weekly Off',
                    '${_salaryData!.breakdown.sundays.count}',
                    Colors.blue,
                    Icons.weekend),
                _buildAttendanceRow(
                    'Holidays',
                    '${_salaryData!.breakdown.holidays.count}',
                    Colors.teal,
                    Icons.celebration),
              ],
            ),
            SizedBox(height: 16),

            // Salary Details
            _buildProfessionalSection(
              'Salary Details',
              Icons.receipt_long,
              [
                _buildDetailRow(
                    'Employee ID', _salaryData!.employeeId, Icons.badge),
                _buildDetailRow(
                    'Month', _salaryData!.month, Icons.calendar_month),
                _buildDetailRow(
                    'Total Salary',
                    '₹${_salaryData!.totalSalary.toInt()}',
                    Icons.account_balance_wallet),
              ],
            ),
            SizedBox(height: 16),

            // Present Dates
            _buildDateSection(
              'Present Dates',
              Icons.check_circle,
              _salaryData!.breakdown.present.dates,
              Colors.green,
            ),

            // Absent Dates
            if (_salaryData!.breakdown.absent.count > 0) ...[
              SizedBox(height: 16),
              _buildDateSection(
                'Absent Dates',
                Icons.cancel,
                _salaryData!.breakdown.absent.dates,
                Colors.red,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadPayslip() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade50, Colors.white],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.download,
                      size: 40,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  SizedBox(height: 18),
                  Text(
                    'Download Payslip',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Get your monthly payslip in PDF format',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            if (_salaryData != null) ...[
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.receipt_long,
                        color: Colors.green.shade700,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Salary Month: ${_salaryData!.month}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Total Salary: ₹${_salaryData!.totalSalary.toInt()}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
            ],
            Container(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _salaryData != null
                    ? () {
                        // Implement download functionality here
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.info_outline,
                                    color: Colors.white, size: 18),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                      'Download functionality will be implemented here',
                                      style: TextStyle(fontSize: 13)),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.blue.shade900,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      }
                    : null,
                icon: Icon(Icons.download, size: 18),
                label: Text('Download PDF',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade900,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            SizedBox(height: 16),
            if (_salaryData == null && !_isLoading) ...[
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 32,
                      color: Colors.grey[600],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please load salary data first',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loadSalaryData,
                      child: Text('Load Salary Data',
                          style: TextStyle(fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[600],
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Professional UI Helper Methods
  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalSection(
      String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.blue.shade900,
                    size: 18,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceRow(
      String label, String value, Color color, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: Colors.blue.shade700, size: 18),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection(
      String title, IconData icon, List<String> dates, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 18,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${dates.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: dates
                  .map((date) => Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: color.withOpacity(0.3)),
                        ),
                        child: Text(
                          date,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: color,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> rows) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ...rows,
        ],
      ),
    );
  }

  Widget _buildRow(String label, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13)),
          Text(amount,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildColumn(String label, String amount, Color color) {
    return Flexible(
      child: Column(
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 8)),
          Text(amount,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}
