import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.amber),
      child: Center(
        child: Text(
          'Info Page',
          style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
