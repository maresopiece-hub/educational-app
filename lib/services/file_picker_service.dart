import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

abstract class FilePickerService {
  /// Returns a PickedFile or null if the user cancelled.
  Future<PickedFile?> pickFile();
}

class PickedFile {
  final Uint8List bytes;
  final String name;
  PickedFile({required this.bytes, required this.name});
}

class DefaultFilePickerService implements FilePickerService {
  @override
  Future<PickedFile?> pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: true, allowedExtensions: ['pdf', 'ppt', 'pptx'], type: FileType.custom);
    if (result == null || result.files.isEmpty) return null;
    final f = result.files.first;
    if (f.bytes == null) return null;
    return PickedFile(bytes: f.bytes!, name: f.name);
  }
}
