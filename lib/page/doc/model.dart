import 'package:whispering_time/util/env.dart';
import 'package:intl/intl.dart';
import 'package:whispering_time/util/time.dart';

class Doc {
  String title;
  String content;
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
    required this.level,
    required this.createAt,
    required this.updateAt,
    required this.config,
    required this.id,
  });

  factory Doc.fromJson(Map<String, dynamic> json) {
    final contentMap = json['content'] as Map<String, dynamic>? ?? {};
    int parsedLevel = 0;
    final levelValue = contentMap['level'] ?? json['level'];
    if (levelValue is int) {
      parsedLevel = levelValue;
    } else if (levelValue is String) {
      parsedLevel = int.tryParse(levelValue) ?? 0;
    }
    final title = contentMap['title'] ?? json['title'] ?? '';
    final body = contentMap['rich'] ?? json['content'] ?? '';

    return Doc(
      title: title as String,
      content: body as String,
      level: parsedLevel,
      createAt: Time.stringToTime(json['createAt'] as String),
      updateAt: Time.stringToTime(json['updateAt'] as String),
      config: DocConfig(isShowTool: json['config']['is_show_tool'] as bool),
      id: json['id'] as String,
    );
  }
  String toJson() {
    return '''
    {
      "title": "$title",
      "content": "$content",
      "level": $level,
      "createAt": "$createAtString",
      "updateAt": "$updateAtString",
      "config": ${config.toJson()},
      "id": "$id"
    }
    ''';
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
