import 'dart:convert';
import 'package:employeeattendance/DrawerPage/appliedleave.dart';
import 'package:employeeattendance/class/constants.dart';
import 'package:employeeattendance/controller/globalvariable.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class LeaveApplication extends StatefulWidget {
  const LeaveApplication({Key? key}) : super(key: key);

  @override
  State<LeaveApplication> createState() => _LeaveApplicationState();
}

class _LeaveApplicationState extends State<LeaveApplication> {
  bool isLoading = false;

  Future<void> applyForLeave(
      String type, String reason, String fromDate, String toDate) async {
    final url =
        '${apiUrl}leave?emp_id=${GlobalVariable.empID}&type=$type&region=$reason&start_date=$fromDate&end_date=$toDate';
    setState(() {
      isLoading = true;
    });
    var response = await http.post(Uri.parse(url));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body.toString());
      if (data['error'] == false) {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: 'Leave applied successfully');
        Get.off(() => const AppliedLeave());
      } else {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: 'Something went wrong');
      }
    } else {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
          msg: '${response.statusCode} ${response.reasonPhrase}');
    }
  }

  String selectedValue = "-----";
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();
  TextEditingController reasonController = TextEditingController();
  List<String> leaveType = [
    "-----",
    "Half Day",
    "Sick leave request",
    "Casual Leave request",
    "Maternity Leave request",
    "Compensatory Leave request",
    "Unpaid Leave request",
    "Work from Home",
  ];
  final formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    fromDateController.dispose();
    toDateController.dispose();
    reasonController.dispose();
    leaveType.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue.shade900,
        title: const Text(
          "Leave Application",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("Type of Leave"),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue.shade900),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                        ),
                        value: selectedValue,
                        items: leaveType
                            .map((item) => DropdownMenuItem<String>(
                                value: item,
                                child: Text(item,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: item == '-----'
                                          ? Colors.grey
                                          : Colors.black87,
                                    ))))
                            .toList(),
                        onChanged: ((value) => setState(() {
                              selectedValue = value!;
                            })),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle("Reason"),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: reasonController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue.shade900),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Please provide specific details...",
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle("From"),
                              const SizedBox(height: 8),
                              _buildDateField(
                                  fromDateController, context, true),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle("To"),
                              const SizedBox(height: 8),
                              _buildDateField(toDateController, context, false),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          if (reasonController.text.isNotEmpty &&
                              fromDateController.text.isNotEmpty &&
                              toDateController.text.isNotEmpty &&
                              selectedValue != "-----") {
                            applyForLeave(selectedValue, reasonController.text,
                                fromDateController.text, toDateController.text);
                            reasonController.clear();
                            fromDateController.clear();
                            toDateController.clear();
                            setState(() {
                              selectedValue = '-----';
                            });
                          } else {
                            Fluttertoast.showToast(
                                msg: 'Please fill in all details');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade900,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Submit Application",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildDateField(
      TextEditingController controller, BuildContext context, bool isFromDate) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: () async {
          DateTime initialDate = DateTime.now();

          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: initialDate,
            firstDate: isFromDate
                ? DateTime.now()
                : fromDateController.text.isNotEmpty
                    ? DateFormat("dd-MMM-yyyy").parse(fromDateController.text)
                    : DateTime.now(),
            lastDate: DateTime(2050),
            initialEntryMode: DatePickerEntryMode.calendarOnly,
            selectableDayPredicate: (DateTime date) {
              if (isFromDate && toDateController.text.isNotEmpty) {
                final toDate =
                    DateFormat("dd-MMM-yyyy").parse(toDateController.text);
                return date.isBefore(toDate) || date.isAtSameMomentAs(toDate);
              } else if (!isFromDate && fromDateController.text.isNotEmpty) {
                final fromDate =
                    DateFormat("dd-MMM-yyyy").parse(fromDateController.text);
                return date.isAfter(fromDate) ||
                    date.isAtSameMomentAs(fromDate);
              }
              return true;
            },
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: Colors.blue.shade900,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black87,
                  ),
                  dialogBackgroundColor: Colors.white,
                  datePickerTheme: DatePickerThemeData(
                    dayStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    weekdayStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade900,
                    ),
                    dayBackgroundColor:
                        MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.selected)) {
                        return Colors.blue.shade900;
                      }
                      return Colors.transparent;
                    }),
                    dayForegroundColor:
                        MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.selected)) {
                        return Colors.white;
                      }
                      if (states.contains(MaterialState.disabled)) {
                        return Colors.grey.shade400;
                      }
                      return Colors.black87;
                    }),
                    todayBackgroundColor:
                        MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.selected)) {
                        return Colors.blue.shade900;
                      }
                      return Colors.blue.shade50;
                    }),
                    todayBorder: BorderSide(
                      color: Colors.blue.shade900,
                      width: 1,
                    ),
                    headerBackgroundColor: Colors.blue.shade900,
                    headerForegroundColor: Colors.white,
                    surfaceTintColor: Colors.transparent,
                  ),
                ),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                    ),
                    child: child!,
                  ),
                ),
              );
            },
          );

          if (pickedDate != null) {
            String formattedDate = DateFormat("dd-MMM-yyyy").format(pickedDate);
            setState(() {
              controller.text = formattedDate;

              if (isFromDate && toDateController.text.isNotEmpty) {
                final toDate =
                    DateFormat("dd-MMM-yyyy").parse(toDateController.text);
                if (pickedDate.isAfter(toDate)) {
                  toDateController.clear();
                }
              } else if (!isFromDate && fromDateController.text.isNotEmpty) {
                final fromDate =
                    DateFormat("dd-MMM-yyyy").parse(fromDateController.text);
                if (pickedDate.isBefore(fromDate)) {
                  fromDateController.clear();
                }
              }
            });
          }
        },
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade900),
          ),
          filled: true,
          fillColor: Colors.white,
          hintText: "Select Date",
          hintStyle: TextStyle(color: Colors.grey[400]),
          suffixIcon:
              Icon(Icons.calendar_today, size: 20, color: Colors.blue.shade900),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
