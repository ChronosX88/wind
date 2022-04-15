import 'package:flutter/cupertino.dart';
import 'package:wind/nntp_client.dart';
import 'package:wind/thread_list_view.dart';

class ThreadListModel extends ChangeNotifier {
  String currentGroup = "";
  NNTPClient? client;
  Map<String, Map<int, List<ThreadItem>>> threads = {};

  Future<void> selectNewsgroup(String name) async {
    if (currentGroup == name) return;

    currentGroup = name;
    await client!.selectGroup(name);
    threads.putIfAbsent(name, () => {});

    notifyListeners();
  }

  Future<List<ThreadItem>> getNewThreads(
      int perPage, int pageNum, bool clearCache) async {
    if (currentGroup == "") return [];
    List<ThreadItem> items = [];

    if (clearCache) {
      threads[currentGroup]?.clear();
    }

    if (threads[currentGroup]!.containsKey(pageNum)) {
      items.addAll(threads[currentGroup]![pageNum]!);
    } else {
      var resp = await client!.getNewThreads(perPage, pageNum);
      resp.forEach((pair) {
        var number = pair.item1;
        var msg = pair.item2;
        items.add(ThreadItem(
            msg.getHeaderValue("Message-Id")!,
            number,
            msg.getHeaderValue("Subject")!,
            msg.getHeaderValue("From")!,
            msg.getHeaderValue("Date")!,
            msg.decodeTextPlainPart()!));
      });

      threads[currentGroup]![pageNum] = items;
    }

    return items;
  }
}
