import 'package:flutter/cupertino.dart';
import 'package:wind/message_item_view.dart';
import 'package:wind/nntp_client.dart';

class ThreadModel extends ChangeNotifier {
  NNTPClient? client;

  var commentTextController = TextEditingController(text: "");

  Future<MessageItem> getPost(int number) async {
    var msg = await client!.getPost(number);
    return MessageItem(
        msg.getHeaderValue("Message-Id")!,
        number,
        msg.getHeaderValue("Subject")!,
        msg.getHeaderValue("From")!,
        msg.getHeaderValue("Date")!,
        msg.decodeTextPlainPart()!);
  }

  Future<List<MessageItem>> getThread(int threadNumber) async {
    if (client!.currentGroup == "") return [];

    List<MessageItem> items = [];

    var thread = await client!.getThread(threadNumber);

    thread.forEach((pair) {
      var messageNum = pair.item1;
      var message = pair.item2;
      items.add(MessageItem(
          message.getHeaderValue("Message-Id")!,
          messageNum,
          null,
          message.getHeaderValue("From")!,
          message.getHeaderValue("Date")!,
          message.decodeTextPlainPart()!));
    });

    return items;
  }
}
