import 'package:bill_maker/components/invoice_item.dart';
import 'package:bill_maker/screens/Home.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(InvoiceItemAdapter());
  Hive.registerAdapter(ItemAdapter());
  await Hive.openBox<InvoiceItem>('invoices');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
    );
  }
}
