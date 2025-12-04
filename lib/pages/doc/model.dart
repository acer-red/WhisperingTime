import 'package:whispering_time/utils/env.dart';
import 'package:intl/intl.dart';
import 'package:whispering_time/utils/time.dart';

class Doc {
  String title;
  String content;
  String plainText;
  int level;
  DateTime createAt;
  DateTime updateAt;
  DocConfig config;
  String id;
  int get day => createAt.day;
  String get levelString => Level.string(level);
  String get createAtString => DateFormat('yyyy-MM-dd HH:mm').format(createAt);
  String get updateAtString => DateFormat('yyyy-MM-dd HH:mm').format(updateAt);
  late bool isSearch;
  Doc({
    required this.title,
    required this.content,
    required this.plainText,
    required this.level,
    required this.createAt,
    required this.updateAt,
    required this.config,
    required this.id,
  });

  factory Doc.fromJson(Map<String, dynamic> json) {
    return Doc(
      title: json['title'] as String,
      content: json['content'] as String,
      plainText: json['plain_text'] as String,
      level: json['level'] as int,
      createAt: Time.stringToTime(json['createAt'] as String),
      updateAt: Time.stringToTime(json['updateAt'] as String),
      config: DocConfig(isShowTool: json['config']['is_show_tool'] as bool),
      id: json['id'] as String,
    );
  }
}

class DocConfig {
  bool? isShowTool;
  DocConfig({this.isShowTool});
  Map<String, dynamic> toJson() {
    return {
      'is_show_tool': isShowTool,
    };
  }
}
