import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:mfd_app/features/extraction/domain/entities/document.dart';
import 'package:mfd_app/features/extraction/domain/logic/document_heuristics.dart';
import 'package:mfd_app/features/extraction/domain/services/gemini_service.dart';
import 'package:mfd_app/features/forecasting/presentation/controllers/forecast_controller.dart';

// State definitions
enum UploadStatus { idle, analyzing, success, error }

class UploadState {
  final List<Document> files;
  final UploadStatus status;
  final String? errorMessage;

  UploadState({required this.files, this.status = UploadStatus.idle, this.errorMessage});

  UploadState copyWith({
    List<Document>? files,
    UploadStatus? status,
    String? errorMessage,
  }) {
    return UploadState(
      files: files ?? this.files,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}

final uploadControllerProvider = StateNotifierProvider<UploadController, UploadState>((ref) {
  return UploadController(ref);
});

class UploadController extends StateNotifier<UploadState> {
  final Ref _ref;
  final _uuid = const Uuid();

  UploadController(this._ref) : super(UploadState(files: []));

  Future<void> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true, // Load into memory for Web support
      type: FileType.custom,
      allowedExtensions: ['pdf', 'csv', 'xlsx', 'pptx'],
    );

    if (result != null) {
      final newDocs = result.files.map((file) {
        final docType = DocumentHeuristics.guessType(file.name);
        final tag = DocumentHeuristics.classify(file.name);
        
        return Document(
          id: _uuid.v4(),
          name: file.name,
          sizeBytes: file.size,
          type: docType,
          tag: tag,
          path: file.path, // Optional on Web
          bytes: file.bytes, // Critical for Web
          status: ProcessingStatus.uploading, // Start as uploading/idle
        );
      }).toList();

      state = state.copyWith(files: [...state.files, ...newDocs]);
    }
  }

  void removeFile(String id) {
    state = state.copyWith(
      files: state.files.where((doc) => doc.id != id).toList(),
    );
  }

  Future<bool> processDocuments() async {
    if (state.files.isEmpty) return false;

    // UI Feedback: Analyzing
    state = state.copyWith(status: UploadStatus.analyzing);

    try {
      const service = GeminiService();
      
      // Filter only valid files with content
      final docsToProcess = state.files
          .where((d) => d.bytes != null || d.path != null)
          // If bytes are null but path exists (Desktop edge case?), we might need to read it.
          // But since we used withData:true, bytes should be there.
          // If purely path based (legacy), we can't read it easily without dart:io.
          // Let's assume bytes are present.
          .where((d) {
             if (d.bytes != null) return true;
             // Use conditional check for IO if needed, but for now enforcing bytes simplify Web.
             return false;
          })
          .toList();

      if (docsToProcess.isEmpty) throw Exception('No valid file content found. Please try re-uploading.');

      final assumptions = await service.extractData(docsToProcess);
      
      // Push Data to Forecast Engine
      _ref.read(forecastControllerProvider.notifier).setAssumptions(assumptions);

      state = state.copyWith(status: UploadStatus.success);
      return true;
    } catch (e) {
      print('AI Process Error: $e');
      // Set distinct error message based on common issues
      final msg = e.toString().replaceAll('Exception: ', '');
      String errorMsg = 'Extraction Failed: $msg';
      if (e.toString().contains('No valid files')) errorMsg = 'Please upload a PDF or CSV first.';
      
      state = state.copyWith(status: UploadStatus.error, errorMessage: errorMsg);
      
      // Reset to idle after a moment so user can try again
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) state = state.copyWith(status: UploadStatus.idle, errorMessage: null);
      });
      return false;
    }
  }
}
