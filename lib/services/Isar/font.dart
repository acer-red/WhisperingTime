import 'package:isar/isar.dart';
import 'env.dart';
import 'package:whispering_time/services/Isar/font.dart';
import 'package:whispering_time/utils/path.dart';
import 'package:whispering_time/utils/env.dart';
import 'package:path/path.dart' as path;
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

  Future<bool> isExistFont(String filename, String sha256) async {
    final d = await getFontsDir();
    String f = path.join(d, fileName);

    final isFile = await File(f).exists();
    final isDB = await isar.fonts.filter().sha256EqualTo(sha256).findFirst();

    if (isFile) {
      // 文件存在，数据库存在
      if (isDB != null) {
        return true;
      }
      // 文件存在，数据库不存在
      await File(f).delete();
      return false;
    } else {
      // 文件不存在，但是数据库存在
      if (isDB != null) {
        return await isar.writeTxn(() async {
          return await isar.fonts.delete(isDB.id);
        });
      }
      return false;
    }
  }

  Future<LastState> uploadFont(List<int> data) async {
    final existingFont =
        await isar.fonts.filter().sha256EqualTo(sha256).findFirst();

    if (existingFont != null) {
      return LastState.exist;
    }

    final d = await getFontsDir();
    String f = path.join(d, fileName);
    File file = File(f);

    try {
      await file.writeAsBytes(data);
    } catch (e) {
      log.e(e.toString());
      return LastState.err;
    }

    try {
      await isar.writeTxn(() async {
        await isar.fonts.put(this);
      });
    } catch (e) {
      log.e(e.toString());
      file.delete();
      return LastState.err;
    }
    return LastState.ok;
  }
}
