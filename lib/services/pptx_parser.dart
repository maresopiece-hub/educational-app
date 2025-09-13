import 'dart:io';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import 'package:file_picker/file_picker.dart';

class PPTXParser {
  Future<String> extractText() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pptx']);
    if (result != null && result.files.single.path != null) {
      final bytes = File(result.files.single.path!).readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);
      String allText = '';
      for (final file in archive) {
        if (file.name.startsWith('ppt/slides/slide') && file.name.endsWith('.xml')) {
          final xmlContent = String.fromCharCodes(file.content as List<int>);
          final document = XmlDocument.parse(xmlContent);
          final textElements = document.findAllElements('a:t', namespace: '*');
          for (final elem in textElements) {
            allText += '${elem.innerText} ';
          }
        }
      }
      return allText.trim();
    }
    return '';
  }
}
