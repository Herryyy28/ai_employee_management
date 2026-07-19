import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

class ExportHelper {
  ExportHelper._();

  // 1. Generate Payslip PDF and invoke Print/Share preview sheet
  static Future<void> generatePayrollPdf({
    required String employeeName,
    required String monthYear,
    required double baseSalary,
    required double allowances,
    required double deductions,
  }) async {
    final pdf = pw.Document();
    final netSalary = baseSalary + allowances - deductions;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'AI-EMS WORKSPACE PORTAL',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
                ),
                pw.SizedBox(height: 8),
                pw.Divider(thickness: 2),
                pw.SizedBox(height: 24),
                pw.Text('OFFICIAL SALARY SLIP', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                pw.Text('Period: $monthYear', style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey600)),
                pw.SizedBox(height: 32),
                
                // Employee details
                pw.Text('Employee Name: $employeeName', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 24),

                // Table grid of financials
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Financial Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Amount (USD)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Base Salary')),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('\$${baseSalary.toStringAsFixed(2)}')),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Allowances')),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('\$${allowances.toStringAsFixed(2)}')),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Deductions')),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('-\$${deductions.toStringAsFixed(2)}')),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 40),
                pw.Divider(),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('NET DISBURSED SALARY:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.Text('\$${netSalary.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.green700)),
                  ],
                ),
                pw.SizedBox(height: 80),
                pw.Center(
                  child: pw.Text('This is a system-generated statement and requires no physical signature.', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500)),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Render print layout dialog
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  // 2. Generate Excel spreadsheets and save to downloads directory
  static Future<String> generateAttendanceExcel(List<Map<String, dynamic>> logs) async {
    final excel = Excel.createExcel();
    final Sheet sheetObject = excel['Attendance Report'];
    excel.setDefaultSheet('Attendance Report');

    // Add headers
    sheetObject.appendRow([
      TextCellValue('Date'),
      TextCellValue('Employee Email'),
      TextCellValue('Clock In'),
      TextCellValue('Clock Out'),
      TextCellValue('Status'),
    ]);

    // Add rows
    for (var log in logs) {
      sheetObject.appendRow([
        TextCellValue(log['date']?.toString() ?? ''),
        TextCellValue(log['email']?.toString() ?? ''),
        TextCellValue(log['clock_in']?.toString() ?? ''),
        TextCellValue(log['clock_out']?.toString() ?? 'N/A'),
        TextCellValue(log['status']?.toString().toUpperCase() ?? ''),
      ]);
    }

    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/Attendance_Report_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final file = File(path);
    
    final bytes = excel.save();
    if (bytes != null) {
      await file.writeAsBytes(bytes);
    }
    
    return path;
  }
}
