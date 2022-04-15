import 'package:flutter/cupertino.dart';
import 'package:wind/message_item_view.dart';
import 'package:wind/nntp_client.dart';

class ThreadModel extends ChangeNotifier {
  NNTPClient? client;

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
