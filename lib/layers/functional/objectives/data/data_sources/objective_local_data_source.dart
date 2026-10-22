import 'dart:convert';
import 'dart:io';

class ObjectiveLocalDataSource {
  ObjectiveLocalDataSource(this._directory);

  final Future<Directory> Function() _directory;

  Future<File> get _file async => File('${(await _directory()).path}/objectives.json');

  Future<List<Map<String, dynamic>>> read() async {
    final file = await _file;
    if (!await file.exists()) return [];
    return (jsonDecode(await file.readAsString()) as List).cast<Map<String, dynamic>>();
  }

  Future<void> write(List<Map<String, dynamic>> objectives) async {
    final file = await _file;
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString(jsonEncode(objectives), flush: true);
    await temporary.rename(file.path);
  }
}
