import 'package:flutter/material.dart';
import 'package:whispering_time/services/Isar/font.dart';
import 'package:whispering_time/services/http/fonthub.dart';

class FontManager extends StatefulWidget {
  @override
  State<FontManager> createState() => _FontManager();
}

class _FontManager extends State<FontManager> {
  @override
  void initState() {
    super.initState();
    // loadFromHttp();
  }

  // void loadFromHttp() async {

  // }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        height: 300,
        width: 200,
        child: FutureBuilder(
          future: _loadFonts(),
          builder: (BuildContext context, AsyncSnapshot<List<Font?>> snapshot) {
            if (snapshot.hasData) {
              return snapshot.data?.isEmpty == true
                  ? Text("233")
                  : ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final font = snapshot.data![index]!;
                        font.load();

                        return ListTile(
                          title: Text(
                            font.name!,
                            style: TextStyle(fontFamily: font.fullName!),
                          ),
                          onTap: () {
                            // Http().getFontFile(font;
                          },
                        );
                      });
            } else if (snapshot.hasError) {
              return Text("Error loading fonts: ${snapshot.error}");
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
      actions: [
        TextButton(
          child: Text("设为默认"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Future<List<Font?>> _loadFonts() async {
    // 从网络加载所有字体信息到数据库
    final ret = await Http().getFonts();
    ret.data.toList().forEach((element) async {
      await element.save();
    });

    // 从数据库中加载所有字体信息到UI
    return await Font().getFonts();
  }
}
