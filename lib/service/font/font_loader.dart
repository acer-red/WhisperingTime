import 'dart:async';

import 'package:whispering_time/service/http/fonthub.dart';
import 'package:whispering_time/service/isar/font.dart';

class FontLoadingException implements Exception {
  FontLoadingException(this.message);

  final String message;

  @override
  String toString() => 'FontLoadingException: $message';
}

class FontLoaderService {
  FontLoaderService({Http? http}) : _http = http ?? Http();

  final Http _http;

  /// Fetch font metadata from remote, cache locally if needed, and return
  /// the locally available font records.
  Future<List<Font>> fetchFonts({bool refreshRemote = true}) async {
    if (refreshRemote) {
      await _refreshRemoteFonts();
    }

    final fonts = await Font().getFonts();
    return fonts.whereType<Font>().toList();
  }

  /// Ensure the provided fonts are registered with the engine.
  Future<void> registerFonts(Iterable<Font> fonts) async {
    await Future.wait(fonts.map((font) => font.load()));
  }

  Future<void> _refreshRemoteFonts() async {
    final response = await _http.getFonts();
    if (response.isNotOK) {
      throw FontLoadingException(response.msg);
    }

    final results =
        await Future.wait(response.data.map((fontItem) => fontItem.save()));
    if (results.any((result) => result == false)) {
      throw FontLoadingException('字体资源下载失败');
    }
  }
}
