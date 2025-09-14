import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FileService {
  /// Pick a file (pdf or pptx) and copy it into app documents directory; returns saved path or null.
  Future<String?> pickAndSaveFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result == null || result.files.isEmpty) return null;
    final file = result.files.first;
    final bytes = file.bytes;
    final name = file.name;
    final appDir = await getApplicationDocumentsDirectory();
    final dest = File(p.join(appDir.path, 'imports', name));
    await dest.parent.create(recursive: true);
    if (bytes != null) {
      await dest.writeAsBytes(bytes, flush: true);
    } else if (file.path != null) {
      await File(file.path!).copy(dest.path);
    } else {
      return null;
    }
    return dest.path;
  }
}
