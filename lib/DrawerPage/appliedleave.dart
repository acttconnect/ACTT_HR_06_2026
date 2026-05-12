import 'dart:convert';
import 'package:employeeattendance/class/constants.dart';
import 'package:employeeattendance/controller/globalvariable.dart';
import 'package:employeeattendance/model/data_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class AppliedLeave extends StatelessWidget {
  const AppliedLeave({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    Future<DataModel> getLeaveData() async {
      final url = '${apiUrl}leavedata?emp_id=${GlobalVariable.empID}';
      var response = await http.post(Uri.parse(url));
      var data = jsonDecode(response.body.toString());
      return DataModel.fromJson(data);
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Leave History",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.blue.shade900,
      ),
      body: SizedBox(
        height: screenHeight,
        width: screenWidth,
        child: FutureBuilder<DataModel>(
          future: getLeaveData(),
          builder: (context, snapshot) => snapshot.hasData
              ? snapshot.data!.employeeLeaveData!.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history_outlined, 
                            size: 64, 
                            color: Colors.grey[400]
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No leave applications yet",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: snapshot.data!.employeeLeaveData!.length,
                      itemBuilder: (context, index) =>
                          buildHistoryCard(snapshot, index))
              : const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
        ),
      ),
    );
  }

  Widget buildHistoryCard(AsyncSnapshot<DataModel> snapshot, int index) {
    TextStyle text = const TextStyle(
      fontSize: 15, 
      color: Colors.black87,
      height: 1.5,
    );
    TextStyle smallText = TextStyle(
      fontSize: 13, 
      color: Colors.grey[600],
      height: 1.5,
    );
    TextStyle headText = const TextStyle(
      fontSize: 18, 
      color: Colors.black87, 
      fontWeight: FontWeight.w600,
      height: 1.2,
    );
    String? status = snapshot.data!.employeeLeaveData![index].status;

    Color getStatusColor() {
      switch(status) {
        case "0": return Colors.orange;
        case "1": return Colors.green.shade600;
        case "2": return Colors.red.shade600;
        default: return Colors.grey;
      }
    }

    String getStatusText() {
      switch(status) {
        case "0": return "Pending";
        case "1": return "Approved";
        case "2": return "Rejected";
        default: return "Unknown";
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${snapshot.data!.employeeLeaveData![index].type}",
                  style: headText,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: getStatusColor(),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    getStatusText(),
                    style: TextStyle(
                      color: getStatusColor(),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "${snapshot.data!.employeeLeaveData![index].region}",
              style: text,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, 
                  size: 16, 
                  color: Colors.grey[600]
                ),
                const SizedBox(width: 8),
                Text(
                  "${snapshot.data!.employeeLeaveData![index].startDate}",
                  style: smallText,
                ),
                Text(" - ", style: smallText),
                Text(
                  "${snapshot.data!.employeeLeaveData![index].endDate}",
                  style: smallText,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
