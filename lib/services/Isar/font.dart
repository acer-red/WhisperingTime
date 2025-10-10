import 'package:isar/isar.dart';
import 'config.dart';
import 'package:whispering_time/utils/path.dart';
import 'package:path/path.dart' as path;
import 'dart:ui' as ui; // 访问 ui.loadFontFromList
import 'dart:io';
import 'package:http/http.dart' as http;

part 'font.g.dart';

@Collection()
class Font {
  Id id = Isar.autoIncrement;

  String? name = '';
  String? fullName = '';
  String? subName = '';
  String? copyRight = '';
  String? license = '';
  String? fileName = '';
  String? version = '';
  String? sha256 = '';
  String? downloadURL = '';

  Font({
    this.name,
    this.fullName,
    this.subName,
    this.copyRight,
    this.license,
    this.fileName,
    this.version,
    this.sha256,
    this.downloadURL,
  });

  Future<void> load() async {
    final fontFile = await getFilePath();
    final data = File(fontFile);
    print("加载字体文件 $name");
    await ui.loadFontFromList(await data.readAsBytes(), fontFamily: fullName);
  }

  Future<String> getFilePath() async {
    return path.join(await getFontsDir(), fileName!);
  }

  Future<bool> isExist() async {
    final fontFile = await getFilePath();
    final f = File(fontFile);
    final isFileExist = (await f.stat()).type != FileSystemEntityType.notFound;
    final d = isar.fonts.filter().sha256EqualTo(sha256);
    final isDBExist = await d.findFirst();

    if (isFileExist && isDBExist != null) {
      return true;
    }
    if (isFileExist) {
      f.delete();
    }
    if (isDBExist != null) {
      d.deleteAll();
    }

    return false;
  }

  Future<List<Font?>> getFonts() async {
    print("查找所有字体信息");
    return isar.fonts.where().findAll();
  }

  Future<bool> download() async {
    final request = await http.get(Uri.parse(downloadURL!));
    if (request.statusCode != 200) {
      print("下载字体文件失败 $name 链接: $downloadURL 状态码: ${request.statusCode}");
      return false;
    }
    final f = await getFilePath();
    print("保存字体文件 $name 路径:$f");

    await File(f).writeAsBytes(request.bodyBytes);
    return true;
  }

  Future<bool> upload() async {
    print("上传字体文件 $name");
    final isDB = await isar.fonts.filter().sha256EqualTo(sha256).findFirst();
    if (isDB != null) {
      return true;
    }
    await isar.writeTxn(() async {
      await isar.fonts.put(this);
    });

    return true;
  }
}
