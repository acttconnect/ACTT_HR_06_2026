import 'dart:convert';
import 'package:employeeattendance/HomePage/main_screen.dart';
import 'package:employeeattendance/class/constants.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../controller/globalvariable.dart';
import '../model/notification_model.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final smallLightText = const TextStyle(
    fontSize: 12,
    color: Colors.black45,
  );

  final xLargeLightText = const TextStyle(
    fontSize: 20,
    color: Colors.black45,
  );

  final largeText = const TextStyle(
    fontSize: 16,
    color: Colors.black,
  );

  Future<NotificationModel> getNotification() async {
    final url = '${apiUrl}show-notification?emp_id=${GlobalVariable.empID}';
    final response = await http.post(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['error'] == false) {
        return NotificationModel.fromJson(data);
      } else {
        Fluttertoast.showToast(msg: 'error true');
      }
    } else {
      Fluttertoast.showToast(msg: '${response.reasonPhrase}');
    }
    throw Exception('Unable to load data');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen(),));
          },
        ),
        backgroundColor: Colors.blue.shade900,
        title: const Text('Notification', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder<NotificationModel>(
            future: getNotification(),
            builder: (context, snapshot) => snapshot.hasData
                ? snapshot.data!.notifiication!.isEmpty
                    ? noNotification(size)
                    : AnimationLimiter(
                        child: ListView.builder(
                          itemCount: snapshot.data!.notifiication!.length,
                          itemBuilder: (context, index) {
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 375),
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: notificationCard(snapshot, size, index),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                : const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }

  Center noNotification(Size size) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_off, size: 80, color: Colors.blue),
          const SizedBox(height: 10),
          Text('No Notifications Yet', style: xLargeLightText.copyWith(color: Colors.blue.shade900)),
        ],
      ),
    );
  }

  Widget notificationCard(
      AsyncSnapshot<NotificationModel> snapshot, Size size, int index) {
    final item = snapshot.data!.notifiication!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.blue.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.notifications, color: Colors.blue.shade900, size: 30),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item[index].msg!,
                      style: largeText.copyWith(fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item[index].docList!,
                      style: smallLightText.copyWith(color: Colors.black54),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item[index].createdAt!.split(' ').first.substring(0, 10)} at ${item[index].createdAt!.split(' ').last.substring(0, 5)}',
                      style: smallLightText.copyWith(color: Colors.black54),
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
}
