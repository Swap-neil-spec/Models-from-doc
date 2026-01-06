import 'dart:typed_data';

enum DocumentType {
  pdf,
  spreadsheet, // xlsx, csv
  presentation, // pptx
  image,
  unknown
}

enum DocumentTag {
  pnl, // Profit & Loss
  deck, // Investor Deck
  bankStatement,
  financialData, // Raw CSV/Excel
  other
}

enum ProcessingStatus {
  uploading,
  analyzing,
  extracted,
  error
}

class Document {
  final String id;
  final String name;
  final int sizeBytes;
  final DocumentType type;
  final DocumentTag tag;
  final ProcessingStatus status;
  final String? path;
  final Uint8List? bytes; // New: For Web/Memory

  Document({
    required this.id,
    required this.name,
    required this.sizeBytes,
    required this.type,
    this.tag = DocumentTag.other,
    this.status = ProcessingStatus.analyzing,
    this.path,
    this.bytes,
  });

  Document copyWith({
    String? id,
    String? name,
    int? sizeBytes,
    DocumentType? type,
    DocumentTag? tag,
    ProcessingStatus? status,
    String? path,
    Uint8List? bytes,
  }) {
    return Document(
      id: id ?? this.id,
      name: name ?? this.name,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      type: type ?? this.type,
      tag: tag ?? this.tag,
      status: status ?? this.status,
      path: path ?? this.path,
      bytes: bytes ?? this.bytes,
    );
  }
}
