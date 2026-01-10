import 'package:flutter/material.dart';
import 'package:whispering_time/service/http/base.dart';
import 'package:whispering_time/util/env.dart';
import 'package:whispering_time/util/ui.dart';

class AppErrCode {
  static const int ok = 0;
  static const int created = 1;
  static const int dataParseFailed = 2;
  static const int alreadyExist = 3;
  static const int alreadyDeleted = 4;
  static const int unknownType = 5;
  static const int noFound = 6;
  static const int internalServer = 7;
  static const int formatError = 8;
  static const int userAlreadyExist = 9;
}

class AppError {
  static int extractErr(Map<String, dynamic> json) {
    final dynamic err = json['err'];
    return err is int ? err : AppErrCode.formatError;
  }

  static String extractMsg(Map<String, dynamic> json) {
    final dynamic msg = json['msg'];
    if (msg is String && msg.isNotEmpty) {
      return msg;
    }
    return '未知错误';
  }

  static bool isSuccess(int code) {
    return code == AppErrCode.ok || code == AppErrCode.created;
  }

  static String resolveMsg(int code, String fallback) {
    switch (code) {
      case AppErrCode.dataParseFailed:
        return '数据解析失败';
      case AppErrCode.alreadyExist:
        return '已存在';
      case AppErrCode.alreadyDeleted:
        return '已删除';
      case AppErrCode.unknownType:
        return '未知类型';
      case AppErrCode.noFound:
        return '未找到';
      case AppErrCode.internalServer:
        return '服务器错误';
      case AppErrCode.formatError:
        return '格式错误';
      case AppErrCode.userAlreadyExist:
        return '用户已存在';
      default:
        return fallback.isNotEmpty ? fallback : '未知错误';
    }
  }

  static void notifyFromJson(Map<String, dynamic> json,
      {BuildContext? context}) {
    final code = extractErr(json);
    final msg = extractMsg(json);
    notifyIfError(code: code, msg: msg, context: context);
  }

  static void notifyIfError(
      {required int code, String? msg, BuildContext? context}) {
    if (isSuccess(code)) return;
    final ctx = context ?? navigatorKey.currentState?.context;
    if (ctx != null && ctx.mounted) {
      showErrMsg(ctx, resolveMsg(code, msg ?? ''));
    }
  }

  /// Convenience for handling `Basic` responses returned by HTTP/GRPC wrappers.
  static bool handleBasic(Basic res, {BuildContext? context}) {
    notifyIfError(code: res.err, msg: res.msg, context: context);
    return res.isOK;
  }
}
