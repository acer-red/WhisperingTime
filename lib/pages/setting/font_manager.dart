import 'package:flutter/material.dart';
import 'package:whispering_time/services/http/fonthub.dart';

class FontManager extends StatefulWidget {
  @override
  State<FontManager> createState() => _FontManager();
}

class _FontManager extends State<FontManager> {
  late Future<ResponseGetFonts> res;

  @override
  void initState() {
    super.initState();
    res = Http().getFonts();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        height: 300,
        width: 200,
        child: FutureBuilder(
          future: _loadFonts(),
          builder:
              (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
            if (snapshot.hasData) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "这是一个示例文本，用于展示字体效果。",
                    style: TextStyle(
                        fontFamily: snapshot.data!.first, fontSize: 16),
                  ),
                  Text(
                    snapshot.data!.first,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              );
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

  Future<List<String>> _loadFonts() async {
    res.then((onValue) {
      for (FontItem font in onValue.data) {
        Http().getFontFile(font);
      }
    });

    await Future.delayed(Duration(seconds: 2));
    return ["ExampleFont"];
  }
}
