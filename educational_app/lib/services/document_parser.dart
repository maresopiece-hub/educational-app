import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:archive/archive_io.dart';

class DocumentParser {
  /// Extracts text from a PDF file at [path].
  Future<String> extractPdfText(String path) async {
    final file = File(path);
    final bytes = await file.readAsBytes();
    final PdfDocument doc = PdfDocument(inputBytes: bytes);
    final String text = PdfTextExtractor(doc).extractText();
    final StringBuffer buf = StringBuffer(text);
    doc.dispose();
    return buf.toString();
  }

  /// Very basic PPTX extractor: extracts text from slide XML by opening the archive
  /// and concatenating text nodes. This is a heuristic and may be improved later.
  Future<String> extractPptxText(String path) async {
    final bytes = File(path).readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);
    final buffer = StringBuffer();
    for (final file in archive) {
      if (file.isFile && file.name.startsWith('ppt/slides/')) {
        final content = String.fromCharCodes(file.content as List<int>);
        // crude: remove xml tags
        final plain = content.replaceAll(RegExp(r'<[^>]*>'), ' ');
        buffer.writeln(plain);
      }
    }
    return buffer.toString();
  }
}
