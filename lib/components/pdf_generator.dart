// ignore_for_file: deprecated_member_use, unused_local_variable

import 'dart:typed_data';
import 'package:bill_maker/components/invoice_item.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfGenerator {
  static Future<Uint8List> generatePdf(InvoiceItem invoice) async {
    final pdf = pw.Document();

    final fontData =
        await rootBundle.load("assets/fonts/NotoSansDevanagari-Regular.ttf");
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());

    final tableHeaders = ['Sr No.', 'Item', 'Quantity', 'Rate', 'Total'];

    final data = invoice.items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return [
        (index + 1).toString(),
        item.item,
        item.quantity.toString(),
        item.rate.toString(),
        (item.quantity * item.rate).toString(),
      ];
    }).toList();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              invoice.title,
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['Sr No.', 'Item', 'Quantity', 'Rate', 'Total'],
              data: invoice.items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return [
                  (index + 1).toString(),
                  pw.Text(item.item,
                      style: pw.TextStyle(font: ttf)), // Use the loaded font
                  item.quantity.toString(),
                  item.rate.toString(),
                  (item.quantity * item.rate).toString(),
                ];
              }).toList(),
              border: pw.TableBorder.all(color: PdfColors.black),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
              columnWidths: {
                0: pw.FixedColumnWidth(50),
                1: pw.FlexColumnWidth(2),
                2: pw.FixedColumnWidth(60),
                3: pw.FixedColumnWidth(60),
                4: pw.FixedColumnWidth(60),
              },
            ),
          ],
        ),
      ),
    );

    return pdf.save();
  }
}
