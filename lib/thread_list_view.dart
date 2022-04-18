import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wind/thread_list_model.dart';

class ThreadListView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ThreadListViewState();
}

class ThreadListViewState extends State<ThreadListView> {
  String _curGroup = "";

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 640,
        padding: EdgeInsets.only(top: 16),
        child: FutureBuilder<List<ThreadItem>>(
          future: _fetchThreadList(context),
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                snapshot.connectionState != ConnectionState.waiting) {
              List<ThreadItem> data = List.from(snapshot.data!);
              if (data.isNotEmpty && data.last.number != -100500)
                data.add(ThreadItem("", -100500, "", "", "",
                    "")); // magic item (for button "load more")
              return _curGroup != ""
                  ? _threadView(data)
                  : Center(
                      child: Text("Новостная группа не выбрана",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)));
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return Center(child: CircularProgressIndicator());
          },
        ));
  }

  Future<List<ThreadItem>> _fetchThreadList(BuildContext context) async {
    var model = context.read<ThreadListModel>();
    _curGroup = model.currentGroup;
    return await model.getNewThreads(false);
  }

  Widget _threadView(List<ThreadItem> items) {
    return items.isNotEmpty
        ? Scrollbar(
            child: ListView.builder(
                key: PageStorageKey("threadList"),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  if (items[index].number == -100500) {
                    return Container(
                      height: 100,
                      padding: EdgeInsets.all(20),
                      child: TextButton(
                        style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.blue),
                        ),
                        onPressed: () {
                          setState(() {
                            items.removeLast();
                          });
                        },
                        child: Text('Загрузить больше'),
                      ),
                    );
                  } else
                    return ThreadListItemView(item: items[index]);
                }),
          )
        : Center(
            child: Text("Эта новостная группа пуста",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)));
  }
}

class ThreadListItemView extends StatelessWidget {
  const ThreadListItemView({Key? key, required this.item}) : super(key: key);

  final ThreadItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 5,
        child: InkWell(
          splashColor: Colors.indigo.withAlpha(30),
          onTap: () =>
              Navigator.pushNamed(context, "/thread?num=${item.number}"),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                child: Text(
                  item.subject,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21),
                ),
                margin: EdgeInsets.only(top: 16, left: 16, right: 16),
              ),
              Container(
                child: Row(
                  children: [
                    Text(
                      item.author,
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.blue,
                          fontSize: 15),
                    ),
                    SizedBox(width: 5),
                    Text(
                      item.date,
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(width: 5),
                    Text(
                      "#${item.number}",
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    )
                  ],
                ),
                margin: EdgeInsets.only(top: 5, bottom: 2, left: 16, right: 16),
              ),
              Container(
                child: Text(item.body, style: TextStyle(fontSize: 17)),
                margin: EdgeInsets.all(16),
              )
            ],
          ),
        ));
  }
}

class ThreadItem {
  final String id;
  final int number;
  final String subject;
  final String author;
  final String date;
  final String body;

  ThreadItem(
      this.id, this.number, this.subject, this.author, this.date, this.body);
}
