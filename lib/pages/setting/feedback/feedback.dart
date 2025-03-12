import 'package:flutter/material.dart';
import 'package:whispering_time/services/http/self.dart';
import 'edit.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  List<FeedBack> _items = [];
  @override
  void initState() {
    super.initState();
    getItems();
  }

  getItems() {
    Http().getFeedbacks().then((value) {
      setState(() {
        _items = value.data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("交流反馈"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Edit(),
                    ));
              })
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: Offset(0, 2), // changes position of shadow
                  ),
                ],
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(Icons.search, color: Colors.grey),
                  ),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '搜索',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: _items.length,
                separatorBuilder: (BuildContext context, int index) => SizedBox(
                  height: 30.0,
                ),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: ExpansionTile(
                      title: Text(
                        item.title,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        item.content.length > 50
                            ? '${item.content.substring(0, 50)}...'
                            : item.content,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      trailing: Icon(Icons.expand_more),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('类型: ${item.type}',
                                  style: TextStyle(fontSize: 14)),
                              SizedBox(height: 8),
                              // Text('其他信息: ${item.otherInfo ?? '暂无'}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
