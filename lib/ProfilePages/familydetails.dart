import 'package:employeeattendance/controller/globalvariable.dart';
import 'package:flutter/material.dart';

class FamilyDetails extends StatelessWidget {
  const FamilyDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Family Details"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black54,
        elevation: 0,
      ),
      body: Column(
        children: [
          const Divider(),
          ListTile(
            title: const Text("Home Address"),
            subtitle: Text(GlobalVariable.permanentAdd),
            leading: Icon(Icons.phone, color: Colors.greenAccent.shade700),
          ),
          const Divider(),
          // ListTile(
          //   title: const Text("Emergency Contact Number"),
          //   subtitle: Text(GlobalVariable.emergencynumber),
          //   leading:
          //       Icon(Icons.perm_identity_sharp, color: Colors.blue.shade600),
          // ),
          // const Divider(),
        ],
      ),
    );
  }
}
