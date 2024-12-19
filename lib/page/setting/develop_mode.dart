import 'package:flutter/material.dart';
import 'package:whispering_time/env.dart';

class Devleopmode extends StatefulWidget {
  @override
  State createState() => _DevleopmodeState();
}

class _DevleopmodeState extends State<Devleopmode> {
   bool _isOpened = Settings().getDevlopMode();
  TextEditingController serverAddressControl = TextEditingController();
  @override
  void initState() {
    super.initState();
    serverAddressControl.text = Settings().getServerAddress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => backPage(),
        ),
        title: Text("开发者模式"),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('进入开发者模式'),
            value: _isOpened,
            onChanged: (bool value) {
              setState(() {
                Settings().setDevlopMode(value);
                _isOpened = value;
              });
            },
          ),
          divider(),
          Padding(
            padding: const EdgeInsets.only(left: 18, right: 18),
            child: Row(children: [
              Expanded(
                child: Text(
                  '服务器地址',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
              Expanded(
                child: TextField(
                  textAlign: TextAlign.right,
                  enabled: _isOpened,
                  maxLines: 1,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: serverAddressControl.text,
                    border: InputBorder.none,
                  ),
                  controller: serverAddressControl,
                ),
              )
            ]),
          ),
          divider(),
        ],
      ),
    );
  }

  backPage() {
    if (_isOpened != Settings().getDevlopMode()) {
      Settings().setDevlopMode(_isOpened);
    }
    if (serverAddressControl.text != Settings().getServerAddress()) {
      Settings().setServerAddress(serverAddressControl.text);
    }
    Navigator.of(context).pop();
  }
}