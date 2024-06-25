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
        await rootBundle.load('assets/fonts/NotoSansDevanagari-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

    final fontDataBold =
        await rootBundle.load("assets/fonts/NotoSansDevanagari-Bold.ttf");
    final ttfBold = pw.Font.ttf(fontDataBold.buffer.asByteData());

    final tableHeaders = ['Item', 'Size', 'Quantity', 'Rate', 'Total'];

    // Calculate Grand Total
    double grandTotal = 0.0;
    for (var item in invoice.items) {
      grandTotal += item.quantity * item.rate;
    }

    // Create a table header row
    pw.TableRow tableHeader = pw.TableRow(
      decoration: const pw.BoxDecoration(
        border: null,
        color: PdfColors.grey100,
      ),
      children: tableHeaders.asMap().entries.map((entry) {
        int index = entry.key;
        String header = entry.value;
        return pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(
            header,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
            ),
            textAlign: index == 0 ? pw.TextAlign.left : pw.TextAlign.center,
          ),
        );
      }).toList(),
    );

    // Create a list to store table rows
    List<pw.TableRow> tableRows = [tableHeader];

    // Create table rows for each item
    for (var item in invoice.items) {
      pw.TableRow tableRow = pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(
                vertical: 6, horizontal: 4.5), // Adjust vertical padding here
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
            padding: const pw.EdgeInsets.symmetric(
                vertical: 6, horizontal: 4.5), // Adjust vertical padding here
            child: pw.Center(
              child: pw.Text(
                item.quantity == 0 && item.rate == 0.0
                    ? ''
                    : item.size.toString(),
                style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
              ),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(
                vertical: 6, horizontal: 4.5), // Adjust vertical padding here
            child: pw.Center(
              child: pw.Text(
                item.quantity == 0 && item.rate == 0.0
                    ? ''
                    : item.quantity.toString(),
                style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
              ),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(
                vertical: 6, horizontal: 4.5), // Adjust vertical padding here
            child: pw.Center(
              child: pw.Text(
                item.quantity == 0 && item.rate == 0.0
                    ? ''
                    : item.rate.toString(),
                style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
              ),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(
                vertical: 6, horizontal: 4.5), // Adjust vertical padding here
            child: pw.Center(
              child: pw.Text(
                item.quantity == 0 && item.rate == 0.0
                    ? ''
                    : (item.quantity * item.rate).toStringAsFixed(2),
                style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
              ),
            ),
          ),
        ],
      );
      tableRows.add(tableRow);
    }

    // Add pages to the PDF document
    int rowsPerPage = 20;
    int totalPages = (tableRows.length / rowsPerPage).ceil();
    for (int i = 0; i < totalPages; i++) {
      // Create a page
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (i == 0)
                pw.Text(
                  invoice.title,
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
              // Table section
              pw.SizedBox(height: 60),
              pw.Table(
                border: null,
                defaultVerticalAlignment: pw.TableCellVerticalAlignment.top,
                columnWidths: {
                  0: const pw.FlexColumnWidth(), // Item column width (flexible)
                  1: const pw.FixedColumnWidth(140), // Size column width
                  2: const pw.FixedColumnWidth(60), // Quantity column width
                  3: const pw.FixedColumnWidth(60), // Rate column width
                  4: const pw.FixedColumnWidth(60), // Total column width
                },
                children: tableRows.sublist(
                    i * rowsPerPage,
                    (i + 1) * rowsPerPage > tableRows.length
                        ? tableRows.length
                        : (i + 1) * rowsPerPage),
              ),
              pw.SizedBox(height: 14),
              if (i == totalPages - 1)
                pw.Row(children: [
                  pw.Expanded(
                    child: pw.DecoratedBox(
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          bottom: pw.BorderSide(
                            color: PdfColors.black,
                            width: .5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ]), // Space between table and grand total
              pw.SizedBox(height: 30),
              if (i == totalPages - 1)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Container(
                      decoration: const pw.BoxDecoration(
                        border: pw.Border.symmetric(
                          horizontal: pw.BorderSide(
                            color: PdfColors.black,
                            width: .5,
                          ),
                        ),
                      ),
                      child: pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          "Total amount:  " + grandTotal.toStringAsFixed(2),
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
    }

    return pdf.save();
  }
}
