import 'dart:io';
import 'package:employeeattendance/ProfilePages/show_upload_doc.dart';
import 'package:employeeattendance/class/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../controller/globalvariable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class UploadDocuments extends StatefulWidget {
  const UploadDocuments({Key? key}) : super(key: key);

  @override
  State<UploadDocuments> createState() => _UploadDocumentsState();
}

class _UploadDocumentsState extends State<UploadDocuments> {
  File? image;
  final docNameController = TextEditingController();
  final fileController = TextEditingController();
  final docKey = GlobalKey<FormState>();
  RxBool isLoading = false.obs;

  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      final tempImage = File(image.path);
      setState(() {
        this.image = tempImage;
        fileController.text = tempImage.path.split('/').last;
      });
    } on PlatformException {
      rethrow;
    }
  }

  Future<void> uploadDocument(String docName, String imagePath) async {
    final url =
        '${apiUrl}uploading-file?doc_name=$docName&emp_id=${GlobalVariable.empID}';
    isLoading.value = true;
    final request = http.MultipartRequest('Post', Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath('file', imagePath));
    http.StreamedResponse response = await request.send();
    isLoading.value = false;
    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: 'Document submitted successfully');
      docNameController.clear();
      fileController.clear();
      Get.off(() => const ShowUploadDoc());
    } else {
      Fluttertoast.showToast(msg: 'Server error');
    }
  }

  @override
  void dispose() {
    docNameController.dispose();
    fileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text(
          "Upload Documents",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Get.to(() => const ShowUploadDoc()),
            icon: const Icon(Icons.file_upload, color: Colors.white),
          )
        ],
      ),
      body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Center(
                    child: Form(
                      key: docKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(
                              'assets/images/upload.jpg',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 150,
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            "Document Details",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: docNameController,
                            validator: (value) => value!.isEmpty ? 'Document name cannot be empty' : null,
                            decoration: InputDecoration(
                              hintText: 'Enter document name',
                              hintStyle: TextStyle(color: Colors.grey[600]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            "Upload Files",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: fileController,
                            readOnly: true,
                            validator: (value) => value!.isEmpty ? '* Please upload a document' : null,
                            onTap: () => pickImage(ImageSource.gallery),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.file_present, color: Colors.grey,),
                              hintText: 'Select Document/Image',
                              hintStyle: TextStyle(color: Colors.grey[600]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (docKey.currentState!.validate()) {
                                  uploadDocument(docNameController.text, image!.path);
                                }
                              },
                              icon: const Icon(Icons.upload_file, color: Colors.white,),
                              label: Text(
                                'UPLOAD',
                                style: const TextStyle(fontSize: 16, color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                backgroundColor: Colors.blue.shade900,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      );
  }
}
