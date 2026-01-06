import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mfd_app/features/forecasting/domain/services/export_service.dart';
import 'package:mfd_app/features/forecasting/domain/entities/financial_model.dart';
import 'package:mfd_app/features/forecasting/domain/entities/assumption.dart';
import 'dart:typed_data';

final exportControllerProvider = Provider((ref) => ExportController(ExportService()));

class ExportController {
  final ExportService _service;

  ExportController(this._service);

  Future<void> exportCsv(FinancialModel model) async {
    final file = await _service.generateCsv(model);
    await Share.shareXFiles([XFile(file.path)], text: 'Here is your Financial Forecast CSV');
  }

  Future<void> exportPdf(FinancialModel model, List<Assumption> assumptions) async {
    final file = await _service.generatePdf(model, assumptions);
    await Share.shareXFiles([XFile(file.path)], text: 'Here is your Financial Forecast PDF Report');
  }

  Future<void> exportImage(Uint8List bytes) async {
    // Save to temp file and share
    final file = XFile.fromData(bytes, name: 'investor_slide.png', mimeType: 'image/png');
    await Share.shareXFiles([file], text: 'Investor Update Slide');
  }
}
