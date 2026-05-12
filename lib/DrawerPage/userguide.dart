import 'package:flutter/material.dart';

class UserGuide extends StatelessWidget {
  const UserGuide({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("UserGuide"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black54,
        elevation: 0,
      ),
    );
  }
}
