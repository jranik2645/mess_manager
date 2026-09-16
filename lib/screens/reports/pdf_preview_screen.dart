import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../models/report_model.dart';
import '../../services/pdf_service.dart';

class PdfPreviewScreen extends StatelessWidget {
  final MonthlyReportModel report;

  const PdfPreviewScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${report.monthKey} চূড়ান্ত রিপোর্ট PDF'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'PDF শেয়ার করুন',
            onPressed: () => PdfService.shareReport(report),
          ),
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'প্রিন্ট করুন',
            onPressed: () => PdfService.printReport(report),
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => PdfService.generateMonthlyReportPdf(report),
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        pdfFileName: 'Mess_Report_${report.monthKey}.pdf',
      ),
    );
  }
}
