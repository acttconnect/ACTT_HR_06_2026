import 'dart:convert';
import 'package:employeeattendance/class/constants.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../../controller/globalvariable.dart';
import 'package:http/http.dart' as http;

class ExpenseController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<ExpenseModel> allExpense = <ExpenseModel>[].obs;
  Future<void> fetchExpense() async {
    final url = '${apiUrl}show-expense?emp_id=${GlobalVariable.empID}';
    isLoading.value = true;
    final response = await http.post(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['error'] == false) {
        isLoading.value = false;
        List<ExpenseModel> allData = (data['data'] as List)
            .map((expense) => ExpenseModel(
                date: expense['date'],
                itemName: expense['item_name'],
                amount: expense['amount'],
                image: expense['image'] ?? '',
                status: expense['expenses_status']))
            .toList();
        allExpense.value = allData;
      } else {
        Fluttertoast.showToast(msg: 'Something went wrong');
        isLoading.value = false;
      }
    } else {
      Fluttertoast.showToast(
          msg: '${response.statusCode} ${response.reasonPhrase}');
      isLoading.value = false;
    }
  }
}

class ExpenseModel {
  final String date;
  final String itemName;
  final String amount;
  final String status;
  final String? image;

  ExpenseModel(
      {required this.date,
      required this.itemName,
      required this.amount,
      required this.status,
      this.image});
}
