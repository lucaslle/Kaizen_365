import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Hands files to the phone's own share sheet and file picker: nothing leaves the phone unless the user sends it.
class FileExchange {
  Future<void> share(String fileName, String content) async {
    final file = File('${(await getTemporaryDirectory()).path}/$fileName');
    await file.writeAsString(content, flush: true);
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path, mimeType: 'application/json')]));
  }

  /// The content of the file the user picks, or null when they cancel.
  Future<String?> pickText() async {
    final picked = await FilePicker.pickFile();
    return picked?.xFile.readAsString();
  }
}
