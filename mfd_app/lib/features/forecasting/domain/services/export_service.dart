import 'dart:io';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:mfd_app/features/forecasting/domain/entities/financial_model.dart';
import 'package:mfd_app/features/forecasting/domain/entities/assumption.dart';

class ExportService {
  Future<File> generateCsv(FinancialModel model) async {
    final List<List<dynamic>> rows = [];
    
    // Header
    rows.add(['Metric', ...model.monthLabels]);
    
    // Data Rows
    rows.add(['Revenue', ...model.revenue]);
    rows.add(['Opex', ...model.opex]);
    rows.add(['Gross Margin', ...model.grossMargin]);
    rows.add(['Net Burn', ...model.netBurn]);
    rows.add(['Cash Balance', ...model.cashBalance]);

    final String csvData = const ListToCsvConverter().convert(rows);
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/forecast_export.csv');
    return file.writeAsString(csvData);
  }

  Future<File> generatePdf(FinancialModel model, List<Assumption> assumptions) async {
    final doc = pw.Document();
    
    // Font setup
    final font = await PdfGoogleFonts.interRegular();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font),
        build: (pw.Context context) => [
          _buildHeader(),
          pw.SizedBox(height: 20),
          _buildSummary(model),
          pw.SizedBox(height: 20),
          _buildAssumptionsTable(assumptions),
          pw.SizedBox(height: 20),
          pw.Text('Monthly Forecast', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          _buildForecastTable(model),
        ],
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/forecast_report.pdf');
    return file.writeAsBytes(await doc.save());
  }

  pw.Widget _buildHeader() {
    return pw.Header(
      level: 0,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('ModelFromDocs Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.Text('Generated: ${DateTime.now().toString().split(' ')[0]}'),
        ],
      ),
    );
  }

  pw.Widget _buildSummary(FinancialModel model) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: pw.BorderRadius.circular(8),
        color: PdfColors.grey100,
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _summaryMetric('Runway', '${model.runwayMonths} Months', model.runwayMonths < 12 ? PdfColors.red : PdfColors.green),
          _summaryMetric('Ending Cash', '\$${model.cashBalance.last.toStringAsFixed(0)}', PdfColors.black),
        ],
      ),
    );
  }

  pw.Widget _summaryMetric(String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(label, style: const pw.TextStyle(color: PdfColors.grey700)),
        pw.Text(value, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: color)),
      ],
    );
  }

  pw.Widget _buildAssumptionsTable(List<Assumption> assumptions) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
         pw.TableRow(
           decoration: const pw.BoxDecoration(color: PdfColors.grey200),
           children: [
             pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Assumption', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
             pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Value', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
           ]
         ),
         ...assumptions.map((a) => pw.TableRow(
           children: [
             pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(a.label)),
             pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('${a.value.toStringAsFixed(1)} ${a.unit}')),
           ]
         )).toList(),
      ],
    );
  }
  
  pw.Widget _buildForecastTable(FinancialModel model) {
     // Show first 6 months for brevity in V1
     final previewMonths = 6;
     
     return pw.Table(
       border: pw.TableBorder.all(color: PdfColors.grey300),
       children: [
         // Header
         pw.TableRow(
           decoration: const pw.BoxDecoration(color: PdfColors.grey200),
           children: [
             pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Month', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
             ...model.monthLabels.take(previewMonths).map((m) => pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(m, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)))).toList(),
           ]
         ),
         // Revenue
         pw.TableRow(children: [
           pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Revenue')),
           ...model.revenue.take(previewMonths).map((v) => pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(v.toStringAsFixed(0)))).toList(),
         ]),
         // Opex
         pw.TableRow(children: [
           pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Opex')),
           ...model.opex.take(previewMonths).map((v) => pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(v.toStringAsFixed(0)))).toList(),
         ]),
         // Cash
         pw.TableRow(children: [
           pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Cash')),
           ...model.cashBalance.take(previewMonths).map((v) => pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(v.toStringAsFixed(0), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)))).toList(),
         ]),
       ]
     );
  }
}
