import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../class/constants.dart';
import '../controller/globalvariable.dart';
import '../model/showdoc_model.dart';

class ShowUploadDoc extends StatefulWidget {
  const ShowUploadDoc({super.key});

  @override
  State<ShowUploadDoc> createState() => _ShowUploadDocState();
}

class _ShowUploadDocState extends State<ShowUploadDoc> {
  RxBool isLoading = false.obs;

  Future<ShowDocModel> getUploadedDoc() async {
    final url = '${apiUrl}emp-document?emp_id=${GlobalVariable.empID}';
    try {
      final response = await http.post(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Always return the ShowDocModel, let the UI handle empty data
        return ShowDocModel.fromJson(data);
      } else {
        Fluttertoast.showToast(msg: 'Server error: ${response.statusCode}');
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'An error occurred: $e');
      throw Exception('Unable to load documents: $e');
    }
  }

  Future<String> downloadDoc(String url, String fileName) async {
    isLoading.value = true;
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/$fileName';
        final file = await File(path).create();
        await file.writeAsBytes(response.bodyBytes);
        OpenFile.open(path);
        return path;
      } else {
        throw Exception('Failed to download document. Status code: ${response.statusCode}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Download error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.blue.shade900,
        title: const Text('Uploaded Documents', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),),
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(
        () => isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : FutureBuilder<ShowDocModel>(
                future: getUploadedDoc(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(fontSize: 16, color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {}); // Refresh the FutureBuilder
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData) {
                    return emptyData();
                  } else {
                    // Check if the API returned an error or empty data
                    final showDocModel = snapshot.data!;
                    if (showDocModel.error == true || showDocModel.data == null || showDocModel.data!.isEmpty) {
                      return emptyData();
                    } else {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: showDocModel.data!.length,
                        itemBuilder: (context, index) => buildDownloadCard(snapshot, index),
                      );
                    }
                  }
                },
              ),
      ),
    );
  }

  Widget buildDownloadCard(AsyncSnapshot<ShowDocModel> snapshot, int index) {
    final item = snapshot.data!.data![index];
    return GestureDetector(
      onTap: () => downloadDoc('$imgPath/${item.storePath}', item.storePath!),
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.documentName!.toUpperCase(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                item.storePath!,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: const Text(
                  'Click to download',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget emptyData() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder_open, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            "No documents available for download.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            "Uploaded documents will appear here.",
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
