import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

Future<String> getFontsDir() async {
  final directory = await getApplicationCacheDirectory();

  final p = path.join(directory.path, "fonts");
  final s = await Directory(p).stat();
  if (s.type == FileSystemEntityType.notFound) {
    Directory(p).create();
  }
  return p;
}

Future<Directory> getCacheDir() async {
  final directory = await getApplicationCacheDirectory();
  return directory;
}

Future<Directory> getMainStoreDir() async {
  final document = await getApplicationDocumentsDirectory();
  return document;
}
Future<Directory> getTempDir() async {
  final directory = await getTemporaryDirectory();
  return directory;
}
