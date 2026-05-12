import 'dart:convert';
import 'dart:io';
import 'package:employeeattendance/DrawerPage/expense/show_expense.dart';
import 'package:employeeattendance/class/constants.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../controller/globalvariable.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  final itemController = TextEditingController();
  final amountController = TextEditingController();
  final dateController = TextEditingController();
  final expenseKey = GlobalKey<FormState>();
  File? image;
  String billPath = '';
  bool isLoading = false;

  submitExpenses(String date, String itemName, String amount) async {
    final url =
        '${apiUrl}expense?emp_id=${GlobalVariable.empID}&date=$date&item_name=$itemName&amount=$amount';
    setState(() {
      isLoading = true;
    });
    final response = await http.post(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['error'] == false) {
        setState(() {
          isLoading = false;
        });
        Get.off(() => ShowExpense());
        Fluttertoast.showToast(msg: 'Expense submitted');
      } else {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: 'Server error true');
      }
    } else {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
          msg: '${response.statusCode} ${response.reasonPhrase}');
    }
  }

  Future submitExpense(String date, String itemName, String amount) async {
    final request = http.MultipartRequest(
        'POST',
        Uri.parse(
            '${apiUrl}expense?emp_id=${GlobalVariable.empID}&date=$date&item_name=$itemName&amount=$amount'));
    setState(() {
      isLoading = true;
    });
    request.files.add(await http.MultipartFile.fromPath('image', billPath));

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
      });
      Get.off(() => ShowExpense());
      Fluttertoast.showToast(msg: 'Expense submitted');
    } else {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
          msg: '${response.statusCode} ${response.reasonPhrase}');
    }
  }

  pickImage() async {
    XFile? pickedImg =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImg != null) {
      image = File(pickedImg.path);
      billPath = image!.path;
      Fluttertoast.showToast(msg: 'Image uploaded');
      setState(() {});
    } else {
      Fluttertoast.showToast(msg: 'No Files selected');
    }
  }

  @override
  void dispose() {
    itemController.dispose();
    amountController.dispose();
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add your Expense', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade900,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 1,
        actions: [
          IconButton(
              onPressed: () => Get.to(() => ShowExpense()),
              icon: const Icon(Icons.receipt_long, color: Colors.white)),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: expenseKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/images/expense.png', height: 250),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: dateController,
                                validator: (value) => value!.isEmpty
                                    ? 'Date cannot be null'
                                    : null,
                                onTap: () async {
                                  final pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(DateTime.now().year),
                                      lastDate: DateTime.now());
                                  if (pickedDate != null) {
                                    String formattedDate =
                                        DateFormat('dd-MMM-yyyy')
                                            .format(pickedDate);
                                    setState(() {
                                      dateController.text = formattedDate;
                                    });
                                  }
                                },
                                readOnly: true,
                                decoration: const InputDecoration(
                                  hintText: 'Enter Date',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 3,
                              child: GestureDetector(
                                onTap: () {
                                  pickImage();
                                },
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.upload),
                                      SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          'Upload bill (Optional)',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        billPath == ''
                            ? Container()
                            : Text(
                                billPath.split('/').last,
                                textAlign: TextAlign.right,
                                style: const TextStyle(color: Colors.green),
                              ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: itemController,
                          keyboardType: TextInputType.text,
                          validator: (value) => value!.isEmpty
                              ? 'Item name cannot be null'
                              : null,
                          decoration: const InputDecoration(
                              hintText: 'Enter Item name'),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          validator: (value) => value!.isEmpty
                              ? 'Amount cannot be null or zero'
                              : null,
                          decoration: const InputDecoration(
                              hintText: 'Enter amount (in Rs.)'),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade900),
                          onPressed: () {
                            final isValid = expenseKey.currentState!.validate();
                            if (isValid) {
                              billPath == ''
                                  ? submitExpenses(
                                      dateController.text,
                                      itemController.text,
                                      amountController.text)
                                  : submitExpense(
                                      dateController.text,
                                      itemController.text,
                                      amountController.text);
                            }
                          },
                          child: const Text('Add Expense',
                              style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(height: 12.0),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Note :',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Once the expenses are approved, they will be processed for reimbursement in the next payroll cycle.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black38,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Please ensure that all expense details provided in the submission form are accurate and complete.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black38,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'By submitting expenses regularly, we can process reimbursements efficiently and without delays.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black38,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
