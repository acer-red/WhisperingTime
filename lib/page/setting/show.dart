import 'package:flutter/material.dart';
import 'package:whispering_time/env.dart';

class Show extends StatefulWidget {
  @override
  State createState() => _ShowState();
}

class _ShowState extends State<Show> {
 bool visualNoneTitle = Settings().getVisualNoneTitle();

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
      body: SwitchListTile(
        title: const Text('隐藏空白标题'),
        value: visualNoneTitle,
        onChanged: (bool value) {
          setState(() {
            visualNoneTitle = value;
            Settings().setVisualNoneTitle(value);
          });
        },
      ),
    );
  }

  backPage() {
  
    Navigator.of(context).pop();
  }
}
