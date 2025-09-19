import 'dart:io';
import '../utils/file_parser.dart';

abstract class ParserService {
  Future<String> extractTextFromBytes(List<int> bytes);
}

class DefaultParserService implements ParserService {
  @override
  Future<String> extractTextFromBytes(List<int> bytes) async {
    final dir = Directory.systemTemp;
    final tmp = File('${dir.path}/import_${DateTime.now().microsecondsSinceEpoch}');
    await tmp.writeAsBytes(bytes);
    final text = await FileParser.extractText(tmp);
    // cleanup
    try {
      await tmp.delete();
    } catch (_) {}
    return text;
  }
}
