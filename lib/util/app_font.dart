import 'package:flutter/widgets.dart';
import 'package:whispering_time/service/isar/font.dart';
import 'package:whispering_time/service/isar/config.dart';
import 'package:whispering_time/util/env.dart';
import 'package:whispering_time/service/sp/sp.dart';

Future<void> initAppFont(BuildContext context) async {
  final languageCode = SP().getLanguageCode();
  final serverAddress = Config.fontHubServerAddress;
  final downloadURL =
      "$serverAddress/api/app?name=${getAppName(languageCode: languageCode)}&language=$languageCode";
  final font = Font(
      name: "appfont-$languageCode",
      downloadURL: downloadURL,
      fileName: "AppFont-$languageCode",
      fullName: "AppFont-$languageCode");

  final isExist = await font.isExist();
  if (isExist) {
    await font.load();
    return;
  }
  final ok = await font.download();
  if (!ok) {
    throw Exception("应用字体下载失败");
  }
  try {
    await font.upload();
    await font.load();
  } catch (e) {
    log.e("保存应用字体失败,${e.toString()}");
    return;
  }
}

String getAppName({String? languageCode, bool human = false}) {
  languageCode ??= SP().getLanguageCode();
  switch (languageCode) {
    case "zh":
      return human ? appNameZhHuman : appNameZh;
    case "en":
      return human ? appNameEnHuman : appNameEn;
    default:
      return appNameEn;
  }
}
