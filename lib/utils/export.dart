import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:intl/intl.dart';
import 'package:whispering_time/services/http.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:whispering_time/utils/env.dart';
import 'package:file_picker/file_picker.dart';

class ExportData {
  String content;
  String title;
  String plainText;
  int level;
  DateTime crtime;

  String get levelString => Level.string(level);
  String get crtimeString => DateFormat('yyyy-MM-dd HH:mm').format(crtime);
  // String get uptimeString =>DateFormat('yyyy-MM-dd HH:mm').format(uptime);

  ExportData({
    required this.content,
    required this.title,
    required this.plainText,
    required this.level,
    required this.crtime,
  });
}

class Export {
  int integrateMode = 0;
  static const int resourceTheme = 0;
  static const int resourceGroup = 1;
  static const int resourceDoc = 2;
  int resourceType;

  String? tid;
  String? gid;
  ExportData? doc;
  Export(this.resourceType, {this.tid, this.gid, this.doc});

  void dialog(
    BuildContext context,
    String title,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Container(
            width: 300,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text("导出选项",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                RadioListTileExample(onValueChanged: (int value) {
                  integrateMode = value;
                }),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        pdf();
                        Navigator.of(context).pop();
                      },
                      child: const Text("导出为PDF"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        txt();
                        Navigator.of(context).pop();
                      },
                      child: const Text("导出为文本"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  pdf() {
    switch (integrateMode) {
      // 拆分为多个文件
      case 0:
        switch (resourceType) {
          case resourceTheme:
            PDF().themeSplit();
            break;
          case resourceGroup:
            if (tid == null || gid == null) {
              log.e("tid或gid为空");
              return;
            }
            TXT(tid: tid, gid: gid).groupSplit();
            break;
          case resourceDoc:
            if (doc == null) {
              log.e("doc为空");
              return;
            }
            PDF().docSplit(doc!);
            break;
          default:
        }
        break;
      // 合并为一个文件
      case 1:
        switch (resourceType) {
          case resourceTheme:
            PDF().themeOne();
            break;
          case resourceGroup:
            if (tid == null || gid == null) {
              log.e("tid或gid为空");
              return;
            }
            PDF(tid: tid, gid: gid).groupOne();
            break;
          case resourceDoc:
            // if (doc == null) {
            //   log.e("doc为空");
            //   return;
            // }
            // PDF().pdfOne(doc);
            break;
          default:
        }
        break;
    }
  }

  txt() {
    switch (integrateMode) {
      // 拆分为多个文件
      case 0:
        switch (resourceType) {
          case resourceTheme:
            TXT().themeSplit();
            break;
          case resourceGroup:
            if (tid == null || gid == null) {
              log.e("tid或gid为空");
              return;
            }
            TXT(tid: tid, gid: gid).groupSplit();
            break;
          case resourceDoc:
            if (doc == null) {
              log.e("doc为空");
              return;
            }
            TXT().docSplit(doc!);
            break;
          default:
        }
        break;
      // 合并为一个文件
      case 1:
        switch (resourceType) {
          case resourceTheme:
            TXT().themeOne();
            break;
          case resourceGroup:
            if (tid == null || gid == null) {
              log.e("tid或gid为空");
              return;
            }
            TXT(tid: tid, gid: gid).groupOne();
            break;
          case resourceDoc:
            if (doc == null) {
              log.e("doc为空");
              return;
            }
            // pdfOne(doc);
            break;
          default:
        }
        break;
    }
  }
}

class RadioListTileExample extends StatefulWidget {
  final ValueChanged<int> onValueChanged; // 添加回调函数
  const RadioListTileExample({required this.onValueChanged});

  @override
  State<StatefulWidget> createState() => _RadioListTileExampleState();
}

class _RadioListTileExampleState extends State<RadioListTileExample> {
  int _selectedValue = 0; // 存储选中的值

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        RadioListTile<int>(
          title: const Text('保存为多个文件'),
          value: 0,
          groupValue: _selectedValue,
          onChanged: (int? value) {
            if (value == null) {
              return;
            }

            setState(() {
              _selectedValue = value;
              widget.onValueChanged(value);
            });
          },
        ),
        RadioListTile<int>(
          title: const Text('保存为一个文件'),
          value: 1,
          groupValue: _selectedValue,
          onChanged: (int? value) {
            if (value == null) {
              return;
            }

            setState(() {
              _selectedValue = value;
              widget.onValueChanged(value);
            });
          },
        ),
      ],
    );
  }
}

class TXT {
  String? tid;
  String? gid;
  TXT({this.tid, this.gid});

  /// 导出所有主题为多个txt文件
  Future<void> themeSplit() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory == null) {
      return;
    }

    final res = await Http().getThemesAndDoc();
    if (res.isNotOK) {
      return;
    }
    if (res.data.isEmpty) {
      return;
    }
    String currentDate = Time.getCurrentTime();
    for (XTheme theme in res.data) {
      for (XGroup group in theme.groups) {
        for (XDoc doc in group.docs) {
          // 文件名: XTheme.name/XGroup.name/XDoc.title
          // 文件内容: XTheme.name/XGroup.name/XDoc.plainText
          final String fileName = doc.title.isEmpty ? "无题" : doc.title;
          final String savePath =
              '$selectedDirectory/枫迹/$currentDate/${theme.name}/${group.name}';

          // 创建文件夹并写入文件
          final filePath = '$savePath/$fileName.txt';

          File file = File(filePath);

          try {
            await Directory(savePath).create(recursive: true);
          } catch (e) {
            log.e('创建文件夹失败: $e');
            return;
          }

          try {
            await file.writeAsString(doc.plainText);
          } catch (e) {
            print('写入TXT时出错: $e');
            return;
          }
          print("保存成功 $savePath");
        }
      }
    }
    print("保存结束");
  }

  /// 导出所有主题为单个txt文件
  Future<void> themeOne() async {
    final res = await Http().getThemesAndDoc();
    if (res.isNotOK) {
      return;
    }
    if (res.data.isEmpty) {
      return;
    }

    String? filePath = await FilePicker.platform.saveFile(
      dialogTitle: '选择保存路径',
      fileName: '枫迹--${Time.getCurrentTime()}.txt',
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (filePath == null) {
      return;
    }

    Stream<String> dataStream = (() async* {
      for (XTheme theme in res.data) {
        for (XGroup group in theme.groups) {
          for (XDoc doc in group.docs) {
            yield "分类: ${theme.name}/${group.name}\n";
            yield "主题: ${doc.title}\n";
            yield "印迹分级: ${doc.levelString}\n";
            yield "创建时间: ${doc.crtimeString}\n";
            yield doc.plainText;
            yield "\n\n\n\n------------------------------------------------------------\n";
          }
        }
      }
    })();

    // 将 String Stream 转换为 List<int> Stream (UTF-8 编码)
    Stream<List<int>> byteStream = dataStream.transform(utf8.encoder);

    await saveSteam(filePath, byteStream);

    print("保存结束");
  }

  /// 导出一个主题下的一个分组的所有印迹为多个TXT文件
  Future<void> groupSplit() async {
    final res = await Http(tid: tid, gid: gid).getGroupAndDocDetail();
    if (res.isNotOK) {
      return;
    }
    if (res.data.docs.isEmpty) {
      return;
    }

    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory == null) {
      return;
    }

    String currentDate = Time.getCurrentTime();
    for (DDoc doc in res.data.docs) {
      // 文件名: DGroup.name/DDoc.title
      // 文件内容: DGroup.name/DDoc.content
      final String savePath =
          '$selectedDirectory/枫迹/$currentDate/${res.data.docs}';
      print("目录:$savePath,title:${doc.title}");
      try {
        await Directory(savePath).create(recursive: true);
      } catch (e) {
        log.e('创建文件夹失败: $e');
        return;
      }
      try {
        await docSplit(
            ExportData(
                title: doc.title,
                content: "",
                plainText: doc.plainText,
                level: doc.level,
                crtime: doc.crtime),
            savePath: savePath);
      } catch (e) {
        log.e('写入TXT失败失败: $e');
        return;
      }
    }
    print("保存结束");
  }

  /// 导出一个主题下的一个分组的所有印迹为单个TXT文件
  Future<void> groupOne() async {
    final res = await Http(tid: tid, gid: gid).getGroupAndDocDetail();
    if (res.isNotOK) {
      return;
    }
    if (res.data.docs.isEmpty) {
      return;
    }

    String? filePath = await FilePicker.platform.saveFile(
      dialogTitle: '选择保存路径',
      fileName: '枫迹-${res.data.name}-${Time.getCurrentTime()}.txt',
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (filePath == null) {
      return;
    }

    Stream<String> dataStream = (() async* {
      for (DDoc doc in res.data.docs) {
        yield "分类: ${res.data.name}\n";
        yield "主题: ${doc.title}\n";
        yield "印迹分级: ${doc.levelString}\n";
        yield "创建时间: ${doc.crtimeString}\n";
        yield doc.plainText;
        yield "\n\n\n\n------------------------------------------------------------\n";
      }
    })();

    // 将 String Stream 转换为 List<int> Stream (UTF-8 编码)
    Stream<List<int>> byteStream = dataStream.transform(utf8.encoder);

    await saveSteam(filePath, byteStream);

    print("保存结束");
  }

  Future<void> docSplit(ExportData doc, {String? savePath}) async {
    if (savePath == null) {
      String? savePath = await FilePicker.platform.saveFile(
        dialogTitle: '选择保存路径',
        fileName: doc.title,
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );

      if (savePath == null) {
        return;
      }
    }
    String fileName =
        "${savePath!}/${doc.title.isEmpty ? "无题" : doc.title}.txt";
    File file = File(fileName);
    await file.writeAsString(doc.plainText);
    print("保存成功：$fileName");
  }

  Future<void> saveSteam(String filePath, Stream<List<int>> dataStream) async {
    File file = File(filePath);
    IOSink sink = file.openWrite(); // 打开文件用于写入，返回 IOSink

    try {
      await dataStream.forEach((chunk) {
        // 遍历数据流中的每个数据块
        sink.add(chunk); // 将数据块添加到 IOSink
      });
    } catch (e) {
      log.e('写入文件出错: $e');
    } finally {
      await sink.close(); // 关闭 IOSink
    }
  }
}

class PDF {
  String? tid;
  String? gid;
  PDF({this.tid, this.gid});

  /// 导出所有主题为多个PDF文件
  Future<void> themeSplit() async {
    print("导出所有主题为多个PDF文件");
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory == null) {
      return;
    }

    final res = await Http().getThemesAndDocDetail();
    if (res.isNotOK) {
      return;
    }
    if (res.data.isEmpty) {
      return;
    }
    String currentDate = Time.getCurrentTime();
    for (DTheme theme in res.data) {
      for (DGroup group in theme.groups) {
        for (DDoc doc in group.docs) {
          // 文件名: DTheme.name/DGroup.name/DDoc.title
          // 文件内容: DTheme.name/DGroup.name/DDoc.content
          final String savePath =
              '$selectedDirectory/枫迹/$currentDate/${theme.name}/${group.name}';
          print("目录:$savePath,title:${doc.title}");
          try {
            await Directory(savePath).create(recursive: true);
          } catch (e) {
            log.e('创建文件夹失败: $e');
            return;
          }
          try {
            await docSplit(
                ExportData(
                    title: doc.title,
                    content: doc.content,
                    plainText: "",
                    level: doc.level,
                    crtime: doc.crtime),
                savePath: savePath);
          } catch (e) {
            log.e('写入PDF失败失败: $e');
            return;
          }
        }
      }
    }
    log.i("保存结束");
  }

  /// 导出所有主题为单个PDF文件
  Future<void> themeOne() async {
    print("导出所有主题为单个PDF文件");
    final res = await Http().getThemesAndDocDetail();
    if (res.isNotOK) {
      return;
    }
    if (res.data.isEmpty) {
      return;
    }
    final pdf = pw.Document();
    pw.Font font = pw.Font.ttf(
        (await rootBundle.load("lib/assets/NotoSansSC-VariableFont_wght.ttf")));

    double titleFontSize = 30;
    double mainBodyFontSize = 9;

    List<Map<String, dynamic>> outline = [];
    List<pw.Widget> content = [];

    for (DTheme theme in res.data) {
      for (DGroup group in theme.groups) {
        for (DDoc doc in group.docs) {
          // 添加到大纲
          outline.add({
            'title': "${theme.name}/${group.name}/${doc.title}",
            'page': content.length + 2, // +2 是因为首页和大纲页
          });

          // 创建印迹内容
          QuillController edit = QuillController(
              document: Document.fromJson(jsonDecode(doc.content)),
              selection: const TextSelection.collapsed(offset: 0));

          content.add(pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                    level: 0,
                    child: pw.Text(doc.title,
                        style: pw.TextStyle(
                            fontSize: titleFontSize,
                            font: font,
                            fontWeight: pw.FontWeight.bold))),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("印迹分级: ${doc.levelString}",
                        style: pw.TextStyle(
                            fontSize: mainBodyFontSize,
                            font: font,
                            color: PdfColor.fromInt(Colors.grey.value),
                            fontWeight: pw.FontWeight.normal)),
                    pw.Text("创建时间: ${doc.crtimeString}",
                        style: pw.TextStyle(
                            fontSize: mainBodyFontSize,
                            font: font,
                            color: PdfColor.fromInt(Colors.grey.value),
                            fontWeight: pw.FontWeight.normal)),
                  ],
                ),
                pw.SizedBox(height: 20),
                ...edit.document.toDelta().toList().map((op) {
                  if (op.isInsert && op.value is String) {
                    String value = op.value.toString();
                    if (value.contains('\n')) {
                      List<String> paragraphs = value.split('\n');
                      return pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: paragraphs.map((paragraph) {
                            if (paragraph.trim().isEmpty) {
                              return pw.SizedBox(height: 10);
                            }
                            return pw.Column(
                              children: [
                                pw.Text(paragraph,
                                    style: pw.TextStyle(
                                        fontSize: mainBodyFontSize,
                                        font: font,
                                        fontWeight: pw.FontWeight.normal)),
                                pw.SizedBox(height: 10)
                              ],
                            );
                          }).toList());
                    } else {
                      return pw.Paragraph(
                          text: value,
                          style: pw.TextStyle(
                              fontSize: mainBodyFontSize,
                              font: font,
                              fontWeight: pw.FontWeight.normal));
                    }
                  } else if (op.isInsert && op.value is Map) {
                    final map = op.value as Map;
                    if (map.containsKey('image')) {
                      return _pdfImage(map);
                    } else {
                      log.e("发现未知map类型");
                    }
                  }
                  log.e("发现未知类型");
                  return pw.Paragraph(
                      text: op.value.toString(),
                      style: pw.TextStyle(
                          fontSize: mainBodyFontSize,
                          font: font,
                          fontWeight: pw.FontWeight.normal));
                }).toList()
              ]));
        }
      }
    }

    // 首页
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Text("枫迹",
                style: pw.TextStyle(
                    fontSize: 40, font: font, fontWeight: pw.FontWeight.bold)),
          );
        },
      ),
    );

    // 大纲页
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("大纲",
                  style: pw.TextStyle(
                      fontSize: 30,
                      font: font,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              ...outline.map((item) {
                return pw.Text(item['title'],
                    style: pw.TextStyle(
                      fontSize: 12,
                      font: font,
                    ));
              }).toList(),
            ],
          );
        },
      ),
    );

    // 内容页
    pdf.addPage(pw.MultiPage(build: (pw.Context context) {
      return content;
    }));

    String? filePath = await FilePicker.platform.saveFile(
      dialogTitle: '选择保存路径',
      fileName: '枫迹-${Time.getCurrentTime()}.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (filePath == null) {
      return;
    }

    File file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    print("保存成功：${file.path}");
  }

  /// 导出一个主题下的一个分组的所有印迹为多个PDF文件
  Future<void> groupSplit() async {
    final res = await Http(tid: tid, gid: gid).getGroupAndDocDetail();
    if (res.isNotOK) {
      return;
    }
    if (res.data.docs.isEmpty) {
      return;
    }

    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory == null) {
      return;
    }

    String currentDate = Time.getCurrentTime();
    for (DDoc doc in res.data.docs) {
      // 文件名: DGroup.name/DDoc.title
      // 文件内容: DGroup.name/DDoc.content
      final String savePath =
          '$selectedDirectory/枫迹/$currentDate/${res.data.name}';
      print("目录:$savePath,title:${doc.title}");
      try {
        await Directory(savePath).create(recursive: true);
      } catch (e) {
        log.e('创建文件夹失败: $e');
        return;
      }
      try {
        await docSplit(
            ExportData(
                title: doc.title,
                content: doc.content,
                plainText: "",
                level: doc.level,
                crtime: doc.crtime),
            savePath: savePath);
      } catch (e) {
        log.e('写入PDF失败失败: $e');
        return;
      }
    }
    log.i("保存结束");
  }

  /// 导出一个主题下的一个分组的所有印迹为单个PDF文件
  Future<void> groupOne() async {
    print("导出一个主题下的一个分组的所有印迹为单个PDF文件");

    final res = await Http(tid: tid, gid: gid).getGroupAndDocDetail();
    if (res.isNotOK) {
      return;
    }
    if (res.data.docs.isEmpty) {
      return;
    }

    if (res.isNotOK) {
      return;
    }
    if (res.data.docs.isEmpty) {
      return;
    }
    final pdf = pw.Document();
    pw.Font font = pw.Font.ttf(
        (await rootBundle.load("lib/assets/NotoSansSC-VariableFont_wght.ttf")));

    double titleFontSize = 30;
    double mainBodyFontSize = 9;

    List<Map<String, dynamic>> outline = [];
    List<pw.Widget> content = [];

    for (DDoc doc in res.data.docs) {
      // 添加到大纲
      outline.add({
        'title': "${res.data.name}/${doc.title}",
        'page': content.length + 2, // +2 是因为首页和大纲页
      });

      // 创建印迹内容
      QuillController edit = QuillController(
          document: Document.fromJson(jsonDecode(doc.content)),
          selection: const TextSelection.collapsed(offset: 0));

      content.add(
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Header(
            level: 0,
            child: pw.Text(doc.title,
                style: pw.TextStyle(
                    fontSize: titleFontSize,
                    font: font,
                    fontWeight: pw.FontWeight.bold))),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("印迹分级: ${doc.levelString}",
                style: pw.TextStyle(
                    fontSize: mainBodyFontSize,
                    font: font,
                    color: PdfColor.fromInt(Colors.grey.value),
                    fontWeight: pw.FontWeight.normal)),
            pw.Text("创建时间: ${doc.crtimeString}",
                style: pw.TextStyle(
                    fontSize: mainBodyFontSize,
                    font: font,
                    color: PdfColor.fromInt(Colors.grey.value),
                    fontWeight: pw.FontWeight.normal)),
          ],
        ),
        pw.SizedBox(height: 20),
        ...edit.document.toDelta().toList().map((op) {
          if (op.isInsert && op.value is String) {
            String value = op.value.toString();
            if (value.contains('\n')) {
              List<String> paragraphs = value.split('\n');
              return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: paragraphs.map((paragraph) {
                    if (paragraph.trim().isEmpty) {
                      return pw.SizedBox(height: 10);
                    }
                    return pw.Column(
                      children: [
                        pw.Text(paragraph,
                            style: pw.TextStyle(
                                fontSize: mainBodyFontSize,
                                font: font,
                                fontWeight: pw.FontWeight.normal)),
                        pw.SizedBox(height: 10)
                      ],
                    );
                  }).toList());
            } else {
              return pw.Paragraph(
                  text: value,
                  style: pw.TextStyle(
                      fontSize: mainBodyFontSize,
                      font: font,
                      fontWeight: pw.FontWeight.normal));
            }
          } else if (op.isInsert && op.value is Map) {
            final map = op.value as Map;
            if (map.containsKey('image')) {
              return _pdfImage(map);
            } else {
              log.e("发现未知map类型");
            }
          }
          log.e("发现未知类型");
          return pw.Paragraph(
              text: op.value.toString(),
              style: pw.TextStyle(
                  fontSize: mainBodyFontSize,
                  font: font,
                  fontWeight: pw.FontWeight.normal));
        }).toList()
      ]));
    }

    // 首页
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Text("枫迹",
                style: pw.TextStyle(
                    fontSize: 40, font: font, fontWeight: pw.FontWeight.bold)),
          );
        },
      ),
    );

    // 大纲页
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("大纲",
                  style: pw.TextStyle(
                      fontSize: 30,
                      font: font,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              ...outline.map((item) {
                return pw.Text(item['title'],
                    style: pw.TextStyle(
                      fontSize: 12,
                      font: font,
                    ));
              }).toList(),
            ],
          );
        },
      ),
    );

    // 内容页
    pdf.addPage(pw.MultiPage(build: (pw.Context context) {
      return content;
    }));

    String? filePath = await FilePicker.platform.saveFile(
      dialogTitle: '选择保存路径',
      fileName: '枫迹-${Time.getCurrentTime()}.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (filePath == null) {
      return;
    }

    File file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    print("保存成功：${file.path}");
  }

  Future<void> one(ExportData doc, {String? savePath}) async {
    QuillController edit = QuillController(
        document: Document.fromJson(jsonDecode(doc.content)),
        selection: const TextSelection.collapsed(offset: 0));

    final pdf = pw.Document();
    pw.Font font = pw.Font.ttf(
        (await rootBundle.load("lib/assets/NotoSansSC-VariableFont_wght.ttf")));

    double titleFontSize = 30;
    double mainBodyFontSize = 9;

    pdf.addPage(
      pw.MultiPage(
        header: (pw.Context context) {
          if (context.pageNumber != 1) {
            return pw.Container();
          }
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: _pdfHeader(doc, font, titleFontSize, mainBodyFontSize),
          );
        },
        build: (pw.Context context) {
          return edit.document.toDelta().toList().map((op) {
            if (op.isInsert && op.value is String) {
              String value = op.value.toString();
              if (value.contains('\n')) {
                List<String> paragraphs = value.split('\n');
                return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: paragraphs.map((paragraph) {
                      if (paragraph.trim().isEmpty) {
                        return pw.SizedBox(height: 10);
                      }
                      return pw.Column(
                        children: [
                          pw.Text(paragraph,
                              style: pw.TextStyle(
                                  fontSize: mainBodyFontSize,
                                  font: font,
                                  fontWeight: pw.FontWeight.normal)),
                          pw.SizedBox(height: 10)
                        ],
                      );
                    }).toList());
              } else {
                return pw.Paragraph(
                    text: value,
                    style: pw.TextStyle(
                        fontSize: mainBodyFontSize,
                        font: font,
                        fontWeight: pw.FontWeight.normal));
              }
            } else if (op.isInsert && op.value is Map) {
              final map = op.value as Map;
              if (map.containsKey('image')) {
                return _pdfImage(map);
              } else {
                log.e("发现未知map类型");
                // return pw.Paragraph(
                //     text: op.value.toString(),
                //     style: pw.TextStyle(
                //         fontSize: mainBodyFontSize,
                //         font: font,
                //         fontWeight: pw.FontWeight.normal));
              }
            }
            log.e("发现未知类型");
            return pw.Paragraph(
                text: op.value.toString(),
                style: pw.TextStyle(
                    fontSize: mainBodyFontSize,
                    font: font,
                    fontWeight: pw.FontWeight.normal));
          }).toList();
        },
      ),
    );
    final String fileName = doc.title.isEmpty ? "无题" : doc.title;

    if (savePath == null) {
      savePath = await FilePicker.platform.saveFile(
        dialogTitle: '选择保存路径',
        fileName: '$fileName.pdf',
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (savePath == null) {
        return;
      }
    } else {
      savePath = '$savePath/$fileName.pdf';
    }

    File file = File(savePath);
    await file.writeAsBytes(await pdf.save());

    print('PDF文件已保存：${file.path}');
  }

  List<pw.Widget> _pdfHeader(
      ExportData doc, pw.Font font, double titleFontSize, double fontsize) {
    return [
      pw.Header(
          level: 0,
          child: pw.Text(doc.title,
              style: pw.TextStyle(
                  fontSize: titleFontSize,
                  font: font,
                  fontWeight: pw.FontWeight.bold))),
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text("印迹分级: ${doc.levelString}",
              style: pw.TextStyle(
                  fontSize: fontsize,
                  font: font,
                  color: PdfColor.fromInt(Colors.grey.value),
                  fontWeight: pw.FontWeight.normal)),
          pw.Text("创建时间: ${doc.crtimeString}",
              style: pw.TextStyle(
                  fontSize: fontsize,
                  font: font,
                  color: PdfColor.fromInt(Colors.grey.value),
                  fontWeight: pw.FontWeight.normal)),
        ],
      ),
      pw.SizedBox(height: 20),
    ];
  }

  pw.Image _pdfImage(Map<dynamic, dynamic> map) {
    return pw.Image(
      pw.MemoryImage(
        base64Decode(
          map['image'].toString().split(',').last,
        ),
      ),
      width: double.tryParse(map['width'].toString()),
      height: double.tryParse(map['height'].toString()),
    );
  }

  Future<void> docSplit(ExportData doc, {String? savePath}) async {
    QuillController edit = QuillController(
        document: Document.fromJson(jsonDecode(doc.content)),
        selection: const TextSelection.collapsed(offset: 0));

    final pdf = pw.Document();
    pw.Font font = pw.Font.ttf(
        (await rootBundle.load("lib/assets/NotoSansSC-VariableFont_wght.ttf")));

    double titleFontSize = 30;
    double mainBodyFontSize = 9;

    pdf.addPage(
      pw.MultiPage(
        header: (pw.Context context) {
          if (context.pageNumber != 1) {
            return pw.Container();
          }
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: _pdfHeader(doc, font, titleFontSize, mainBodyFontSize),
          );
        },
        build: (pw.Context context) {
          return edit.document.toDelta().toList().map((op) {
            if (op.isInsert && op.value is String) {
              String value = op.value.toString();
              if (value.contains('\n')) {
                List<String> paragraphs = value.split('\n');
                return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: paragraphs.map((paragraph) {
                      if (paragraph.trim().isEmpty) {
                        return pw.SizedBox(height: 10);
                      }
                      return pw.Column(
                        children: [
                          pw.Text(paragraph,
                              style: pw.TextStyle(
                                  fontSize: mainBodyFontSize,
                                  font: font,
                                  fontWeight: pw.FontWeight.normal)),
                          pw.SizedBox(height: 10)
                        ],
                      );
                    }).toList());
              } else {
                return pw.Paragraph(
                    text: value,
                    style: pw.TextStyle(
                        fontSize: mainBodyFontSize,
                        font: font,
                        fontWeight: pw.FontWeight.normal));
              }
            } else if (op.isInsert && op.value is Map) {
              final map = op.value as Map;
              if (map.containsKey('image')) {
                return _pdfImage(map);
              } else {
                log.e("发现未知map类型");
                // return pw.Paragraph(
                //     text: op.value.toString(),
                //     style: pw.TextStyle(
                //         fontSize: mainBodyFontSize,
                //         font: font,
                //         fontWeight: pw.FontWeight.normal));
              }
            }
            log.e("发现未知类型");
            return pw.Paragraph(
                text: op.value.toString(),
                style: pw.TextStyle(
                    fontSize: mainBodyFontSize,
                    font: font,
                    fontWeight: pw.FontWeight.normal));
          }).toList();
        },
      ),
    );
    final String fileName = doc.title.isEmpty ? "无题" : doc.title;

    if (savePath == null) {
      savePath = await FilePicker.platform.saveFile(
        dialogTitle: '选择保存路径',
        fileName: '$fileName.pdf',
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (savePath == null) {
        return;
      }
    } else {
      savePath = '$savePath/$fileName.pdf';
    }

    File file = File(savePath);
    await file.writeAsBytes(await pdf.save());

    print('PDF文件已保存：${file.path}');
  }
}
