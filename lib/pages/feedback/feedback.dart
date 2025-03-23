import 'package:flutter/material.dart';
import 'package:whispering_time/services/http/index.dart';
import 'package:whispering_time/services/sp/sp.dart';
import 'package:whispering_time/utils/ui.dart';
import 'edit.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  List<FeedBack> _items = [];
  TextEditingController searchController = TextEditingController();
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

  add() async {
    final isVisitor = SP().getIsVisitor();
    if (mounted) {
      if (isVisitor) {
        showErrMsg(context, '游客无法创建反馈');
        return;
      }
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Edit(),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("反馈"),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.add), onPressed: () => add())
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
                    color: Colors.grey.withValues(alpha: 0.2),
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
                      controller: searchController,
                      onChanged: (value) => search(),
                      decoration: InputDecoration(
                        hintText: '搜索',
                        border: InputBorder.none,
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  searchController.clear();
                                  search();
                                },
                              )
                            : null,
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
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            item.content.length > 100
                                ? '${item.content.substring(0, 100)}...'
                                : item.content,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '创建时间: ${item.crtime}',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              // You can add more info or actions here
                            ],
                          ),
                        ],
                      ),
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

  void search() {
    Http().getFeedbacks(text: searchController.text).then((value) {
      setState(() {
        _items = value.data;
      });
    });
  }
}
