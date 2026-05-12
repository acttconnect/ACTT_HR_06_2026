import 'dart:convert';
import 'dart:io';
import 'package:employeeattendance/class/constants.dart';
import 'package:employeeattendance/model/download_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../controller/globalvariable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Downloads extends StatefulWidget {
  const Downloads({Key? key}) : super(key: key);

  @override
  State<Downloads> createState() => _DownloadsState();
}

class _DownloadsState extends State<Downloads> {
  RxBool isLoading = false.obs;

  Future<DownloadModel> getDownloads() async {
    final url = '${apiUrl}view-document?emp_id=${GlobalVariable.empID}';
    try {
      final response = await http.post(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['error'] == false) {
          return DownloadModel.fromJson(data);
        } else {
          Fluttertoast.showToast(msg: 'An error occurred while fetching data.');
        }
      } else {
        Fluttertoast.showToast(msg: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to load data: $e');
    }
    throw Exception('Unable to load');
  }

  Future<String> downloadDoc(String pdfUrl, String fileName) async {
    isLoading.value = true;
    try {
      final response = await http.get(Uri.parse(pdfUrl));
      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/$fileName.pdf';
        final file = await File(path).create();
        await file.writeAsBytes(response.bodyBytes);
        OpenFile.open(path);
        return path;
      } else {
        throw Exception('Failed to download document. Status code: ${response.statusCode}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Download failed: $e');
    } finally {
      isLoading.value = false;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text("Downloads", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        elevation: 1,
        backgroundColor: Colors.blue.shade900,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/Download-bro.png', height: 200),
            const SizedBox(height: 20),
            const Icon(Icons.download, size: 50, color: Colors.blue),
            const SizedBox(height: 20),
            Obx(
              () => isLoading.value
                  ? const SpinKitCircle(color: Colors.blue, size: 50.0)
                  : FutureBuilder<DownloadModel>(
                      future: getDownloads(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const SpinKitCircle(color: Colors.blue, size: 50.0);
                        } else if (snapshot.hasError) {
                          return const Text('Error loading data');
                        } else if (!snapshot.hasData || snapshot.data!.data!.isEmpty) {
                          return emptyData();
                        } else {
                          return Expanded(
                            child: ListView.builder(
                              itemCount: snapshot.data!.data!.length,
                              itemBuilder: (context, index) => buildDownloadCard(snapshot, index),
                            ),
                          );
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDownloadCard(AsyncSnapshot<DownloadModel> snapshot, int index) {
    final item = snapshot.data!.data![index];
    return GestureDetector(
      onTap: () => downloadDoc('$imgLink/${item.doc}', item.title!),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title!.toUpperCase(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(item.doc!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Click to download',
                style: TextStyle(fontSize: 14, color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget emptyData() {
    return const Center(
      child: Text(
        "No documents available for download.",
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}
