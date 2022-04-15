import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wind/message_item_view.dart';
import 'package:wind/nntp_client.dart';
import 'package:wind/thread_list_view.dart';
import 'package:wind/thread_model.dart';

class ThreadScreenArguments {
  final ThreadItem item;

  ThreadScreenArguments(this.item);
}

class ThreadScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ThreadScreenState();
}

class ThreadScreenState extends State<ThreadScreen> {
  late NNTPClient client;
  late int threadNumber;

  @override
  Widget build(BuildContext context) {
    var args =
        ModalRoute.of(context)!.settings.arguments as ThreadScreenArguments;
    client = context.read<NNTPClient>();
    threadNumber = args.item.number;

    return Scaffold(
      appBar: AppBar(
        title: Text("Thread #${args.item.number}"),
      ),
      body: Center(
          child: Container(
        width: 640,
        child: FutureBuilder<List<MessageItem>>(
          future: _fetch(context),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<MessageItem> data = List.from(snapshot.data!);
              data.insert(
                  0,
                  MessageItem(args.item.id, args.item.number, args.item.subject,
                      args.item.author, args.item.date, args.item.body));
              return _listView(data);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      )),
    );
  }

  Future<List<MessageItem>> _fetch(BuildContext context) async {
    var model = context.read<ThreadModel>();
    return await model.getThread(threadNumber);
  }

  Widget _listView(List<MessageItem> data) {
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return MessageItemView(item: data[index], isOpPost: index == 0);
        });
  }
}
