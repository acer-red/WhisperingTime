import 'package:flutter/material.dart';
import 'package:whispering_time/services/Isar/font.dart';
import 'package:whispering_time/services/http/fonthub.dart';

class FontManager extends StatefulWidget {
  @override
  State<FontManager> createState() => _FontManager();
}

class _FontManager extends State<FontManager> {
  String selectedLanguage = 'zh';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    double initialDragPosition = 0;

    return AlertDialog(
      content: SizedBox(
        height: 300,
        width: 200,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: DropdownButton<String>(
                value: selectedLanguage,
                items: [
                  DropdownMenuItem(
                    value: "zh",
                    child: Text("中文"),
                  ),
                  DropdownMenuItem(
                    value: "en",
                    child: Text("English"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedLanguage = value!;
                  });
                },
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: _loadFonts(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Font?>> snapshot) {
                  if (snapshot.hasData) {
                    return snapshot.data?.isEmpty == true
                        ? Text("233")
                        : GestureDetector(
                          onHorizontalDragStart: (details) {
                            initialDragPosition = details.localPosition.dx;
                          },
                          onHorizontalDragUpdate: (details) {
                            final currentPosition = details.localPosition.dx;
                            final delta =
                              currentPosition - initialDragPosition;
                            scrollController
                              .jumpTo(scrollController.offset - delta);
                            initialDragPosition = currentPosition;
                          },
                          child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            controller: scrollController,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final font = snapshot.data![index]!;
                              font.load();

                              return Text(
                              selectedLanguage == "zh"
                                ? "这是最好的时代，这是最坏的时代，这是智慧的时代，这是愚蠢的时代，这是信仰的纪元，这是怀疑的纪元，这是光明的季节，这是黑暗的季节，这是希望之春，这是绝望之冬，我们面前拥有一切，我们面前一无所有，我们都在直接通往天堂，我们都在直接走向另一边——简而言之，这个时期与现在时期如此相似，以至于一些最喧嚣的权威人物坚持认为，无论好坏，都应该用最高级的比较级来接受它。"
                                : "It was the best of times, it was the worst of times, it was the age of wisdom, it was the age of foolishness, it was the epoch of belief, it was the epoch of incredulity, it was the season of Light, it was the season of Darkness, it was the spring of hope, it was the winter of despair, we had everything before us, we had nothing before us, we were all going direct to Heaven, we were all going direct the other way—in short, the period was so far like the present period, that some of its noisiest authorities insisted on its being received, for good or for evil, in the superlative degree of comparison only.",
                              style:
                                TextStyle(fontFamily: font.fullName!),
                              );
                            }),
                          );
                  } else if (snapshot.hasError) {
                    return Text("Error loading fonts: ${snapshot.error}");
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            ),
          ],
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
