import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whispering_time/main.dart';
import '../../../http.dart';

// 事件编辑页面
class EEdit extends StatefulWidget {
  final String docid;

  EEdit({
    required this.docid,
  });
  @override
  State<EEdit> createState() => _EEdit();
}

class _EEdit extends State<EEdit> with RouteAware {
  LocalHistoryEntry? _localHistoryEntry;
  TextEditingController edit = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("")),
        body: SizedBox.expand(
            child: Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: TextField(
            controller: edit,
            autofocus: true,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: InputDecoration(
              hintText: '或简单，或详尽～',
              border: InputBorder.none,
            ),
          ),
        )));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    String uid = Provider.of<MyAppState>(context, listen: false).uid;

    _localHistoryEntry = LocalHistoryEntry(onRemove: () async {
      Http(data:edit.text, uid: uid).postdoc(widget.docid);
      print('EEdit 页面离开了');
    });
    ModalRoute.of(context)?.addLocalHistoryEntry(_localHistoryEntry!);
  }

  @override
  void dispose() {
    // 在页面销毁时，注销监听器
    ModalRoute.of(context)?.removeLocalHistoryEntry(_localHistoryEntry!);
    super.dispose();
  }
}
