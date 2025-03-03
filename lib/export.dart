import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:whispering_time/http.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:whispering_time/env.dart';
import 'package:file_picker/file_picker.dart';

class Export {
  static Future<void> pdf(Doc doc) async {
    QuillController edit = QuillController(
        document: Document.fromJson(jsonDecode(doc.content)),
        selection: const TextSelection.collapsed(offset: 0));

    final pdf = pw.Document();
    pw.Font font = pw.Font.ttf(
        (await rootBundle.load("assets/NotoSansSC-VariableFont_wght.ttf")));
    double fontsize = 10;
    pdf.addPage(
      pw.MultiPage(
        header: (pw.Context context) {
          if (context.pageNumber == 1) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                    level: 0,
                    child: pw.Text(doc.title,
                        style: pw.TextStyle(
                            fontSize: 30,
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
              ],
            );
          }
          return pw.SizedBox();
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
                                  fontSize: fontsize,
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
                        fontSize: fontsize,
                        font: font,
                        fontWeight: pw.FontWeight.normal));
              }
            } else if (op.isInsert && op.value is Map) {
              final insertMap = op.value as Map;
              if (insertMap.containsKey('image')) {
                return pw.Image(
                  pw.MemoryImage(
                    base64Decode(
                      insertMap['image'].toString().split(',').last,
                    ),
                  ),
                  width: double.tryParse(insertMap['width'].toString()),
                  height: double.tryParse(insertMap['height'].toString()),
                );
              } else {
                log.e("发现未知map类型");
                return pw.Paragraph(
                    text: op.value.toString(),
                    style: pw.TextStyle(
                        fontSize: fontsize,
                        font: font,
                        fontWeight: pw.FontWeight.normal));
              }
            }
            log.e("发现未知类型");
            return pw.Paragraph(
                text: op.value.toString(),
                style: pw.TextStyle(
                    fontSize: fontsize,
                    font: font,
                    fontWeight: pw.FontWeight.normal));
          }).toList();
        },
      ),
    );

    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: '选择保存路径',
      fileName: '${doc.title}.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (outputFile == null) {
      return;
    }

    File file = File(outputFile);
    await file.writeAsBytes(await pdf.save());

    print('PDF文件已保存：${file.path}');
  }

  static Future<void> txt(Doc doc) async {
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
            await file.writeAsString(doc.plainText);
          } catch (e) {
            print('写入文件时出错: $e');
            return;
          }
        }
      }
    }
  }
}
