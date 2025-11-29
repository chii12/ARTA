import 'dart:io';

/// Simple helper to save CSV to a temporary file on non-web platforms.
Future<String> saveCsvFile(String filename, String csv) async {
  final tmpDir = Directory.systemTemp.createTempSync('arta_');
  final file = File('${tmpDir.path}${Platform.pathSeparator}$filename');
  await file.writeAsString(csv);
  return file.path;
}
