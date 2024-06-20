import 'package:flutter/material.dart';

class UserInfo extends StatelessWidget {
  const UserInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.pinkAccent),
      child: Center(
        child: Text(
          'User Info Page',
          style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
