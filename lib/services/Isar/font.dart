import 'dart:typed_data';

import 'package:isar/isar.dart';
import 'config.dart';
import 'package:whispering_time/utils/path.dart';
import 'package:path/path.dart' as path;
import 'dart:ui' as ui; // 访问 ui.loadFontFromList
import 'dart:io';

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

  void load() async {
    final fontFile = await getFilePath();
    final data = File(fontFile);
    print("加载字体文件 $fullName");
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

  void saveFile(Uint8List data) async {
    final f = await getFilePath();
    print("保存字体文件 $fullName 路径:$f");

    await File(f).writeAsBytes(data);
    return;
  }

  Future<bool> upload() async {
    print("上传字体文件 $fullName");
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
