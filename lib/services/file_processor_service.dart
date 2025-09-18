import 'dart:io';
import 'package:file_picker/file_picker.dart';

/// Service responsible for picking and processing files (PDF/PPTX).
class FileProcessorService {
  /// Launches a file picker and returns selected file paths.
  Future<List<String>?> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) return null;
    return result.paths.whereType<String>().toList();
  }

  /// Basic local parsing stub. Replace with real parsing logic using `pdfx` or similar.
  Future<Map<String, dynamic>> parseFile(String path) async {
    final file = File(path);
    // TODO: use pdfx for PDF, a PPTX parser for slides, split into sections,
    // compute keyword coverage and completeness score.
    return {
      'path': path,
      'size': await file.length(),
      'sections': [],
      'score': 0.0,
    };
  }

  /// Convenience method: pick a single file and parse it, returning a short summary.
  Future<String?> pickAndParse() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result == null || result.files.isEmpty) return null;
    final path = result.paths.firstWhere((p) => p != null, orElse: () => null);
    if (path == null) return null;
    final map = await parseFile(path);
    final size = map['size'] ?? 0;
    final sections = (map['sections'] as List).length;
    final score = map['score'] ?? 0.0;
    return 'Parsed $path — size: $size bytes, sections: $sections, score: $score';
  }
}
