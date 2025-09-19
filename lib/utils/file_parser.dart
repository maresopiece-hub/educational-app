import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:xml/xml.dart';

class FileParser {
  static Future<String> extractText(File file) async {
    final path = file.path;
    final ext = path.split('.').last.toLowerCase();
    if (!['pdf', 'ppt', 'pptx'].contains(ext)) {
      throw Exception('Unsupported file type: $ext');
    }

    try {
      if (ext == 'pdf') {
        final bytes = await file.readAsBytes();
        final doc = PdfDocument(inputBytes: bytes);
        final extractor = PdfTextExtractor(doc);
        final text = extractor.extractText();
        doc.dispose();
        return _cleanText(text);
      } else {
        final bytes = await file.readAsBytes();
        final archive = ZipDecoder().decodeBytes(bytes);
        final buffer = StringBuffer();
        for (final ent in archive) {
          if (!ent.isFile) continue;
          final name = ent.name;
          if (name.startsWith('ppt/slides/slide') && name.endsWith('.xml')) {
            try {
              final xml = XmlDocument.parse(utf8.decode(ent.content as List<int>));
              final texts = <String>[];
              for (final node in xml.findAllElements('a:t')) {
                texts.add(node.text);
              }
              for (final node in xml.findAllElements('p:t')) {
                texts.add(node.text);
              }
              buffer.writeln(texts.join('\n'));
            } catch (_) {}
          }
        }
        return _cleanText(buffer.toString());
      }
    } catch (e) {
      // swallow and return empty string; caller will handle
      return '';
    }
  }

  static String _cleanText(String s) {
    final lines = s.split(RegExp(r'\r?\n')).map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    return lines.join('\n\n');
  }
}
