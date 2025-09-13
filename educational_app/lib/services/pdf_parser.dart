import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class PDFParser {
  Future<String> extractText() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null && result.files.single.path != null) {
      PdfDocument document = PdfDocument(inputBytes: File(result.files.single.path!).readAsBytesSync());
      String text = '';
      for (int i = 0; i < document.pages.count; i++) {
        text += PdfTextExtractor(document).extractText(startPageIndex: i, endPageIndex: i);
      }
      document.dispose();
      return text;
    }
    return '';
  }
}
