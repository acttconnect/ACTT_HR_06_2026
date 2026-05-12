import 'package:employeeattendance/controller/globalvariable.dart';
import 'package:flutter/material.dart';

class PersonalDetails extends StatelessWidget {
  const PersonalDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Personal Details"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black54,
        elevation: 0,
      ),
      body: Column(
        children: [
          const Divider(),
          ListTile(
            title: const Text("Contact Number"),
            subtitle: Text(GlobalVariable.number),
            leading: Icon(Icons.phone, color: Colors.greenAccent.shade700),
          ),
          const Divider(),
          ListTile(
            title: const Text("Employee ID"),
            subtitle: Text(GlobalVariable.empID),
            leading:
                Icon(Icons.perm_identity_sharp, color: Colors.blue.shade600),
          ),
        ],
      ),
    );
  }
}
