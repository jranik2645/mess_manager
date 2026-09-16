import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/report_model.dart';
import '../utils/formatters.dart';

class PdfService {
  /// Generate the PDF document bytes for a Monthly Final Report
  static Future<Uint8List> generateMonthlyReportPdf(MonthlyReportModel report) async {
    final pdf = pw.Document();

    final fontRegular = await PdfGoogleFonts.hindSiliguriRegular();
    final fontBold = await PdfGoogleFonts.hindSiliguriBold();

    final monthFormatted = AppFormatters.displayMonthKey(report.monthKey);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
        ),
        build: (pw.Context context) {
          return [
            // Header
            pw.Container(
              alignment: pw.Alignment.center,
              padding: const pw.EdgeInsets.only(bottom: 12),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.blue900, width: 2),
                ),
              ),
              child: pw.Column(
                children: [
                  pw.Text(
                    'MESS MANAGER FINAL REPORT',
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 20,
                      color: PdfColors.blue900,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'মাসিক চূড়ান্ত মেস হিসাব বিবরণী',
                    style: pw.TextStyle(font: fontRegular, fontSize: 13, color: PdfColors.grey700),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Month: $monthFormatted',
                        style: pw.TextStyle(font: fontBold, fontSize: 11),
                      ),
                      pw.Text(
                        'Manager: ${report.managerName.isNotEmpty ? report.managerName : "Mess Manager"}',
                        style: pw.TextStyle(font: fontBold, fontSize: 11),
                      ),
                      pw.Text(
                        'Date: ${AppFormatters.formatDate(report.generatedAt)}',
                        style: pw.TextStyle(font: fontRegular, fontSize: 10, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // Summary Section
            pw.Text(
              'মেস সারাংশ (MESS SUMMARY)',
              style: pw.TextStyle(font: fontBold, fontSize: 13, color: PdfColors.blue800),
            ),
            pw.SizedBox(height: 8),

            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              children: [
                _buildSummaryRow('মোট সদস্য (Total Members)', '${report.totalMembers} জন', fontRegular, fontBold),
                _buildSummaryRow('দিনের মিল (Day Meals)', AppFormatters.formatMeal(report.totalDayMeals), fontRegular, fontBold),
                _buildSummaryRow('রাতের মিল (Night Meals)', AppFormatters.formatMeal(report.totalNightMeals), fontRegular, fontBold),
                _buildSummaryRow('সর্বমোট মিল (Total Meals)', AppFormatters.formatMeal(report.totalMeals), fontRegular, fontBold, isHighlight: true),
                _buildSummaryRow('মোট জমা (Total Deposit)', '৳ ${report.totalDeposit.toStringAsFixed(2)}', fontRegular, fontBold),
                _buildSummaryRow('নিয়মিত বাজার খরচ (Regular Cost)', '৳ ${report.totalRegularCost.toStringAsFixed(2)}', fontRegular, fontBold),
                _buildSummaryRow('অতিরিক্ত বিল (Extra Bill)', '৳ ${report.totalExtraBill.toStringAsFixed(2)}', fontRegular, fontBold),
                _buildSummaryRow('মোট ব্যয় (Total Cost)', '৳ ${report.totalCost.toStringAsFixed(2)}', fontRegular, fontBold, isHighlight: true),
                _buildSummaryRow('মিল রেট (Meal Rate)', '৳ ${report.mealRate.toStringAsFixed(2)}', fontRegular, fontBold, isRate: true),
                _buildSummaryRow('হাতে অবশিষ্ট উদ্বৃত্ত (Remaining Balance)', '৳ ${report.remainingBalance.toStringAsFixed(2)}', fontRegular, fontBold),
              ],
            ),

            pw.SizedBox(height: 20),

            // Member-wise Breakdown Table
            pw.Text(
              'সদস্যভিত্তিক চূড়ান্ত হিসাব (MEMBER-WISE REPORT)',
              style: pw.TextStyle(font: fontBold, fontSize: 13, color: PdfColors.blue800),
            ),
            pw.SizedBox(height: 8),

            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(2.2),
                1: const pw.FlexColumnWidth(1.0),
                2: const pw.FlexColumnWidth(1.0),
                3: const pw.FlexColumnWidth(1.1),
                4: const pw.FlexColumnWidth(1.4),
                5: const pw.FlexColumnWidth(1.4),
                6: const pw.FlexColumnWidth(1.3),
                7: const pw.FlexColumnWidth(1.6),
              },
              children: [
                // Table Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.blue100),
                  children: [
                    _tableCell('Member', fontBold, isHeader: true),
                    _tableCell('Day', fontBold, isHeader: true, align: pw.TextAlign.center),
                    _tableCell('Night', fontBold, isHeader: true, align: pw.TextAlign.center),
                    _tableCell('Total', fontBold, isHeader: true, align: pw.TextAlign.center),
                    _tableCell('Deposit', fontBold, isHeader: true, align: pw.TextAlign.right),
                    _tableCell('Meal Cost', fontBold, isHeader: true, align: pw.TextAlign.right),
                    _tableCell('Extra Bill', fontBold, isHeader: true, align: pw.TextAlign.right),
                    _tableCell('Balance', fontBold, isHeader: true, align: pw.TextAlign.right),
                  ],
                ),
                // Table Rows
                ...report.memberReports.map((m) {
                  final isDue = m.balance < -0.5;
                  final isPositive = m.balance > 0.5;
                  final balanceColor = isDue
                      ? PdfColors.red700
                      : (isPositive ? PdfColors.green800 : PdfColors.grey800);

                  return pw.TableRow(
                    children: [
                      _tableCell(m.memberName, fontRegular),
                      _tableCell(AppFormatters.formatMeal(m.dayMeal), fontRegular, align: pw.TextAlign.center),
                      _tableCell(AppFormatters.formatMeal(m.nightMeal), fontRegular, align: pw.TextAlign.center),
                      _tableCell(AppFormatters.formatMeal(m.totalMeal), fontBold, align: pw.TextAlign.center),
                      _tableCell(m.deposit.toStringAsFixed(0), fontRegular, align: pw.TextAlign.right),
                      _tableCell(m.mealCost.toStringAsFixed(1), fontRegular, align: pw.TextAlign.right),
                      _tableCell(m.extraBill.toStringAsFixed(1), fontRegular, align: pw.TextAlign.right),
                      _tableCell(
                        m.balance.toStringAsFixed(1),
                        fontBold,
                        align: pw.TextAlign.right,
                        textColor: balanceColor,
                      ),
                    ],
                  );
                }),
              ],
            ),

            pw.SizedBox(height: 24),

            // Signatures
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  children: [
                    pw.Container(width: 120, decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: PdfColors.grey700)))),
                    pw.SizedBox(height: 4),
                    pw.Text('ম্যানেজারের স্বাক্ষর', style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Container(width: 120, decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: PdfColors.grey700)))),
                    pw.SizedBox(height: 4),
                    pw.Text('মেম্বারদের পক্ষ থেকে স্বাক্ষর', style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.TableRow _buildSummaryRow(
    String label,
    String value,
    pw.Font fontRegular,
    pw.Font fontBold, {
    bool isHighlight = false,
    bool isRate = false,
  }) {
    return pw.TableRow(
      decoration: isRate
          ? const pw.BoxDecoration(color: PdfColors.amber50)
          : (isHighlight ? const pw.BoxDecoration(color: PdfColors.grey100) : null),
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: pw.Text(
            label,
            style: pw.TextStyle(font: isHighlight || isRate ? fontBold : fontRegular, fontSize: 10.5),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: pw.Text(
            value,
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(
              font: fontBold,
              fontSize: isRate ? 12 : 10.5,
              color: isRate ? PdfColors.blue900 : PdfColors.black,
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _tableCell(
    String text,
    pw.Font font, {
    bool isHeader = false,
    pw.TextAlign align = pw.TextAlign.left,
    PdfColor textColor = PdfColors.black,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          font: font,
          fontSize: isHeader ? 10 : 9.5,
          color: isHeader ? PdfColors.blue900 : textColor,
        ),
      ),
    );
  }

  /// Print or Share Report directly
  static Future<void> printReport(MonthlyReportModel report) async {
    final pdfBytes = await generateMonthlyReportPdf(report);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Mess_Report_${report.monthKey}.pdf',
    );
  }

  /// Share PDF via System Sheet
  static Future<void> shareReport(MonthlyReportModel report) async {
    final pdfBytes = await generateMonthlyReportPdf(report);
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'Mess_Report_${report.monthKey}.pdf',
    );
  }
}

