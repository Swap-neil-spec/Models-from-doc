import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:mfd_app/features/forecasting/domain/entities/actuals_series.dart';

class CsvParsingService {
  
  /// Parses a financial CSV and returns valid ActualsSeries data points.
  Future<List<ActualsSeries>> parseFinancialCsv(List<int> bytes, {String defaultMetric = 'revenue', String filename = 'csv_upload'}) async {
    try {
      final content = utf8.decode(bytes);
      final fields = const CsvToListConverter().convert(content); // Use synchronous convert for simpler flow? Or stream?
      // Stream is better for large files, but bytes are already in memory here.
      // convert is fine.

      if (fields.isEmpty) return [];

      // 1. Identify Headers
      final headers = fields.first.map((e) => e.toString().toLowerCase().trim()).toList();
      
      int dateIdx = -1;
      int amountIdx = -1;

      // Smart Header Search
      final dateKeywords = ['date', 'created', 'time', 'timestamp'];
      final amountKeywords = ['amount', 'net', 'total', 'price', 'value', 'net amount'];

      for (int i = 0; i < headers.length; i++) {
        final h = headers[i];
        if (dateIdx == -1 && dateKeywords.any((k) => h.contains(k))) dateIdx = i;
        if (amountIdx == -1 && amountKeywords.any((k) => h == k || h.contains(k))) amountIdx = i;
      }

      if (dateIdx == -1 || amountIdx == -1) {
        throw FormatException('Could not identify Date or Amount columns. Headers: $headers');
      }

      final List<ActualsSeries> seriesList = [];
      
      // 2. Parse Rows
      for (int i = 1; i < fields.length; i++) {
        final row = fields[i];
        if (row.length <= dateIdx || row.length <= amountIdx) continue;

        try {
          // Parse Date
          final dateStr = row[dateIdx].toString();
          final date = _parseDate(dateStr);
          if (date == null) continue;

          // Parse Amount
          double amount = 0.0;
          final amountRaw = row[amountIdx];
          if (amountRaw is num) {
            amount = amountRaw.toDouble();
          } else {
             amount = double.tryParse(amountRaw.toString().replaceAll(RegExp(r'[^0-9.-]'), '')) ?? 0.0;
          }

          seriesList.add(ActualsSeries(
            date: date,
            metric: defaultMetric,
            value: amount,
            source: filename, 
          ));
          
        } catch (e) {
          // Skip malformed row
          // print('Skipping row $i: $e');
        }
      }
      
      return seriesList;

    } catch (e) {
      print('CSV Parse Error: $e');
      return [];
    }
  }

  DateTime? _parseDate(String dateStr) {
    if (dateStr.isEmpty) return null;
    
    // Attempt standard formats
    // Use trim to avoid whitespace issues
    final cleanStr = dateStr.trim();
    
    // Use DateTime.tryParse first (ISO 8601)
    final d = DateTime.tryParse(cleanStr);
    if (d != null) return d;
    
    // Unix Timestamp check (integer)
    if (RegExp(r'^\d{10}$').hasMatch(cleanStr)) {
        return DateTime.fromMillisecondsSinceEpoch(int.parse(cleanStr) * 1000);
    }

    final formats = [
      'yyyy-MM-dd HH:mm:ss',
      'yyyy-MM-dd',
      'MM/dd/yyyy',
      'dd/MM/yyyy',
      'MM-dd-yyyy',
    ];

    for (var fmt in formats) {
      try {
        return DateFormat(fmt).parse(cleanStr);
      } catch (_) {}
    }
    return null;
  }
}
