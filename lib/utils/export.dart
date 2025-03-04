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

class ExportDoc {
  String content;
  String title;
  String plainText;
  int level;
  DateTime crtime;

  String get levelString => Level.string(level);
  String get crtimeString => DateFormat('yyyy-MM-dd HH:mm').format(crtime);
  // String get uptimeString =>DateFormat('yyyy-MM-dd HH:mm').format(uptime);

  ExportDoc({
    required this.content,
    required this.title,
    required this.plainText,
    required this.level,
    required this.crtime,
  });
}

class Export {
  void dialog(BuildContext context, String title, Future<void> Function() pdf,
      Future<void> Function() txt) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 300,
              child: Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text("导出到本地"),
                    ElevatedButton(
                      onPressed: () {
                        pdf();
                        Navigator.of(context).pop();
                      },
                      child: const Text("PDF"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        txt();
                        Navigator.of(context).pop();
                      },
                      child: const Text("纯文本"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<void> pdf(ExportDoc doc, {String? savePath}) async {
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

  static List<pw.Widget> _pdfHeader(
      ExportDoc doc, pw.Font font, double titleFontSize, double fontsize) {
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

  static pw.Image _pdfImage(Map<dynamic, dynamic> map) {
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

  static Future<void> txt(ExportDoc doc) async {
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: '选择保存路径',
      fileName: doc.title,
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (outputFile == null) {
      return;
    }

    File file = File(outputFile);
    await file.writeAsString(doc.plainText);
    print("TXT文件已保存：${file.path}");
  }

  static Future<void> themeTXT() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory == null) {
      return;
    }

    final themes = await Http().getThemesAndDoc();
    if (themes.isNotOK) {
      return;
    }
    if (themes.data.isEmpty) {
      return;
    }
    String currentDate = Time.getCurrentTime();
    for (XTheme theme in themes.data) {
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
        }
      }
    log.i("保存结束");

    }
  }

  static Future<void> themePDF() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory == null) {
      return;
    }

    final themes = await Http().getThemesAndDocDetail();
    if (themes.isNotOK) {
      return;
    }
    if (themes.data.isEmpty) {
      return;
    }
    String currentDate = Time.getCurrentTime();
    for (DTheme theme in themes.data) {
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
            await Export.pdf(
                ExportDoc(
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
}
