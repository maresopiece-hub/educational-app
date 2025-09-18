import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:math';

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
    final lower = path.toLowerCase();
    String fullText = '';
    if (lower.endsWith('.pdf')) {
      try {
        final bytes = await file.readAsBytes();
        final doc = PdfDocument(inputBytes: bytes);
        final extractor = PdfTextExtractor(doc);
        fullText = extractor.extractText();
        doc.dispose();
      } catch (e) {
        fullText = '';
      }
    } else {
      // For non-PDFs use a simple fallback: read file as text if possible.
      try {
        fullText = await file.readAsString();
      } catch (_) {
        fullText = '';
      }
    }

    // Heuristic: split into sections by headings (lines in ALL CAPS or starting with digits)
    final lines = fullText.split(RegExp(r'\r?\n'));
    final sections = <Map<String, dynamic>>[];
    final buffer = <String>[];
    String currentHeading = 'Introduction';

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      final isHeading = RegExp(r'^[0-9]+[\.)]?\s+').hasMatch(trimmed) || (trimmed.length < 80 && trimmed.toUpperCase() == trimmed && trimmed.length > 3);
      if (isHeading) {
        if (buffer.isNotEmpty) {
          sections.add({'heading': currentHeading, 'text': buffer.join('\n')});
          buffer.clear();
        }
        currentHeading = trimmed;
      } else {
        buffer.add(trimmed);
      }
    }
    if (buffer.isNotEmpty) {
      sections.add({'heading': currentHeading, 'text': buffer.join('\n')});
    }

    // Basic keyword coverage: pick top N keywords (words longer than 5 chars) and measure coverage
    final words = RegExp(r"[A-Za-z]{4,}").allMatches(fullText.toLowerCase()).map((m) => m.group(0)!).toList();
    final freq = <String, int>{};
    for (var w in words) {
      freq[w] = (freq[w] ?? 0) + 1;
    }
    final keywords = freq.keys.toList()..sort((a, b) => freq[b]!.compareTo(freq[a]!));
    final topKeywords = keywords.take(min(10, keywords.length)).toList();

    double completeness = 0.0;
    if (topKeywords.isNotEmpty) {
      var found = 0;
      for (var k in topKeywords) {
        if (fullText.contains(k)) {
          found++;
        }
      }
      completeness = found / topKeywords.length;
    }

    // Generate a basic plan: for each section produce a simplified explanation, one example and three questions (MCQ/short/essay)
    final generatedSections = <Map<String, dynamic>>[];
    for (var sec in sections) {
      final text = sec['text'] as String;
      final short = text.split('.').take(2).join('.').trim();
      final example = text.split('.').where((s) => s.trim().isNotEmpty).firstWhere((_) => true, orElse: () => 'Example not found');
      // Questions: MCQ placeholder, short answer, essay prompt
      final mcq = {
        'question': 'Which statement best describes ${sec['heading']}?',
        'options': ['Option A', 'Option B', 'Option C', 'Option D'],
        'answer': 'Option A',
      };
      final shortQ = {'question': 'Briefly explain ${sec['heading']}.', 'answer': short};
      final essay = {'question': 'Discuss ${sec['heading']} in detail and provide examples.', 'answer': ''};

      generatedSections.add({
        'heading': sec['heading'],
        'explanation': short,
        'example': example,
        'questions': [mcq, shortQ, essay],
      });
    }

    final score = (completeness * 100).clamp(0.0, 100.0);

    return {
      'path': path,
      'size': await file.length(),
      'sections': generatedSections,
      'keywords': topKeywords,
      'score': score,
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
