import 'dart:convert';
import 'package:employeeattendance/DrawerPage/view_attendance.dart';
import 'package:employeeattendance/class/constants.dart';
import 'package:employeeattendance/controller/globalvariable.dart';
import 'package:employeeattendance/model/calender_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class Calender extends StatefulWidget {
  const Calender({Key? key}) : super(key: key);

  @override
  State<Calender> createState() => _CalenderState();
}

class _CalenderState extends State<Calender> {
  Future<CalenderModel> getData() async {
    if (GlobalVariable.uid == null) {
      throw Exception('User ID not available. Please login again.');
    }
    
    final url = '${apiUrl}attendance?id=${GlobalVariable.uid}';
    var response = await http.post(Uri.parse(url));
    var data = jsonDecode(response.body.toString());
    return CalenderModel.fromJson(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: const Text("Attendance", style: TextStyle(color: Colors.white)),
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
              onPressed: () => Get.to(const ViewAttendance()),
              icon: const Icon(Icons.calendar_month, color: Colors.white)),
        ],
      ),
      body: FutureBuilder<CalenderModel>(
          future: getData(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(fontSize: 16, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {}); // Retry
                      },
                      child: Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            
            return Column(
              children: [
                Expanded(
                  child: FutureBuilder<CalenderModel>(
                    future: getData(),
                    builder: ((context, snapshot) => snapshot.hasData
                        ? snapshot.data!.status == true
                            ? ListView.builder(
                                itemCount: snapshot.data!.data!.length,
                                itemBuilder: ((context, index) =>
                                    buildTile(snapshot, index)),
                              )
                            : const Center(child: Text("No data found..."))
                        : const Center(
                            child: CircularProgressIndicator(),
                          )),
                  ),
                ),
              ],
            );
          }),
    );
  }

  Card buildTile(AsyncSnapshot<CalenderModel> snapshot, int index) {
    bool isPresent = snapshot.data!.data![index].workStatus == 'Present';
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              snapshot.data!.data![index].date!,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              snapshot.data!.data![index].day!,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.login, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      snapshot.data!.data![index].checkin!,
                      style: const TextStyle(fontSize: 16, color: Colors.green),
                    ),
                  ],
                ),
                const Text("---"),
                Row(
                  children: [
                    const Icon(Icons.logout, color: Colors.red),
                    const SizedBox(width: 4),
                    Text(
                      snapshot.data!.data![index].checkout!,
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              alignment: Alignment.center,
              height: 30,
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blueAccent)),
              child: Text(
                "Working hour : ${snapshot.data!.data![index].workingHours}",
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            const Text('Check-In Location', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              snapshot.data!.data![index].checkinLocation!,
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.indigoAccent),
            ),
            const SizedBox(height: 8),
            const Text('Check-Out Location', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              snapshot.data!.data![index].checkoutLocation ?? '-----',
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.indigoAccent),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text('Status : ',
                    style: TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    )),
                Text(
                  snapshot.data!.data![index].workStatus ?? 'Not Available',
                  style: TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isPresent ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
