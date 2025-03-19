import 'package:flutter/material.dart';
import 'package:whispering_time/services/isar/config.dart';

class Show extends StatefulWidget {
  @override
  State createState() => _ShowState();
}

class _ShowState extends State<Show> {
 bool visualNoneTitle = Config.instance.visualNoneTitle;
  bool defaultShowTool = Config.instance.defaultShowTool;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => backPage(),
        ),
        title: Text("显示设置"),
      ),
      body: Column(
        children: [

          SwitchListTile(
            title: const Text('隐藏空白标题'),
            value: visualNoneTitle,
            onChanged: (bool value) {
              setState(() {
                visualNoneTitle = value;
                Config.instance.setVisualNoneTitle(value);
              });
            },
          ),
          SwitchListTile(
            title: const Text('默认显示工具栏'),
            value: defaultShowTool,
            onChanged: (bool value) {
              setState(() {
                defaultShowTool = value;
                Config.instance.setDefaultShowTool(value);
              });
            },
          ),
        ],
      ),
      
    );
  }

  backPage() {
  
    Navigator.of(context).pop();
  }
}
