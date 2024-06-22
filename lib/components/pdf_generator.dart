import 'dart:typed_data';
import 'package:bill_maker/components/invoice_item.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfGenerator {
  static Future<Uint8List> generatePdf(InvoiceItem invoice) async {
    final pdf = pw.Document();

    // Load Hindi font (e.g., Google Noto Sans Devanagari)
    final fontData =
        await rootBundle.load("assets/fonts/NotoSansDevanagari-Regular.ttf");

    final ttf = pw.Font.ttf(fontData.buffer.asByteData());

    final fontDataBold =
        await rootBundle.load("assets/fonts/NotoSansDevanagari-Bold.ttf");

    final ttfBold = pw.Font.ttf(fontDataBold.buffer.asByteData());

    final tableHeaders = ['Sr No.', 'Item', 'Quantity', 'Rate', 'Total'];

    int srNo = 1;

    // Calculate Grand Total
    double grandTotal = 0.0;
    for (var item in invoice.items) {
      grandTotal += item.quantity * item.rate;
    }

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              invoice.title,
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            // Table section
            pw.Table(
              border: null,
              defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
              columnWidths: {
                0: pw.FixedColumnWidth(50), // Sr No. column width
                1: pw.FlexColumnWidth(), // Item column width (flexible)
                2: pw.FixedColumnWidth(60), // Quantity column width
                3: pw.FixedColumnWidth(60), // Rate column width
                4: pw.FixedColumnWidth(60), // Total column width
              },
              children: [
                // Table headers
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    border: null,
                    color: PdfColors.grey100,
                  ),
                  children: tableHeaders.map((header) {
                    return pw.Padding(
                      padding: pw.EdgeInsets.all(4),
                      child: pw.Center(
                        child: pw.Text(
                          header,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                // Table rows
                for (var item in invoice.items)
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text(
                          item.quantity == 0 && item.rate == 0.0
                              ? '=>'
                              : (srNo++).toString(),
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.normal, font: ttf),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text(
                          item.item,
                          style: item.quantity == 0 && item.rate == 0.0
                              ? pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  font: ttfBold,
                                )
                              : pw.TextStyle(
                                  fontWeight: pw.FontWeight.normal,
                                  font: ttf,
                                ),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Center(
                          child: pw.Text(
                            item.quantity == 0 && item.rate == 0.0
                                ? ''
                                : item.quantity.toString(),
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.normal),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Center(
                          child: pw.Text(
                            item.quantity == 0 && item.rate == 0.0
                                ? ''
                                : item.rate.toString(),
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.normal),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Center(
                          child: pw.Text(
                            item.quantity == 0 && item.rate == 0.0
                                ? ''
                                : (item.quantity * item.rate).toString(),
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.normal),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            pw.SizedBox(height: 40), // Space between table and grand total

            // Grand Total section
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                  'Total:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(width: 10),
                pw.Text(
                  grandTotal.toStringAsFixed(2),
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return pdf.save();
  }
}
