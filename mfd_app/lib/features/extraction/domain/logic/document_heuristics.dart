import 'package:mfd_app/features/extraction/domain/entities/document.dart';

class DocumentHeuristics {
  static DocumentTag classify(String name) {
    final lowerName = name.toLowerCase();
    
    if (lowerName.contains('p&l') || 
        lowerName.contains('profit') || 
        lowerName.contains('income') || 
        lowerName.contains('statement')) {
      return DocumentTag.pnl;
    }
    
    if (lowerName.endsWith('.pptx') || 
        lowerName.contains('deck') || 
        lowerName.contains('presentation') || 
        lowerName.contains('pitch')) {
      return DocumentTag.deck;
    }

    if (lowerName.contains('bank') || lowerName.contains('balance')) {
      return DocumentTag.bankStatement;
    }

    if (lowerName.endsWith('.csv') || lowerName.endsWith('.xlsx')) {
      return DocumentTag.financialData;
    }

    return DocumentTag.other;
  }

  static DocumentType guessType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.pdf')) return DocumentType.pdf;
    if (lower.endsWith('.csv') || lower.endsWith('.xlsx') || lower.endsWith('.xls')) return DocumentType.spreadsheet;
    if (lower.endsWith('.pptx')) return DocumentType.presentation;
    if (lower.endsWith('.png') || lower.endsWith('.jpg')) return DocumentType.image;
    return DocumentType.unknown;
  }
}
